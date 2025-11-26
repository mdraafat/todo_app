import 'package:flutter_test/flutter_test.dart';
import 'package:todo_app/features/auth/domain/entities/user.dart';

void main() {
  group('User Entity', () {
    test('creates User with all properties', () {
      const user = User(
        id: '123',
        email: 'test@gmail.com',
        displayName: 'Test User',
      );

      expect(user.id, '123');
      expect(user.email, 'test@gmail.com');
      expect(user.displayName, 'Test User');
    });

    test('creates User without optional properties', () {
      const user = User(
        id: '123',
        email: 'test@gmail.com',
      );

      expect(user.displayName, null);
    });

    test('equality works correctly', () {
      const user1 = User(
        id: '123',
        email: 'test@gmail.com',
        displayName: 'Test User',
      );

      const user2 = User(
        id: '123',
        email: 'test@gmail.com',
        displayName: 'Test User',
      );

      const user3 = User(
        id: '456',
        email: 'other@gmail.com',
      );

      expect(user1, equals(user2));
      expect(user1, isNot(equals(user3)));
    });

    test('props includes all fields', () {
      const user = User(
        id: '123',
        email: 'test@gmail.com',
        displayName: 'Test User',
      );

      expect(
        user.props,
        equals([
          '123',
          'test@gmail.com',
          'Test User',
          'https://example.com/photo.jpg'
        ]),
      );
    });
  });
}
