env = SConscript("lib/godot-cpp/SConstruct").Clone()
env.Tool("apple", toolpath=["tools"])

# Add support for generating compilation database files
env.Tool("compilation_db")
compiledb = env.CompilationDatabase("compile_commands.json")
env.Alias("compiledb", compiledb)

# Setup variant build dir for each setup
def remove_prefix(s, prefix):
    return s[len(prefix):] if s.startswith(prefix) else s

build_dir = "build/{}".format(remove_prefix(env["suffix"], "."))
VariantDir(build_dir, 'src', duplicate=False)

if env["platform"] in ["macos", "ios"]:
    # Compile flags
    env.Append(LINKFLAGS="-framework Foundation")

    # Build Objective-C GDExtension
    source_directories = ["."]
    sources = [
        Glob(f"{build_dir}/{directory}/*.cpp") + Glob(f"{build_dir}/{directory}/*.mm")
        for directory in source_directories
    ]
    if env["platform"] == "ios":
        library = env.StaticLibrary(
            f"{build_dir}/libobjcgdextension{env["suffix"]}{env["LIBSUFFIX"]}",
            source=sources,
        )
        godotcpp_xcframework = env.XCFramework(
            f"addons/objc-gdextension/build/libgodot-cpp{env["suffix"]}.xcframework",
            [
                f"lib/godot-cpp/bin/libgodot-cpp{env["suffix"]}{env["LIBSUFFIX"]}",
                *map(str, Glob(f"lib/godot-cpp/bin/libgodot-cpp{env["suffix"]}*{env["LIBSUFFIX"]}")),
            ],
        )
        luagdextension_xcframework = env.XCFramework(
            f"addons/objc-gdextension/build/libobjcgdextension{env["suffix"]}.xcframework",
            [
                f"{build_dir}/libobjcgdextension{env["suffix"]}{env["LIBSUFFIX"]}",
                *map(str, Glob(f"{build_dir}/libobjcgdextension{env["suffix"]}*{env["LIBSUFFIX"]}")),
            ],
        )
        env.Depends(godotcpp_xcframework, library)
        env.Depends(luagdextension_xcframework, godotcpp_xcframework)
        Default(luagdextension_xcframework)
    else:
        library = env.SharedLibrary(
            f"addons/objc-gdextension/build/libobjcgdextension{env["suffix"]}{env["SHLIBSUFFIX"]}",
            source=sources,
        )
else:
    dummy_env = Environment(
        CPPPATH="lib/gdextension-lite",
    )
    if env.get("is_msvc"):
        dummy_env.Append(CFLAGS="/Zc:preprocessor")
    else:
        dummy_env.Append(CFLAGS="-flto")
    library = dummy_env.SharedLibrary(
        f"addons/objc-gdextension/build/libobjcgdextension{env["suffix"]}{env["SHLIBSUFFIX"]}",
        source=[
            "src/dummy_main.c",
            "lib/gdextension-lite/gdextension-lite/gdextension-lite-one.c",
        ]
    )
Default(library)
