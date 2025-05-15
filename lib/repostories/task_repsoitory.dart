import '../models/task_model.dart';
import '../data/database_helper.dart';
import '../data/api_service.dart';
import 'dart:async';

class TaskRepository {
  final DatabaseHelper _databaseHelper = DatabaseHelper();
  final ApiService _apiService = ApiService();
  bool _hasNetwork = true;

  Future<List<Task>> getTasks() async {
    if (_hasNetwork) {
      try {
        List<Task> remoteTasks = await _apiService.fetchTasks();
        await _syncLocalDatabase(remoteTasks);
        return remoteTasks;
      } catch (e) {
        _hasNetwork = false;
        print('Network error: $e. Falling back to local database.');
        return await _databaseHelper.getTasks();
      }
    } else {
      return await _databaseHelper.getTasks();
    }
  }

  Future<Task?> getTask(int id) async {
    if (_hasNetwork) {
      try {
        Task task = await _apiService.fetchTask(id);
        return task;
      } catch (e) {
        _hasNetwork = false;
        print('Network error: $e. Falling back to local database.');
        return await _databaseHelper.getTask(id);
      }
    } else {
      return await _databaseHelper.getTask(id);
    }
  }

  Future<Task> createTask(Task task) async {
    if (_hasNetwork) {
      try {
        Task createdTask = await _apiService.createTask(task);
        await _databaseHelper.insertTask(createdTask);
        return createdTask;
      } catch (e) {
        _hasNetwork = false;
        print('Network error: $e. Saving locally only.');
        int id = await _databaseHelper.insertTask(task);
        return task.copyWith(id: id);
      }
    } else {
      int id = await _databaseHelper.insertTask(task);
      return task.copyWith(id: id);
    }
  }

  Future<Task> updateTask(Task task) async {
    if (_hasNetwork) {
      try {
        Task updatedTask = await _apiService.updateTask(task);
        await _databaseHelper.updateTask(updatedTask);
        return updatedTask;
      } catch (e) {
        _hasNetwork = false;
        print('Network error: $e. Updating locally only.');
        await _databaseHelper.updateTask(task);
        return task;
      }
    } else {
      await _databaseHelper.updateTask(task);
      return task;
    }
  }

  Future<void> deleteTask(int id) async {
    if (_hasNetwork) {
      try {
        await _apiService.deleteTask(id);
        await _databaseHelper.deleteTask(id);
      } catch (e) {
        _hasNetwork = false;
        print('Network error: $e. Deleting locally only.');
        await _databaseHelper.deleteTask(id);
      }
    } else {
      await _databaseHelper.deleteTask(id);
    }
  }

  Future<void> setNetworkStatus(bool hasNetwork) async {
    _hasNetwork = hasNetwork;
    if (hasNetwork) {
      await _syncWithServer();
    }
  }

  Future<void> _syncWithServer() async {
    List<Task> localTasks = await _databaseHelper.getTasks();
    List<Task> remoteTasks = await _apiService.fetchTasks();

    for (var localTask in localTasks) {
      bool exists = remoteTasks.any((task) => task.id == localTask.id);
      if (!exists) {
        await _apiService.createTask(localTask);
      }
    }
  }

  Future<void> _syncLocalDatabase(List<Task> remoteTasks) async {
    for (var remoteTask in remoteTasks) {
      Task? localTask = await _databaseHelper.getTask(remoteTask.id!);
      if (localTask == null) {
        await _databaseHelper.insertTask(remoteTask);
      }
    }
  }
}