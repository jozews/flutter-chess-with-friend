
import 'dart:async';


class MoveTimer {

  double timestampStarted;
  double timestampEnded;

  MoveTimer(this.timestampStarted, this.timestampEnded);

  double get duration => timestampEnded - timestampStarted;
}


class Timer {

  double timeTotal;

  double incrementOnStart;
  double incrementOnEnd;

  Timer({this.timeTotal = 500.0, this.incrementOnStart = 0.0, this.incrementOnEnd = 0.0}) {
    timeLight = timeTotal;
    timeDark = timeTotal;
  }

  double timeLight;
  double timeDark;

  List<MoveTimer> moves = [];
  double timestampStart;

  var streamController = StreamController();

  var millisecondsTickPrecision = 10;

  double get timestampNow => DateTime.now().millisecondsSinceEpoch/1000.0;
  bool get isLightTicking => moves.length % 2 == 0;
  double get timeOfTicking => isLightTicking ? timeLight : timeDark;


  getTime(bool isLight) {
    return isLight ? timeLight : timeDark;
  }

  setTime(bool isLight, double time) {
    if (isLight) {
      timeLight = time;
    }
    else {
      timeDark = time;
    }
  }

  tick() async {
    while (true) {
      await Future.delayed(Duration(milliseconds: millisecondsTickPrecision));
      if (timestampStart != null) {
        setTime(isLightTicking, (timestampNow - timestampStart));
        streamController.add(true);
      }
    }
  }

  addTimestampStart({double timestamp}) {
    timestampStart = timestamp ?? timestampNow;
    // increment
    var timeIncremented = getTime(isLightTicking) + incrementOnStart;
    setTime(isLightTicking, timeIncremented);
  }

  addTimestampEnd({double timestamp}) {
    // increment
    var timeIncremented = getTime(isLightTicking) + incrementOnEnd;
    setTime(isLightTicking, timeIncremented);
    // add move
    var move = MoveTimer(timestampStart, timestamp ?? timestampNow);
    moves.add(move);
    timestampStart = null;
  }

  Stream startTicking() {
    tick();
    return streamController.stream;
  }
}