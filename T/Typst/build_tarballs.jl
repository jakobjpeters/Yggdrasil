# Note that this script can accept some limited command-line arguments, run
# `julia build_tarballs.jl --help` to see a usage message.
using BinaryBuilder, Pkg

name = "Typst"
version = v"0.13.1"

# Collection of sources required to complete build
sources = [
    GitSource("https://github.com/typst/typst.git", "8ace67d942a4b8c6b9d95b73b3a39f5d0259c7b2")
]

# Bash recipe for building across all platforms
script = raw"""
cd $WORKSPACE/srcdir/typst
cargo build -p typst-cli --release
install -Dvm 755 "target/${rust_target}/release/typst${exeext}" "${bindir}/typst${exeext}"
install_license LICENSE
"""

# These are the platforms we will build for by default, unless further
# platforms are passed in on the command line
platforms = filter(supported_platforms()) do p
    !((Sys.iswindows(p) && arch(p) == "i686") || (arch(p) == "powerpc64le") || (Sys.isfreebsd(p) && arch(p) == "aarch64") || (arch(p) == "riscv64"))
end

# The products that we will ensure are always built
products = [
    ExecutableProduct("typst", :typst),
]

# Dependencies that must be installed before this package can be built
dependencies = [
    Dependency("OpenSSL_jll"; compat="3.0.8"),
]

# Build the tarballs, and possibly a `build.jl` as well.
build_tarballs(ARGS, name, version, sources, script, platforms, products, dependencies;
               julia_compat="1.6", compilers=[:rust, :c], lock_microarchitecture=false,
               preferred_gcc_version = v"5")
