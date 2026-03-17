import 'package:flutter_riverpod/flutter_riverpod.dart';

enum SplashStatus { initial, loading, authenticated, unauthenticated }

class SplashState {
  final SplashStatus status;

  const SplashState({required this.status});
}

class SplashNotifier extends StateNotifier<SplashState> {
  SplashNotifier() : super(const SplashState(status: SplashStatus.initial));

  Future<void> initialize() async {
    state = const SplashState(status: SplashStatus.loading);

    await Future.delayed(const Duration(milliseconds: 2500));

    state = const SplashState(status: SplashStatus.authenticated);
  }
}

final splashProvider =
    StateNotifierProvider<SplashNotifier, SplashState>((ref) {
  return SplashNotifier();
});
