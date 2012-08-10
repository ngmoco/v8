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
    cp -R include $OUTPUT_DIR

    # build the production version of v8
    make android_arm.release -j8 debuggersupport=off
    mkdir $OUTPUT_DIR/prod
    cp -R out/android_arm.release/obj.target/tools/gyp/*.a $OUTPUT_DIR/prod
    
    make clean
    # build the release version of V8
    make android_arm.release -j8 
    cp -R out/android_arm.release/obj.target/tools/gyp/*.a $OUTPUT_DIR/rel

    make clean
    # build the debug version
    make android_arm.debug -j8
    cp -R out/android_arm.debug/obj.target/tools/gyp/*.a $OUTPUT_DIR/debug

    echo "Build Completed"
fi




