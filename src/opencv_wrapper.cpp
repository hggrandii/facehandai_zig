#include <opencv2/opencv.hpp>

extern "C" {
typedef void *ZigCvCapture;
typedef void *ZigCvMat;

ZigCvCapture zig_cv_capture_create(int device) {
  cv::VideoCapture *cap = new cv::VideoCapture(device);
  if (!cap->isOpened()) {
    delete cap;
    return nullptr;
  }
  return cap;
}

void zig_cv_capture_release(ZigCvCapture cap) {
  if (cap) {
    delete static_cast<cv::VideoCapture *>(cap);
  }
}

bool zig_cv_capture_is_opened(ZigCvCapture cap) {
  return static_cast<cv::VideoCapture *>(cap)->isOpened();
}

bool zig_cv_capture_read(ZigCvCapture cap, ZigCvMat mat) {
  return static_cast<cv::VideoCapture *>(cap)->read(
      *static_cast<cv::Mat *>(mat));
}

ZigCvMat zig_cv_mat_create() { return new cv::Mat(); }

void zig_cv_mat_release(ZigCvMat mat) {
  if (mat) {
    delete static_cast<cv::Mat *>(mat);
  }
}

int zig_cv_mat_rows(ZigCvMat mat) { return static_cast<cv::Mat *>(mat)->rows; }

int zig_cv_mat_cols(ZigCvMat mat) { return static_cast<cv::Mat *>(mat)->cols; }

bool zig_cv_mat_empty(ZigCvMat mat) {
  return static_cast<cv::Mat *>(mat)->empty();
}

void zig_cv_cvt_color(ZigCvMat src, ZigCvMat dst, int code) {
  cv::cvtColor(*static_cast<cv::Mat *>(src), *static_cast<cv::Mat *>(dst),
               code);
}

void zig_cv_canny(ZigCvMat src, ZigCvMat dst, double threshold1,
                  double threshold2, int aperture_size) {
  cv::Canny(*static_cast<cv::Mat *>(src), *static_cast<cv::Mat *>(dst),
            threshold1, threshold2, aperture_size);
}

void zig_cv_named_window(const char *name, int flags) {
  cv::namedWindow(name, flags);
}

void zig_cv_destroy_window(const char *name) { cv::destroyWindow(name); }

void zig_cv_imshow(const char *name, ZigCvMat mat) {
  cv::imshow(name, *static_cast<cv::Mat *>(mat));
}

int zig_cv_wait_key(int delay) { return cv::waitKey(delay); }

int zig_cv_get_color_bgr2gray() { return cv::COLOR_BGR2GRAY; }
int zig_cv_get_color_gray2bgr() { return cv::COLOR_GRAY2BGR; }

int zig_cv_get_window_autosize() { return cv::WINDOW_AUTOSIZE; }
}

extern "C" void draw_line(ZigCvMat mat, int x1, int y1, int x2, int y2,
                          unsigned char r, unsigned char g, unsigned char b) {
  if (mat) {
    cv::line(*static_cast<cv::Mat *>(mat), cv::Point(x1, y1), cv::Point(x2, y2),
             cv::Scalar(b, g, r), 1);
  }
}

extern "C" void draw_circle(ZigCvMat mat, int x, int y, int radius,
                            unsigned char r, unsigned char g, unsigned char b) {
  if (mat) {
    cv::circle(*static_cast<cv::Mat *>(mat), cv::Point(x, y), radius,
               cv::Scalar(b, g, r), -1);
  }
}
