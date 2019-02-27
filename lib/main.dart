import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'App.dart';

void main() {
  SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeRight, DeviceOrientation.landscapeLeft]).then((_) {
    runApp(App());
  });
}