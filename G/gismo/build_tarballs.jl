using BinaryBuilder
using Pkg

name = "gismo"
version = v"25.07.0"
sources = [
    GitSource("https://github.com/gismo/gismo.git",       # The URL of the git repository
              "3cd33adc2e957aeaaa1ab7acc5104e4e3e17ffe3") # The commit hash to checkout
]

# NOTE: to control nproc, use the environment variable BINARYBUILDER_NPROC=<number of processors>
script = raw"""
cmake -B build                                      \
  -DCMAKE_INSTALL_PREFIX=${prefix}                  \
  -DCMAKE_TOOLCHAIN_FILE=${CMAKE_TARGET_TOOLCHAIN}  \
  -DCMAKE_BUILD_TYPE=Release                        \
  -DGISMO_OPTIONAL="gsCInterface"                   \
  -DGISMO_gsCInterface_HEAD="f17f28b32cd4bcbe1fdf76dbafedf2858f2c8a02" \
  -DGISMO_WITH_OPENMP=ON                            \
  -DTARGET_ARCHITECTURE=none                        \
  gismo/

cmake --build build --target install -- -j$nproc gismo

install_license ${WORKSPACE}/srcdir/gismo/LICENSE.txt
"""

platforms = expand_cxxstring_abis(supported_platforms())

products = [
    LibraryProduct("libgismo", :libgismo),
]

dependencies = [
    # For OpenMP we use libomp from `LLVMOpenMP_jll` where we use LLVM as compiler (BSD
    # systems), and libgomp from `CompilerSupportLibraries_jll` everywhere else.
    Dependency(PackageSpec(name="CompilerSupportLibraries_jll", uuid="e66e0078-7015-5450-92f7-15fbd957f2ae");
               platforms=filter(!Sys.isbsd, platforms)),
    Dependency(PackageSpec(name="LLVMOpenMP_jll", uuid="1d63c593-3942-5779-bab2-d838dc0a180e");
               platforms=filter(Sys.isbsd, platforms))
]

build_tarballs(ARGS, name, version, sources, script, platforms, products, dependencies; julia_compat="1.6", preferred_gcc_version = v"9")
