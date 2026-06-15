import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:agendapf/presentation/views/calendar.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await initializeDateFormatting('pt_BR', null);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Calendário',
      theme: ThemeData(
        useMaterial3: true,
      ),
      home: const CalendarPage(),
    );
  }
}