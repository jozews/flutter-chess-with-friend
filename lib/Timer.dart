
import 'dart:async';
import 'dart:math';

class MoveTimer {

  double timestampStarted;
  double timestampEnded;

  MoveTimer(this.timestampStarted, this.timestampEnded);

  double get duration => timestampEnded - timestampStarted;
}

enum ControlTimer {
  min3, min5, min10
}

class Timer {

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
      case ControlTimer.min3:
        timeTotal = 3*60.0;
        incrementOnStart = 0.0;
        incrementOnEnd = 0.0;
        break;
      case ControlTimer.min5:
        timeTotal = 5*60.0;
        incrementOnStart = 0.0;
        incrementOnEnd = 0.0;
        break;
      case ControlTimer.min10:
        timeTotal = 10*60.0;
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

  var millisecondsTickPrecision = 50;

  double get timestampNow => DateTime.now().millisecondsSinceEpoch/1000.0;
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
    while (true) {
      await Future.delayed(Duration(milliseconds: millisecondsTickPrecision));
      if (timestampStart != null) {
        var timeUpdated = timeOnStart - (timestampNow - timestampStart);
        var timeUpdatedMaxed = max(0.0, timeUpdated);

        if (!stopped && timeUpdatedMaxed.ceil() != getTime(isLightTicking).ceil()) {
          setTime(isLightTicking, timeUpdatedMaxed);
          streamController.add(timeUpdatedMaxed);
        }
        if (stopped || timeUpdatedMaxed == 0.0) {
          stop();
          break;
        }
      }
    }
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
    var timeIncremented = timeOfTicking + incrementOnEnd;
    setTime(isLightTicking, timeIncremented);
    // add move
    var move = MoveTimer(timestampStart, timestampEnd);
    moves.add(move);
    // stop tick
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