import 'package:equatable/equatable.dart';

import '../../domain/entities/todo.dart';

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