#!/usr/bin/env ruby

$VERBOSE = true

def show_usage_and_quit
  puts "Usage: ngcore_build_v8 path/to/android-ndk-r6b/"
  puts "   the resulting v8 archives will be copied into the package/ subfolder."
  puts "   Note: must use a downloaded ndk from google, the one in submoduels/coreTools does not include static libs for stlport."
  puts "   Note: download ndk from google: http://dl.google.com/android/ndk/android-ndk-r6b-darwin-x86.tar.bz2"
  puts "   Note: also satisfy gyp dependencies by typing \"make dependencies\" before running this script."
  puts "   Note: if all artifacts are built, then (manually) copy them from package/ folder to respective locations in libs/ folder."
  exit 1
end

def sh command
  puts "running command: `#{command}`" if $VERBOSE
  IO.popen command + " 2>&1" do |pipe|
    while !pipe.eof?
      puts(pipe.readline)
    end
  end

  if $?.exitstatus != 0
    puts "error running command: `#{command}` status = #{$?.exitstatus}"
    exit 1
  elsif $VERBOSE
    puts "success running command: `#{command}` status = #{$?.exitstatus}"
  end
end

def clean_build_v8 make_target, additional_make_options, output_dir
  puts "Clean Building #{output_dir}..."
  sh "rm -rf out"
  sh "mkdir out"
  sh "make clean"
  sh "make #{make_target} -j8 #{additional_make_options}"
  sh "mkdir #{output_dir}"
  if make_target == 'ia32.debug' || make_target == 'ia32.release'
    sh "cp -R out/#{make_target}/*.a #{output_dir}"
  else
    sh "cp -R out/#{make_target}/obj.target/tools/gyp/*.a #{output_dir}"
  end
  puts "DONE"
end

# check command line args
show_usage_and_quit if !ARGV[0] || (ARGV[0] && !File.exists?(ARGV[0]))

ENV["ANDROID_NDK_ROOT"] = ARGV[0]

OUTPUT_DIR = "package"

puts "Setup..."
sh "rm -rf #{OUTPUT_DIR}"
sh "mkdir #{OUTPUT_DIR}"
sh "cp -R include #{OUTPUT_DIR}"
puts "DONE"

# release
clean_build_v8 "android_arm.release", "", "#{OUTPUT_DIR}/armv7-prod"
clean_build_v8 "android_arm.release", "NGCORE_ARMV7=0 armv7=0 vfp3=off", "#{OUTPUT_DIR}/armv6-prod"

# release with debugger support
clean_build_v8 "android_arm.release", "debuggersupport=1", "#{OUTPUT_DIR}/armv7-rel"
clean_build_v8 "android_arm.release", "debuggersupport=1 NGCORE_ARMV7=0 armv7=0 vfp3=off", "#{OUTPUT_DIR}/armv6-rel"

# ios simulator release with debugger support.
#clean_build_v8 "ia32.debug", "debuggersupport=1 werror=no", "#{OUTPUT_DIR}/ia32-debug"
clean_build_v8 "ia32.release", "debuggersupport=1 werror=no", "#{OUTPUT_DIR}/ia32-rel"

# NOTE: these builds are currently disabled they lock up the clang compiler on the host machine (used to build the tools necessary to build a snapshot)

# debug
#clean_build_v8 "android_arm.debug", "want_separate_host_toolset=0", "#{OUTPUT_DIR}/armv7-debug"
#clean_build_v8 "android_arm.debug", "want_separate_host_toolset=0 NGCORE_ARMV7=0 armv7=0 vfp3=off", "#{OUTPUT_DIR}/armv6-debug"

puts "Build complete"
