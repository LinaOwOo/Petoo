import 'package:flutter_riverpod/flutter_riverpod.dart';

class AuthState {
  final bool isAuthenticated;
  final String? userId;
  final String? email;
  final String? displayName;

  AuthState({
    this.isAuthenticated = false,
    this.userId,
    this.email,
    this.displayName,
  });

  AuthState copyWith({
    bool? isAuthenticated,
    String? userId,
    String? email,
    String? displayName,
  }) {
    return AuthState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      userId: userId ?? this.userId,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
    );
  }
}

class AuthNotifier extends Notifier<AuthState> {
  @override
  AuthState build() {
    return AuthState();
  }

  Future<void> signInWithEmail(String email, String password) async {
    await Future.delayed(const Duration(seconds: 1));

    state = AuthState(
      isAuthenticated: true,
      userId: 'user_${email.hashCode}',
      email: email,
      displayName: email.split('@').first,
    );
  }

  Future<void> registerWithEmail(
      String email, String password, String name) async {
    await Future.delayed(const Duration(seconds: 1));

    state = AuthState(
      isAuthenticated: true,
      userId: 'user_${email.hashCode}',
      email: email,
      displayName: name,
    );
  }

  Future<void> signOut() async {
    await Future.delayed(const Duration(milliseconds: 400));
    state = AuthState();
  }
}

final authProvider = NotifierProvider<AuthNotifier, AuthState>(
  () => AuthNotifier(),
);
