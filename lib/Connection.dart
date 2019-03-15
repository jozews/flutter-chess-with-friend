

class Connection {

  String idDevice;
  String idEndpoint;
  String nameEndpoint;
  double scoreLocal;
  double scoreRemote;
  bool isLocalLight;
  bool didLocalDraw;
  bool didRemoteDraw;

  Connection(this.idEndpoint, this.nameEndpoint);

}