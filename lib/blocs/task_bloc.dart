import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../models/task_model.dart';
import '../repostories/task_repsoitory.dart';

// Events
abstract class TaskEvent {}

class FetchTasks extends TaskEvent {}

class AddTask extends TaskEvent {
  final Task task;
  AddTask(this.task);
}

class UpdateTask extends TaskEvent {
  final Task task;
  UpdateTask(this.task);
}

class DeleteTask extends TaskEvent {
  final int id;
  DeleteTask(this.id);
}

class ToggleTaskCompletion extends TaskEvent {
  final Task task;
  ToggleTaskCompletion(this.task);
}

// States
abstract class TaskState {}

class TaskInitial extends TaskState {}

class TaskLoading extends TaskState {}

class TasksLoaded extends TaskState {
  final List<Task> tasks;
  TasksLoaded(this.tasks);
}

class TaskOperationSuccess extends TaskState {
  final String message;
  TaskOperationSuccess(this.message);
}

class TaskError extends TaskState {
  final String message;
  TaskError(this.message);
}

// BLoC
class TaskBloc extends Bloc<TaskEvent, TaskState> {
  final TaskRepository _taskRepository;
  late StreamSubscription _connectivitySubscription;

  TaskBloc(this._taskRepository) : super(TaskInitial()) {
    on<FetchTasks>(_onFetchTasks);
    on<AddTask>(_onAddTask);
    on<UpdateTask>(_onUpdateTask);
    on<DeleteTask>(_onDeleteTask);
    on<ToggleTaskCompletion>(_onToggleTaskCompletion);

    // Monitor connectivity changes
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen((result) {
      bool hasNetwork = result != ConnectivityResult.none;
      _taskRepository.setNetworkStatus(hasNetwork);
      if (hasNetwork) {
        add(FetchTasks());
      }
    });
  }

  Future<void> _onFetchTasks(FetchTasks event, Emitter<TaskState> emit) async {
    emit(TaskLoading());
    try {
      final tasks = await _taskRepository.getTasks();
      emit(TasksLoaded(tasks));
    } catch (e) {
      emit(TaskError('Failed to fetch tasks: ${e.toString()}'));
    }
  }

  Future<void> _onAddTask(AddTask event, Emitter<TaskState> emit) async {
    emit(TaskLoading());
    try {
      await _taskRepository.createTask(event.task);
      emit(TaskOperationSuccess('Task added successfully'));
      add(FetchTasks());
    } catch (e) {
      emit(TaskError('Failed to add task: ${e.toString()}'));
    }
  }

  Future<void> _onUpdateTask(UpdateTask event, Emitter<TaskState> emit) async {
    emit(TaskLoading());
    try {
      await _taskRepository.updateTask(event.task);
      emit(TaskOperationSuccess('Task updated successfully'));
      add(FetchTasks());
    } catch (e) {
      emit(TaskError('Failed to update task: ${e.toString()}'));
    }
  }

  Future<void> _onDeleteTask(DeleteTask event, Emitter<TaskState> emit) async {
    emit(TaskLoading());
    try {
      await _taskRepository.deleteTask(event.id);
      emit(TaskOperationSuccess('Task deleted successfully'));
      add(FetchTasks());
    } catch (e) {
      emit(TaskError('Failed to delete task: ${e.toString()}'));
    }
  }

  Future<void> _onToggleTaskCompletion(ToggleTaskCompletion event, Emitter<TaskState> emit) async {
    emit(TaskLoading());
    try {
      final updatedTask = event.task.copyWith(isCompleted: !event.task.isCompleted);
      await _taskRepository.updateTask(updatedTask);
      emit(TaskOperationSuccess('Task status updated'));
      add(FetchTasks());
    } catch (e) {
      emit(TaskError('Failed to update task status: ${e.toString()}'));
    }
  }

  @override
  Future<void> close() {
    _connectivitySubscription.cancel();
    return super.close();
  }
}