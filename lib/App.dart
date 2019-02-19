
import 'package:flutter/material.dart';

import 'WidgetGame.dart';

class App extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chess Umbrella',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: WidgetGame(),
    );
  }
}