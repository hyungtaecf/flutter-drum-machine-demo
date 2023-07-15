// import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';

enum DrumSample { KICK, SNARE, HAT, TOM1, TOM2, CRASH }

abstract class Sampler {
  static String _ext = '.wav';

  static Map<DrumSample, String> samples = const {
    DrumSample.KICK: 'kick',
    DrumSample.SNARE: 'snare',
    DrumSample.HAT: 'hat',
    DrumSample.TOM1: 'tom1',
    DrumSample.TOM2: 'tom2',
    DrumSample.CRASH: 'crash'
  };

  static List<Color> colors = [
    Colors.red,
    Colors.amber,
    Colors.purple,
    Colors.blue,
    Colors.cyan,
    Colors.pink,
  ];

//   static List<String> _files = List.generate(
//       samples.length, (i) => samples[DrumSample.values[i]]! + _ext);

  static AudioPlayer _player = AudioPlayer();
//   static AudioCache _cache = AudioCache(respectSilence: true);

//   static Future<void> init() => _player.loadAll(_files);

  static void play(DrumSample sample) => _player
      .play(AssetSource(samples[sample]! + _ext), mode: PlayerMode.lowLatency);
}
