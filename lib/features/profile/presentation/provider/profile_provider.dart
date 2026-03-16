import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProfileState {
  final String userName;
  final String? avatarPath;
  final String petName;
  final String petEmoji;

  ProfileState({
    required this.userName,
    this.avatarPath,
    required this.petName,
    required this.petEmoji,
  });
}

class ProfileNotifier extends Notifier<ProfileState> {
  @override
  ProfileState build() {
    return ProfileState(
      userName: 'Alex',
      avatarPath: null,
      petName: 'Luna',
      petEmoji: '🐱',
    );
  }

  void updateProfile({
    String? userName,
    String? avatarPath,
    String? petName,
    String? petEmoji,
  }) {
    state = ProfileState(
      userName: userName ?? state.userName,
      avatarPath: avatarPath ?? state.avatarPath,
      petName: petName ?? state.petName,
      petEmoji: petEmoji ?? state.petEmoji,
    );
  }
}

final profileProvider = NotifierProvider<ProfileNotifier, ProfileState>(
  () => ProfileNotifier(),
);
