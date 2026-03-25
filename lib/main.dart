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
    await _copiarModelo(); // <- primero copiar
    RustBridge.initModel().then((result) {
        print('Modelo inicializado: $result');
    });
    runApp(const MyApp());
}

Future<void> _copiarModelo() async {
    final dir = await getApplicationDocumentsDirectory();
    final modelPath = '${dir.path}/arcface.onnx';
    
    // solo copiar si no existe
    if (!File(modelPath).existsSync()) {
        final data = await rootBundle.load('assets/arcface.onnx');
        final bytes = data.buffer.asUint8List();
        await File(modelPath).writeAsBytes(bytes);
        print('✅ Modelo copiado al almacenamiento');
    } else {
        print('✅ Modelo ya existe');
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
