import React, { useState, useEffect } from 'react';
import { View, Text, TouchableOpacity, GestureResponderEvent, StyleSheet, Alert } from 'react-native';
import { Audio } from 'expo-av';

const DUBSTEP_STING = require('../assets/dubstep-sting.wav');
const TASKS_DATA = require('../assets/tasks.json');

interface TaskItem {
  id: string;
  text: string;
}

export default function HomeScreen() {
  const [tasks, setTasks] = useState<TaskItem[]>([]);
  const [currentTask, setCurrentTask] = useState<TaskItem | null>(null);
  const [sound, setSound] = useState<Audio.Sound | null>(null);
  const [isLoading, setIsLoading] = useState(false);
  const [longPressTimer, setLongPressTimer] = useState<NodeJS.Timeout | null>(null);

  useEffect(() => {
    loadTasks();
    return () => {
      if (sound) {
        sound.unloadAsync();
      }
    };
  }, []);

  const loadTasks = () => {
    const taskList = TASKS_DATA.tasks.map((task: string, index: number) => ({
      id: `task-${index}`,
      text: task,
    }));
    setTasks(taskList);
  };

  const playDubstep = async () => {
    try {
      if (sound) {
        await sound.stopAsync();
        await sound.unloadAsync();
      }

      const { sound: newSound } = await Audio.Sound.createAsync(DUBSTEP_STING);
      setSound(newSound);
      await newSound.playAsync();
    } catch (error) {
      console.log('Error playing sound:', error);
    }
  };

  const getRandomTask = () => {
    if (tasks.length === 0) {
      Alert.alert('No Tasks', 'All tasks have been deleted!');
      return null;
    }
    return tasks[Math.floor(Math.random() * tasks.length)];
  };

  const handleMaverickPress = async () => {
    setIsLoading(true);
    try {
      await playDubstep();
      const task = getRandomTask();
      setCurrentTask(task);
    } catch (error) {
      console.log('Error:', error);
    } finally {
      setIsLoading(false);
    }
  };

  const handleTaskPressIn = () => {
    const timer = setTimeout(() => {
      if (currentTask) {
        deleteTask(currentTask.id);
      }
    }, 1000);
    setLongPressTimer(timer);
  };

  const handleTaskPressOut = () => {
    if (longPressTimer) {
      clearTimeout(longPressTimer);
      setLongPressTimer(null);
    }
  };

  const deleteTask = (taskId: string) => {
    const updatedTasks = tasks.filter(t => t.id !== taskId);
    setTasks(updatedTasks);
    setCurrentTask(null);
    Alert.alert('Task Deleted', 'Task removed from the list.');
  };

  return (
    <View style={styles.container}>
      <TouchableOpacity
        style={[styles.button, isLoading && styles.buttonPressed]}
        onPress={handleMaverickPress}
        disabled={isLoading}
      >
        <Text style={styles.buttonText}>MAVERICK</Text>
      </TouchableOpacity>

      {currentTask && (
        <TouchableOpacity
          onPressIn={handleTaskPressIn}
          onPressOut={handleTaskPressOut}
          activeOpacity={0.7}
          style={styles.taskContainer}
        >
          <Text style={styles.taskText}>{currentTask.text}</Text>
          <Text style={styles.taskHint}>Long-press to delete</Text>
        </TouchableOpacity>
      )}

      <Text style={styles.counter}>Tasks remaining: {tasks.length}</Text>
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    backgroundColor: '#0a0a0a',
    padding: 20,
  },
  button: {
    width: 200,
    height: 200,
    borderRadius: 100,
    backgroundColor: '#FF6B35',
    justifyContent: 'center',
    alignItems: 'center',
    shadowColor: '#FF6B35',
    shadowOffset: { width: 0, height: 0 },
    shadowOpacity: 0.8,
    shadowRadius: 20,
    elevation: 15,
    marginBottom: 40,
  },
  buttonPressed: {
    backgroundColor: '#E55A2B',
    shadowOpacity: 0.5,
  },
  buttonText: {
    fontSize: 42,
    fontWeight: 'bold',
    color: '#fff',
    letterSpacing: 2,
  },
  taskContainer: {
    backgroundColor: '#1a1a1a',
    borderRadius: 12,
    padding: 20,
    borderLeftWidth: 4,
    borderLeftColor: '#FF6B35',
    marginTop: 20,
    maxWidth: '90%',
  },
  taskText: {
    fontSize: 20,
    color: '#fff',
    fontWeight: '600',
    marginBottom: 8,
  },
  taskHint: {
    fontSize: 12,
    color: '#888',
    fontStyle: 'italic',
  },
  counter: {
    position: 'absolute',
    bottom: 30,
    fontSize: 14,
    color: '#666',
  },
});
