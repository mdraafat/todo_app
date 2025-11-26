import 'package:flutter_test/flutter_test.dart';
import 'package:todo_app/features/todo/domain/entities/todo.dart';

void main() {
  group('Todo Entity', () {
    final now = DateTime.now();
    
    test('creates Todo with all properties', () {
      final todo = Todo(
        id: '1',
        title: 'Buy milk',
        description: 'From the store',
        isCompleted: false,
        createdAt: now,
      );

      expect(todo.id, '1');
      expect(todo.title, 'Buy milk');
      expect(todo.description, 'From the store');
      expect(todo.isCompleted, false);
      expect(todo.createdAt, now);
    });

    test('creates Todo without description', () {
      final todo = Todo(
        id: '1',
        title: 'Buy milk',
        isCompleted: false,
        createdAt: now,
      );

      expect(todo.description, null);
    });

    test('copyWith updates specified properties', () {
      final original = Todo(
        id: '1',
        title: 'Buy milk',
        description: 'From the store',
        isCompleted: false,
        createdAt: now,
      );

      final updated = original.copyWith(
        title: 'Buy eggs',
        isCompleted: true,
      );

      expect(updated.id, original.id);
      expect(updated.title, 'Buy eggs');
      expect(updated.description, original.description);
      expect(updated.isCompleted, true);
      expect(updated.createdAt, original.createdAt);
    });

    test('copyWith with no parameters returns same values', () {
      final original = Todo(
        id: '1',
        title: 'Buy milk',
        isCompleted: false,
        createdAt: now,
      );

      final copy = original.copyWith();

      expect(copy.id, original.id);
      expect(copy.title, original.title);
      expect(copy.isCompleted, original.isCompleted);
      expect(copy.createdAt, original.createdAt);
    });

    test('equality works correctly', () {
      final todo1 = Todo(
        id: '1',
        title: 'Buy milk',
        isCompleted: false,
        createdAt: now,
      );

      final todo2 = Todo(
        id: '1',
        title: 'Buy milk',
        isCompleted: false,
        createdAt: now,
      );

      final todo3 = Todo(
        id: '2',
        title: 'Buy milk',
        isCompleted: false,
        createdAt: now,
      );

      expect(todo1, equals(todo2));
      expect(todo1, isNot(equals(todo3)));
    });

    test('props includes all fields', () {
      final todo = Todo(
        id: '1',
        title: 'Buy milk',
        description: 'From store',
        isCompleted: false,
        createdAt: now,
      );

      expect(
        todo.props,
        equals(['1', 'Buy milk', 'From store', false, now]),
      );
    });
  });
}
