import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'dart:typed_data';
import 'camara_page.dart';
import '../rust_bridge.dart';
class IngresoPage extends StatefulWidget {
  final List<CameraDescription> cameras;

  const IngresoPage({super.key, required this.cameras});

  @override
  State<IngresoPage> createState() => _IngresoPageState();
}

class _IngresoPageState extends State<IngresoPage> {
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

    if (!context.mounted) return;

    // 2. Si el usuario tomó la foto (no canceló)
    if (fotoBytes != null) {
      setState(() {
        _isProcessing = true;
        _statusMessage = "Verificando identidad...";
      });

      // --- SIMULACIÓN DE PROCESAMIENTO ---
      // Aquí es donde llamarías a tu lógica de pgvector o API
      final nombre = await Future(() => 
    RustBridge.verificarUsuario(fotoBytes));

if (nombre != null) {
    _statusMessage = "✅ Bienvenido $nombre";
} else {
    _statusMessage = "❌ Rostro no reconocido";
} 
      // ------------------------------------

      if (!context.mounted) return;

      setState(() {
        _isProcessing = false;
        _statusMessage = "¡Acceso Concedido!";
      });

      // Opcional: Navegar a la pantalla principal tras el éxito
      // Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => HomePage()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Ingreso Biométrico")),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(30.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icono dinámico según el estado
              _isProcessing 
                ? const CircularProgressIndicator() 
                : const Icon(Icons.face_unlock_outlined, size: 100, color: Colors.blue),
              
              const SizedBox(height: 30),
              
              Text(
                _statusMessage,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
              ),

              const SizedBox(height: 50),

              // Botón para reintentar o iniciar
              if (!_isProcessing)
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton.icon(
                    onPressed: () => _iniciarEscaneo(context),
                    icon: const Icon(Icons.videocam),
                    label: const Text("ABRIR CÁMARA"),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, foregroundColor: Colors.white),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
