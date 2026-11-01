
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Catálogo de películas',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blueGrey,
          brightness: Brightness.dark,
        ),
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [

          // Imagen de fondo
          Image.asset(
            'assets/images/fondo_peliculas.jpg',
            fit: BoxFit.cover,
          ),

          // Capa oscura para mejorar la lectura
          Container(
            color: Colors.black.withValues(alpha: 0.65),
          ),

          // Contenido de la pantalla
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),

                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [

                    // Icono de películas
                    const Icon(
                      Icons.movie_creation_outlined,
                      size: 85,
                      color: Colors.white,
                    ),

                    const SizedBox(height: 20),

                    // Nombre de la aplicación
                    const Text(
                      'CATÁLOGO DE PELÍCULAS',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 23,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 1.5,
                      ),
                    ),

                    const SizedBox(height: 35),

                    // Mensaje de bienvenida
                    const Text(
                      '¡Bienvenido!',
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Texto solicitado en la actividad
                    const Text(
                      'Hello World',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.white70,
                      ),
                    ),

                    const SizedBox(height: 15),

                    // Descripción de la aplicación
                    const Text(
                      'Descubre y disfruta de las mejores '
                      'películas en un solo lugar',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                        height: 1.5,
                      ),
                    ),

                    const SizedBox(height: 40),

                    // Botón Iniciar sesión
                    SizedBox(
                      width: 250,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Pantalla de inicio de sesión',
                              ),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blueGrey,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Iniciar sesión'),
                      ),
                    ),

                    const SizedBox(height: 15),

                    // Botón Registrarse
                    SizedBox(
                      width: 250,
                      height: 50,
                      child: OutlinedButton(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Pantalla de registro',
                              ),
                            ),
                          );
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white,
                          side: const BorderSide(
                            color: Colors.white,
                          ),
                        ),
                        child: const Text('Registrarse'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

