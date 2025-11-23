import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../todo/data/repositories/todo_repository_impl.dart';
import '../../../todo/domain/repositories/todo_repository.dart';
import '../../data/models/user.dart';
import '../../domain/repositories/auth_repository.dart';

abstract class AuthEvent {}

class AuthCheckRequested extends AuthEvent {}

class SignInWithGoogleRequested extends AuthEvent {}

class SignOutRequested extends AuthEvent {}

class AuthUserChanged extends AuthEvent {
  final User? user;
  AuthUserChanged(this.user);
}


class AuthState {
  final User? user;
  final bool isLoading;
  final String? errorMessage;

  AuthState({
    this.user,
    this.isLoading = false,
    this.errorMessage,
  });

  bool get isAuthenticated => user != null;

  AuthState copyWith({
    User? user,
    bool? isLoading,
    String? errorMessage,
    bool clearUser = false,
  }) {
    return AuthState(
      user: clearUser ? null : (user ?? this.user),
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}


class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository authRepository;
  final TodoRepository todoRepository;

  AuthBloc({
    required this.authRepository,
    required this.todoRepository,
  }) : super(AuthState()) {
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