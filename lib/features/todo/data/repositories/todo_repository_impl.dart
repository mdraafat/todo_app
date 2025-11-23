import '../../../auth/domain/repositories/auth_repository.dart';
import '../../domain/entities/todo.dart';
import '../../domain/repositories/todo_repository.dart';
import '../datasources/local_data_source.dart';
import '../datasources/remote_data_source.dart';
import '../models/todo_model.dart';

class TodoRepositoryImpl implements TodoRepository {
  final LocalDataSource localDataSource;
  final RemoteDataSource remoteDataSource;
  final AuthRepository authRepository;

  TodoRepositoryImpl({
    required this.localDataSource,
    required this.remoteDataSource,
    required this.authRepository,
  });

  @override
  Future<List<Todo>> getTodos() async {
    final user = authRepository.currentUser;
    
    if (user != null) {
      
      final todos = await remoteDataSource.getTodos(user.id);
      return todos.map((model) => model.toEntity()).toList();
    } else {
      
      final todos = await localDataSource.getTodos();
      return todos.map((model) => model.toEntity()).toList();
    }
  }

  @override
  Future<void> addTodo(Todo todo) async {
    final user = authRepository.currentUser;
    final todoModel = TodoModel.fromEntity(todo);
    
    if (user != null) {
      await remoteDataSource.addTodo(user.id, todoModel);
    } else {
      final currentTodos = await localDataSource.getTodos();
      await localDataSource.saveTodos([...currentTodos, todoModel]);
    }
  }

  @override
  Future<void> updateTodo(Todo todo) async {
    final user = authRepository.currentUser;
    final todoModel = TodoModel.fromEntity(todo);
    
    if (user != null) {
      await remoteDataSource.updateTodo(user.id, todoModel);
    } else {
      final currentTodos = await localDataSource.getTodos();
      final updatedTodos = currentTodos.map((t) {
        return t.id == todo.id ? todoModel : t;
      }).toList();
      await localDataSource.saveTodos(updatedTodos);
    }
  }

  @override
  Future<void> deleteTodo(String id) async {
    final user = authRepository.currentUser;
    
    if (user != null) {
      await remoteDataSource.deleteTodo(user.id, id);
    } else {
      final currentTodos = await localDataSource.getTodos();
      final filteredTodos = currentTodos.where((t) => t.id != id).toList();
      await localDataSource.saveTodos(filteredTodos);
    }
  }

  @override
  Stream<List<Todo>> watchTodos() {
    final user = authRepository.currentUser;
    
    if (user != null) {
      return remoteDataSource.watchTodos(user.id).map(
        (todos) => todos.map((model) => model.toEntity()).toList(),
      );
    } else {
      
      
      return Stream.value([]).asyncExpand((_) async* {
        final todos = await localDataSource.getTodos();
        yield todos.map((model) => model.toEntity()).toList();
      });
    }
  }

  
  Future<void> syncLocalTodosToCloud(String userId) async {
    final localTodos = await localDataSource.getTodos();
    
    for (final todo in localTodos) {
      await remoteDataSource.addTodo(userId, todo);
    }
    
    
    await localDataSource.clearTodos();
  }
}