import 'package:flutter_riverpod/flutter_riverpod.dart';

class CalendarState {
  final List<Map<String, dynamic>> tasks;
  CalendarState({required this.tasks});
}

class CalendarNotifier extends Notifier<CalendarState> {
  @override
  CalendarState build() {
    final now = DateTime.now();
    return CalendarState(tasks: [
      {
        'date': DateTime(now.year, now.month, 5),
        'title': 'Сходить на прием к стоматологу',
        'completed': false,
        'paw': 'green_paw',
      },
      {
        'date': DateTime(now.year, now.month, 9),
        'title': 'Вакцинация',
        'completed': false,
        'paw': 'blue_paw',
      },
      {
        'date': DateTime(now.year, now.month, 22),
        'title': 'Плановый осмотр',
        'completed': false,
        'paw': 'blue_paw',
      },
      {
        'date': DateTime(now.year, now.month, 7),
        'title': 'Купить таблетки',
        'completed': false,
        'paw': 'paw_yellow',
      },
    ]);
  }

  void addTask(DateTime date, String title, String paw) {
    state = CalendarState(tasks: [
      ...state.tasks,
      {
        'date': date,
        'title': title,
        'completed': false,
        'paw': paw,
      },
    ]);
  }

  void toggleTask(int index) {
    final newTasks = List<Map<String, dynamic>>.from(state.tasks);
    newTasks[index]['completed'] = !newTasks[index]['completed'];
    state = CalendarState(tasks: newTasks);
  }
}

final calendarProvider = NotifierProvider<CalendarNotifier, CalendarState>(
  () => CalendarNotifier(),
);
