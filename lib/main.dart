import 'package:flutter/material.dart';

import 'src/view/app.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  final title = 'Flutter BLE Scan Demo';

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: title,
      home: App(
        title: title,
      ),
    );
  }
}
