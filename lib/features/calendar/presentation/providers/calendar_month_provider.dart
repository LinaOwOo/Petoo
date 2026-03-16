import 'package:flutter_riverpod/flutter_riverpod.dart';

final calendarMonthProvider =
    StateNotifierProvider<CalendarMonthNotifier, DateTime>(
  (ref) => CalendarMonthNotifier(),
);

class CalendarMonthNotifier extends StateNotifier<DateTime> {
  CalendarMonthNotifier() : super(DateTime.now());

  void previousMonth() {
    state = DateTime(state.year, state.month - 1, 1);
  }

  void nextMonth() {
    state = DateTime(state.year, state.month + 1, 1);
  }

  void goToMonth(DateTime date) {
    state = DateTime(date.year, date.month, 1);
  }
}
