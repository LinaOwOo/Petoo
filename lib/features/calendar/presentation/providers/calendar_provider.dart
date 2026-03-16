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
        'id': '1',
        'date': DateTime(now.year, now.month, 5),
        'title': 'Сходить на прием к стоматологу',
        'completed': false,
        'paw': 'green_paw',
        'hasReminder': false,
      },
      {
        'id': '2',
        'date': DateTime(now.year, now.month, 9),
        'title': 'Вакцинация',
        'completed': false,
        'paw': 'blue_paw',
        'hasReminder': false,
      },
      {
        'id': '3',
        'date': DateTime(now.year, now.month, 22),
        'title': 'Плановый осмотр',
        'completed': false,
        'paw': 'blue_paw',
        'hasReminder': false,
      },
      {
        'id': '4',
        'date': DateTime(now.year, now.month, 7),
        'title': 'Купить таблетки',
        'completed': false,
        'paw': 'yellow_paw',
        'hasReminder': false,
      },
    ]);
  }

  void addTask(DateTime date, String title, String paw,
      {bool hasReminder = false}) {
    state = CalendarState(tasks: [
      ...state.tasks,
      {
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'date': date,
        'title': title,
        'completed': false,
        'paw': paw,
        'hasReminder': hasReminder,
      },
    ]);
  }

  void toggleTaskById(String id) {
    final newTasks = List<Map<String, dynamic>>.from(state.tasks);
    final index = newTasks.indexWhere((t) => t['id'] == id);
    if (index != -1) {
      newTasks[index]['completed'] = !newTasks[index]['completed'];
      state = CalendarState(tasks: newTasks);
    }
  }
}

final calendarProvider = NotifierProvider<CalendarNotifier, CalendarState>(
  () => CalendarNotifier(),
);
