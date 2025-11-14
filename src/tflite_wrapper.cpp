#include "tflite_wrapper.h"

#include "tensorflow/lite/interpreter.h"
#include "tensorflow/lite/kernels/register.h"
#include "tensorflow/lite/model.h"
#include "tensorflow/lite/optional_debug_tools.h"

#include <cstring>
#include <opencv2/opencv.hpp>

extern "C" {

typedef void *ZigTFLiteModel;
typedef void *ZigTFLiteInterpreter;
typedef void *ZigTFLiteTensor;

// Model functions
ZigTFLiteModel zig_tflite_model_from_file(const char *path) {
  auto model = tflite::FlatBufferModel::BuildFromFile(path);
  if (!model) {
    return nullptr;
  }
  return model.release();
}

void zig_tflite_model_delete(ZigTFLiteModel model) {
  if (model) {
    delete static_cast<tflite::FlatBufferModel *>(model);
  }
}

// Interpreter functions
ZigTFLiteInterpreter zig_tflite_interpreter_create(ZigTFLiteModel model,
                                                   int num_threads) {
  auto *fb_model = static_cast<tflite::FlatBufferModel *>(model);

  tflite::ops::builtin::BuiltinOpResolver resolver;
  auto interpreter = std::make_unique<tflite::Interpreter>();

  tflite::InterpreterBuilder builder(*fb_model, resolver);
  builder(&interpreter);

  if (!interpreter) {
    return nullptr;
  }

  interpreter->SetNumThreads(num_threads);

  return interpreter.release();
}

void zig_tflite_interpreter_delete(ZigTFLiteInterpreter interpreter) {
  if (interpreter) {
    delete static_cast<tflite::Interpreter *>(interpreter);
  }
}

bool zig_tflite_interpreter_allocate_tensors(ZigTFLiteInterpreter interpreter) {
  auto *interp = static_cast<tflite::Interpreter *>(interpreter);
  return interp->AllocateTensors() == kTfLiteOk;
}

bool zig_tflite_interpreter_invoke(ZigTFLiteInterpreter interpreter) {
  auto *interp = static_cast<tflite::Interpreter *>(interpreter);
  return interp->Invoke() == kTfLiteOk;
}

// Tensor functions
ZigTFLiteTensor
zig_tflite_interpreter_get_input_tensor(ZigTFLiteInterpreter interpreter,
                                        int index) {
  auto *interp = static_cast<tflite::Interpreter *>(interpreter);
  return interp->input_tensor(index);
}

ZigTFLiteTensor
zig_tflite_interpreter_get_output_tensor(ZigTFLiteInterpreter interpreter,
                                         int index) {
  auto *interp = static_cast<tflite::Interpreter *>(interpreter);
  return interp->output_tensor(index);
}

int zig_tflite_tensor_byte_size(ZigTFLiteTensor tensor) {
  auto *t = static_cast<TfLiteTensor *>(tensor);
  return t->bytes;
}

void *zig_tflite_tensor_data(ZigTFLiteTensor tensor) {
  auto *t = static_cast<TfLiteTensor *>(tensor);
  return t->data.raw;
}

void zig_tflite_tensor_copy_from_buffer(ZigTFLiteTensor tensor,
                                        const void *data, size_t size) {
  auto *t = static_cast<TfLiteTensor *>(tensor);
  if (t->bytes >= size) {
    memcpy(t->data.raw, data, size);
  }
}

int zig_tflite_tensor_dims(ZigTFLiteTensor tensor) {
  auto *t = static_cast<TfLiteTensor *>(tensor);
  return t->dims->size;
}

int zig_tflite_tensor_dim(ZigTFLiteTensor tensor, int dim_index) {
  auto *t = static_cast<TfLiteTensor *>(tensor);
  if (dim_index < t->dims->size) {
    return t->dims->data[dim_index];
  }
  return 0;
}
}

extern "C" {

struct FaceInterpreterWrapper {
  tflite::FlatBufferModel *model;
  tflite::Interpreter *interpreter;
};

FaceInterpreter tflite_create_interpreter(const char *path) {
  auto model = tflite::FlatBufferModel::BuildFromFile(path);
  if (!model) {
    return nullptr;
  }

  tflite::ops::builtin::BuiltinOpResolver resolver;
  std::unique_ptr<tflite::Interpreter> interpreter;
  tflite::InterpreterBuilder(*model, resolver)(&interpreter);
  if (!interpreter) {
    return nullptr;
  }

  if (interpreter->AllocateTensors() != kTfLiteOk) {
    return nullptr;
  }

  auto *wrapper = new FaceInterpreterWrapper;
  wrapper->model = model.release();
  wrapper->interpreter = interpreter.release();
  return wrapper;
}

void tflite_destroy_interpreter(FaceInterpreter handle) {
  auto *wrapper = static_cast<FaceInterpreterWrapper *>(handle);
  if (!wrapper)
    return;
  delete wrapper->interpreter;
  delete wrapper->model;
  delete wrapper;
}

// SUPER SIMPLE implementation: assumes a single input and output tensor.
// It will likely need tuning depending on the exact model.
int tflite_detect_face(FaceInterpreter handle, void *frame,
                       float *out_landmarks) {
  auto *wrapper = static_cast<FaceInterpreterWrapper *>(handle);
  if (!wrapper || !frame || !out_landmarks)
    return 0;

  auto *interp = wrapper->interpreter;
  cv::Mat &mat = *static_cast<cv::Mat *>(frame);
  if (mat.empty())
    return 0;

  TfLiteTensor *input = interp->input_tensor(0);
  if (!input || !input->dims || input->dims->size < 4) {
    return 0;
  }

  const int wanted_height = input->dims->data[1];
  const int wanted_width = input->dims->data[2];
  const int wanted_channels = input->dims->data[3];

  cv::Mat resized;
  cv::resize(mat, resized, cv::Size(wanted_width, wanted_height));

  cv::Mat rgb;
  if (resized.channels() == 3 && wanted_channels == 3) {
    cv::cvtColor(resized, rgb, cv::COLOR_BGR2RGB);
  } else {
    rgb = resized;
  }

  if (input->type == kTfLiteFloat32) {
    float *input_data = input->data.f;
    const int pixel_count = wanted_width * wanted_height * wanted_channels;

    for (int y = 0; y < wanted_height; ++y) {
      const uint8_t *row = rgb.ptr<uint8_t>(y);
      for (int x = 0; x < wanted_width; ++x) {
        for (int c = 0; c < wanted_channels; ++c) {
          int idx = (y * wanted_width + x) * wanted_channels + c;
          input_data[idx] = row[x * wanted_channels + c] / 255.0f;
        }
      }
    }
  } else if (input->type == kTfLiteUInt8) {
    uint8_t *input_data = input->data.uint8;
    std::memcpy(input_data, rgb.data,
                wanted_width * wanted_height * wanted_channels);
  } else {
    // unsupported input type
    return 0;
  }

  if (interp->Invoke() != kTfLiteOk) {
    return 0;
  }

  TfLiteTensor *output = interp->output_tensor(0);
  if (!output || output->type != kTfLiteFloat32) {
    return 0;
  }

  const int out_elems = output->bytes / sizeof(float);
  std::memcpy(out_landmarks, output->data.f, output->bytes);

  // We assume 3 values per landmark (x, y, z)
  return out_elems / 3;
}
}
