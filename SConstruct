import os

env = Environment()

# Build zip distribution
if "zip" in COMMAND_LINE_TARGETS:
    addons_license = env.Install(target="addons/objc-gdextension", source="LICENSE")
    zip_sources = [
        addons_license,
        "addons/objc-gdextension/objcgdextension.gdextension",
        *Glob("addons/objc-gdextension/build/libobjcgdextension*"),
    ]
    env.Zip("build/objc-gdextension.zip", zip_sources)
    env.Alias("zip", "build/objc-gdextension.zip")
elif "test" in COMMAND_LINE_TARGETS:
    godot_bin = os.getenv("GODOT_BIN", "godot")
    env.Execute(f"{godot_bin} --headless --quit --path test --script test_entrypoint.gd")
else:  # build library
    env = SConscript("lib/godot-cpp/SConstruct").Clone()

    # Add support for generating compilation database files
    env.Tool("compilation_db")
    compiledb = env.CompilationDatabase("compile_commands.json")
    env.Alias("compiledb", compiledb)

    # Compile with debugging symbols
    if ARGUMENTS.get("debugging_symbols") == 'true':
        if "-O2" in env["CCFLAGS"]:
            env["CCFLAGS"].remove("-O2")
        env.Append(CCFLAGS=["-g", "-O0"])

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

    Default(library)
