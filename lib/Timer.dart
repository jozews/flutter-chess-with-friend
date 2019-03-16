
import 'dart:async';
import 'dart:math';

class MoveTimer {

  double timestampStarted;
  double timestampEnded;

  MoveTimer(this.timestampStarted, this.timestampEnded);

  double get duration => timestampEnded - timestampStarted;
}

enum ControlTimer {
  min1, min1plus1, min3, min3plus2, min5, min5plus2, min10, min15
}

class Timer {

  static double get timestampNow => DateTime.now().millisecondsSinceEpoch/1000.0;

  double timeTotal;

  double incrementOnStart;
  double incrementOnEnd;

  ControlTimer control;

  Timer({this.timeTotal = 500.0, this.incrementOnStart = 0.0, this.incrementOnEnd = 0.0}) {
    timeLight = timeTotal;
    timeDark = timeTotal;
  }

  Timer.control(this.control) {
    switch (control) {
      case ControlTimer.min1:
        timeTotal = 1*60.0;
        incrementOnStart = 0.0;
        incrementOnEnd = 0.0;
        break;
      case ControlTimer.min1plus1:
        timeTotal = 1*60.0;
        incrementOnStart = 0.0;
        incrementOnEnd = 1.0;
        break;
      case ControlTimer.min3:
        timeTotal = 3*60.0;
        incrementOnStart = 0.0;
        incrementOnEnd = 0.0;
        break;
      case ControlTimer.min3plus2:
        timeTotal = 3*60.0;
        incrementOnStart = 0.0;
        incrementOnEnd = 2.0;
        break;
      case ControlTimer.min5:
        timeTotal = 5*60.0;
        incrementOnStart = 0.0;
        incrementOnEnd = 0.0;
        break;
      case ControlTimer.min5plus2:
        timeTotal = 5*60.0;
        incrementOnStart = 0.0;
        incrementOnEnd = 2.0;
        break;
      case ControlTimer.min10:
        timeTotal = 10*60.0;
        incrementOnStart = 0.0;
        incrementOnEnd = 0.0;
        break;
      case ControlTimer.min15:
        timeTotal = 15*60.0;
        incrementOnStart = 0.0;
        incrementOnEnd = 0.0;
        break;
    }
    timeLight = timeTotal;
    timeDark = timeTotal;
  }

  double timestampStart;
  double timeOnStart;

  double timeLight;
  double timeDark;

  List<MoveTimer> moves = [];

  var streamController = StreamController();

  var stopped = false;

  var millisecondsTickPrecision = 10;

  bool get isLightTicking => moves.length % 2 == 0;
  double get timeOfTicking => getTime(isLightTicking);

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

    if (timestampStart != null) {

      var timeUpdated = timeOnStart - (timestampNow - timestampStart);
      var timeUpdatedFloored = timeUpdated.floor();

      if (!stopped && timeUpdatedFloored != getTime(isLightTicking).floor()) {
        setTime(isLightTicking, timeUpdated);
        streamController.add(timeUpdatedFloored);
      }
    }

    await Future.delayed(Duration(milliseconds: millisecondsTickPrecision));

    if (stopped) {
      return;
    }

    tick();
  }

  addTimestampStart({double timestamp}) {
    // increment
    var timeIncremented = timeOfTicking + incrementOnStart;
    setTime(isLightTicking, timeIncremented);
    // tick
    timestampStart = timestamp ?? timestampNow;
    timeOnStart = timeOfTicking;
  }

  addTimestampEnd({double timestamp}) {

    var timestampEnd = timestamp ?? timestampNow;

    // update
    var timeUpdated = timeOnStart - (timestampNow - timestampStart);
    var timeUpdatedMaxed = max(0.0, timeUpdated);

    var timeIncremented = timeUpdatedMaxed + incrementOnEnd;
    setTime(isLightTicking, timeIncremented);
    streamController.add(timeIncremented);

    // add move
    var move = MoveTimer(timestampStart, timestampEnd);
    moves.add(move);

    // halt tick
    timestampStart = null;
  }

  Stream start() {
    stopped = false;
    tick();
    return streamController.stream;
  }

  stop() {
    stopped = true;
    streamController.close();
  }
}