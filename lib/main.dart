import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class BigBrotherApp extends StatelessWidget {
  const BigBrotherApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
    	title: 'Big Brother',
    	debugShowCheckedModeBanner: false,
    	theme: ThemeData(
    		textTheme: GoogleFonts.notoSansTextTheme(),
    	),
      home: Scaffold(
        body: Center(
          child: Text('Big brother is watching.'),
        ),
      ),
    );
  }
}

void main() =>  runApp(const BigBrotherApp());

