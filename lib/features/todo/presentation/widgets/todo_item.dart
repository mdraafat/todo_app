import 'package:flutter/material.dart';

import '../../domain/entities/todo.dart';

class TodoItem extends StatelessWidget {
  final Todo todo;
  final VoidCallback onTap;
  final VoidCallback onToggle;

  const TodoItem({
    super.key,
    required this.todo,
    required this.onTap,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Checkbox(
          value: todo.isCompleted,
          onChanged: (_) => onToggle(),
        ),
        title: Text(
          todo.title,
          style: TextStyle(
            decoration: todo.isCompleted ? TextDecoration.lineThrough : null,
            color: todo.isCompleted
                ? Theme.of(context).colorScheme.onSurfaceVariant
                : null,
          ),
        ),
        subtitle: todo.description != null
            ? Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  todo.description!,
                  style: TextStyle(
                    decoration:
                        todo.isCompleted ? TextDecoration.lineThrough : null,
                  ),
                ),
              )
            : null,
        onTap: onTap,
      ),
    );
  }
}