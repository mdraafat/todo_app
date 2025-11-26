import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:todo_app/features/todo/domain/entities/todo.dart';
import 'package:todo_app/features/todo/presentation/widgets/todo_item.dart';

void main() {
  group('TodoItem Widget', () {
    late Todo testTodo;
    bool tapCalled = false;
    bool toggleCalled = false;

    setUp(() {
      tapCalled = false;
      toggleCalled = false;
      testTodo = Todo(
        id: '1',
        title: 'Test Todo',
        description: 'Test Description',
        isCompleted: false,
        createdAt: DateTime.now(),
      );
    });

    Widget createWidget(Todo todo) {
      return MaterialApp(
        home: Scaffold(
          body: TodoItem(
            todo: todo,
            onTap: () => tapCalled = true,
            onToggle: () => toggleCalled = true,
          ),
        ),
      );
    }

    testWidgets('displays todo title', (tester) async {
      await tester.pumpWidget(createWidget(testTodo));

      expect(find.text('Test Todo'), findsOneWidget);
    });

    testWidgets('displays todo description when available', (tester) async {
      await tester.pumpWidget(createWidget(testTodo));

      expect(find.text('Test Description'), findsOneWidget);
    });

    testWidgets('displays unchecked checkbox for incomplete todo',
        (tester) async {
      await tester.pumpWidget(createWidget(testTodo));

      final checkbox = tester.widget<Checkbox>(find.byType(Checkbox));
      expect(checkbox.value, false);
    });

    testWidgets('displays checked checkbox for completed todo', (tester) async {
      final completedTodo = testTodo.copyWith(isCompleted: true);
      await tester.pumpWidget(createWidget(completedTodo));

      final checkbox = tester.widget<Checkbox>(find.byType(Checkbox));
      expect(checkbox.value, true);
    });

    testWidgets('applies strikethrough to completed todo title',
        (tester) async {
      final completedTodo = testTodo.copyWith(isCompleted: true);
      await tester.pumpWidget(createWidget(completedTodo));

      final titleText = tester.widget<Text>(
        find.text('Test Todo'),
      );
      expect(titleText.style?.decoration, TextDecoration.lineThrough);
    });

    testWidgets('calls onToggle when checkbox is tapped', (tester) async {
      await tester.pumpWidget(createWidget(testTodo));

      await tester.tap(find.byType(Checkbox));
      await tester.pump();

      expect(toggleCalled, true);
    });

    testWidgets('calls onTap when ListTile is tapped', (tester) async {
      await tester.pumpWidget(createWidget(testTodo));

      await tester.tap(find.byType(ListTile));
      await tester.pump();

      expect(tapCalled, true);
    });

    testWidgets('renders as a Card widget', (tester) async {
      await tester.pumpWidget(createWidget(testTodo));

      expect(find.byType(Card), findsOneWidget);
    });
  });
}