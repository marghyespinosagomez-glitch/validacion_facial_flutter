import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'camara_page.dart';
import 'dart:typed_data';
import '../rust_bridge.dart';
import 'registro_exitoso_page.dart';

class RegisterPage extends StatefulWidget {
  final List<CameraDescription> cameras;

  const RegisterPage({super.key, required this.cameras});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  // El TextEditingController nos permite extraer el texto del cuadro
  final TextEditingController _nameController = TextEditingController();

  bool _isProcessing = false; // Controla si mostramos el cargando
  String _statusMessage = "Listo para iniciar validación facial";

  Future<void> _iniciarEscaneo(BuildContext context) async {
    // 1. Abrimos la cámara y esperamos los bytes
    final Uint8List? fotoBytes = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CameraPage(cameras: widget.cameras),
      ),
    );
    print('fotoBytes::  ${fotoBytes}');
    print('_nameController::  ${_nameController.text}');

    if (!context.mounted) return;

    // 2. Si el usuario tomó la foto (no canceló)
    if (fotoBytes != null) {
      setState(() {
        _isProcessing = true;
        _statusMessage = "Registrando usuario...";
      });

      final resultado =
          await RustBridge.registrarUsuario(_nameController.text, fotoBytes);

      if (!context.mounted) return;

      if (resultado == 1) {
        await RustBridge.initIndex(); // reconstruye el índice
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const RegistroExitosoPage()),
        );
      } else {
        setState(() {
          _isProcessing = false;
          _statusMessage = "❌ Error al registrar usuario";
        });
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose(); // Importante para liberar memoria
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Registro de Usuario")),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _isProcessing
                ? const CircularProgressIndicator()
                : const Icon(Icons.face_unlock_outlined,
                    size: 100, color: Colors.blue),

            const Icon(Icons.person_add_alt_1, size: 80, color: Colors.green),
            const SizedBox(height: 30),

            // Cuadro de texto para el nombre
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: "Nombre Completo",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person),
              ),
            ),

            const SizedBox(height: 30),

            // Botón para abrir la cámara
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton.icon(
                onPressed: () {
                  if (_nameController.text.isNotEmpty) {
                    // Si escribió algo, abrimos la cámara
                    _iniciarEscaneo(context);
                  } else {
                    // Si está vacío, mostramos una alerta rápida
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text("Por favor, ingresa un nombre")),
                    );
                  }
                },
                icon: const Icon(Icons.camera_alt),
                label: const Text("CAPTURAR ROSTRO"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
