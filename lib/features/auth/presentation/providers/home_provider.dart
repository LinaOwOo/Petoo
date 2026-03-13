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
      [
        {
          'name': 'Барсик',
          'breed': 'Мейн-кун',
          'age': '2 года',
          'location': 'Москва',
          'image': 'https://picsum.photos/id/237/400/300',
          'category': 'Кошки',
        },
        {
          'name': 'Рекс',
          'breed': 'Лабрадор',
          'age': '1 год',
          'location': 'Санкт-Петербург',
          'image': 'https://picsum.photos/id/1015/400/300',
          'category': 'Собаки',
        },
        {
          'name': 'Тортила',
          'breed': 'Красноухая',
          'age': '5 лет',
          'location': 'Казань',
          'image': 'https://picsum.photos/id/201/400/300',
          'category': 'Черепашки',
        },
        {
          'name': 'Флэппи',
          'breed': 'Карликовый',
          'age': '8 месяцев',
          'location': 'Новосибирск',
          'image': 'https://picsum.photos/id/160/400/300',
          'category': 'Кролики',
        },
      ],
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
}

final homeProvider = NotifierProvider<HomeNotifier, HomeState>(
  () => HomeNotifier(),
);
