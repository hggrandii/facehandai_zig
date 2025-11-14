#ifndef ZIG_OPENCV_WRAPPER_H
#define ZIG_OPENCV_WRAPPER_H
#include <stdbool.h>
#ifdef __cplusplus
extern "C" {
#endif
// Opaque pointer types
typedef void *ZigCvCapture;
typedef void *ZigCvMat;
// VideoCapture functions
ZigCvCapture zig_cv_capture_create(int device);
void zig_cv_capture_release(ZigCvCapture cap);
bool zig_cv_capture_is_opened(ZigCvCapture cap);
bool zig_cv_capture_read(ZigCvCapture cap, ZigCvMat mat);
// Mat functions
ZigCvMat zig_cv_mat_create(void);
void zig_cv_mat_release(ZigCvMat mat);
int zig_cv_mat_rows(ZigCvMat mat);
int zig_cv_mat_cols(ZigCvMat mat);
bool zig_cv_mat_empty(ZigCvMat mat);
// Image processing functions
void zig_cv_cvt_color(ZigCvMat src, ZigCvMat dst, int code);
void zig_cv_canny(ZigCvMat src, ZigCvMat dst, double threshold1,
                  double threshold2, int aperture_size);
// HighGUI functions
void zig_cv_named_window(const char *name, int flags);
void zig_cv_destroy_window(const char *name);
void zig_cv_imshow(const char *name, ZigCvMat mat);
int zig_cv_wait_key(int delay);
// Drawing functions
void draw_line(ZigCvMat mat, int x1, int y1, int x2, int y2, unsigned char r,
               unsigned char g, unsigned char b);
void draw_circle(ZigCvMat mat, int x, int y, int radius, unsigned char r,
                 unsigned char g, unsigned char b);
// Constants
int zig_cv_get_color_bgr2gray(void);
int zig_cv_get_color_gray2bgr(void);
int zig_cv_get_window_autosize(void);
#ifdef __cplusplus
}
#endif
#endif
