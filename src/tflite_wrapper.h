#ifndef ZIG_TFLITE_WRAPPER_H
#define ZIG_TFLITE_WRAPPER_H

#include <stdbool.h>
#include <stddef.h>

#ifdef __cplusplus
extern "C" {
#endif

// Opaque pointer types
typedef void *ZigTFLiteModel;
typedef void *ZigTFLiteInterpreter;
typedef void *ZigTFLiteTensor;

// Model functions
ZigTFLiteModel zig_tflite_model_from_file(const char *path);
void zig_tflite_model_delete(ZigTFLiteModel model);

// Interpreter functions
ZigTFLiteInterpreter zig_tflite_interpreter_create(ZigTFLiteModel model,
                                                   int num_threads);
void zig_tflite_interpreter_delete(ZigTFLiteInterpreter interpreter);
bool zig_tflite_interpreter_allocate_tensors(ZigTFLiteInterpreter interpreter);
bool zig_tflite_interpreter_invoke(ZigTFLiteInterpreter interpreter);

// Tensor functions
ZigTFLiteTensor
zig_tflite_interpreter_get_input_tensor(ZigTFLiteInterpreter interpreter,
                                        int index);
ZigTFLiteTensor
zig_tflite_interpreter_get_output_tensor(ZigTFLiteInterpreter interpreter,
                                         int index);

// Tensor data access
int zig_tflite_tensor_byte_size(ZigTFLiteTensor tensor);
void *zig_tflite_tensor_data(ZigTFLiteTensor tensor);
void zig_tflite_tensor_copy_from_buffer(ZigTFLiteTensor tensor,
                                        const void *data, size_t size);

// Tensor shape info
int zig_tflite_tensor_dims(ZigTFLiteTensor tensor);
int zig_tflite_tensor_dim(ZigTFLiteTensor tensor, int dim_index);

// High-level convenience API used from Zig
typedef void *FaceInterpreter;

// Create an interpreter from a model file (.tflite, not .task).
FaceInterpreter tflite_create_interpreter(const char *model_path);

// Destroy interpreter and associated resources.
void tflite_destroy_interpreter(FaceInterpreter interpreter);

// Run face landmark model on a frame.
// - interpreter: created by tflite_create_interpreter
// - frame: cv::Mat* (passed as opaque pointer)
// - out_landmarks: pointer to at least 468*3 floats
// Returns: number of landmarks (e.g. 468) or 0 on failure.
int tflite_detect_face(FaceInterpreter interpreter, void *frame,
                       float *out_landmarks);

#ifdef __cplusplus
}
#endif

#endif
