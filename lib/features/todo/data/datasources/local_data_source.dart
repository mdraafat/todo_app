import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/todo_model.dart';

abstract class LocalDataSource {
  Future<List<TodoModel>> getTodos();
  Future<void> saveTodos(List<TodoModel> todos);
  Future<void> clearTodos();
}

class LocalDataSourceImpl implements LocalDataSource {
  static const String _todosKey = 'todos';
  final SharedPreferences sharedPreferences;

  LocalDataSourceImpl({required this.sharedPreferences});

  @override
  Future<List<TodoModel>> getTodos() async {
    final todosJson = sharedPreferences.getString(_todosKey);
    if (todosJson == null) return [];

    final List<dynamic> decoded = json.decode(todosJson);
    return decoded.map((json) => TodoModel.fromJson(json)).toList();
  }

  @override
  Future<void> saveTodos(List<TodoModel> todos) async {
    final todosJson = json.encode(todos.map((todo) => todo.toJson()).toList());
    await sharedPreferences.setString(_todosKey, todosJson);
  }

  @override
  Future<void> clearTodos() async {
    await sharedPreferences.remove(_todosKey);
  }
}
