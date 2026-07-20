import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'simulation_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeLeft]);
  runApp(const CentripetalForceApp());
}

class CentripetalForceApp extends StatelessWidget {
  const CentripetalForceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Centripetal Force Simulation',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF141420),
      ),
      home: const SimulationPage(),
    );
  }
}
