const std = @import("std");
const c = @cImport({
    @cInclude("opencv_wrapper.h");
    @cInclude("tflite_wrapper.h");
});
const landmark_groups = @import("landmark_groups.zig");

pub fn main() !void {
    std.debug.print("Starting face landmark detection...\n", .{});

    // --- Camera ---
    const cap = c.zig_cv_capture_create(0);
    if (cap == null) {
        std.debug.print("Failed to open camera\n", .{});
        return error.CameraError;
    }
    defer c.zig_cv_capture_release(cap);

    // --- TFLite interpreter ---
    const interpreter = c.tflite_create_interpreter("models/face_landmarks_detector.tflite");
    if (interpreter == null) {
        std.debug.print("Failed to create TFLite interpreter\n", .{});
        return error.InterpreterError;
    }
    defer c.tflite_destroy_interpreter(interpreter);

    // --- Frame Mat ---
    const frame = c.zig_cv_mat_create();
    if (frame == null) {
        std.debug.print("Failed to create frame Mat\n", .{});
        return error.FrameError;
    }
    defer c.zig_cv_mat_release(frame);

    // --- Window ---
    c.zig_cv_named_window("Face Landmarks", c.zig_cv_get_window_autosize());
    defer c.zig_cv_destroy_window("Face Landmarks");

    std.debug.print("Press 'q' to quit\n", .{});

    var frame_index: usize = 0;

    // MediaPipe Face Landmarker v2 → 478 landmarks, each (x, y, z)
    const max_model_points = 478;
    var landmarks: [max_model_points * 3]f32 = undefined;

    while (true) {
        if (!c.zig_cv_capture_read(cap, frame)) break;

        const width: c_int = c.zig_cv_mat_cols(frame);
        const height: c_int = c.zig_cv_mat_rows(frame);

        const raw_count = c.tflite_detect_face(interpreter, frame, &landmarks);

        frame_index += 1;
        if (frame_index % 30 == 0) {
            std.debug.print("frame {}: raw_count (points) = {d}\n", .{ frame_index, raw_count });
        }

        if (raw_count > 0) {
            var points: usize = @intCast(raw_count);
            if (points > max_model_points) {
                points = max_model_points;
            }
            const used_values = points * 3;

            var i: usize = 0;
            while (i < points) : (i += 1) {
                const x = landmarks[i * 3];
                const y = landmarks[i * 3 + 1];

                const px = landmarkToPixel(x, width);
                const py = landmarkToPixel(y, height);

                const color = landmark_groups.getColorForLandmark(@intCast(i));
                c.draw_circle(frame, px, py, 2, color[0], color[1], color[2]);
            }

            drawFaceMeshConnections(
                frame,
                landmarks[0..used_values],
                points,
                width,
                height,
            );
        }

        c.zig_cv_imshow("Face Landmarks", frame);

        if (c.zig_cv_wait_key(1) == 'q') break;
    }

    std.debug.print("Cleanup complete\n", .{});
}

fn landmarkToPixel(v: f32, frame_size: c_int) c_int {
    const input_size: f32 = 256.0;
    var scaled = v * (@as(f32, @floatFromInt(frame_size)) / input_size);

    if (scaled < 0.0) scaled = 0.0;
    const max = @as(f32, @floatFromInt(frame_size - 1));
    if (scaled > max) scaled = max;

    return @as(c_int, @intFromFloat(scaled));
}

fn drawFaceMeshConnections(
    frame: c.ZigCvMat,
    landmarks: []const f32,
    points: usize,
    width: c_int,
    height: c_int,
) void {
    const connections = [_][2]u16{
        // Lips outline
        .{ 61, 146 },  .{ 146, 91 },  .{ 91, 181 },  .{ 181, 84 },  .{ 84, 17 },
        .{ 17, 314 },  .{ 314, 405 }, .{ 405, 321 }, .{ 321, 375 }, .{ 375, 291 },

        // Left eye
        .{ 33, 133 },  .{ 133, 160 }, .{ 160, 159 }, .{ 159, 158 }, .{ 158, 157 },
        .{ 157, 173 }, .{ 173, 33 },

        // Right eye
         .{ 362, 263 }, .{ 263, 466 }, .{ 466, 388 },
        .{ 388, 387 }, .{ 387, 386 }, .{ 386, 385 }, .{ 385, 362 },

        // Face oval
        .{ 10, 338 },
        .{ 338, 297 }, .{ 297, 332 }, .{ 332, 284 }, .{ 284, 251 },
    };

    for (connections) |conn| {
        const idx1 = conn[0];
        const idx2 = conn[1];

        if (idx1 >= points or idx2 >= points) continue;

        const x1 = landmarkToPixel(landmarks[idx1 * 3], width);
        const y1 = landmarkToPixel(landmarks[idx1 * 3 + 1], height);
        const x2 = landmarkToPixel(landmarks[idx2 * 3], width);
        const y2 = landmarkToPixel(landmarks[idx2 * 3 + 1], height);

        c.draw_line(frame, x1, y1, x2, y2, 100, 100, 100);
    }
}
