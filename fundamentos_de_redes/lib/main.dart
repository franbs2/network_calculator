import 'package:flutter/material.dart';
import 'package:fundamentos_de_redes/inicio.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        textTheme: GoogleFonts.outfitTextTheme(),
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.cyan),
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      home: Scaffold(backgroundColor: Colors.white, body: Inicio()),
    );
  }
}
