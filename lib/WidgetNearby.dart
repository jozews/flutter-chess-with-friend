

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:simple_permissions/simple_permissions.dart';
import 'package:device_info/device_info.dart';

import 'WidgetGame.dart';
import 'Nearby.dart';


class WidgetNearby extends StatefulWidget {

  WidgetNearby({Key key}) : super(key: key);

  @override
  StateWidgetNearby createState() => StateWidgetNearby();
}


class StateWidgetNearby extends State<WidgetNearby> {

  static const ID_SERVICE = "jozews";

  static var deviceInfo = DeviceInfoPlugin();
  static AndroidDeviceInfo infoAndroid;

  static var isConnected = false;

  var widgetGame = WidgetGame();


  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIOverlays([]);
    setupConnection();
  }

  setupConnection() async {

    await SimplePermissions.requestPermission(Permission.AccessCoarseLocation);
    infoAndroid = await deviceInfo.androidInfo;

    Nearby.startDiscovering(idService: ID_SERVICE).listen((discovery) {
      switch (discovery.type) {
        case TypeDiscovery.found:
          // handle one connection for now
          if (!isConnected) {
            return;
          }
          // request connection
          Nearby.requestConnection(idEndpoint: discovery.idEndpoint).listen((lifecycle) {
            switch (lifecycle.type) {
              case TypeLifecycle.initiated:
                break;
              case TypeLifecycle.result:
                break;
              case TypeLifecycle.disconnected:
                isConnected = false;
                break;
            }
          });
          break;
        case TypeDiscovery.lost:
          break;
      }
    });

    Nearby.startAdvertising(name: infoAndroid.model, idService: ID_SERVICE).listen((advertise) {
      switch (advertise.type) {
        case TypeLifecycle.initiated:
          // accept connection
          Nearby.acceptConnection(idEndpoint: advertise.idEndpoint).listen((payload) {
            switch (payload.type) {
              case TypePayload.initiated:
                break;
              case TypePayload.result:
                break;
              case TypePayload.disconnected:
                isConnected = false;
                break;
            }
          });
          break;
        case TypeLifecycle.result:
          break;
        case TypeLifecycle.disconnected:
          isConnected = false;
          break;
      }
    });
  }


  @override
  Widget build(BuildContext context) {
    return widgetGame;
  }

}