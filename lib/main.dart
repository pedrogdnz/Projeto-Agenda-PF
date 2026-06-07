import 'package:agendapf/presentation/views/reservas.dart';
import 'package:flutter/material.dart';
import 'package:agendapf/presentation/views/login.dart';
import 'package:agendapf/presentation/views/register.dart';
import 'package:agendapf/presentation/views/calendar.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.light(
          primary: Colors.black,
        )
      ),
      home: Reservas(),
      debugShowCheckedModeBanner: false,
    );
  }
}