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

target("frankenapp")
    set_kind("binary")

    -- Enable standard C++ language standard
    set_languages("c++20")

    -- Add the Vala compiler rule so xmake drives valac
    add_rules("vala")

    -- Source files across all three worlds
    add_files("src/ui_frontend.vala")
    add_files("src/core_engine.cpp")
    add_files("src/apple_bridge.mm")

    -- Pull in GLib / GObject compile and link flags
    add_packages("gobject", "glib")

    -- Vala configuration
    add_values("vala.packages", "gobject-2.0", "glib-2.0")
    add_values("vala.flags", "-H", "src/vala_exports.h")

    -- Include directories for headers
    add_includedirs("src")

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