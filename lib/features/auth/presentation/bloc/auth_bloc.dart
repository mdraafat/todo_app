import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../todo/data/repositories/todo_repository_impl.dart';
import '../../../todo/domain/repositories/todo_repository.dart';
import '../../domain/repositories/auth_repository.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository authRepository;
  final TodoRepository todoRepository;

  AuthBloc({
    required this.authRepository,
    required this.todoRepository,
  }) : super(const AuthState()) {
    on<AuthCheckRequested>(_onAuthCheckRequested);
    on<SignInWithGoogleRequested>(_onSignInWithGoogleRequested);
    on<SignOutRequested>(_onSignOutRequested);
    on<AuthUserChanged>(_onAuthUserChanged);

    
    add(AuthCheckRequested());

    
    authRepository.authStateChanges.listen((user) {
      add(AuthUserChanged(user));
    });
  }

  void _onAuthCheckRequested(AuthCheckRequested event, Emitter<AuthState> emit) {
    final user = authRepository.currentUser;
    emit(state.copyWith(user: user));
  }

  Future<void> _onSignInWithGoogleRequested(
    SignInWithGoogleRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, errorMessage: null));
    
    try {
      final user = await authRepository.signInWithGoogle();
      
      if (user != null) {
        emit(state.copyWith(user: user, isLoading: false));
        
        
        if (todoRepository is TodoRepositoryImpl) {
          await (todoRepository as TodoRepositoryImpl).syncLocalTodosToCloud(user.id);
        }
      } else {
        emit(state.copyWith(isLoading: false));
      }
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to sign in with Google',
      ));
    }
  }

  Future<void> _onSignOutRequested(
    SignOutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(isLoading: true));
    
    try {
      await authRepository.signOut();
      
      emit(state.copyWith(clearUser: true, isLoading: false));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to sign out',
      ));
    }
  }

  void _onAuthUserChanged(AuthUserChanged event, Emitter<AuthState> emit) {
    if (event.user == null) {
      emit(state.copyWith(clearUser: true));
    } else {
      emit(state.copyWith(user: event.user));
    }
  }
}