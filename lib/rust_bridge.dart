import 'dart:ffi';
import 'dart:typed_data';
import 'package:ffi/ffi.dart';

// Tipos de las funciones de Rust
typedef RegistrarUsuarioNative = Int32 Function(
  Pointer<Utf8> nombre,
  Pointer<Uint8> imagen,
  IntPtr imagenLen,
);

typedef VerificarUsuarioNative = Int32 Function(
  Pointer<Uint8> imagen,
  IntPtr imagenLen,
  Pointer<Utf8> resultado,
  IntPtr resultadoLen,
);

typedef RegistrarUsuarioDart = int Function(
  Pointer<Utf8> nombre,
  Pointer<Uint8> imagen,
  int imagenLen,
);

typedef VerificarUsuarioDart = int Function(
  Pointer<Uint8> imagen,
  int imagenLen,
  Pointer<Utf8> resultado,
  int resultadoLen,
);

class RustBridge {
  static final DynamicLibrary _lib = DynamicLibrary.open(
    'libreconocimiento_facial.so',
  );

  static final RegistrarUsuarioDart _registrarUsuario = _lib
      .lookup<NativeFunction<RegistrarUsuarioNative>>('registrar_usuario')
      .asFunction();

  static final VerificarUsuarioDart _verificarUsuario = _lib
      .lookup<NativeFunction<VerificarUsuarioNative>>('verificar_usuario')
      .asFunction();

  // Registrar usuario
  static int registrarUsuario(String nombre, Uint8List imagen) {
    final nombrePtr = nombre.toNativeUtf8();
    final imagenPtr = calloc<Uint8>(imagen.length);
    imagenPtr.asTypedList(imagen.length).setAll(0, imagen);

    final result = _registrarUsuario(nombrePtr, imagenPtr, imagen.length);

    calloc.free(nombrePtr);
    calloc.free(imagenPtr);
    return result;
  }

  // Verificar usuario
  static String? verificarUsuario(Uint8List imagen) {
    final imagenPtr = calloc<Uint8>(imagen.length);
    imagenPtr.asTypedList(imagen.length).setAll(0, imagen);
    final resultadoPtr = calloc<Uint8>(256);

    final result = _verificarUsuario(imagenPtr, imagen.length, resultadoPtr.cast<Utf8>(), 256);

    String? nombre;
    if (result == 1) {
      nombre = resultadoPtr.cast<Utf8>().toDartString();
    }

    calloc.free(imagenPtr);
    calloc.free(resultadoPtr);
    return nombre;
  }
}
