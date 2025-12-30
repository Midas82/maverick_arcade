import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:rxdart/rxdart.dart';

import '../models/task_model.dart';

class TaskRepository {
  final _tasksSubject = BehaviorSubject<List<Task>>.seeded([]);
  Stream<List<Task>> get tasksStream => _tasksSubject.stream;

  List<Task> _globalTasks = [];
  List<Task> _userTasks = [];

  Future<void> init() async {
    await _loadGlobalTasks();
    await _loadUserTasks();
    _emitTasks();
  }

  Future<void> _loadGlobalTasks() async {
    try {
      final jsonString = await rootBundle.loadString('assets/global_tasks.json');
      final List<dynamic> jsonList = json.decode(jsonString);
      _globalTasks = jsonList.map((j) => Task.fromJson(j)).toList();
    } catch (e) {
      print('Error loading global tasks: $e');
      // Fallback or empty
    }
  }

  Future<void> _loadUserTasks() async {
    if (kIsWeb) {
      // On web, user tasks aren't persisted (could use localStorage/SharedPreferences)
      _userTasks = [];
      return;
    }
    try {
      final file = await _getUserFile();
      if (await file.exists()) {
        final jsonString = await file.readAsString();
        final List<dynamic> jsonList = json.decode(jsonString);
        _userTasks = jsonList.map((j) => Task.fromJson(j)).toList();
      }
    } catch (e) {
      print('Error loading user tasks: $e');
    }
  }

  Future<void> addTask(Task task) async {
    _userTasks.add(task);
    await _saveUserTasks();
    _emitTasks();
  }

  Future<void> removeUserTask(String id) async {
    _userTasks.removeWhere((t) => t.id == id);
    await _saveUserTasks();
    _emitTasks();
  }

  Future<void> _saveUserTasks() async {
    if (kIsWeb) {
      // On web, user tasks aren't persisted to file system
      return;
    }
    try {
      final file = await _getUserFile();
      final jsonList = _userTasks.map((t) => t.toJson()).toList();
      await file.writeAsString(json.encode(jsonList));
    } catch (e) {
      print('Error saving user tasks: $e');
    }
  }

  Future<File> _getUserFile() async {
    if (kIsWeb) {
      throw UnsupportedError('File operations not supported on web');
    }
    final directory = await getApplicationDocumentsDirectory();
    return File('${directory.path}/user_tasks.json');
  }

  void _emitTasks() {
    _tasksSubject.add([..._globalTasks, ..._userTasks]);
  }
  
  List<Task> get currentTasks => _tasksSubject.value;
}
