import 'dart:async';
import 'package:flutter_drum_machine_demo/services/sampler.dart';

enum ControlState { READY, PLAY, RECORD }

class Event {
  const Event();
}

class TickEvent extends Event {}

class ControlEvent extends Event {
  const ControlEvent(this.state);
  final ControlState state;
}

class PadEvent extends Event {
  const PadEvent(this.sample);
  final DrumSample sample;
}

class EditEvent extends Event {
  const EditEvent(this.sample, this.position);
  final DrumSample sample;
  final int position;
}

class Signal {}

abstract class AudioEngine {
  // Each pattern has eight steps
  static const int _resolution = 8;
  static int step = 0;

  // Engine control current state
  static ControlState _state = ControlState.READY;
  static get state => _state;

  // Beats per minute
  static int _bpm = 120;
  static int get bpm => _bpm;
  static set bpm(int x) {
    _bpm = x;
    if (_state != ControlState.READY) {
      synchronize();
    }
    _signal.add(Signal());
  }

  // Generates a new blank track data structure
  static Map<DrumSample, List<bool>> get _blanktape =>
      Map.fromIterable(DrumSample.values,
          key: (k) => k,
          value: (v) => List.generate(_resolution, (i) => false));

  // Track note on/off data
  static Map<DrumSample, List<bool>> _trackdata = _blanktape;
  static Map<DrumSample, List<bool>> get trackdata => _trackdata;

  // Timer tick duration
  static Duration get _tick =>
      Duration(milliseconds: (60000 / bpm / 2).round());
  static Stopwatch _watch = Stopwatch();
  static Timer? _timer;

  // Outbound signal driver - allows widgets to listen for signals from audio engine
  static StreamController<Signal> _signal =
      StreamController<Signal>.broadcast();
  static Future<void> close() =>
      _signal.close(); // Not used but required by SDK
  static StreamSubscription<Signal> listen(Function(Signal) onData) =>
      _signal.stream.listen(onData);

  // Incoming event handler
  static void on<T extends Event>(Event event) {
    switch (T) {
      case PadEvent:
        if (state == ControlState.RECORD) {
          return processInput(event as PadEvent);
        }
        Sampler.play((event as PadEvent).sample);
        return;

      case TickEvent:
        if (state == ControlState.READY) {
          return;
        }
        return next();

      case EditEvent:
        return edit(event as EditEvent);

      case ControlEvent:
        return control(event as ControlEvent);
    }
  }

  // Controller state change handler
  static control(ControlEvent event) {
    switch (event.state) {
      case ControlState.PLAY:
      case ControlState.RECORD:
        if (state == ControlState.READY) {
          start();
        }
        break;

      case ControlState.READY:
      default:
        reset();
    }

    _state = event.state;
    _signal.add(Signal());
  }

  // Note block edit event handler
  static void edit(EditEvent event) {
    trackdata[event.sample]![event.position] =
        !trackdata[event.sample]![event.position];
    if (trackdata[event.sample]![event.position]) {
      Sampler.play(event.sample);
    }
    _signal.add(Signal());
  }

  // Quantize input using the stopwatch
  static void processInput(PadEvent event) {
    int position = (_watch.elapsedMilliseconds < 900)
        ? step
        : (step != 7)
            ? step + 1
            : 0;
    edit(EditEvent(event.sample, position));
  }

  // Reset the engine
  static void reset() {
    step = 0;
    _watch.reset();
    if (_timer != null) {
      _timer!.cancel();
    }
  }

  // Start the sequencer
  static void start() {
    reset();
    _watch.start();
    _timer = Timer.periodic(_tick, (t) => on<TickEvent>(TickEvent()));
  }

  // Process the next step
  static void next() {
    step = (step == 7) ? 0 : step + 1;
    _watch.reset();

    trackdata.forEach((DrumSample sample, List<bool> track) {
      if (track[step]) {
        Sampler.play(sample);
      }
    });

    _watch.start();
    _signal.add(Signal());
  }

  static void synchronize() {
    _watch.stop();
    _timer?.cancel();

    _watch.start();
    _timer = Timer.periodic(_tick, (t) => on<TickEvent>(TickEvent()));
  }
}
