import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:peto/features/home/presentation/providers/home_provider.dart';

class PetDetailsState {
  final Map<String, dynamic> pet;
  PetDetailsState({required this.pet});
}

class PetDetailsNotifier extends FamilyNotifier<PetDetailsState, String> {
  @override
  PetDetailsState build(String petId) {
    final pets = ref.watch(homeProvider).pets;
    final pet = pets.firstWhere(
      (p) => p['id'] == petId,
      orElse: () => <String, dynamic>{},
    );
    return PetDetailsState(pet: Map.from(pet));
  }

  void updateField(String key, dynamic value) {
    final newPet = Map<String, dynamic>.from(state.pet);
    newPet[key] = value;
    state = PetDetailsState(pet: newPet);
  }

  void save() {
    if (state.pet.isEmpty) return;
    ref.read(homeProvider.notifier).updatePet(state.pet);
  }
}

final petDetailsProvider =
    NotifierProvider.family<PetDetailsNotifier, PetDetailsState, String>(
  () => PetDetailsNotifier(),
);
