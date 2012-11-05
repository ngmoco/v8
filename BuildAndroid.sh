#!/bin/bash

OUTPUT_DIR=package

if [ $# == 2 ]; then
    OUTPUT_DIR=$2
fi

# We expect argument one to be the directory of the ndk.  For now I will check
# if the directory exists and if it doesn't bust an error
if [ ! -d "$1" ]; then
    echo "$1 is not a directory.  Please try again"
else
    export ANDROID_NDK_ROOT=$1
    if [ -d "$OUTPUT_DIR" ]; then
        rm -r $OUTPUT_DIR/*
    else
        mkdir $OUTPUT_DIR
    fi
    # Clean up the system
    make clean

    # Copy over the include files
    echo "Copy includes"
    cp -R include $OUTPUT_DIR

    echo "Building Prod"
    # build the production version of v8
    echo "Building Release no debug"
    make android_arm.release -j8 
    mkdir $OUTPUT_DIR/prod
    cp -R out/android_arm.release/obj.target/tools/gyp/*.a $OUTPUT_DIR/prod
    
    echo ""
    echo ""
    echo ""

    make clean
    echo "Building Rel"
    # build the release version of V8
    echo "Building Release with debug"
    make android_arm.release -j8 debugersupport=on
    mkdir $OUTPUT_DIR/rel
    cp -R out/android_arm.release/obj.target/tools/gyp/*.a $OUTPUT_DIR/rel

    echo ""
    echo ""
    echo ""

    make clean
    # build the debug version
    echo "Building debug"
    make android_arm.debug -j8
    mkdir $OUTPUT_DIR/debug
    cp -R out/android_arm.debug/obj.target/tools/gyp/*.a $OUTPUT_DIR/debug

    echo "Build Completed"
fi




