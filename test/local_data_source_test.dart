import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:todo_app/features/todo/data/datasources/local_data_source.dart';
import 'package:todo_app/features/todo/data/models/todo_model.dart';

class MockSharedPreferences extends Mock implements SharedPreferences {}

void main() {
  late LocalDataSourceImpl dataSource;
  late MockSharedPreferences mockSharedPreferences;

  const todosKey = 'todos';

  setUp(() {
    mockSharedPreferences = MockSharedPreferences();
    dataSource = LocalDataSourceImpl(sharedPreferences: mockSharedPreferences);
  });

  group('LocalDataSource - getTodos', () {
    test('returns list of TodoModels when data exists', () async {
      // Arrange
      final testTodos = [
        TodoModel(
          id: '1',
          title: 'Todo 1',
          description: 'Description 1',
          isCompleted: false,
          createdAt: DateTime(2024, 1, 1),
        ),
        TodoModel(
          id: '2',
          title: 'Todo 2',
          description: null,
          isCompleted: true,
          createdAt: DateTime(2024, 1, 2),
        ),
      ];

      final todosJson = json.encode(
        testTodos.map((todo) => todo.toJson()).toList(),
      );

      when(() => mockSharedPreferences.getString(todosKey))
          .thenReturn(todosJson);

      // Act
      final result = await dataSource.getTodos();

      // Assert
      expect(result, isA<List<TodoModel>>());
      expect(result.length, 2);
      expect(result[0].id, '1');
      expect(result[0].title, 'Todo 1');
      expect(result[0].isCompleted, false);
      expect(result[1].id, '2');
      expect(result[1].title, 'Todo 2');
      expect(result[1].isCompleted, true);
      verify(() => mockSharedPreferences.getString(todosKey)).called(1);
    });

    test('returns empty list when no data exists', () async {
      // Arrange
      when(() => mockSharedPreferences.getString(todosKey)).thenReturn(null);

      // Act
      final result = await dataSource.getTodos();

      // Assert
      expect(result, isEmpty);
      expect(result, isA<List<TodoModel>>());
      verify(() => mockSharedPreferences.getString(todosKey)).called(1);
    });

    test('correctly parses todos without description', () async {
      // Arrange
      final testTodos = [
        TodoModel(
          id: '1',
          title: 'Todo without description',
          description: null,
          isCompleted: false,
          createdAt: DateTime(2024, 1, 1),
        ),
      ];

      final todosJson = json.encode(
        testTodos.map((todo) => todo.toJson()).toList(),
      );

      when(() => mockSharedPreferences.getString(todosKey))
          .thenReturn(todosJson);

      // Act
      final result = await dataSource.getTodos();

      // Assert
      expect(result.length, 1);
      expect(result[0].description, null);
    });

    test('handles completed todos correctly', () async {
      // Arrange
      final testTodos = [
        TodoModel(
          id: '1',
          title: 'Completed Todo',
          isCompleted: true,
          createdAt: DateTime(2024, 1, 1),
        ),
      ];

      final todosJson = json.encode(
        testTodos.map((todo) => todo.toJson()).toList(),
      );

      when(() => mockSharedPreferences.getString(todosKey))
          .thenReturn(todosJson);

      // Act
      final result = await dataSource.getTodos();

      // Assert
      expect(result[0].isCompleted, true);
    });

    test('throws exception when JSON is invalid', () async {
      // Arrange
      when(() => mockSharedPreferences.getString(todosKey))
          .thenReturn('invalid json');

      // Act & Assert
      expect(
        () => dataSource.getTodos(),
        throwsA(isA<FormatException>()),
      );
    });
  });

  group('LocalDataSource - saveTodos', () {
    test('successfully saves todos to SharedPreferences', () async {
      // Arrange
      final testTodos = [
        TodoModel(
          id: '1',
          title: 'Todo 1',
          description: 'Description 1',
          isCompleted: false,
          createdAt: DateTime(2024, 1, 1),
        ),
        TodoModel(
          id: '2',
          title: 'Todo 2',
          isCompleted: true,
          createdAt: DateTime(2024, 1, 2),
        ),
      ];

      when(() => mockSharedPreferences.setString(any(), any()))
          .thenAnswer((_) async => true);

      // Act
      await dataSource.saveTodos(testTodos);

      // Assert
      final captured = verify(
        () => mockSharedPreferences.setString(todosKey, captureAny()),
      ).captured;

      expect(captured.length, 1);
      final savedJson = captured[0] as String;
      final decoded = json.decode(savedJson) as List;
      expect(decoded.length, 2);
      expect(decoded[0]['id'], '1');
      expect(decoded[0]['title'], 'Todo 1');
      expect(decoded[1]['id'], '2');
    });

    test('saves empty list successfully', () async {
      // Arrange
      when(() => mockSharedPreferences.setString(any(), any()))
          .thenAnswer((_) async => true);

      // Act
      await dataSource.saveTodos([]);

      // Assert
      final captured = verify(
        () => mockSharedPreferences.setString(todosKey, captureAny()),
      ).captured;

      expect(captured.length, 1);
      final savedJson = captured[0] as String;
      final decoded = json.decode(savedJson) as List;
      expect(decoded, isEmpty);
    });

    test('correctly serializes todos with all fields', () async {
      // Arrange
      final testTodo = TodoModel(
        id: '1',
        title: 'Complete Todo',
        description: 'Full description',
        isCompleted: true,
        createdAt: DateTime(2024, 1, 1),
      );

      when(() => mockSharedPreferences.setString(any(), any()))
          .thenAnswer((_) async => true);

      // Act
      await dataSource.saveTodos([testTodo]);

      // Assert
      final captured = verify(
        () => mockSharedPreferences.setString(todosKey, captureAny()),
      ).captured;

      final savedJson = captured[0] as String;
      final decoded = json.decode(savedJson) as List;
      final savedTodo = decoded[0] as Map<String, dynamic>;

      expect(savedTodo['id'], '1');
      expect(savedTodo['title'], 'Complete Todo');
      expect(savedTodo['description'], 'Full description');
      expect(savedTodo['isCompleted'], true);
      expect(savedTodo['createdAt'], isNotNull);
    });

    test('correctly serializes todos without description', () async {
      // Arrange
      final testTodo = TodoModel(
        id: '1',
        title: 'Todo without description',
        description: null,
        isCompleted: false,
        createdAt: DateTime(2024, 1, 1),
      );

      when(() => mockSharedPreferences.setString(any(), any()))
          .thenAnswer((_) async => true);

      // Act
      await dataSource.saveTodos([testTodo]);

      // Assert
      final captured = verify(
        () => mockSharedPreferences.setString(todosKey, captureAny()),
      ).captured;

      final savedJson = captured[0] as String;
      final decoded = json.decode(savedJson) as List;
      final savedTodo = decoded[0] as Map<String, dynamic>;

      expect(savedTodo.containsKey('description'), true);
      expect(savedTodo['description'], null);
    });

    test('throws exception when save fails', () async {
      // Arrange
      final testTodos = [
        TodoModel(
          id: '1',
          title: 'Todo 1',
          isCompleted: false,
          createdAt: DateTime(2024, 1, 1),
        ),
      ];

      when(() => mockSharedPreferences.setString(any(), any()))
          .thenThrow(Exception('Save failed'));

      // Act & Assert
      expect(
        () => dataSource.saveTodos(testTodos),
        throwsException,
      );
    });
  });

  group('LocalDataSource - clearTodos', () {
    test('successfully clears todos from SharedPreferences', () async {
      // Arrange
      when(() => mockSharedPreferences.remove(todosKey))
          .thenAnswer((_) async => true);

      // Act
      await dataSource.clearTodos();

      // Assert
      verify(() => mockSharedPreferences.remove(todosKey)).called(1);
    });

    test('throws exception when clear fails', () async {
      // Arrange
      when(() => mockSharedPreferences.remove(todosKey))
          .thenThrow(Exception('Clear failed'));

      // Act & Assert
      expect(
        () => dataSource.clearTodos(),
        throwsException,
      );
    });

    test('uses correct key for clearing', () async {
      // Arrange
      when(() => mockSharedPreferences.remove(any()))
          .thenAnswer((_) async => true);

      // Act
      await dataSource.clearTodos();

      // Assert
      verify(() => mockSharedPreferences.remove(todosKey)).called(1);
      verifyNever(() => mockSharedPreferences.remove('wrong_key'));
    });
  });

  group('LocalDataSource - integration scenarios', () {
    test('save and retrieve todos maintains data integrity', () async {
      // Arrange
      final originalTodos = [
        TodoModel(
          id: '1',
          title: 'Todo 1',
          description: 'Description 1',
          isCompleted: false,
          createdAt: DateTime(2024, 1, 1),
        ),
        TodoModel(
          id: '2',
          title: 'Todo 2',
          isCompleted: true,
          createdAt: DateTime(2024, 1, 2),
        ),
      ];

      String? savedData;

      // Mock save
      when(() => mockSharedPreferences.setString(any(), any()))
          .thenAnswer((invocation) async {
        savedData = invocation.positionalArguments[1] as String;
        return true;
      });

      // Mock retrieve
      when(() => mockSharedPreferences.getString(todosKey))
          .thenAnswer((_) => savedData);

      // Act
      await dataSource.saveTodos(originalTodos);
      final retrievedTodos = await dataSource.getTodos();

      // Assert
      expect(retrievedTodos.length, originalTodos.length);
      expect(retrievedTodos[0].id, originalTodos[0].id);
      expect(retrievedTodos[0].title, originalTodos[0].title);
      expect(retrievedTodos[0].description, originalTodos[0].description);
      expect(retrievedTodos[0].isCompleted, originalTodos[0].isCompleted);
      expect(retrievedTodos[1].id, originalTodos[1].id);
    });
  });
}
