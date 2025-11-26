import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:todo_app/features/auth/domain/entities/user.dart';
import 'package:todo_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:todo_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:todo_app/features/auth/presentation/bloc/auth_event.dart';
import 'package:todo_app/features/auth/presentation/bloc/auth_state.dart';
import 'package:todo_app/features/todo/domain/repositories/todo_repository.dart';

class MockAuthRepository extends Mock implements AuthRepository {}
class MockTodoRepository extends Mock implements TodoRepository {}

void main() {
  late AuthBloc authBloc;
  late MockAuthRepository mockAuthRepository;
  late MockTodoRepository mockTodoRepository;

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    mockTodoRepository = MockTodoRepository();
    
    when(() => mockAuthRepository.authStateChanges).thenAnswer(
      (_) => Stream.value(null),
    );
    when(() => mockAuthRepository.currentUser).thenReturn(null);
    
    authBloc = AuthBloc(
      authRepository: mockAuthRepository,
      todoRepository: mockTodoRepository,
    );
  });

  tearDown(() {
    authBloc.close();
  });

  group('AuthBloc - Initial State', () {
    test('initial state is unauthenticated', () {
      expect(authBloc.state.isAuthenticated, false);
      expect(authBloc.state.user, null);
      expect(authBloc.state.isLoading, false);
      expect(authBloc.state.errorMessage, null);
    });
  });

  group('AuthBloc - Google Sign In', () {
    test('Google sign-in successfully authenticates user', () async {
      // Arrange
      const user = User(
        id: 'google_123',
        email: 'user@gmail.com',
        displayName: 'Test User',
      );

      when(() => mockAuthRepository.signInWithGoogle())
          .thenAnswer((_) async => user);

      // Act
      authBloc.add(SignInWithGoogleRequested());
      await Future.delayed(const Duration(milliseconds: 100));

      // Assert
      expect(authBloc.state.isAuthenticated, true);
      expect(authBloc.state.user, user);
      expect(authBloc.state.user?.email, 'user@gmail.com');
      expect(authBloc.state.user?.displayName, 'Test User');
      expect(authBloc.state.isLoading, false);
      expect(authBloc.state.errorMessage, null);
    });

    test('Google sign-in handles user cancellation', () async {
      // Arrange - User closes Google sign-in dialog
      when(() => mockAuthRepository.signInWithGoogle())
          .thenAnswer((_) async => null);

      // Act
      authBloc.add(SignInWithGoogleRequested());
      await Future.delayed(const Duration(milliseconds: 100));

      // Assert
      expect(authBloc.state.isAuthenticated, false);
      expect(authBloc.state.user, null);
      expect(authBloc.state.isLoading, false);
    });

    test('Google sign-in sets loading state during authentication', () async {
      // Arrange
      const user = User(id: '123', email: 'test@example.com');
      
      when(() => mockAuthRepository.signInWithGoogle())
          .thenAnswer((_) async {
        await Future.delayed(const Duration(milliseconds: 50));
        return user;
      });

      // Act
      authBloc.add(SignInWithGoogleRequested());
      
      // Assert - Check loading state immediately
      await Future.delayed(const Duration(milliseconds: 10));
      expect(authBloc.state.isLoading, true);
      
      // Wait for completion
      await Future.delayed(const Duration(milliseconds: 100));
      expect(authBloc.state.isLoading, false);
    });

    test('Google sign-in handles network errors', () async {
      // Arrange
      when(() => mockAuthRepository.signInWithGoogle())
          .thenThrow(Exception('Network error'));

      // Act
      authBloc.add(SignInWithGoogleRequested());
      await Future.delayed(const Duration(milliseconds: 100));

      // Assert
      expect(authBloc.state.isAuthenticated, false);
      expect(authBloc.state.errorMessage, 'Failed to sign in with Google');
      expect(authBloc.state.isLoading, false);
    });

    test('Google sign-in handles OAuth errors', () async {
      // Arrange
      when(() => mockAuthRepository.signInWithGoogle())
          .thenThrow(Exception('OAuth failed'));

      // Act
      authBloc.add(SignInWithGoogleRequested());
      await Future.delayed(const Duration(milliseconds: 100));

      // Assert
      expect(authBloc.state.isAuthenticated, false);
      expect(authBloc.state.errorMessage, 'Failed to sign in with Google');
    });
  });

  group('AuthBloc - Sign Out', () {
    test('sign out successfully clears user state', () async {
      // Arrange
      when(() => mockAuthRepository.signOut()).thenAnswer((_) async {});

      // Act
      authBloc.add(SignOutRequested());
      await Future.delayed(const Duration(milliseconds: 100));

      // Assert
      expect(authBloc.state.isAuthenticated, false);
      expect(authBloc.state.user, null);
      expect(authBloc.state.isLoading, false);
    });

    test('sign out handles errors gracefully', () async {
      // Arrange
      when(() => mockAuthRepository.signOut())
          .thenThrow(Exception('Sign out failed'));

      // Act
      authBloc.add(SignOutRequested());
      await Future.delayed(const Duration(milliseconds: 100));

      // Assert
      expect(authBloc.state.errorMessage, 'Failed to sign out');
      expect(authBloc.state.isLoading, false);
    });
  });

  group('AuthBloc - Auth State Changes', () {
    test('responds to auth state changes from Firebase', () async {
      // Arrange
      const user = User(
        id: 'firebase_123',
        email: 'user@gmail.com',
        displayName: 'Firebase User',
      );

      // Act - Simulate Firebase auth state change
      authBloc.add(AuthUserChanged(user));
      await Future.delayed(const Duration(milliseconds: 50));

      // Assert
      expect(authBloc.state.isAuthenticated, true);
      expect(authBloc.state.user, user);
    });

    test('handles user sign out from auth state changes', () async {
      // Act - Simulate Firebase auth state change to null (signed out)
      authBloc.add(AuthUserChanged(null));
      await Future.delayed(const Duration(milliseconds: 50));

      // Assert
      expect(authBloc.state.isAuthenticated, false);
      expect(authBloc.state.user, null);
    });

    test('checks current user on initialization', () async {
      // Arrange
      const user = User(
        id: '123',
        email: 'test@example.com',
        displayName: 'Existing User',
      );

      when(() => mockAuthRepository.currentUser).thenReturn(user);

      // Act
      authBloc.add(AuthCheckRequested());
      await Future.delayed(const Duration(milliseconds: 100));

      // Assert
      expect(authBloc.state.isAuthenticated, true);
      expect(authBloc.state.user, user);
    });
  });

  group('AuthState', () {
    test('isAuthenticated returns true when user exists', () {
      const state = AuthState(
        user: User(id: '123', email: 'test@gmail.com'),
      );

      expect(state.isAuthenticated, true);
    });

    test('isAuthenticated returns false when user is null', () {
      const state = AuthState(user: null);

      expect(state.isAuthenticated, false);
    });

    test('copyWith updates user correctly', () {
      const initialState = AuthState(user: null);
      const newUser = User(id: '123', email: 'test@gmail.com');

      final newState = initialState.copyWith(user: newUser);

      expect(newState.user, newUser);
      expect(newState.isAuthenticated, true);
    });

    test('copyWith updates loading state', () {
      const initialState = AuthState(isLoading: false);

      final newState = initialState.copyWith(isLoading: true);

      expect(newState.isLoading, true);
    });

    test('copyWith clears user when clearUser is true', () {
      const initialState = AuthState(
        user: User(id: '123', email: 'test@gmail.com'),
      );

      final newState = initialState.copyWith(clearUser: true);

      expect(newState.user, null);
      expect(newState.isAuthenticated, false);
    });

    test('copyWith clears error when clearError is true', () {
      const initialState = AuthState(errorMessage: 'Error occurred');

      final newState = initialState.copyWith(clearError: true);

      expect(newState.errorMessage, null);
    });

    test('copyWith preserves unchanged values', () {
      const initialState = AuthState(
        user: User(id: '123', email: 'test@gmail.com'),
        errorMessage: 'Some error',
      );

      final newState = initialState.copyWith(isLoading: true);

      expect(newState.user, initialState.user);
      expect(newState.errorMessage, initialState.errorMessage);
      expect(newState.isLoading, true);
    });
  });
}