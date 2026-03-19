import 'dart:ffi';
import 'dart:typed_data';
import 'package:ffi/ffi.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

typedef InitModelNative = Int32 Function(Pointer<Utf8> modelPath);
typedef InitModelDart = int Function(Pointer<Utf8> modelPath);
typedef InitIndexNative = Int32 Function(Pointer<Utf8> dbPath);
typedef InitIndexDart = int Function(Pointer<Utf8> dbPath);

typedef RegistrarUsuarioNative = Int32 Function(
  Pointer<Utf8> nombre,
  Pointer<Uint8> imagen,
  IntPtr imagenLen,
  Pointer<Utf8> dbPath,
);

typedef VerificarUsuarioNative = Int32 Function(
  Pointer<Uint8> imagen,
  IntPtr imagenLen,
  Pointer<Utf8> resultado,
  IntPtr resultadoLen,
  Pointer<Utf8> dbPath,
);

typedef RegistrarUsuarioDart = int Function(
  Pointer<Utf8> nombre,
  Pointer<Uint8> imagen,
  int imagenLen,
  Pointer<Utf8> dbPath,
);

typedef VerificarUsuarioDart = int Function(
  Pointer<Uint8> imagen,
  int imagenLen,
  Pointer<Utf8> resultado,
  int resultadoLen,
  Pointer<Utf8> dbPath,
);

class RustBridge {
  static final DynamicLibrary _lib = DynamicLibrary.open(
    'libreconocimiento_facial.so',
  );
  static final InitIndexDart _initIndex =
      _lib.lookup<NativeFunction<InitIndexNative>>('init_index').asFunction();

  static Future<int> initIndex() async {
    final dbPath = await _getDbPath();
    final dbPathPtr = dbPath.toNativeUtf8();
    final result = _initIndex(dbPathPtr);
    calloc.free(dbPathPtr);
    return result;
  }

  static Future<String> _getModelPath() async {
    return '/data/user/0/com.example.app_facial/files/arcface.onnx';
  }

  static Future<String> _getDbPath() async {
    final dir = await getApplicationDocumentsDirectory();
    return path.join(dir.path, 'faces.db');
  }

  static final RegistrarUsuarioDart _registrarUsuario = _lib
      .lookup<NativeFunction<RegistrarUsuarioNative>>('registrar_usuario')
      .asFunction();

  static final VerificarUsuarioDart _verificarUsuario = _lib
      .lookup<NativeFunction<VerificarUsuarioNative>>('verificar_usuario')
      .asFunction();

  static final InitModelDart _initModel =
      _lib.lookup<NativeFunction<InitModelNative>>('init_model').asFunction();

  static Future<int> initModel() async {
    final modelPath = await _getModelPath();
    print('Cargando modelo desde: $modelPath');
    final modelPathPtr = modelPath.toNativeUtf8();
    final result = _initModel(modelPathPtr);
    calloc.free(modelPathPtr);
    return result;
  }

  static Future<int> registrarUsuario(String nombre, Uint8List imagen) async {
    final dbPath = await _getDbPath();
    final nombrePtr = nombre.toNativeUtf8();
    final dbPathPtr = dbPath.toNativeUtf8();
    final imagenPtr = calloc<Uint8>(imagen.length);
    imagenPtr.asTypedList(imagen.length).setAll(0, imagen);

    final result =
        _registrarUsuario(nombrePtr, imagenPtr, imagen.length, dbPathPtr);

    calloc.free(nombrePtr);
    calloc.free(imagenPtr);
    calloc.free(dbPathPtr);
    return result;
  }

  static Future<String?> verificarUsuario(Uint8List imagen) async {
    final dbPath = await _getDbPath();
    final dbPathPtr = dbPath.toNativeUtf8();
    final imagenPtr = calloc<Uint8>(imagen.length);
    imagenPtr.asTypedList(imagen.length).setAll(0, imagen);
    final resultadoPtr = calloc<Uint8>(256);

    final result = _verificarUsuario(
        imagenPtr, imagen.length, resultadoPtr.cast<Utf8>(), 256, dbPathPtr);
    print('resultado codigo: $result'); // para debug
    String? nombre;
    if (result == 1 || result == 2) {
      nombre = resultadoPtr.cast<Utf8>().toDartString();
    }

    calloc.free(imagenPtr);
    calloc.free(resultadoPtr);
    calloc.free(dbPathPtr);
    return nombre;
  }
}
