
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'WidgetNearby.dart';
import 'WidgetGame.dart';
import 'WidgetSettings.dart';


class App extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIOverlays([]);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Chess Umbrella',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: WidgetGame(),
    );
  }
}