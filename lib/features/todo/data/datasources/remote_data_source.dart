import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/todo_model.dart';

abstract class RemoteDataSource {
  Future<List<TodoModel>> getTodos(String userId);
  Future<void> addTodo(String userId, TodoModel todo);
  Future<void> updateTodo(String userId, TodoModel todo);
  Future<void> deleteTodo(String userId, String todoId);
  Stream<List<TodoModel>> watchTodos(String userId);
}

class RemoteDataSourceImpl implements RemoteDataSource {
  final FirebaseFirestore firestore;

  RemoteDataSourceImpl({required this.firestore});

  CollectionReference _todosCollection(String userId) {
    return firestore.collection('users').doc(userId).collection('todos');
  }

  @override
  Future<List<TodoModel>> getTodos(String userId) async {
    final snapshot = await _todosCollection(userId).get();
    return snapshot.docs
        .map((doc) => TodoModel.fromJson({...doc.data() as Map<String, dynamic>, 'id': doc.id}))
        .toList();
  }

  @override
  Future<void> addTodo(String userId, TodoModel todo) async {
    await _todosCollection(userId).doc(todo.id).set(todo.toJson());
  }

  @override
  Future<void> updateTodo(String userId, TodoModel todo) async {
    await _todosCollection(userId).doc(todo.id).update(todo.toJson());
  }

  @override
  Future<void> deleteTodo(String userId, String todoId) async {
    await _todosCollection(userId).doc(todoId).delete();
  }

  @override
  Stream<List<TodoModel>> watchTodos(String userId) {
    return _todosCollection(userId).snapshots().map(
          (snapshot) => snapshot.docs
              .map((doc) => TodoModel.fromJson({...doc.data() as Map<String, dynamic>, 'id': doc.id}))
              .toList(),
        );
  }
}