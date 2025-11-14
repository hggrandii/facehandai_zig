const std = @import("std");

pub const LandmarkGroup = struct {
    name: []const u8,
    indices: []const u16,
    color: [3]u8,
};

pub const LIPS = [_]u16{
    61,  146, 91,  181, 84, 17, 314, 405, 321, 375, 291, 185, 40,  39,  37,  0,
    267, 269, 270, 409, 78, 95, 88,  178, 87,  14,  317, 402, 318, 324, 308,
};

pub const LEFT_EYE = [_]u16{
    33, 7, 163, 144, 145, 153, 154, 155, 133, 173, 157, 158, 159, 160, 161, 246,
};

pub const RIGHT_EYE = [_]u16{
    362, 382, 381, 380, 374, 373, 390, 249, 263, 466, 388, 387, 386, 385, 384, 398,
};

pub const FACE_OVAL = [_]u16{
    10,  338, 297, 332, 284, 251, 389, 356, 454, 323, 361, 288, 397, 365, 379,
    378, 400, 377, 152, 148, 176, 149, 150, 136, 172, 58,  132, 93,  234, 127,
    162, 21,  54,  103, 67,  109,
};

pub const groups = [_]LandmarkGroup{
    .{ .name = "lips", .indices = &LIPS, .color = .{ 255, 100, 100 } },
    .{ .name = "left_eye", .indices = &LEFT_EYE, .color = .{ 100, 255, 100 } },
    .{ .name = "right_eye", .indices = &RIGHT_EYE, .color = .{ 100, 100, 255 } },
    .{ .name = "face_oval", .indices = &FACE_OVAL, .color = .{ 255, 255, 100 } },
};

pub fn getColorForLandmark(index: u16) [3]u8 {
    for (groups) |group| {
        for (group.indices) |idx| {
            if (idx == index) return group.color;
        }
    }
    return .{ 200, 200, 200 };
}
