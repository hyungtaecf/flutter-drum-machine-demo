import 'package:flutter/material.dart';
import 'package:flutter_drum_machine_demo/services/audio-engine.dart';
import 'package:flutter_drum_machine_demo/services/sampler.dart';

class Pad extends StatelessWidget {
  Pad({required this.height, required this.width, required this.value});

  final double height;
  final double width;
  final int value;

  DrumSample get _sample => DrumSample.values[value];
  String get _name => Sampler.samples[_sample]!;
  Color get _color => Sampler.colors[_sample.index];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        height: height * .82,
        width: width * .88,
        child: Container(
            alignment: Alignment.center,
            decoration: BoxDecoration(
                border: Border.all(color: _color),
                borderRadius: BorderRadius.all(Radius.circular(4)),
                color: _color.withOpacity(0.12)),
            child: SizedBox.expand(
                child: InkWell(
              enableFeedback: false,
              onTap: () => AudioEngine.on<PadEvent>(PadEvent(_sample)),
              child: Center(child: Text(_name)),
            ))));
  }
}
