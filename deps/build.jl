using BinaryProvider # requires BinaryProvider 0.3.0 or later

# Example taken from
# https://github.com/JuliaIO/ImageMagick.jl/blob/master/deps/build.jl
dependencies = [
    "build_Zlib.v1.2.11.jl",
    "build_GEOS.v3.7.2.jl",
    "build_SQLite.v3.28.0.jl",
    "build_PROJ.v6.1.0.jl",
    # "build_LibCURL.v7.64.1.jl"
]

for elem in dependencies
    # it's a bit faster to run the build in an anonymous module instead of
    # starting a new julia process
    m = Module(:__anon__)
    Core.include(m, (joinpath(@__DIR__, elem)))
end

# Parse some basic command-line arguments
const verbose = "--verbose" in ARGS
const prefix = Prefix(get([a for a in ARGS if a != "--verbose"], 1, joinpath(@__DIR__, "usr")))
products = [
    LibraryProduct(prefix, ["libgdal"], :libgdal),
    ExecutableProduct(prefix, "gdal_contour", :gdal_contour_path),
    ExecutableProduct(prefix, "gdal_grid", :gdal_grid_path),
    ExecutableProduct(prefix, "gdal_rasterize", :gdal_rasterize_path),
    ExecutableProduct(prefix, "gdal_translate", :gdal_translate_path),
    ExecutableProduct(prefix, "gdaladdo", :gdaladdo_path),
    ExecutableProduct(prefix, "gdalbuildvrt", :gdalbuildvrt_path),
    ExecutableProduct(prefix, "gdaldem", :gdaldem_path),
    ExecutableProduct(prefix, "gdalinfo", :gdalinfo_path),
    ExecutableProduct(prefix, "gdallocationinfo", :gdallocationinfo_path),
    ExecutableProduct(prefix, "gdalmanage", :gdalmanage_path),
    ExecutableProduct(prefix, "gdalsrsinfo", :gdalsrsinfo_path),
    ExecutableProduct(prefix, "gdaltindex", :gdaltindex_path),
    ExecutableProduct(prefix, "gdaltransform", :gdaltransform_path),
    ExecutableProduct(prefix, "gdalwarp", :gdalwarp_path),
    ExecutableProduct(prefix, "nearblack", :nearblack_path),
    ExecutableProduct(prefix, "ogr2ogr", :ogr2ogr_path),
    ExecutableProduct(prefix, "ogrinfo", :ogrinfo_path),
    ExecutableProduct(prefix, "ogrlineref", :ogrlineref_path),
    ExecutableProduct(prefix, "ogrtindex", :ogrtindex_path),
]

# Download binaries from hosted location
bin_prefix = "https://github.com/JuliaGeo/GDALBuilder/releases/download/v3.0.0-3"

# Listing of files generated by BinaryBuilder:
download_info = Dict(
    Linux(:aarch64, libc=:glibc) => ("$bin_prefix/GDAL.v3.0.0.aarch64-linux-gnu.tar.gz", "ebe236883d8480fe7482fd1d27c2535c41e808abe1e5cf8c4550be538c3b77e2"),
    Linux(:aarch64, libc=:musl) => ("$bin_prefix/GDAL.v3.0.0.aarch64-linux-musl.tar.gz", "0425ae5159cd02c41a526fcb8469b2676bc2f5b4120bea014c8383e291d0c4eb"),
    Linux(:armv7l, libc=:glibc, call_abi=:eabihf) => ("$bin_prefix/GDAL.v3.0.0.arm-linux-gnueabihf.tar.gz", "8e9af6c82436788805d59b7c62b26f319fe4460898186939bda3d2931dff28d3"),
    Linux(:armv7l, libc=:musl, call_abi=:eabihf) => ("$bin_prefix/GDAL.v3.0.0.arm-linux-musleabihf.tar.gz", "08c659da2d0bdd9b5c67458e9506ac2ef92ee5c6143f45f0650ade3d6e7f6722"),
    Linux(:i686, libc=:glibc) => ("$bin_prefix/GDAL.v3.0.0.i686-linux-gnu.tar.gz", "99bd95d5de4dcd7ac9248654c7e53d9b7cb65aaf47352d923ba5da2c41336017"),
    Linux(:i686, libc=:musl) => ("$bin_prefix/GDAL.v3.0.0.i686-linux-musl.tar.gz", "7cbd4de983f1b6c470cfcf208febaaa5467e91f46644fac034ad70e0603e42d1"),
    # removed compiler_abi as suggested in https://github.com/JuliaPackaging/BinaryBuilder.jl/issues/407#issuecomment-473688254
    # such that GCC4 platforms will also pick up this GCC7 build, ref https://github.com/JuliaPackaging/BinaryBuilder.jl/issues/407
    Windows(:i686) => ("$bin_prefix/GDAL.v3.0.0.i686-w64-mingw32-gcc7.tar.gz", "8d056a9a4781cc13e572b689c581ef9ab48d5f397b2ca3882466e168aabb5b45"),
    Linux(:powerpc64le, libc=:glibc) => ("$bin_prefix/GDAL.v3.0.0.powerpc64le-linux-gnu.tar.gz", "29772014a34d5300c950399f6d07dcc960feff6671a30fc21a834c7482d4e359"),
    MacOS(:x86_64) => ("$bin_prefix/GDAL.v3.0.0.x86_64-apple-darwin14.tar.gz", "df0dd3dfec28cf98b7a8d4fdf9f770599bd3bde2fe223f33e903aa052a4f0ada"),
    Linux(:x86_64, libc=:glibc) => ("$bin_prefix/GDAL.v3.0.0.x86_64-linux-gnu.tar.gz", "22e576ebb9c45a8571869f5ebaca0ab1c6f443aa281c0fcdf5176c75d9912742"),
    Linux(:x86_64, libc=:musl) => ("$bin_prefix/GDAL.v3.0.0.x86_64-linux-musl.tar.gz", "f2ab4b8ff55621f22963f6749c210876b5be14c3cee724ece7dfc73ea9b3a14e"),
    FreeBSD(:x86_64) => ("$bin_prefix/GDAL.v3.0.0.x86_64-unknown-freebsd11.1.tar.gz", "0b4b817a13fccb3e65b32df535679163aa0d061077542ceda00764d34c96159e"),
    # removed compiler_abi as suggested in https://github.com/JuliaPackaging/BinaryBuilder.jl/issues/407#issuecomment-473688254
    # such that GCC4 platforms will also pick up this GCC7 build, ref https://github.com/JuliaPackaging/BinaryBuilder.jl/issues/407
    Windows(:x86_64) => ("$bin_prefix/GDAL.v3.0.0.x86_64-w64-mingw32-gcc7.tar.gz", "aa1b84e77de61eda6f3e9f569ff8e7bab3b99d38fa2edddb9069ef82ba3d5256"),
)

# Install unsatisfied or updated dependencies:
unsatisfied = any(!satisfied(p; verbose=verbose) for p in products)
dl_info = choose_download(download_info, platform_key_abi())
if dl_info === nothing && unsatisfied
    # If we don't have a compatible .tar.gz to download, complain.
    # Alternatively, you could attempt to install from a separate provider,
    # build from source or something even more ambitious here.
    error("Your platform (\"$(Sys.MACHINE)\", parsed as \"$(triplet(platform_key_abi()))\") is not supported by this package!")
end

# If we have a download, and we are unsatisfied (or the version we're
# trying to install is not itself installed) then load it up!
if unsatisfied || !isinstalled(dl_info...; prefix=prefix)
    # Download and install binaries
    install(dl_info...; prefix=prefix, force=true, verbose=verbose)
end

# Write out a deps.jl file that will contain mappings for our products
write_deps_file(joinpath(@__DIR__, "deps_gdal.jl"), products, verbose=verbose)

function include_deps(name)
    """
    module $name
        import Libdl
        path = joinpath(@__DIR__, $(repr(string("deps_", name, ".jl"))))
        isfile(path) || error("$name wasn't build correctly. Please run Pkg.build(\\\"GDAL\\\")")
        include(path)
    end
    using .$name
    """
end

open("deps.jl", "w") do io
    for dep in (:zlib, :geos, :sqlite, :proj, #=:curl,=# :gdal)
        println(io, include_deps(dep))
    end
    println(io, """
    const libgdal = gdal.libgdal
    const libproj = proj.libproj
    function check_deps()
        zlib.check_deps()
        geos.check_deps()
        sqlite.check_deps()
        proj.check_deps()
        # curl.check_deps()
        gdal.check_deps()
    end
    """)
end
