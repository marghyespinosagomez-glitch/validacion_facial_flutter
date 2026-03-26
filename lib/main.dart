import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
// import 'screens/camara_page.dart';
import 'screens/login_page.dart';
import 'rust_bridge.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

late List<CameraDescription> _cameras;

Future<void> main() async {
    WidgetsFlutterBinding.ensureInitialized();
    _cameras = await availableCameras();
    await _copiarModelos();
    // await _copiarBD();
    RustBridge.initModel().then((result) {
        print('Modelo inicializado: $result');
    });
    runApp(const MyApp());
}

// Future<void> _copiarBD() async {
//     final dir = await getApplicationDocumentsDirectory();
//     final dbPath = '${dir.path}/faces.db';
//     final sdPath = '/sdcard/faces.db';
    
//     if (File(sdPath).existsSync() && !File(dbPath).existsSync()) {
//         await File(sdPath).copy(dbPath);
//         print('✅ BD copiada desde SD');
//     }
// }

Future<void> _copiarModelos() async {
    final dir = await getApplicationDocumentsDirectory();
    
    // copiar shape predictor
    final predictorPath = '${dir.path}/shape_predictor.dat';
    if (!File(predictorPath).existsSync()) {
        final data = await rootBundle.load('assets/shape_predictor_5_face_landmarks.dat');
        final bytes = data.buffer.asUint8List();
        await File(predictorPath).writeAsBytes(bytes);
        print('✅ Shape predictor copiado');
    }
    
    // copiar modelo de reconocimiento
    final recognizerPath = '${dir.path}/dlib_recognition.dat';
    if (!File(recognizerPath).existsSync()) {
        final data = await rootBundle.load('assets/dlib_face_recognition_resnet_model_v1.dat');
        final bytes = data.buffer.asUint8List();
        await File(recognizerPath).writeAsBytes(bytes);
        print('✅ Modelo reconocimiento copiado');
    }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Sistema Biométrico',
      theme: ThemeData(primarySwatch: Colors.blue),
      // Definimos la pantalla de inicio
      home: LoginPage(cameras: _cameras),
    );
  }
}
