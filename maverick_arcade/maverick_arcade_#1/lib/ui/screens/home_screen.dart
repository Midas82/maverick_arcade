import 'dart:async';
import 'dart:math';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';

import '../../data/task_repository.dart';
import '../../logic/game_engine.dart';
import '../../models/task_model.dart';
import '../widgets/vertical_spin_wheel.dart';
import 'add_task_screen.dart';

class HomeScreen extends StatefulWidget {
  final TaskRepository repository;
  final GameEngine gameEngine;

  const HomeScreen({
    super.key,
    required this.repository,
    required this.gameEngine,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  StreamController<int> selectedController = StreamController<int>();
  VibeMode currentVibe = VibeMode.chaos;
  final AudioPlayer audioPlayer = AudioPlayer();
  bool isSpinning = false;

  @override
  void dispose() {
    selectedController.close();
    audioPlayer.dispose();
    super.dispose();
  }

  void _spinWheel(List<Task> pool) {
    if (isSpinning || pool.isEmpty) return;

    setState(() {
      isSpinning = true;
    });

    // 1. Select random index
    final randomIndex = Random().nextInt(pool.length);
    selectedController.add(randomIndex);

    // 2. Play Sound (if available)
    // audioPlayer.play(AssetSource('audio/dubstep_sting.wav')); 

    // 3. The VerticalSpinWheel widget listens to the stream and handles the animation/callback
  }

  void _showResult(Task task) {
    audioPlayer.play(AssetSource('audio/win.wav'));
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2C2C2C),
        title: const Text('🎯 MISSION ACQUIRED', style: TextStyle(color: Colors.orange)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              task.title,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Chip(
              label: Text('${task.durationMinutes} min'),
              backgroundColor: Colors.grey[800],
              labelStyle: const TextStyle(color: Colors.white),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('ACCEPT', style: TextStyle(color: Colors.green)),
          ),
          TextButton(
            onPressed: () {
              // Reroll logic could go here
              Navigator.pop(context);
            },
            child: const Text('DEFER', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('MAVERICK ARCADE'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddTaskScreen(repository: widget.repository),
                ),
              );
            },
          ),

        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/background.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          children: [
            // Vibe Selector
            SizedBox(
              height: 60,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
              children: VibeMode.values.map((mode) {
                final isSelected = currentVibe == mode;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(mode.name.toUpperCase()),
                    selected: isSelected,
                    onSelected: (selected) {
                      if (selected) {
                        setState(() {
                          currentVibe = mode;
                        });
                      }
                    },
                    selectedColor: Colors.orange,
                    backgroundColor: Colors.grey[800],
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.black : Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          
          const SizedBox(height: 20),

          // Wheel Area
          Expanded(
            child: StreamBuilder<List<Task>>(
              stream: widget.repository.tasksStream,
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                
                // Filter tasks based on Vibe
                final pool = widget.gameEngine.filterTasks(currentVibe);

                if (pool.isEmpty) {
                  return const Center(
                    child: Text(
                      'No tasks match this Vibe!\nAdd some or switch modes.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey),
                    ),
                  );
                }

                return VerticalSpinWheel(
                  items: pool,
                  triggerSpin: selectedController.stream,
                  onSpinComplete: (task) {
                    if (mounted) {
                      setState(() {
                        isSpinning = false;
                      });
                      _showResult(task);
                    }
                  },
                );
              },
            ),
          ),

          // Spin Button
          Padding(
            padding: const EdgeInsets.all(32.0),
            child: SizedBox(
              width: double.infinity,
              height: 60,
              child: ElevatedButton(
                onPressed: isSpinning ? null : () {
                  final pool = widget.gameEngine.filterTasks(currentVibe);
                  _spinWheel(pool);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF6B35), // Maverick Orange
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: Text(
                  isSpinning ? 'SPINNING...' : 'SPIN THE WHEEL',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 1.5,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      ),
    );
  }

  Color _getColorForCategory(TaskCategory category) {
    switch (category) {
      case TaskCategory.home: return Colors.blueAccent;
      case TaskCategory.self: return Colors.greenAccent;
      case TaskCategory.creative: return Colors.purpleAccent;
      case TaskCategory.experiments: return Colors.yellowAccent;
      case TaskCategory.fixIt: return Colors.redAccent;
      default: return Colors.grey;
    }
  }
}
