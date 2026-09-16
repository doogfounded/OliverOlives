set_project("OliverOlives")
set_version("1.0.0")

-- Default to mingw
set_defaultplat("mingw")
set_policy("package.include_external_headers", false)
set_policy("check.auto_ignore_flags", false)

-- Pull in system packages via pkg-config (from MSYS2 / MinGW)
add_requires("pkgconfig::gobject-2.0", {alias = "gobject"})
add_requires("pkgconfig::glib-2.0", {alias = "glib"})

if not is_plat("macosx") then
    add_requires("pkgconfig::gnustep-base", {alias = "gnustep"})
end

rule("hip")
    set_extensions(".hip")
    on_buildcmd_file(function (target, batchcmds, sourcefile, opt)
        local objectfile = target:objectfile(sourcefile)
        table.insert(target:objectfiles(), objectfile)

        batchcmds:show_progress(opt.progress, "${color.build.object}compiling.hip %s", sourcefile)

        local hip_path = os.getenv("HIP_PATH") or "C:/Program Files/AMD/ROCm/7.2"
        local hip_clang = path.join(hip_path, "bin", "clang.exe")

        batchcmds:mkdir(path.directory(objectfile))
        batchcmds:vrunv(hip_clang, {
            "--target=x86_64-w64-windows-gnu",
            "-D_MSC_VER=1940",
            "-D_NATIVE_WCHAR_T_DEFINED=1",
            "-x", "hip",
            "--offload-arch=gfx1201",
            "-isystem", path.join(hip_path, "include"),
            "-c", sourcefile,
            "-o", objectfile
        })
        batchcmds:add_depfiles(sourcefile)
        batchcmds:set_depmtime(os.mtime(objectfile))
        batchcmds:set_depcache(target:dependfile(objectfile))
    end)

target("frankenapp")
    set_kind("binary")

    -- Enable standard C++ language standard
    set_languages("c++20")

    -- Add the Vala and HIP compiler rules
    add_rules("vala", "hip")

    -- Source files across all three worlds
    add_files("src/ui_frontend.vala")
    add_files("src/core_engine.cpp")
    add_files("src/apple_bridge.mm")
    add_files("src/gpu_kernel.hip")

    -- Pull in GLib / GObject compile and link flags
    add_packages("gobject", "glib")

    -- Vala configuration
    add_values("vala.packages", "gobject-2.0", "glib-2.0")
    add_values("vala.flags", "-H", "src/vala_exports.h")

    -- Include directories for headers
    add_includedirs("src")

    -- Add HIP / CUDA include and library paths
    local hip_path = os.getenv("HIP_PATH") or "C:/Program Files/AMD/ROCm/7.2"
    add_includedirs(path.join(hip_path, "include"))
    add_linkdirs(path.join(hip_path, "lib"))
    add_links("amdhip64")

    -- Platform-specific link rules for the Objective-C runtime
    if is_plat("macosx") then
        add_frameworks("Foundation")
    else
        add_packages("gnustep")
        add_mxflags("-fobjc-runtime=gnustep-2.0")
        add_links("gnustep-base", "objc")

        on_load(function (target)
            import("lib.detect.find_tool")
            local lld = find_tool("ld.lld") or find_tool("lld")
            if lld then
                target:add("ldflags", "-fuse-ld=" .. (lld.program:gsub("\\", "/")), {force = true})
            end
        end)
    end

    -- Ensure C++ standard library is linked
    add_links("stdc++")