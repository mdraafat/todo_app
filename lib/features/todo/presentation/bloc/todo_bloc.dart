import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../auth/domain/repositories/auth_repository.dart';
import '../../domain/entities/todo.dart';
import '../../domain/repositories/todo_repository.dart';

abstract class TodoEvent {}

class LoadTodos extends TodoEvent {}

class AddTodo extends TodoEvent {
  final String title;
  final String? description;

  AddTodo({
    required this.title,
    this.description,
  });
}

class ToggleTodo extends TodoEvent {
  final String id;

  ToggleTodo(this.id);
}

class DeleteTodo extends TodoEvent {
  final String id;

  DeleteTodo(this.id);
}

class UpdateTodo extends TodoEvent {
  final String id;
  final String? title;
  final String? description;

  UpdateTodo({
    required this.id,
    this.title,
    this.description,
  });
}

class TodosUpdated extends TodoEvent {
  final List<Todo> todos;

  TodosUpdated(this.todos);
}

class TodoState extends Equatable {
  final List<Todo> todos;
  final bool isLoading;
  final String? errorMessage;

  const TodoState({
    required this.todos,
    this.isLoading = false,
    this.errorMessage,
  });

  int get completedCount => todos.where((todo) => todo.isCompleted).length;
  int get totalCount => todos.length;

  TodoState copyWith({
    List<Todo>? todos,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
  }) {
    return TodoState(
      todos: todos ?? this.todos,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
  
  @override
  List<Object?> get props => [todos, isLoading, errorMessage];
}

class TodoBloc extends Bloc<TodoEvent, TodoState> {
  final TodoRepository todoRepository;
  final AuthRepository authRepository;
  StreamSubscription? _todosSubscription;
  StreamSubscription? _authSubscription;

  TodoBloc({required this.todoRepository, required this.authRepository})
      : super(TodoState(todos: [])) {
    on<LoadTodos>(_onLoadTodos);
    on<AddTodo>(_onAddTodo);
    on<ToggleTodo>(_onToggleTodo);
    on<DeleteTodo>(_onDeleteTodo);
    on<UpdateTodo>(_onUpdateTodo);
    on<TodosUpdated>(_onTodosUpdated);

    _authSubscription = authRepository.authStateChanges.listen((user) async {
      await _todosSubscription?.cancel();
      _todosSubscription = null;
      
      await Future.delayed(const Duration(milliseconds: 100));
      
      add(LoadTodos());
    });
  }

  Future<void> _onLoadTodos(LoadTodos event, Emitter<TodoState> emit) async {
    emit(state.copyWith(isLoading: true));

    try {
      await _todosSubscription?.cancel();
      _todosSubscription = null;
      
      final todos = await todoRepository.getTodos();
      emit(state.copyWith(todos: todos, isLoading: false));

      _todosSubscription = todoRepository.watchTodos().listen((todos) {
        add(TodosUpdated(todos));
      });
    } catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: 'Failed to load todos'));
    }
  }

  Future<void> _onAddTodo(AddTodo event, Emitter<TodoState> emit) async {
    try {
      final newTodo = Todo(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: event.title,
        description: event.description,
        isCompleted: false,
        createdAt: DateTime.now(),
      );

      await todoRepository.addTodo(newTodo);

      final todos = await todoRepository.getTodos();
      emit(state.copyWith(todos: todos));
    } catch (e) {
      emit(state.copyWith(errorMessage: 'Failed to add todo'));
    }
  }

  Future<void> _onToggleTodo(ToggleTodo event, Emitter<TodoState> emit) async {
    try {
      final todo = state.todos.firstWhere((t) => t.id == event.id);
      final updatedTodo = todo.copyWith(isCompleted: !todo.isCompleted);

      await todoRepository.updateTodo(updatedTodo);

      final todos = await todoRepository.getTodos();
      emit(state.copyWith(todos: todos));
    } catch (e) {
      emit(state.copyWith(errorMessage: 'Failed to update todo'));
    }
  }

  Future<void> _onDeleteTodo(DeleteTodo event, Emitter<TodoState> emit) async {
    try {
      await todoRepository.deleteTodo(event.id);

      final todos = await todoRepository.getTodos();
      emit(state.copyWith(todos: todos));
    } catch (e) {
      emit(state.copyWith(errorMessage: 'Failed to delete todo'));
    }
  }

  Future<void> _onUpdateTodo(UpdateTodo event, Emitter<TodoState> emit) async {
    try {
      final todo = state.todos.firstWhere((t) => t.id == event.id);
      final updatedTodo = todo.copyWith(
        title: event.title,
        description: event.description,
      );

      await todoRepository.updateTodo(updatedTodo);

      final todos = await todoRepository.getTodos();
      emit(state.copyWith(todos: todos));
    } catch (e) {
      emit(state.copyWith(errorMessage: 'Failed to update todo'));
    }
  }

  void _onTodosUpdated(TodosUpdated event, Emitter<TodoState> emit) {
    emit(state.copyWith(todos: event.todos));
  }

  @override
  Future<void> close() {
    _todosSubscription?.cancel();
    _authSubscription?.cancel();
    return super.close();
  }
}