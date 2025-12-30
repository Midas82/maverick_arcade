import 'package:flutter/material.dart';
import '../../data/task_repository.dart';
import '../../models/task_model.dart';

class AddTaskScreen extends StatefulWidget {
  final TaskRepository repository;

  const AddTaskScreen({super.key, required this.repository});

  @override
  State<AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  
  TaskCategory _selectedCategory = TaskCategory.home;
  EnergyLevel _selectedEnergy = EnergyLevel.medium;
  double _duration = 15;

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  void _saveTask() {
    if (_formKey.currentState!.validate()) {
      final newTask = Task(
        title: _titleController.text,
        category: _selectedCategory,
        energyLevel: _selectedEnergy,
        durationMinutes: _duration.round(),
      );

      widget.repository.addTask(newTask);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ADD NEW TASK'),
        backgroundColor: Colors.transparent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Title Input
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Task Title',
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Color(0xFF2C2C2C),
                ),
                style: const TextStyle(color: Colors.white),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Category Dropdown
              DropdownButtonFormField<TaskCategory>(
                value: _selectedCategory,
                decoration: const InputDecoration(
                  labelText: 'Category',
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Color(0xFF2C2C2C),
                ),
                dropdownColor: const Color(0xFF2C2C2C),
                items: TaskCategory.values.map((category) {
                  return DropdownMenuItem(
                    value: category,
                    child: Text(
                      category.name.toUpperCase(),
                      style: const TextStyle(color: Colors.white),
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedCategory = value!;
                  });
                },
              ),
              const SizedBox(height: 20),

              // Energy Level Dropdown
              DropdownButtonFormField<EnergyLevel>(
                value: _selectedEnergy,
                decoration: const InputDecoration(
                  labelText: 'Energy Level',
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Color(0xFF2C2C2C),
                ),
                dropdownColor: const Color(0xFF2C2C2C),
                items: EnergyLevel.values.map((level) {
                  return DropdownMenuItem(
                    value: level,
                    child: Text(
                      level.name.toUpperCase(),
                      style: const TextStyle(color: Colors.white),
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedEnergy = value!;
                  });
                },
              ),
              const SizedBox(height: 20),

              // Duration Slider
              Text(
                'Duration: ${_duration.round()} minutes',
                style: const TextStyle(color: Colors.white, fontSize: 16),
              ),
              Slider(
                value: _duration,
                min: 1,
                max: 120,
                divisions: 119,
                activeColor: Colors.orange,
                label: '${_duration.round()} min',
                onChanged: (value) {
                  setState(() {
                    _duration = value;
                  });
                },
              ),

              const SizedBox(height: 40),

              // Save Button
              SizedBox(
                height: 50,
                child: ElevatedButton(
                  onPressed: _saveTask,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  child: const Text(
                    'CREATE TASK',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
