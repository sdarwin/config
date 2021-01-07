#!/bin/bash

# Copyright 2020 Rene Rivera, Sam Darwin
# Distributed under the Boost Software License, Version 1.0.
# (See accompanying file LICENSE.txt or copy at http://boost.org/LICENSE_1_0.txt)

set -e
export TRAVIS_BUILD_DIR=$(pwd)
export DRONE_BUILD_DIR=$(pwd)
export TRAVIS_BRANCH=$DRONE_BRANCH
export VCS_COMMIT_ID=$DRONE_COMMIT
export GIT_COMMIT=$DRONE_COMMIT
export REPO_NAME=$DRONE_REPO
export PATH=~/.local/bin:/usr/local/bin:$PATH

if [ "$DRONE_JOB_BUILDTYPE" == "boost" ]; then

echo '==================================> INSTALL'

BOOST_BRANCH=develop && [ "$TRAVIS_BRANCH" == "master" ] && BOOST_BRANCH=master || true
cd ..
git clone -b $BOOST_BRANCH --depth 1 https://github.com/boostorg/boost.git boost-root
cd boost-root
git submodule update --init tools/build
git submodule update --init tools/boost_install
git submodule update --init libs/headers
git submodule update --init libs/detail
git submodule update --init libs/core
git submodule update --init libs/assert
git submodule update --init libs/type_traits
cp -r $TRAVIS_BUILD_DIR/* libs/config
./bootstrap.sh
./b2 headers

echo '==================================> SCRIPT'

if [ $TEST_INTEL ]; then source ~/.bashrc; fi
echo "using $TOOLSET : : $COMPILER : <cxxflags>$EXTRA_FLAGS <linkflags>$EXTRA_FLAGS ;" > ~/user-config.jam
./b2 libs/config/test//print_config_info toolset=$TOOLSET cxxstd=$CXXSTD $CXXSTD_DIALECT
./b2 -j3 libs/config/test toolset=$TOOLSET cxxstd=$CXXSTD $CXXSTD_DIALECT

fi
