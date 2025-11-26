import 'package:flutter_test/flutter_test.dart';
import 'package:todo_app/features/todo/domain/entities/todo.dart';
import 'package:todo_app/features/todo/presentation/bloc/todo_state.dart';

void main() {
  group('TodoState', () {
    test('creates TodoState with empty todos', () {
      const state = TodoState(todos: []);

      expect(state.todos, isEmpty);
      expect(state.isLoading, false);
      expect(state.errorMessage, null);
    });

    test('creates TodoState with loading state', () {
      const state = TodoState(todos: [], isLoading: true);

      expect(state.isLoading, true);
    });

    test('creates TodoState with error message', () {
      const state = TodoState(
        todos: [],
        errorMessage: 'Failed to load',
      );

      expect(state.errorMessage, 'Failed to load');
    });

    test('completedCount returns correct count', () {
      final state = TodoState(
        todos: [
          Todo(
            id: '1',
            title: 'Todo 1',
            isCompleted: true,
            createdAt: DateTime.now(),
          ),
          Todo(
            id: '2',
            title: 'Todo 2',
            isCompleted: false,
            createdAt: DateTime.now(),
          ),
          Todo(
            id: '3',
            title: 'Todo 3',
            isCompleted: true,
            createdAt: DateTime.now(),
          ),
        ],
      );

      expect(state.completedCount, 2);
    });

    test('completedCount is 0 when no todos are completed', () {
      final state = TodoState(
        todos: [
          Todo(
            id: '1',
            title: 'Todo 1',
            isCompleted: false,
            createdAt: DateTime.now(),
          ),
          Todo(
            id: '2',
            title: 'Todo 2',
            isCompleted: false,
            createdAt: DateTime.now(),
          ),
        ],
      );

      expect(state.completedCount, 0);
    });

    test('totalCount returns correct count', () {
      final state = TodoState(
        todos: [
          Todo(
            id: '1',
            title: 'Todo 1',
            isCompleted: true,
            createdAt: DateTime.now(),
          ),
          Todo(
            id: '2',
            title: 'Todo 2',
            isCompleted: false,
            createdAt: DateTime.now(),
          ),
        ],
      );

      expect(state.totalCount, 2);
    });

    test('totalCount is 0 for empty list', () {
      const state = TodoState(todos: []);

      expect(state.totalCount, 0);
    });

    test('copyWith creates new state with updated todos', () {
      const initialState = TodoState(todos: []);
      final newTodos = [
        Todo(
          id: '1',
          title: 'Todo 1',
          isCompleted: false,
          createdAt: DateTime.now(),
        ),
      ];

      final newState = initialState.copyWith(todos: newTodos);

      expect(newState.todos, equals(newTodos));
      expect(newState.isLoading, initialState.isLoading);
    });

    test('copyWith updates isLoading', () {
      const initialState = TodoState(todos: [], isLoading: false);

      final newState = initialState.copyWith(isLoading: true);

      expect(newState.isLoading, true);
    });

    test('copyWith updates errorMessage', () {
      const initialState = TodoState(todos: []);

      final newState = initialState.copyWith(errorMessage: 'Error occurred');

      expect(newState.errorMessage, 'Error occurred');
    });

    test('copyWith clears error when clearError is true', () {
      const initialState = TodoState(
        todos: [],
        errorMessage: 'Error occurred',
      );

      final newState = initialState.copyWith(clearError: true);

      expect(newState.errorMessage, null);
    });

    test('copyWith preserves errorMessage when clearError is false', () {
      const initialState = TodoState(
        todos: [],
        errorMessage: 'Error occurred',
      );

      final newState = initialState.copyWith(isLoading: true);

      expect(newState.errorMessage, 'Error occurred');
    });

    test('props includes all fields', () {
      final state = TodoState(
        todos: [
          Todo(
            id: '1',
            title: 'Todo 1',
            isCompleted: false,
            createdAt: DateTime.now(),
          ),
        ],
        isLoading: true,
        errorMessage: 'Error',
      );

      expect(state.props.length, 3);
      expect(state.props[0], state.todos);
      expect(state.props[1], true);
      expect(state.props[2], 'Error');
    });
  });
}
