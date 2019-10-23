using BinaryProvider

# Parse some basic command-line arguments
const verbose = "--verbose" in ARGS
const prefix = Prefix(get([a for a in ARGS if a != "--verbose"], 1, joinpath(@__DIR__, "usr")))

# install OpenSSL
include("build_OpenSSL.jl")

# This is the library we care about
products = Product[
    LibraryProduct(prefix, "libpq", :LIBPQ_HANDLE),
]

# Download binaries from hosted location
bin_prefix = "https://github.com/invenia/LibPQBuilder/releases/download/v12.0.0%2B0/LibPQ.v12.0.0+0"

# Listing of files generated by BinaryBuilder:
download_info = Dict(
    Linux(:aarch64, :glibc) => ("$bin_prefix.aarch64-linux-gnu.tar.gz", "4f8a684223eec31bf2c2d61e0a570945ed493f88a07549d09af00533c8b23977"),
    Linux(:armv7l, :glibc)  => ("$bin_prefix.arm-linux-gnueabihf.tar.gz", "59b229bf5ab3213a995c197af6a16821cd73a5b3502ccbf3dad762149a7dce27"),
    Linux(:powerpc64le, :glibc) => ("$bin_prefix.powerpc64le-linux-gnu.tar.gz", "f940b400466ab03892706bbf3877249e29658f3aad1fa5de7a4318423b90adf5"),
    Linux(:i686, :glibc)    => ("$bin_prefix.i686-linux-gnu.tar.gz", "898b2132fdca4077d685463a457b0aeb260ce9cb8230e8f333670344d66b1aa0"),
    Linux(:x86_64, :glibc)  => ("$bin_prefix.x86_64-linux-gnu.tar.gz", "672acf59f5184f630b344ec2e2bf2ff2b140cc88417609b7381575e86a884210"),

    Linux(:aarch64, :musl)  => ("$bin_prefix.aarch64-linux-musl.tar.gz", "6730ee1a448017cc56442b1105cfdcbe95493b24211de52d30c29c98b1ebc49f"),
    Linux(:armv7l, :musl)   => ("$bin_prefix.arm-linux-musleabihf.tar.gz", "729c582794cfad25376012bace87036c0dd2e1a644971043ff292802ee79c42f"),
    Linux(:i686, :musl)     => ("$bin_prefix.i686-linux-musl.tar.gz", "d05641db7e0103c9f6f6fcea52c9e7b397bc9ff70f7682cdd08b9a801ab25749"),
    Linux(:x86_64, :musl)   => ("$bin_prefix.x86_64-linux-musl.tar.gz", "2fda96496f5d0da00dce34ad8569823b060fae8eb92c2ca8e157bba18f242090"),

    FreeBSD(:x86_64)        => ("$bin_prefix.x86_64-unknown-freebsd11.1.tar.gz", "542a79f26e9da68b73c197634720a41a1f15499d0185b8df990fd07fbf74b3d1"),
    MacOS(:x86_64)          => ("$bin_prefix.x86_64-apple-darwin14.tar.gz", "25f0314cefb9e7849d8e0c66cc6b6dba47bded6b2bdd8c57a54a87b6877581c0"),

    Windows(:i686)          => ("$bin_prefix.i686-w64-mingw32.tar.gz", "a4bee02c6055b32bda872655e96c8605acd0d5c95dcf4d989a34d75064670cbd"),
    Windows(:x86_64)        => ("$bin_prefix.x86_64-w64-mingw32.tar.gz", "afc675e48772e772bef040c4b86227994f6bef9bc208b3ed9c4dc80b2570940c"),
)
# First, check to see if we're all satisfied
if any(!satisfied(p; verbose=verbose) for p in products)
    try
        # Download and install binaries
        url, tarball_hash = choose_download(download_info)
        install(url, tarball_hash; prefix=prefix, force=true, verbose=true)
    catch e
        if e isa ArgumentError
            error("Your platform $(Sys.MACHINE) is not supported by this package!")
        else
            rethrow(e)
        end
    end

    # Finally, write out a deps.jl file
    write_deps_file(joinpath(@__DIR__, "deps.jl"), products)
end
