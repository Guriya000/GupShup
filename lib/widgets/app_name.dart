import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppName extends StatelessWidget {
  const AppName({super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      'GupShup',
      style: GoogleFonts.oxanium(
        letterSpacing: 1,
        color: Theme.of(context).primaryColor,
        fontSize: 35,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}
