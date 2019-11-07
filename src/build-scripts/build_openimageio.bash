#!/bin/bash

# Install OpenImageIO

OPENIMAGEIO_REPO=${OPENIMAGEIO_REPO:=OpenImageIO/oiio}
OPENIMAGEIO_BRANCH=${OPENIMAGEIO_BRANCH:=master}
OPENIMAGEIO_SRCDIR=${OPENIMAGEIO_SRCDIR:=$PWD/ext/OpenImageIO}
OPENIMAGEIO_INSTALLDIR=${OPENIMAGEIO_INSTALLDIR:=$OPENIMAGEIO_SRCDIR/dist/$PLATFORM}
OPENIMAGEIO_CMAKE_FLAGS=${OPENIMAGEIO_CMAKE_FLAGS:=""}
OPENIMAGEIO_BUILD_TYPE=${OPENIMAGEIO_BUILD_TYPE:=Release}
OPENIMAGEIO_CXXFLAGS=${OPENIMAGEIO_CXXFLAGS:=""}
BASEDIR=$PWD
CMAKE_GENERATOR=${CMAKE_GENERATOR:="Unix Makefiles"}

if [ ! -e $OPENIMAGEIO_SRCDIR ] ; then
    git clone https://github.com/${OPENIMAGEIO_REPO} $OPENIMAGEIO_SRCDIR
fi

pushd $OPENIMAGEIO_SRCDIR
git fetch --all -p
git checkout $OPENIMAGEIO_BRANCH --force

if [[ "$ARCH" == "windows64" ]] ; then
    mkdir -p build/$PLATFORM && true
    pushd build/$PLATFORM
    cmake ../.. -G "$CMAKE_GENERATOR" \
        -DCMAKE_BUILD_TYPE=${OPENIMAGEIO_BUILD_TYPE} \
        -DCMAKE_INSTALL_PREFIX="$OPENIMAGEIO_INSTALLDIR" \
        -DPYTHON_VERSION="$PYTHON_VERSION" \
        $OPENIMAGEIO_CMAKE_FLAGS -DVERBOSE=1
    echo "Parallel build $CMAKE_BUILD_PARALLEL_LEVEL"
    time cmake --build . --target install --config ${OPENIMAGEIO_BUILD_TYPE}
    popd
    uname -a
else
    make nuke
    make $OPENIMAGEIO_MAKEFLAGS $PAR_MAKEFLAGS $BUILD_FLAGS
fi

popd

export OpenImageIO_ROOT=$OPENIMAGEIO_INSTALLDIR
export PATH=$OpenImageIO_ROOT/bin:$PATH
export DYLD_LIBRARY_PATH=$OpenImageIO_ROOT/lib:$DYLD_LIBRARY_PATH
export LD_LIBRARY_PATH=$OpenImageIO_ROOT/lib:$LD_LIBRARY_PATH
export PYTHONPATH=$OpenImageIO_ROOT/lib/python${PYTHON_VERSION}:$PYTHONPATH

echo "DYLD_LIBRARY_PATH = $DYLD_LIBRARY_PATH"
echo "LD_LIBRARY_PATH = $LD_LIBRARY_PATH"
echo "OpenImageIO_ROOT $OpenImageIO_ROOT"
ls -R $OpenImageIO_ROOT
