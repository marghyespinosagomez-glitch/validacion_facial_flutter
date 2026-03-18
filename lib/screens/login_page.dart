import 'package:flutter/material.dart';
import 'camara_page.dart'; // Importamos la página de la cámara
import 'package:camera/camera.dart';
import 'registro_page.dart';
import 'ingreso_page.dart';

class LoginPage extends StatelessWidget {
  final List<CameraDescription> cameras;

  // const LoginPage({super.key});
  const LoginPage({super.key, required this.cameras});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icono visual de bienvenida
              const Icon(Icons.face_retouching_natural, size: 100, color: Colors.blue),
              const SizedBox(height: 20),
              const Text(
                "Bienvenido",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 50),

              // Botón de Login Facial
              SizedBox(
                width: double.infinity,
                height: 60,
                child: ElevatedButton.icon(
                  onPressed: () {
                    // Navegamos a la cámara para el login facial
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => IngresoPage(cameras: cameras)),
                    );
                  },
                  icon: const Icon(Icons.face),
                  label: const Text("LOGIN FACIAL", style: TextStyle(fontSize: 18)),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, foregroundColor: Colors.white),
                ),
              ),

              const SizedBox(height: 20),

              // Botón de Registro
              SizedBox(
                width: double.infinity,
                height: 60,
                child: OutlinedButton.icon(
                  onPressed: () {
                    print("Ir a pantalla de registro normal");
                    // Aquí podrías navegar a otra página de registro de datos
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => RegisterPage(cameras: cameras)),
                    );
                  },
                  icon: const Icon(Icons.person_add),
                  label: const Text("REGISTRO USUARIO", style: TextStyle(fontSize: 18)),
                  style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.blue)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}