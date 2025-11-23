import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../bloc/todo_bloc.dart';
import '../widgets/todo_item.dart';
import 'add_todo_sheet.dart';
import 'todo_details_page.dart';

class TodoListPage extends StatelessWidget {
  const TodoListPage({super.key});

  void _showAddTodoSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => BlocProvider.value(
        value: BlocProvider.of<TodoBloc>(context),
        child: const AddTodoBottomSheet(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TodoBloc, TodoState>(
      builder: (context, state) {
        return BlocBuilder<AuthBloc, AuthState>(
          builder: (context, authState) {
            return Scaffold(
              appBar: AppBar(
                title: Text(
                  authState.isAuthenticated
                      ? 'Hi, ${authState.user?.displayName ?? authState.user?.email ?? 'User'}'
                      : 'My Tasks',
                ),
                actions: [
                  if (!authState.isAuthenticated)
                    TextButton.icon(
                      onPressed: () => context.read<AuthBloc>().add(
                            SignInWithGoogleRequested(),
                          ),
                      icon: const FaIcon(FontAwesomeIcons.google, size: 16),
                      label: const Text('Sign in'),
                      style: TextButton.styleFrom(
                        foregroundColor: Theme.of(context).colorScheme.primary,
                      ),
                    )
                  else
                    TextButton(
                      onPressed: () =>
                          context.read<AuthBloc>().add(SignOutRequested()),
                      style: TextButton.styleFrom(
                        foregroundColor: Theme.of(context).colorScheme.primary,
                      ),
                      child: const Text(
                        'Sign out',
                      ),
                    ),
                  const SizedBox(width: 8),
                ],
                bottom: PreferredSize(
                  preferredSize: const Size.fromHeight(48),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        if (state.totalCount > 0)
                          Text(
                            '${state.completedCount} of ${state.totalCount} completed',
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurfaceVariant,
                                ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
              body: state.todos.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.check_circle_outline,
                            size: 64,
                            color: Theme.of(context).colorScheme.outline,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No tasks yet',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Add a task to get started',
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurfaceVariant,
                                ),
                          ),
                          const SizedBox(height: 96),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: state.todos.length,
                      itemBuilder: (context, index) {
                        final todo = state.todos[index];
                        return TodoItem(
                          todo: todo,
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      TodoDetailsPage(todo: todo),
                                ));
                          },
                          onToggle: () {
                            context.read<TodoBloc>().add(
                                  ToggleTodo(todo.id),
                                );
                          },
                        );
                      },
                    ),
              floatingActionButton: FloatingActionButton.extended(
                onPressed: () => _showAddTodoSheet(context),
                icon: const Icon(Icons.add),
                label: const Text('Add Task'),
              ),
            );
          },
        );
      },
    );
  }
}