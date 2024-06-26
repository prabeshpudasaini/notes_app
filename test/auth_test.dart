import 'package:notes_app/services/auth/auth_exceptions.dart';
import 'package:notes_app/services/auth/auth_provider.dart';
import 'package:notes_app/services/auth/auth_user.dart';
import 'package:test/test.dart';

void main() {
  group(
    'Mock Authentication',
    () {
      final provider = MockAuthProvider();
      test(
        'Should not be initialized to begin with',
        () {
          expect(provider._isInitialized, false);
        },
      );

      test(
        'Cannot Logout if not initialized',
        () {
          expect(
            provider.logOut(),
            throwsA(const TypeMatcher<NotInitializedException>()),
          );
        },
      );

      test('Should be able to initialize', () async {
        await provider.initialize();
        expect(provider.isInitialized, true);
      });

      test('User should be null after initialization', () {
        expect(provider.currentUser, null);
      });

      test(
        'Should be able to initialize is less than 2 seconds',
        () async {
          await provider.initialize();
          expect(provider.isInitialized, true);
        },
        timeout: const Timeout(
          Duration(seconds: 2),
        ),
      );

      test('Create user should should delegate to login function', () async {
        final badEmailUser = provider.createUser(
          email: 'p@gmail.com',
          password: 'anypassword',
        );
        expect(badEmailUser,
            throwsA(const TypeMatcher<InvalidCredentialsAuthException>()));

        final badPasswordUser = provider.createUser(
          email: 'any@gmail.com',
          password: 'prabesh123',
        );
        expect(badPasswordUser,
            throwsA(const TypeMatcher<InvalidCredentialsAuthException>()));

        final user = await provider.createUser(
          email: 'prabesh@gmail.com',
          password: 'prabesh',
        );
        expect(provider.currentUser, user);
        expect(user.isEmailVerified, false);
      });

      test(
        'User should be able to get verified',
        () {
          provider.sendEmailVerification();
          final user = provider.currentUser;
          expect(user, isNotNull);
          expect(user!.isEmailVerified, true);
        },
      );

      test('Should be able to logout and login again', () async {
        await provider.logOut();
        await provider.logIn(email: 'email', password: 'password');
        final user = provider.currentUser;
        expect(user, isNotNull);
      });
    },
  );
}

class NotInitializedException implements Exception {}

class MockAuthProvider implements AuthProvider {
  var _isInitialized = false;
  bool get isInitialized => _isInitialized;

  AuthUser? _user;

  @override
  Future<AuthUser> createUser(
      {required String email, required String password}) async {
    if (!isInitialized) throw NotInitializedException();
    await Future.delayed(const Duration(seconds: 1));
    return logIn(
      email: email,
      password: password,
    );
  }

  @override
  AuthUser? get currentUser => _user;

  @override
  Future<void> initialize() async {
    await Future.delayed(const Duration(seconds: 1));
    _isInitialized = true;
  }

  @override
  Future<AuthUser> logIn({required String email, required String password}) {
    if (!isInitialized) throw NotInitializedException();
    if (email == 'p@gmail.com') throw InvalidCredentialsAuthException();
    if (password == 'prabesh123') throw InvalidCredentialsAuthException();
    const user =
        AuthUser(isEmailVerified: false, email: 'p@gmail.com', id: 'myUid');
    _user = user;
    return Future.value(user);
  }

  @override
  Future<void> logOut() async {
    if (!isInitialized) throw NotInitializedException();
    if (_user == null) throw InvalidCredentialsAuthException();
    await Future.delayed(const Duration(seconds: 1));
    _user = null;
  }

  @override
  Future<void> sendEmailVerification() async {
    if (!isInitialized) throw NotInitializedException();
    final user = _user;
    if (user == null) throw InvalidCredentialsAuthException();
    const newUser =
        AuthUser(isEmailVerified: true, email: 'p@gmail.com', id: 'myUid');
    _user = newUser;
  }

  @override
  Future<void> sendPasswordReset({required String toEmail}) {
    throw UnimplementedError();
  }
}
