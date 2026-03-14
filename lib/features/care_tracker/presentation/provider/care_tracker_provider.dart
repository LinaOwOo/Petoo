import 'package:flutter_riverpod/flutter_riverpod.dart';

class CareTask {
  final String id;
  final String petId;
  final String type;
  final DateTime date;
  final bool completed;
  final String? note;

  const CareTask({
    required this.id,
    required this.petId,
    required this.type,
    required this.date,
    this.completed = false,
    this.note,
  });

  CareTask copyWith({
    String? id,
    String? petId,
    String? type,
    DateTime? date,
    bool? completed,
    String? note,
  }) {
    return CareTask(
      id: id ?? this.id,
      petId: petId ?? this.petId,
      type: type ?? this.type,
      date: date ?? this.date,
      completed: completed ?? this.completed,
      note: note ?? this.note,
    );
  }
}

class CareTrackerState {
  final List<CareTask> tasks;
  final String? selectedPetId;
  final bool isLoading;

  const CareTrackerState({
    required this.tasks,
    this.selectedPetId,
    this.isLoading = false,
  });

  CareTrackerState copyWith({
    List<CareTask>? tasks,
    String? selectedPetId,
    bool? isLoading,
  }) {
    return CareTrackerState(
      tasks: tasks ?? this.tasks,
      selectedPetId: selectedPetId ?? this.selectedPetId,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  List<CareTask> getTasksForPet(String petId) {
    return tasks.where((task) => task.petId == petId).toList();
  }

  List<CareTask> getTodayTasks(String petId) {
    final now = DateTime.now();
    return getTasksForPet(petId).where((task) {
      return task.date.year == now.year &&
          task.date.month == now.month &&
          task.date.day == now.day;
    }).toList();
  }

  List<CareTask> getWeekTasks(String petId) {
    final now = DateTime.now();
    final weekAgo = now.subtract(const Duration(days: 7));
    return getTasksForPet(petId).where((task) {
      return task.date.isAfter(weekAgo);
    }).toList();
  }
}

class CareTrackerNotifier extends StateNotifier<CareTrackerState> {
  CareTrackerNotifier()
      : super(const CareTrackerState(tasks: [], selectedPetId: null));

  void selectPet(String petId) {
    state = state.copyWith(selectedPetId: petId);
  }

  void addTask(CareTask task) {
    state = state.copyWith(
      tasks: [...state.tasks, task],
    );
  }

  void completeTask(String taskId) {
    state = state.copyWith(
      tasks: state.tasks.map((task) {
        if (task.id == taskId) {
          return task.copyWith(completed: true);
        }
        return task;
      }).toList(),
    );
  }

  void removeTask(String taskId) {
    state = state.copyWith(
      tasks: state.tasks.where((task) => task.id != taskId).toList(),
    );
  }

  void clearTodayTasks(String petId) {
    final todayTasks = getTodayTaskIds(petId);
    state = state.copyWith(
      tasks:
          state.tasks.where((task) => !todayTasks.contains(task.id)).toList(),
    );
  }

  List<String> getTodayTaskIds(String petId) {
    final now = DateTime.now();
    return state.tasks
        .where((task) =>
            task.petId == petId &&
            task.date.year == now.year &&
            task.date.month == now.month &&
            task.date.day == now.day)
        .map((task) => task.id)
        .toList();
  }
}

final careTrackerProvider =
    StateNotifierProvider<CareTrackerNotifier, CareTrackerState>(
  (ref) => CareTrackerNotifier(),
);
