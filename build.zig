const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const exe = b.addExecutable(.{
        .name = "facehandai",
        .root_module = b.createModule(.{
            .root_source_file = b.path("src/main.zig"),
            .target = target,
            .optimize = optimize,
        }),
    });

    exe.linkLibC();
    exe.linkLibCpp();

    // --- OpenCV ---
    exe.linkSystemLibrary("opencv4");
    exe.addIncludePath(.{ .cwd_relative = "/opt/homebrew/opt/opencv/include/opencv4" });

    // Source includes
    exe.addIncludePath(.{ .cwd_relative = "src" });

    // --- TensorFlow Lite headers ---
    exe.addIncludePath(.{ .cwd_relative = "include" });

    exe.addIncludePath(.{ .cwd_relative = "tflite-src" });

    exe.addIncludePath(.{ .cwd_relative = "tflite-src/tensorflow/lite/build/flatbuffers/include" });

    // OpenCV wrapper
    exe.addCSourceFile(.{
        .file = b.path("src/opencv_wrapper.cpp"),
        .flags = &.{
            "-std=c++23",
            "-I/opt/homebrew/opt/opencv/include/opencv4",
        },
    });

    // TFLite wrapper
    exe.addCSourceFile(.{
        .file = b.path("src/tflite_wrapper.cpp"),
        .flags = &.{
            "-std=c++23",
            "-Iinclude",
            "-I/opt/homebrew/opt/opencv/include/opencv4",
        },
    });

    // --- TensorFlow Lite core static lib
    exe.addObjectFile(.{ .cwd_relative = "lib/libtensorflow-lite.a" });

    // --- Extra libs from tflite-src/tensorflow/lite/build ---

    // pthreadpool (for XNNPACK thread pools)
    exe.addObjectFile(.{ .cwd_relative = "tflite-src/tensorflow/lite/build/pthreadpool/libpthreadpool.a" });

    // flatbuffers
    exe.addObjectFile(.{ .cwd_relative = "tflite-src/tensorflow/lite/build/_deps/flatbuffers-build/libflatbuffers.a" });

    // farmhash (util::Fingerprint64)
    exe.addObjectFile(.{ .cwd_relative = "tflite-src/tensorflow/lite/build/_deps/farmhash-build/libfarmhash.a" });

    // gemmlowp
    exe.addObjectFile(.{ .cwd_relative = "tflite-src/tensorflow/lite/build/_deps/gemmlowp-build/libeight_bit_int_gemm.a" });

    // cpuinfo
    exe.addObjectFile(.{ .cwd_relative = "tflite-src/tensorflow/lite/build/_deps/cpuinfo-build/libcpuinfo.a" });
    exe.addObjectFile(.{ .cwd_relative = "tflite-src/tensorflow/lite/build/_deps/cpuinfo-build/libcpuinfo_internals.a" });

    // fft2d (for rdft / rdft2d / spectrogram)
    exe.addObjectFile(.{ .cwd_relative = "tflite-src/tensorflow/lite/build/_deps/fft2d-build/libfft2d_alloc.a" });
    exe.addObjectFile(.{ .cwd_relative = "tflite-src/tensorflow/lite/build/_deps/fft2d-build/libfft2d_fftsg.a" });
    exe.addObjectFile(.{ .cwd_relative = "tflite-src/tensorflow/lite/build/_deps/fft2d-build/libfft2d_fftsg2d.a" });
    // exe.addObjectFile(.{ .cwd_relative = "tflite-src/tensorflow/lite/build/_deps/fft2d-build/libfft2d_fftsg3d.a" });
    // exe.addObjectFile(.{ .cwd_relative = "tflite-src/tensorflow/lite/build/_deps/fft2d-build/libfft2d_shrtdct.a" });

    // ruy (matrix multiplication backend)
    exe.addObjectFile(.{ .cwd_relative = "tflite-src/tensorflow/lite/build/_deps/ruy-build/ruy/libruy_system_aligned_alloc.a" });
    exe.addObjectFile(.{ .cwd_relative = "tflite-src/tensorflow/lite/build/_deps/ruy-build/ruy/libruy_apply_multiplier.a" });
    exe.addObjectFile(.{ .cwd_relative = "tflite-src/tensorflow/lite/build/_deps/ruy-build/ruy/libruy_kernel_arm.a" });
    exe.addObjectFile(.{ .cwd_relative = "tflite-src/tensorflow/lite/build/_deps/ruy-build/ruy/libruy_allocator.a" });
    exe.addObjectFile(.{ .cwd_relative = "tflite-src/tensorflow/lite/build/_deps/ruy-build/ruy/libruy_pack_avx.a" });
    exe.addObjectFile(.{ .cwd_relative = "tflite-src/tensorflow/lite/build/_deps/ruy-build/ruy/libruy_trmul.a" });
    exe.addObjectFile(.{ .cwd_relative = "tflite-src/tensorflow/lite/build/_deps/ruy-build/ruy/libruy_kernel_avx2_fma.a" });
    exe.addObjectFile(.{ .cwd_relative = "tflite-src/tensorflow/lite/build/_deps/ruy-build/ruy/libruy_pack_arm.a" });
    exe.addObjectFile(.{ .cwd_relative = "tflite-src/tensorflow/lite/build/_deps/ruy-build/ruy/libruy_have_built_path_for_avx.a" });
    exe.addObjectFile(.{ .cwd_relative = "tflite-src/tensorflow/lite/build/_deps/ruy-build/ruy/libruy_kernel_avx512.a" });
    exe.addObjectFile(.{ .cwd_relative = "tflite-src/tensorflow/lite/build/_deps/ruy-build/ruy/libruy_have_built_path_for_avx512.a" });
    exe.addObjectFile(.{ .cwd_relative = "tflite-src/tensorflow/lite/build/_deps/ruy-build/ruy/libruy_kernel_avx.a" });
    exe.addObjectFile(.{ .cwd_relative = "tflite-src/tensorflow/lite/build/_deps/ruy-build/ruy/libruy_tune.a" });
    exe.addObjectFile(.{ .cwd_relative = "tflite-src/tensorflow/lite/build/_deps/ruy-build/ruy/libruy_denormal.a" });
    exe.addObjectFile(.{ .cwd_relative = "tflite-src/tensorflow/lite/build/_deps/ruy-build/ruy/libruy_have_built_path_for_avx2_fma.a" });
    exe.addObjectFile(.{ .cwd_relative = "tflite-src/tensorflow/lite/build/_deps/ruy-build/ruy/libruy_pack_avx512.a" });
    exe.addObjectFile(.{ .cwd_relative = "tflite-src/tensorflow/lite/build/_deps/ruy-build/ruy/libruy_blocking_counter.a" });
    exe.addObjectFile(.{ .cwd_relative = "tflite-src/tensorflow/lite/build/_deps/ruy-build/ruy/libruy_prepare_packed_matrices.a" });
    exe.addObjectFile(.{ .cwd_relative = "tflite-src/tensorflow/lite/build/_deps/ruy-build/ruy/libruy_ctx.a" });
    exe.addObjectFile(.{ .cwd_relative = "tflite-src/tensorflow/lite/build/_deps/ruy-build/ruy/libruy_thread_pool.a" });
    exe.addObjectFile(.{ .cwd_relative = "tflite-src/tensorflow/lite/build/_deps/ruy-build/ruy/profiler/libruy_profiler_profiler.a" });
    exe.addObjectFile(.{ .cwd_relative = "tflite-src/tensorflow/lite/build/_deps/ruy-build/ruy/profiler/libruy_profiler_instrumentation.a" });
    exe.addObjectFile(.{ .cwd_relative = "tflite-src/tensorflow/lite/build/_deps/ruy-build/ruy/libruy_prepacked_cache.a" });
    exe.addObjectFile(.{ .cwd_relative = "tflite-src/tensorflow/lite/build/_deps/ruy-build/ruy/libruy_context.a" });
    exe.addObjectFile(.{ .cwd_relative = "tflite-src/tensorflow/lite/build/_deps/ruy-build/ruy/libruy_block_map.a" });
    exe.addObjectFile(.{ .cwd_relative = "tflite-src/tensorflow/lite/build/_deps/ruy-build/ruy/libruy_cpuinfo.a" });
    exe.addObjectFile(.{ .cwd_relative = "tflite-src/tensorflow/lite/build/_deps/ruy-build/ruy/libruy_frontend.a" });
    exe.addObjectFile(.{ .cwd_relative = "tflite-src/tensorflow/lite/build/_deps/ruy-build/ruy/libruy_pack_avx2_fma.a" });
    exe.addObjectFile(.{ .cwd_relative = "tflite-src/tensorflow/lite/build/_deps/ruy-build/ruy/libruy_wait.a" });
    exe.addObjectFile(.{ .cwd_relative = "tflite-src/tensorflow/lite/build/_deps/ruy-build/ruy/libruy_context_get_ctx.a" });

    // Abseil (absl)
    exe.addObjectFile(.{ .cwd_relative = "tflite-src/tensorflow/lite/build/_deps/abseil-cpp-build/absl/strings/libabsl_cord.a" });
    exe.addObjectFile(.{ .cwd_relative = "tflite-src/tensorflow/lite/build/_deps/abseil-cpp-build/absl/strings/libabsl_cord_internal.a" });
    exe.addObjectFile(.{ .cwd_relative = "tflite-src/tensorflow/lite/build/_deps/abseil-cpp-build/absl/strings/libabsl_cordz_info.a" });
    exe.addObjectFile(.{ .cwd_relative = "tflite-src/tensorflow/lite/build/_deps/abseil-cpp-build/absl/strings/libabsl_strings.a" });
    exe.addObjectFile(.{ .cwd_relative = "tflite-src/tensorflow/lite/build/_deps/abseil-cpp-build/absl/strings/libabsl_str_format_internal.a" });
    exe.addObjectFile(.{ .cwd_relative = "tflite-src/tensorflow/lite/build/_deps/abseil-cpp-build/absl/strings/libabsl_strings_internal.a" });
    exe.addObjectFile(.{ .cwd_relative = "tflite-src/tensorflow/lite/build/_deps/abseil-cpp-build/absl/strings/libabsl_cordz_handle.a" });
    exe.addObjectFile(.{ .cwd_relative = "tflite-src/tensorflow/lite/build/_deps/abseil-cpp-build/absl/strings/libabsl_cordz_functions.a" });
    exe.addObjectFile(.{ .cwd_relative = "tflite-src/tensorflow/lite/build/_deps/abseil-cpp-build/absl/strings/libabsl_cordz_sample_token.a" });

    exe.addObjectFile(.{ .cwd_relative = "tflite-src/tensorflow/lite/build/_deps/abseil-cpp-build/absl/types/libabsl_bad_optional_access.a" });
    exe.addObjectFile(.{ .cwd_relative = "tflite-src/tensorflow/lite/build/_deps/abseil-cpp-build/absl/types/libabsl_bad_any_cast_impl.a" });
    exe.addObjectFile(.{ .cwd_relative = "tflite-src/tensorflow/lite/build/_deps/abseil-cpp-build/absl/types/libabsl_bad_variant_access.a" });

    exe.addObjectFile(.{ .cwd_relative = "tflite-src/tensorflow/lite/build/_deps/abseil-cpp-build/absl/flags/libabsl_flags_commandlineflag.a" });
    exe.addObjectFile(.{ .cwd_relative = "tflite-src/tensorflow/lite/build/_deps/abseil-cpp-build/absl/flags/libabsl_flags_usage_internal.a" });
    exe.addObjectFile(.{ .cwd_relative = "tflite-src/tensorflow/lite/build/_deps/abseil-cpp-build/absl/flags/libabsl_flags_private_handle_accessor.a" });
    exe.addObjectFile(.{ .cwd_relative = "tflite-src/tensorflow/lite/build/_deps/abseil-cpp-build/absl/flags/libabsl_flags.a" });
    exe.addObjectFile(.{ .cwd_relative = "tflite-src/tensorflow/lite/build/_deps/abseil-cpp-build/absl/flags/libabsl_flags_usage.a" });
    exe.addObjectFile(.{ .cwd_relative = "tflite-src/tensorflow/lite/build/_deps/abseil-cpp-build/absl/flags/libabsl_flags_program_name.a" });
    exe.addObjectFile(.{ .cwd_relative = "tflite-src/tensorflow/lite/build/_deps/abseil-cpp-build/absl/flags/libabsl_flags_parse.a" });
    exe.addObjectFile(.{ .cwd_relative = "tflite-src/tensorflow/lite/build/_deps/abseil-cpp-build/absl/flags/libabsl_flags_config.a" });
    exe.addObjectFile(.{ .cwd_relative = "tflite-src/tensorflow/lite/build/_deps/abseil-cpp-build/absl/flags/libabsl_flags_commandlineflag_internal.a" });
    exe.addObjectFile(.{ .cwd_relative = "tflite-src/tensorflow/lite/build/_deps/abseil-cpp-build/absl/flags/libabsl_flags_marshalling.a" });
    exe.addObjectFile(.{ .cwd_relative = "tflite-src/tensorflow/lite/build/_deps/abseil-cpp-build/absl/flags/libabsl_flags_reflection.a" });
    exe.addObjectFile(.{ .cwd_relative = "tflite-src/tensorflow/lite/build/_deps/abseil-cpp-build/absl/flags/libabsl_flags_internal.a" });

    exe.addObjectFile(.{ .cwd_relative = "tflite-src/tensorflow/lite/build/_deps/abseil-cpp-build/absl/synchronization/libabsl_graphcycles_internal.a" });
    exe.addObjectFile(.{ .cwd_relative = "tflite-src/tensorflow/lite/build/_deps/abseil-cpp-build/absl/synchronization/libabsl_synchronization.a" });

    exe.addObjectFile(.{ .cwd_relative = "tflite-src/tensorflow/lite/build/_deps/abseil-cpp-build/absl/hash/libabsl_city.a" });
    exe.addObjectFile(.{ .cwd_relative = "tflite-src/tensorflow/lite/build/_deps/abseil-cpp-build/absl/hash/libabsl_hash.a" });
    exe.addObjectFile(.{ .cwd_relative = "tflite-src/tensorflow/lite/build/_deps/abseil-cpp-build/absl/hash/libabsl_low_level_hash.a" });

    exe.addObjectFile(.{ .cwd_relative = "tflite-src/tensorflow/lite/build/_deps/abseil-cpp-build/absl/debugging/libabsl_failure_signal_handler.a" });
    exe.addObjectFile(.{ .cwd_relative = "tflite-src/tensorflow/lite/build/_deps/abseil-cpp-build/absl/debugging/libabsl_debugging_internal.a" });
    exe.addObjectFile(.{ .cwd_relative = "tflite-src/tensorflow/lite/build/_deps/abseil-cpp-build/absl/debugging/libabsl_symbolize.a" });
    exe.addObjectFile(.{ .cwd_relative = "tflite-src/tensorflow/lite/build/_deps/abseil-cpp-build/absl/debugging/libabsl_stacktrace.a" });
    exe.addObjectFile(.{ .cwd_relative = "tflite-src/tensorflow/lite/build/_deps/abseil-cpp-build/absl/debugging/libabsl_demangle_internal.a" });
    exe.addObjectFile(.{ .cwd_relative = "tflite-src/tensorflow/lite/build/_deps/abseil-cpp-build/absl/debugging/libabsl_leak_check.a" });
    exe.addObjectFile(.{ .cwd_relative = "tflite-src/tensorflow/lite/build/_deps/abseil-cpp-build/absl/debugging/libabsl_examine_stack.a" });

    exe.addObjectFile(.{ .cwd_relative = "tflite-src/tensorflow/lite/build/_deps/abseil-cpp-build/absl/crc/libabsl_crc_cord_state.a" });
    exe.addObjectFile(.{ .cwd_relative = "tflite-src/tensorflow/lite/build/_deps/abseil-cpp-build/absl/crc/libabsl_crc32c.a" });
    exe.addObjectFile(.{ .cwd_relative = "tflite-src/tensorflow/lite/build/_deps/abseil-cpp-build/absl/crc/libabsl_crc_internal.a" });
    exe.addObjectFile(.{ .cwd_relative = "tflite-src/tensorflow/lite/build/_deps/abseil-cpp-build/absl/crc/libabsl_crc_cpu_detect.a" });

    exe.addObjectFile(.{ .cwd_relative = "tflite-src/tensorflow/lite/build/_deps/abseil-cpp-build/absl/status/libabsl_status.a" });
    exe.addObjectFile(.{ .cwd_relative = "tflite-src/tensorflow/lite/build/_deps/abseil-cpp-build/absl/status/libabsl_statusor.a" });

    exe.addObjectFile(.{ .cwd_relative = "tflite-src/tensorflow/lite/build/_deps/abseil-cpp-build/absl/time/libabsl_time_zone.a" });
    exe.addObjectFile(.{ .cwd_relative = "tflite-src/tensorflow/lite/build/_deps/abseil-cpp-build/absl/time/libabsl_time.a" });
    exe.addObjectFile(.{ .cwd_relative = "tflite-src/tensorflow/lite/build/_deps/abseil-cpp-build/absl/time/libabsl_civil_time.a" });

    exe.addObjectFile(.{ .cwd_relative = "tflite-src/tensorflow/lite/build/_deps/abseil-cpp-build/absl/container/libabsl_raw_hash_set.a" });
    exe.addObjectFile(.{ .cwd_relative = "tflite-src/tensorflow/lite/build/_deps/abseil-cpp-build/absl/container/libabsl_hashtablez_sampler.a" });

    exe.addObjectFile(.{ .cwd_relative = "tflite-src/tensorflow/lite/build/_deps/abseil-cpp-build/absl/numeric/libabsl_int128.a" });

    exe.addObjectFile(.{ .cwd_relative = "tflite-src/tensorflow/lite/build/_deps/abseil-cpp-build/absl/profiling/libabsl_periodic_sampler.a" });
    exe.addObjectFile(.{ .cwd_relative = "tflite-src/tensorflow/lite/build/_deps/abseil-cpp-build/absl/profiling/libabsl_exponential_biased.a" });

    exe.addObjectFile(.{ .cwd_relative = "tflite-src/tensorflow/lite/build/_deps/abseil-cpp-build/absl/log/libabsl_die_if_null.a" });
    exe.addObjectFile(.{ .cwd_relative = "tflite-src/tensorflow/lite/build/_deps/abseil-cpp-build/absl/log/libabsl_log_internal_conditions.a" });
    exe.addObjectFile(.{ .cwd_relative = "tflite-src/tensorflow/lite/build/_deps/abseil-cpp-build/absl/log/libabsl_log_internal_nullguard.a" });
    exe.addObjectFile(.{ .cwd_relative = "tflite-src/tensorflow/lite/build/_deps/abseil-cpp-build/absl/log/libabsl_log_internal_log_sink_set.a" });
    exe.addObjectFile(.{ .cwd_relative = "tflite-src/tensorflow/lite/build/_deps/abseil-cpp-build/absl/log/libabsl_log_internal_format.a" });
    exe.addObjectFile(.{ .cwd_relative = "tflite-src/tensorflow/lite/build/_deps/abseil-cpp-build/absl/log/libabsl_log_internal_globals.a" });
    exe.addObjectFile(.{ .cwd_relative = "tflite-src/tensorflow/lite/build/_deps/abseil-cpp-build/absl/log/libabsl_log_sink.a" });
    exe.addObjectFile(.{ .cwd_relative = "tflite-src/tensorflow/lite/build/_deps/abseil-cpp-build/absl/log/libabsl_log_internal_check_op.a" });
    exe.addObjectFile(.{ .cwd_relative = "tflite-src/tensorflow/lite/build/_deps/abseil-cpp-build/absl/log/libabsl_log_internal_message.a" });
    exe.addObjectFile(.{ .cwd_relative = "tflite-src/tensorflow/lite/build/_deps/abseil-cpp-build/absl/log/libabsl_log_initialize.a" });
    exe.addObjectFile(.{ .cwd_relative = "tflite-src/tensorflow/lite/build/_deps/abseil-cpp-build/absl/log/libabsl_log_globals.a" });
    exe.addObjectFile(.{ .cwd_relative = "tflite-src/tensorflow/lite/build/_deps/abseil-cpp-build/absl/log/libabsl_log_internal_proto.a" });
    exe.addObjectFile(.{ .cwd_relative = "tflite-src/tensorflow/lite/build/_deps/abseil-cpp-build/absl/log/libabsl_log_entry.a" });
    exe.addObjectFile(.{ .cwd_relative = "tflite-src/tensorflow/lite/build/_deps/abseil-cpp-build/absl/log/libabsl_log_flags.a" });

    exe.addObjectFile(.{ .cwd_relative = "tflite-src/tensorflow/lite/build/_deps/abseil-cpp-build/absl/random/libabsl_random_distributions.a" });
    exe.addObjectFile(.{ .cwd_relative = "tflite-src/tensorflow/lite/build/_deps/abseil-cpp-build/absl/random/libabsl_random_internal_platform.a" });
    exe.addObjectFile(.{ .cwd_relative = "tflite-src/tensorflow/lite/build/_deps/abseil-cpp-build/absl/random/libabsl_random_internal_seed_material.a" });
    exe.addObjectFile(.{ .cwd_relative = "tflite-src/tensorflow/lite/build/_deps/abseil-cpp-build/absl/random/libabsl_random_internal_randen_slow.a" });
    exe.addObjectFile(.{ .cwd_relative = "tflite-src/tensorflow/lite/build/_deps/abseil-cpp-build/absl/random/libabsl_random_internal_distribution_test_util.a" });
    exe.addObjectFile(.{ .cwd_relative = "tflite-src/tensorflow/lite/build/_deps/abseil-cpp-build/absl/random/libabsl_random_seed_gen_exception.a" });

    exe.addObjectFile(.{ .cwd_relative = "tflite-src/tensorflow/lite/build/_deps/abseil-cpp-build/absl/base/libabsl_spinlock_wait.a" });
    exe.addObjectFile(.{ .cwd_relative = "tflite-src/tensorflow/lite/build/_deps/abseil-cpp-build/absl/base/libabsl_log_severity.a" });
    exe.addObjectFile(.{ .cwd_relative = "tflite-src/tensorflow/lite/build/_deps/abseil-cpp-build/absl/base/libabsl_raw_logging_internal.a" });
    exe.addObjectFile(.{ .cwd_relative = "tflite-src/tensorflow/lite/build/_deps/abseil-cpp-build/absl/base/libabsl_base.a" });
    exe.addObjectFile(.{ .cwd_relative = "tflite-src/tensorflow/lite/build/_deps/abseil-cpp-build/absl/base/libabsl_throw_delegate.a" });
    exe.addObjectFile(.{ .cwd_relative = "tflite-src/tensorflow/lite/build/_deps/abseil-cpp-build/absl/base/libabsl_malloc_internal.a" });
    exe.addObjectFile(.{ .cwd_relative = "tflite-src/tensorflow/lite/build/_deps/abseil-cpp-build/absl/base/libabsl_scoped_set_env.a" });
    exe.addObjectFile(.{ .cwd_relative = "tflite-src/tensorflow/lite/build/_deps/abseil-cpp-build/absl/base/libabsl_strerror.a" });

    exe.linkSystemLibrary("pthread");
    // exe.linkSystemLibrary("dl");
    exe.linkSystemLibrary("m");

    b.installArtifact(exe);

    const run_cmd = b.addRunArtifact(exe);
    run_cmd.step.dependOn(b.getInstallStep());

    if (b.args) |args| {
        run_cmd.addArgs(args);
    }

    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&run_cmd.step);
}
