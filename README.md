# Jumpscale Wheelhouse
Build wheels (precompiled dependencies) for Jumpscale 9 (development branch)

# Build
- Clone this repository
- Download image: `docker pull quay.io/pypa/manylinux1_x86_64`
- Build target:
  - `docker run -it --rm -v $(pwd)/core9:/io quay.io/pypa/manylinux1_x86_64 bash /io/build.sh`
  - `docker run -it --rm -v $(pwd)/lib9:/io quay.io/pypa/manylinux1_x86_64 bash /io/build.sh`

For each submodules (core9, lib9, ...) you'll find:
 - Wheels under: `.../wheelhouse/repository`
 - Archives for specific python version under: `.../wheelhouse/release/`
