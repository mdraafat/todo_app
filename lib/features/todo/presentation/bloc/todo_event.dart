import '../../domain/entities/todo.dart';

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