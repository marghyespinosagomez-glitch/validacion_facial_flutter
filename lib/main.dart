import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
// import 'screens/camara_page.dart';
import 'screens/login_page.dart';

late List<CameraDescription> _cameras;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  _cameras = await availableCameras();

  runApp(const MyApp());
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
  
