import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:todo_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:todo_app/features/todo/domain/entities/todo.dart';
import 'package:todo_app/features/todo/domain/repositories/todo_repository.dart';
import 'package:todo_app/features/todo/presentation/bloc/todo_bloc.dart';

// Create mock classes
class MockTodoRepository extends Mock implements TodoRepository {}
class MockAuthRepository extends Mock implements AuthRepository {}
class FakeTodo extends Fake implements Todo {}

void main() {
  late TodoBloc todoBloc;
  late MockTodoRepository mockTodoRepository;
  late MockAuthRepository mockAuthRepository;

  setUpAll(() {
    registerFallbackValue(FakeTodo());
  });

  setUp(() {
    mockTodoRepository = MockTodoRepository();
    mockAuthRepository = MockAuthRepository();
    
    when(() => mockAuthRepository.authStateChanges).thenAnswer(
      (_) => Stream.value(null),
    );
    
    todoBloc = TodoBloc(
      todoRepository: mockTodoRepository,
      authRepository: mockAuthRepository,
    );
  });

  tearDown(() {
    todoBloc.close();
  });

  test('completedCount is 0 when there are no tasks', () async {
    // Arrange - Empty todo list
    when(() => mockTodoRepository.getTodos()).thenAnswer((_) async => []);

    // Act - Load todos
    todoBloc.add(LoadTodos());
    await Future.delayed(const Duration(milliseconds: 100));

    // Assert
    expect(todoBloc.state.completedCount, 0);
    expect(todoBloc.state.totalCount, 0);
    expect(todoBloc.state.todos.isEmpty, true);
  });

  test('completedCount increments when todo is toggled to completed', () async {
    // Arrange - Create a todo list with one incomplete todo
    final todos = [
      Todo(
        id: '1',
        title: 'Buy milk',
        isCompleted: false,
        createdAt: DateTime.now(),
      ),
    ];

    when(() => mockTodoRepository.getTodos()).thenAnswer((_) async => todos);
    when(() => mockTodoRepository.updateTodo(any())).thenAnswer((_) async {});

    // Load initial todos
    todoBloc.add(LoadTodos());
    await Future.delayed(const Duration(milliseconds: 100));

    // Check initial state
    expect(todoBloc.state.completedCount, 0);
    expect(todoBloc.state.totalCount, 1);

    // Act - Toggle the todo to completed
    final completedTodos = [
      todos[0].copyWith(isCompleted: true),
    ];
    when(() => mockTodoRepository.getTodos()).thenAnswer((_) async => completedTodos);

    todoBloc.add(ToggleTodo('1'));
    await Future.delayed(const Duration(milliseconds: 100));

    // Assert - Check if completed count incremented
    expect(todoBloc.state.completedCount, 1);
    expect(todoBloc.state.totalCount, 1);
  });

  test('completedCount correctly counts when multiple todos exist', () async {
    // Arrange - Create multiple todos with different completion states
    final todos = [
      Todo(
        id: '1',
        title: 'Buy milk',
        isCompleted: true,
        createdAt: DateTime.now(),
      ),
      Todo(
        id: '2',
        title: 'Buy eggs',
        isCompleted: false,
        createdAt: DateTime.now(),
      ),
      Todo(
        id: '3',
        title: 'Buy bread',
        isCompleted: true,
        createdAt: DateTime.now(),
      ),
    ];

    when(() => mockTodoRepository.getTodos()).thenAnswer((_) async => todos);

    // Act
    todoBloc.add(LoadTodos());
    await Future.delayed(const Duration(milliseconds: 100));

    // Assert - 2 out of 3 are completed
    expect(todoBloc.state.completedCount, 2);
    expect(todoBloc.state.totalCount, 3);
  });
}