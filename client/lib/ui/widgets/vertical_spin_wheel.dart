import 'dart:math';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../models/task_model.dart';

class VerticalSpinWheel extends StatefulWidget {
  final List<Task> items;
  final Stream<int> triggerSpin;
  final Function(Task) onSpinComplete;

  const VerticalSpinWheel({
    super.key,
    required this.items,
    required this.triggerSpin,
    required this.onSpinComplete,
  });

  @override
  State<VerticalSpinWheel> createState() => _VerticalSpinWheelState();
}

class _VerticalSpinWheelState extends State<VerticalSpinWheel> {
  late FixedExtentScrollController _controller;
  
  // Audio Pool for individual clicks
  final List<AudioPlayer> _audioPool = [];
  final int _poolSize = 5;
  int _currentPoolIndex = 0;
  
  // Spinning and applause sounds
  late AudioPlayer _spinPlayer;
  late AudioPlayer _applausePlayer;
  
  static const double _itemHeight = 50.0; 
  int _lastItemIndex = 0;
  int _lastSoundTime = 0;

  @override
  void initState() {
    super.initState();
    _controller = FixedExtentScrollController();
    _initAudioPool();
    
    _controller.addListener(_playClickSound);

    widget.triggerSpin.listen((targetIndex) {
      _spinTo(targetIndex);
    });
  }

  Future<void> _initAudioPool() async {
    // Initialize click sound pool
    for (int i = 0; i < _poolSize; i++) {
      final player = AudioPlayer();
      await player.setSource(AssetSource('audio/click.wav'));
      await player.setPlayerMode(PlayerMode.lowLatency);
      _audioPool.add(player);
    }
    
    // Initialize spinning sound (looped)
    _spinPlayer = AudioPlayer();
    await _spinPlayer.setSource(AssetSource('audio/wheel_spin.wav'));
    await _spinPlayer.setReleaseMode(ReleaseMode.loop);
    await _spinPlayer.setPlayerMode(PlayerMode.lowLatency);
    
    // Initialize applause sound
    _applausePlayer = AudioPlayer();
    await _applausePlayer.setSource(AssetSource('audio/applause.wav'));
    await _applausePlayer.setPlayerMode(PlayerMode.lowLatency);
  }

  @override
  void dispose() {
    _controller.removeListener(_playClickSound);
    _controller.dispose();
    for (var player in _audioPool) {
      player.dispose();
    }
    _spinPlayer.dispose();
    _applausePlayer.dispose();
    super.dispose();
  }

  void _playClickSound() {
    if (!_controller.hasClients || _audioPool.isEmpty) return;
    final currentItem = _controller.selectedItem;
    
    // Throttle: Only play sound if index changed AND enough time passed (e.g., 50ms)
    final now = DateTime.now().millisecondsSinceEpoch;
    if (currentItem != _lastItemIndex && (now - _lastSoundTime > 50)) {
      _lastItemIndex = currentItem;
      _lastSoundTime = now;
      
      // Play using next player in pool
      _audioPool[_currentPoolIndex].resume(); // resume() is often faster than play() for preloaded
      _currentPoolIndex = (_currentPoolIndex + 1) % _poolSize;
    }
  }

  void _spinTo(int targetIndex) {
    final currentItem = _controller.selectedItem;
    final listLength = widget.items.length;
    
    final minRevolutions = 10; // Faster/Longer spin
    final randomExtraRevolutions = Random().nextInt(10);
    final totalRevolutions = minRevolutions + randomExtraRevolutions;
    
    final targetScrollIndex = currentItem + (totalRevolutions * listLength) + (targetIndex - (currentItem % listLength));
    
    final finalIndex = targetScrollIndex > currentItem 
        ? targetScrollIndex 
        : targetScrollIndex + listLength;

    // Start the spinning sound
    _spinPlayer.seek(Duration.zero);
    _spinPlayer.play(AssetSource('audio/wheel_spin.wav'));

    _controller.animateToItem(
      finalIndex,
      duration: const Duration(seconds: 6),
      curve: Curves.decelerate,
    ).then((_) {
      // Stop spinning sound and play applause
      _spinPlayer.stop();
      _applausePlayer.seek(Duration.zero);
      _applausePlayer.play(AssetSource('audio/applause.wav'));
      
      HapticFeedback.mediumImpact();
      widget.onSpinComplete(widget.items[targetIndex]);
    });
  }

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      shaderCallback: (Rect bounds) {
        return const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.transparent, Colors.black, Colors.black, Colors.transparent],
          stops: [0.0, 0.2, 0.8, 1.0],
        ).createShader(bounds);
      },
      blendMode: BlendMode.dstIn,
      child: ListWheelScrollView.useDelegate(
        controller: _controller,
        itemExtent: _itemHeight,
        perspective: 0.002, // Slightly flatter perspective for "further away" feel
        diameterRatio: 1.5,
        physics: const FixedExtentScrollPhysics(),
        childDelegate: ListWheelChildLoopingListDelegate(
          children: widget.items.asMap().entries.map((entry) {
            final index = entry.key;
            final task = entry.value;
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 40, vertical: 2), // Thinner width too
              decoration: BoxDecoration(
                // Varied colors: Base category color + slight random/index variation
                color: _getVariedColor(task.category, index),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.white.withOpacity(0.2), width: 1),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.5),
                    blurRadius: 2,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  task.title,
                  style: const TextStyle(
                    fontSize: 16, // Smaller font for thinner items
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    shadows: [Shadow(color: Colors.black, blurRadius: 2)],
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Color _getVariedColor(TaskCategory category, int index) {
    // Base colors
    Color base;
    switch (category) {
      case TaskCategory.home: base = Colors.blue; break;
      case TaskCategory.self: base = Colors.green; break;
      case TaskCategory.creative: base = Colors.purple; break;
      case TaskCategory.experiments: base = Colors.amber; break;
      case TaskCategory.fixIt: base = Colors.red; break;
      default: base = Colors.grey;
    }

    // Add variation based on index to make it look "varied" even within categories
    // We shift the hue slightly or change shade
    final hsl = HSLColor.fromColor(base);
    final hueShift = (index * 13.0) % 40 - 20; // +/- 20 degrees hue shift
    final lightnessShift = ((index % 3) * 0.1) - 0.05; // Slight lightness variation

    return hsl.withHue((hsl.hue + hueShift) % 360).withLightness((hsl.lightness + lightnessShift).clamp(0.2, 0.8)).toColor();
  }
}
