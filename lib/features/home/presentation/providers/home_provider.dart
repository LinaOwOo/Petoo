import 'package:flutter_riverpod/flutter_riverpod.dart';

class HomeState {
  final int tab;
  final String category;
  final List<Map<String, dynamic>> pets;

  HomeState({
    required this.tab,
    required this.category,
    required this.pets,
  });

  HomeState copyWith({
    int? tab,
    String? category,
    List<Map<String, dynamic>>? pets,
  }) {
    return HomeState(
      tab: tab ?? this.tab,
      category: category ?? this.category,
      pets: pets ?? this.pets,
    );
  }
}

class HomeNotifier extends Notifier<HomeState> {
  @override
  HomeState build() {
    return HomeState(
      tab: 0,
      category: 'Все',
      pets: [],
    );
  }

  void setTab(int index) {
    state = state.copyWith(tab: index);
  }

  void setCategory(String cat) {
    state = state.copyWith(category: cat);
  }

  void addPet(Map<String, dynamic> pet) {
    state = state.copyWith(
      pets: [...state.pets, pet],
    );
  }

  void removePet(String petId) {
    state = state.copyWith(
      pets: state.pets.where((p) => p['id'] != petId).toList(),
    );
  }

  void updatePet(Map<String, dynamic> updatedPet) {
    final petId = updatedPet['id'] as String?;
    if (petId == null) return;
    final index = state.pets.indexWhere((p) => p['id'] == petId);
    if (index == -1) return;
    final newPets = List<Map<String, dynamic>>.from(state.pets);
    newPets[index] = updatedPet;
    state = state.copyWith(pets: newPets);
  }
}

final homeProvider = NotifierProvider<HomeNotifier, HomeState>(
  () => HomeNotifier(),
);
