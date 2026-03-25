import 'package:flutter/material.dart';

class RegistroExitosoPage extends StatelessWidget {
    const RegistroExitosoPage({super.key});

    @override
    Widget build(BuildContext context) {
        return Scaffold(
            body: Center(
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                        const Icon(Icons.check_circle, size: 100, color: Colors.green),
                        const SizedBox(height: 20),
                        const Text(
                            "¡Usuario Registrado!",
                            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 40),
                        ElevatedButton(
                            onPressed: () => Navigator.popUntil(context, (route) => route.isFirst),
                            child: const Text("Volver al inicio"),
                        ),
                    ],
                ),
            ),
        );
    }
}