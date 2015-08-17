from __future__ import print_function

import os
import os.path

import SCons.Script as scons


class BuildTarget(object):
    """A module's build target."""

    def __init__(self):
        self.module_name = ''
        self.target_dependencies = []

    def add_as_dependent(self, env):
        """Adds this target as a dependent of the specified environment.

        The environment is modified as neccessary, so that when it is used to build,
        this BuildTarget will be part of that build as is appropriate.

        Args:
            env (SCons.Script.Environment): A build environment that is dependent on this target.

        """
        pass

class LibraryTarget(BuildTarget):
    def __init__(self):
        super(BuildTarget, self).__init__()
        self.library_name = ''
        self.library = None
        self.cpppath = None

    def add_as_dependent(self, env):
        # It is important to ensure that the libraries at the top of the
        # dependency hierarchy appear before the libraries that they depend on.
        # Therefore, we addd this LibraryTarget before adding its dependencies.
        env.Append(
            LIBS=[
                self.library_name
            ],
            LIBPATH=[
                os.path.dirname(self.library[0].abspath)
            ],
            CPPPATH=[
                self.cpppath
            ]
        )
        for target in self.target_dependencies:
            target.add_as_dependent(env)

class ExecutableTarget(BuildTarget):
    def __init__(self):
        super(BuildTarget, self).__init__()
        self.executable = None

class Paths(object):
    """Defines common paths used for builds."""

    def __init__(self, root_dir, project_dir, variant_dir):
        self._root_dir = root_dir
        self._project_dir = project_dir
        self._variant_dir = variant_dir
        self._sources_dir = root_dir.Dir('sources')
        self._tools_dir = root_dir.Dir('tools')

    def module_build_file(self, module_name):
        """Returns the named module's build (sconscript) file.

        Args:
            module_name (str): The module name.

        Returns:
            SCons.Script.File: The module's sconscript file.

        """
        return self._sources_dir.Dir(module_name).File('sconscript')

    def variant_dir(self, module_name=None):
        """Returns the variant directory for the named module.

        The variant directory is the module's build directory for the current variant.

        Args:
            module_name (str): The module name.

        Returns:
            SCons.Script.Dir: The module's variant (build) directory.

        """
        if module_name is None:
            module_name = self.active_module_name()
        return self._variant_dir.Dir(module_name)

    def include_dir(self, module_name=None):
        """Returns a module's include directory.

        Args:
            module_name (Optional[str]): The module whose include directory to return or the current
                module if None.

        Returns:
            SCons.Script.Dir: The include directory.

        """
        if module_name is None:
            module_name = self.active_module_name()
        return self._sources_dir.Dir(module_name).Dir('src').Dir('include')

    def active_module_name(self):
        """Returns the name of the module whose sconscript is currently being executed."""
        module_path = scons.Dir('.').srcnode().path
        return os.path.basename(os.path.normpath(module_path))

    def unit_test_executable(self, module_name=None):
        """Returns the name of the unit test executable for the specified module.

        Args:
            module_name (Optional[str]): The module name; defaults to the active module name.

        Returns:
            SCons.Script.File: The unit test executable.

        """
        if module_name is None:
            module_name = self.active_module_name()
        return self.variant_dir(module_name).File('test/' + module_name + '_test')

    def unit_test_library_build_file(self):
        """Returns the unit test library's sconscript file."""
        return self._tools_dir.Dir('gtest').File('sconscript')

    def glob(self, root_dir, pattern):
        """Returns the files that match the specified pattern.

        This version of glob is recursive. It will search for matching files in
        the `root_dir` and all its child directories. In constrast, the Glob function
        provided by scons is not recursive and only search the a single directory.

        Args:
            root_dir (str): Name of the directory, relative to the current diretory to search.
            pattern (str): The pattern used to match files.

        Returns:
            list[SCons.Script.File]: The matching file nodes.

        """
        source_root = scons.Dir(root_dir).srcnode()
        absolute_path = source_root.abspath[:-len(root_dir)]
        absolute_index = len(absolute_path)
        patterns = []
        for root, dirs, files in os.walk(source_root.abspath):
            relative_path = root[absolute_index:]
            glob_pattern = os.path.join(relative_path, pattern)
            patterns.append(glob_pattern)

        files = []
        for p in patterns:
            files.extend(scons.Glob(p))
        return files

class Builder(object):
    """Builds modules.

    Attributes:
        env (Environment): The construction environment used by this builder.
        paths (Paths): The build paths.
    """

    def __init__(self, env, paths):
        """Constructs a builder.

        Args:
            env (Environment): The construction environment.
            paths (Paths): The build paths.
        """
        self.env = env
        self.paths = paths
        self._built_targets = {} # The built targets. Prevents building a module multiple times.
        self._unit_test_target = None

    def clone(self):
        """Returns a clone of this Builder."""
        cloned = Builder(self.env.Clone(), self.paths)
        cloned._built_targets = self._built_targets
        cloned._unit_test_target = self._unit_test_target
        return cloned

    def build_module(self, module_name):
        """Builds the specified module and returns its target.

        Starts a sub-builder that builds module `module_name` using its sconscript file.

        Args:
            module_name (str): The name of the module to build.

        """
        if module_name in self._built_targets:
            return self._built_targets[module_name]

        builder = self.clone()
        exports = ['builder']
        target = builder.env.SConscript(builder.paths.module_build_file(module_name),
                                        variant_dir=builder.paths.variant_dir(module_name),
                                        exports=exports,
                                        duplicate=0)
        self._built_targets[module_name] = target
        return target

    def executable(self, executable_name, module_deps=None):
        """Builds an executable from the current module and returns its target.

        The modules in `module_deps` are built first and then used as dependencies to build the executable.
        The executable is registered as a scons target using `executable_name`.

        Args:
            executable_name (str): The name of the built executable (should typically be the module name).
            module_deps (Optional[list[str]]): The names of the modules the executable being built depends on.

        Returns:
            ExecutableTarget: The target created by building the executable.

        """
        self.build_module_dependencies(module_deps)

        sources = self.paths.glob('src', '*.cpp')
        target = ExecutableTarget()
        target.module_name = self.paths.active_module_name()
        target.executable = self.env.Program('release/' + executable_name, source=sources)
        self._register_target(executable_name, target.executable)
        return target

    def _register_target(self, name, build_target):
        """Registers the build target by name.

        This makes the target executable by `name` using the scons command, i.e. scons `name`.

        Args:
            name (str): The target name to register. This is the name of the target on the scons command-line.
            target (scons target): The scons target to register.

        """
        self.env.Alias(name, build_target)
        scons.Help('\n    ' + name)

    def static_library(self, library_name, module_deps=None):
        """Builds a static library from the current module and returns its target.

        Args:
            library_name (str): The name of the library to build. This should normally be the module name
                without any 'lib' prefix. For example, if building module libfoo as a library
                the `library_name` would be 'foo'.
            module_deps (Optional[list[str]]): The modules this library depeneds on.

        Returns:
            LibraryTarget: The target created by building the library.

        """
        deps = self.build_module_dependencies(module_deps)

        sources = self.paths.glob('src', '*.cpp')
        include_dir = self.paths.include_dir()
        self.env.Append(CPPPATH=[include_dir])

        target = LibraryTarget()
        target.module_name = self.paths.active_module_name()
        target.library_name = library_name
        target.library = self.env.StaticLibrary('release/' + library_name, sources)
        target.cpppath = include_dir
        target.target_dependencies = deps

        self._run_library_module_unit_tests(self.env, target)
        return target

    def build_module_dependencies(self, modules):
        """Builds the specified modules and adds their targets as dependencies of this builder.

        Args:
            modules (list[str]): The modules to build. May be `None`.

        """
        deps = []
        if modules is not None:
            for module in modules:
                target = self.build_module(module)
                target.add_as_dependent(self.env)
                deps.append(target)
        return deps

    def _run_library_module_unit_tests(self, test_env, library_target):
        """Runs the unit tests for the specified library module.

        Args:
            test_env (SCons.Script.Environment): The unit test build environment.
            library_target (LibraryTarget): The libary target to test.
        """
        library_target.add_as_dependent(test_env)

        test_env.Append(
            LIBS=[
                self._unit_test_target.library,
                'pthread',
            ],
            CPPPATH=[
                self._unit_test_target.cpppath
            ]
        )

        sources = self.paths.glob('test', '*.cpp')
        if sources:
            unit_test = test_env.Program(self.paths.unit_test_executable(), source=sources)
            test_env.AddPostAction(unit_test, self._execute_unit_test(library_target.module_name, unit_test))
            test_env.Alias('test', unit_test)
            test_env.AlwaysBuild(unit_test)

    def _execute_unit_test(self, module_name, unit_test):
        """Returns a function that executes the specified unit test.

        Args:
            module_name (str): The name of the module whose unit tests will be run.
            unit_test (SCons.Script.Program): The unit test program.

        Returns:
            function: A function that when called will execute the unit test.

        """
        def execute(*args, **kwargs):
            print("\n{} Unit Tests:".format(module_name))
            os.system(unit_test[0].abspath)
        return execute

    def prepare_tools(self):
        """Performs all required preparation needed to get build tools in a useable state."""
        self._build_unit_test_library()

    def _build_unit_test_library(self):
        """Builds the unit test library."""
        builder = self.clone()
        exports = ['builder']
        self._unit_test_target = builder.env.SConscript(builder.paths.unit_test_library_build_file(),
                                                        exports=exports)