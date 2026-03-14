import 'package:flutter_riverpod/flutter_riverpod.dart';

class HomeState {
  final int tab;
  final String category;
  final List<Map<String, dynamic>> pets;

  HomeState(this.tab, this.category, this.pets);
}

class HomeNotifier extends Notifier<HomeState> {
  @override
  HomeState build() {
    return HomeState(
      0,
      'Все',
      [],
    );
  }

  void setTab(int index) {
    state = HomeState(index, state.category, state.pets);
  }

  void setCategory(String cat) {
    state = HomeState(state.tab, cat, state.pets);
  }

  void addPet(Map<String, dynamic> pet) {
    state = HomeState(
      state.tab,
      state.category,
      [...state.pets, pet],
    );
  }

  void removePet(String name) {
    state = HomeState(
      state.tab,
      state.category,
      state.pets.where((p) => p['name'] != name).toList(),
    );
  }
}

final homeProvider = NotifierProvider<HomeNotifier, HomeState>(
  () => HomeNotifier(),
);
