
import 'package:flutter/services.dart';

typedef void CallbackConnectionInitiated(String idEndpoint, Map info);
typedef void CallbackConnectionResult(String idEndpoint, int result);
typedef void CallbackConnectionDisconnected(String idEndpoint);

typedef void CallbackEndpointFound(String idEndpoint,  Map info);
typedef void CallbackEndpointLost(String idEndpoint);

enum TypeAdvertise {
  found, lost
}

class Advertise {

  TypeAdvertise type;
  String idEndpoint;
  String nameEndpoint;
  String idService;

  Advertise(this.type, this.idEndpoint, this.nameEndpoint, this.idService);

  Advertise.fromMap(Map map) {
    this.type = TypeAdvertise.values[map["type"]];
    this.idEndpoint = map["id_endpoint"];
    this.nameEndpoint = map["name_endpoint"];
    this.idService = map["id_service"];
  }
}


enum TypeDiscovery {
  initiated, result, disconnected
}

class Discovery {

  TypeDiscovery type;
  String idEndpoint;
  String nameEndpoint;
  bool accepted;

  Discovery(this.type, this.idEndpoint, this.nameEndpoint, this.accepted);

  Discovery.fromMap(Map map) {
    this.type = TypeDiscovery.values[map["type"]];
    this.idEndpoint = map["id_endpoint"];
    this.nameEndpoint = map["name_endpoint"];
    this.accepted = map["accepted"];
  }
}


class Nearby {

  static var channelAdvertising = EventChannel("nearby-advertising");
  static var channelDiscovering = EventChannel("nearby-discovering");

  static startAdvertising(String name, String idService) async {
    try {
      channelAdvertising.receiveBroadcastStream([name, idService]).listen((event) {
        var advertise = Advertise.fromMap(event);
        print(advertise);
      });
    } on PlatformException catch (e) {
      print(e);
    }
  }

  static startDiscovering(String idService) async {
    try {
      channelDiscovering.receiveBroadcastStream([idService]).listen((event) {
        var discovery = Discovery.fromMap(event);
        print(discovery);
      });
    } on PlatformException catch (e) {
      print(e);
    }
  }
}