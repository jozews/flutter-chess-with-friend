
import 'package:flutter/material.dart';

import 'WidgetNearby.dart';

class App extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Chess Umbrella',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: WidgetNearby(),
    );
  }
}