import os

env = SConscript("lib/godot-cpp/SConstruct").Clone()

# Add support for generating compilation database files
env.Tool("compilation_db")
compiledb = env.CompilationDatabase("compile_commands.json")
env.Alias("compiledb", compiledb)

if env["platform"] in ["macos", "ios"]:
    # Compile flags
    env.Append(LINKFLAGS="-framework Foundation")

    # Setup variant build dir for each setup
    def remove_prefix(s, prefix):
        return s[len(prefix):] if s.startswith(prefix) else s

    build_dir = "build/{}".format(remove_prefix(env["suffix"], "."))
    VariantDir(build_dir, 'src', duplicate=False)

    # Build Objective-C GDExtension
    source_directories = ["."]
    sources = [
        Glob("{}/{}/*.cpp".format(build_dir, directory)) + Glob("{}/{}/*.mm".format(build_dir, directory))
        for directory in source_directories
    ]
    library = env.SharedLibrary(
        "addons/objc-gdextension/build/libobjcgdextension{}{}".format(env["suffix"], env["SHLIBSUFFIX"]),
        source=sources,
    )
else:
    dummy_env = Environment(
        CPPPATH="lib/gdextension-lite",
        CFLAGS=["-flto", "-O2"],
    )
    library = dummy_env.SharedLibrary(
        "addons/objc-gdextension/build/libobjcgdextension{}{}".format(env["suffix"], env["SHLIBSUFFIX"]),
        source=["src/dummy_main.c", "lib/gdextension-lite/gdextension-lite/gdextension-lite-one.c"]
    )
Default(library)
