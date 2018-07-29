using BinaryProvider # requires BinaryProvider 0.3.0 or later

# Parse some basic command-line arguments
const verbose = "--verbose" in ARGS
const prefix = Prefix(get([a for a in ARGS if a != "--verbose"], 1, joinpath(@__DIR__, "usr")))
products = [
    LibraryProduct(prefix, String["libproj"], :libproj),
    FileProduct(prefix, "share/proj/CH", :ch_path),
    FileProduct(prefix, "share/proj/epsg", :epsg_path),
    FileProduct(prefix, "share/proj/esri", :esri_path),
    FileProduct(prefix, "share/proj/esri.extra", :esri_extra_path),
    FileProduct(prefix, "share/proj/GL27", :gl27_path),
    FileProduct(prefix, "share/proj/IGNF", :ignf_path),
    FileProduct(prefix, "share/proj/nad27", :nad27_path),
    FileProduct(prefix, "share/proj/nad83", :nad83_path),
    FileProduct(prefix, "share/proj/nad.lst", :nad_lst_path),
    FileProduct(prefix, "share/proj/other.extra", :other_extra_path),
    FileProduct(prefix, "share/proj/proj_def.dat", :proj_def_dat_path),
    FileProduct(prefix, "share/proj/world", :world_path),
]

# Download binaries from hosted location
bin_prefix = "https://github.com/JuliaGeo/PROJBuilder/releases/download/v4.9.3-3"

# Listing of files generated by BinaryBuilder:
download_info = Dict(
    Linux(:aarch64, :glibc) => ("$bin_prefix/PROJ.v4.9.3.aarch64-linux-gnu.tar.gz", "2fef7ae57ace63ae641844b99390e37783022225ff278881523d4181fb9e6e3f"),
    Linux(:armv7l, :glibc, :eabihf) => ("$bin_prefix/PROJ.v4.9.3.arm-linux-gnueabihf.tar.gz", "2532eee2bf42a64f43a88891f3b6ffa17c1a024efc4af899bccfe6ab8374ebe3"),
    Linux(:i686, :glibc) => ("$bin_prefix/PROJ.v4.9.3.i686-linux-gnu.tar.gz", "7a1043bc648f5973534fa792a0d8e7c43443f5ae69174db2a11a61dbd57bfa97"),
    Windows(:i686) => ("$bin_prefix/PROJ.v4.9.3.i686-w64-mingw32.tar.gz", "7e55852eeade27c22eb01ed4a4ebd5b77b3a06c044df493e0f1cea67db32e66d"),
    Linux(:powerpc64le, :glibc) => ("$bin_prefix/PROJ.v4.9.3.powerpc64le-linux-gnu.tar.gz", "d0ecbf0e4584e959e4f49195160aada6140f0d356cf1e53cdeed4e97697eb84a"),
    MacOS(:x86_64) => ("$bin_prefix/PROJ.v4.9.3.x86_64-apple-darwin14.tar.gz", "9701ad59fb39e0bc73958fd017499ceece88b8af5c91fbe2f3f7e59cdb64d5c5"),
    Linux(:x86_64, :glibc) => ("$bin_prefix/PROJ.v4.9.3.x86_64-linux-gnu.tar.gz", "8e9820c512a2b71c2db0b7d757cbe176cfa1046a655112c0e6375314caf482a0"),
    Windows(:x86_64) => ("$bin_prefix/PROJ.v4.9.3.x86_64-w64-mingw32.tar.gz", "2c642d7a470007cff4f2eeecd247ff1855085091ce4622971f9da8e7173548a2"),
)

# Install unsatisfied or updated dependencies:
unsatisfied = any(!satisfied(p; verbose=verbose) for p in products)
if haskey(download_info, platform_key())
    url, tarball_hash = download_info[platform_key()]
    if unsatisfied || !isinstalled(url, tarball_hash; prefix=prefix)
        # Download and install binaries
        install(url, tarball_hash; prefix=prefix, force=true, verbose=verbose)
    end
elseif unsatisfied
    # If we don't have a BinaryProvider-compatible .tar.gz to download, complain.
    # Alternatively, you could attempt to install from a separate provider,
    # build from source or something even more ambitious here.
    error("Your platform $(triplet(platform_key())) is not supported by this package!")
end

# Write out a deps.jl file that will contain mappings for our products
write_deps_file(joinpath(@__DIR__, "deps.jl"), products)