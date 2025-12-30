import 'package:flutter/material.dart';
import 'data/task_repository.dart';
import 'logic/game_engine.dart';
import 'ui/screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  final repository = TaskRepository();
  await repository.init();
  
  final gameEngine = GameEngine(repository);

  runApp(MaverickApp(
    repository: repository,
    gameEngine: gameEngine,
  ));
}

class MaverickApp extends StatelessWidget {
  final TaskRepository repository;
  final GameEngine gameEngine;

  const MaverickApp({
    super.key,
    required this.repository,
    required this.gameEngine,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Maverick Arcade',
      theme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.orange,
        scaffoldBackgroundColor: const Color(0xFF1A1A1A),
        useMaterial3: true,
        fontFamily: 'Roboto', // Default, but good to be explicit
      ),
      home: HomeScreen(
        repository: repository,
        gameEngine: gameEngine,
      ),
    );
  }
}
