import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'dart:typed_data';

class CameraPage extends StatefulWidget {
  final List<CameraDescription> cameras; // Pasamos las cámaras como parámetro
  const CameraPage({super.key, required this.cameras});

  @override
  State<CameraPage> createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  late CameraController controller;

  @override
  void initState() {
    super.initState();
    // Usamos el parámetro widget.cameras para acceder a la lista
    controller = CameraController(widget.cameras[1], ResolutionPreset.max);
    controller.initialize().then((_) {
      if (!mounted) return;
      setState(() {});
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  Future<Uint8List> _takePhoto() async {
    print('esta aquii');
    final image = await controller.takePicture();
    // print('Foto guardada en: ${await image.readAsBytes()}');

    return image.readAsBytes();
  }

  @override
  Widget build(BuildContext context) {
    if (!controller.value.isInitialized) {
      return const Center(child: CircularProgressIndicator());
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text("Escaneo Facial"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context), // Regresa al Login
        ),
      ),
      body: Center(
        child: Transform(
          alignment: Alignment.center,
          transform: Matrix4.rotationY(3.14159),
          child: CameraPreview(controller),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          try {
            final byteImg = await _takePhoto();
            print('byteImg: ${byteImg}');
            if (!context.mounted) return;
            Navigator.pop(context, byteImg);
          } catch (e) {
            print(e);
          }
        },
        child: const Icon(Icons.camera_alt),
      ),
    );
  }
}
