import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:peto/core/theme/app_colors.dart';
import '../providers/calendar_provider.dart';

class CalendarScreen extends ConsumerStatefulWidget {
  const CalendarScreen({super.key});

  @override
  ConsumerState<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends ConsumerState<CalendarScreen> {
  int _navIndex = 2;
  DateTime _currentMonth = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(calendarProvider);
    final notifier = ref.read(calendarProvider.notifier);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              const SizedBox(height: 20),
              _buildMonthHeader(),
              const SizedBox(height: 16),
              _buildWeekdayHeaders(),
              const SizedBox(height: 8),
              Expanded(
                child: _buildCalendarGrid(state.tasks, notifier),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: SingleChildScrollView(
                  child: _buildTaskSummary(state.tasks),
                ),
              ),
              const SizedBox(height: 24),
              _buildBottomNavBar(),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        onPressed: () => _showAddTaskModal(context, notifier, _currentMonth),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildMonthHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          icon: const Icon(Icons.chevron_left, color: AppColors.primaryBright),
          onPressed: () {
            setState(() {
              _currentMonth = DateTime(
                _currentMonth.year,
                _currentMonth.month - 1,
                1,
              );
            });
          },
        ),
        Text(
          _getMonthName(_currentMonth),
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.primaryBright,
          ),
        ),
        IconButton(
          icon: const Icon(Icons.chevron_right, color: AppColors.primaryBright),
          onPressed: () {
            setState(() {
              _currentMonth = DateTime(
                _currentMonth.year,
                _currentMonth.month + 1,
                1,
              );
            });
          },
        ),
      ],
    );
  }

  String _getMonthName(DateTime date) {
    const months = [
      'Январь',
      'Февраль',
      'Март',
      'Апрель',
      'Май',
      'Июнь',
      'Июль',
      'Август',
      'Сентябрь',
      'Октябрь',
      'Ноябрь',
      'Декабрь'
    ];
    return '${months[date.month - 1]} ${date.year}';
  }

  Widget _buildWeekdayHeaders() {
    const days = ['Пн', 'Вт', 'Ср', 'Чт', 'Пт', 'Сб', 'Вс'];
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: days
          .map((day) => Text(
                day,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textGrey,
                  fontWeight: FontWeight.w500,
                ),
              ))
          .toList(),
    );
  }

  Widget _buildCalendarGrid(
    List<Map<String, dynamic>> tasks,
    CalendarNotifier notifier,
  ) {
    final now = _currentMonth;
    final firstDay = DateTime(now.year, now.month, 1);
    final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
    final firstWeekday = firstDay.weekday;
    final daysBefore = firstWeekday - 1;
    const totalCells = 42;

    final cells = <Widget>[];

    for (int i = 0; i < daysBefore; i++) {
      final dayNum = DateTime(now.year, now.month, 0).day - daysBefore + i + 1;
      final date = DateTime(now.year, now.month - 1, dayNum);
      cells.add(_buildDayCell(date, false, tasks));
    }

    for (int d = 1; d <= daysInMonth; d++) {
      final date = DateTime(now.year, now.month, d);
      cells.add(_buildDayCell(date, true, tasks));
    }

    final filled = daysBefore + daysInMonth;
    for (int i = 1; i <= totalCells - filled; i++) {
      final date = DateTime(now.year, now.month + 1, i);
      cells.add(_buildDayCell(date, false, tasks));
    }

    return GridView.count(
      crossAxisCount: 7,
      mainAxisSpacing: 4,
      crossAxisSpacing: 4,
      childAspectRatio: 1,
      children: cells,
    );
  }

  Widget _buildDayCell(
    DateTime date,
    bool isCurrentMonth,
    List<Map<String, dynamic>> tasks,
  ) {
    final dayTasks =
        tasks.where((t) => _isSameDay(t['date'] as DateTime, date)).toList();
    final isToday = _isSameDay(date, DateTime.now());

    return GestureDetector(
      onTap: () =>
          _showAddTaskModal(context, ref.read(calendarProvider.notifier), date),
      child: Container(
        decoration: BoxDecoration(
          color: isToday
              ? AppColors.primary.withValues(alpha: 0.15)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: isToday
              ? Border.all(color: AppColors.primaryBright, width: 1.5)
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '${date.day}',
              style: TextStyle(
                fontSize: 14,
                fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                color: isCurrentMonth
                    ? (isToday ? AppColors.primaryBright : AppColors.textDark)
                    : AppColors.textGrey.withValues(alpha: 0.5),
              ),
            ),
            if (dayTasks.isNotEmpty) ...[
              const SizedBox(height: 2),
              SvgPicture.asset(
                'assets/icons/${dayTasks.first['paw']}.svg',
                width: 14,
                height: 14,
                colorFilter: ColorFilter.mode(
                  _getPawColor(dayTasks.first['paw'] as String),
                  BlendMode.srcIn,
                ),
              ),
              if (dayTasks.length > 1) ...[
                const SizedBox(height: 1),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                  decoration: BoxDecoration(
                    color: AppColors.primaryBright,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    '+${dayTasks.length - 1}',
                    style: const TextStyle(
                      fontSize: 9,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }

  Color _getPawColor(String pawType) {
    switch (pawType) {
      case 'blue_paw':
        return AppColors.primaryBright;
      case 'green_paw':
        return AppColors.success;
      case 'pink_paw':
        return AppColors.secondary;
      default:
        return AppColors.primaryBright;
    }
  }

  Widget _buildTaskSummary(List<Map<String, dynamic>> tasks) {
    return Column(
      children: [
        _buildTaskSection(
          'Сегодня',
          _getTasksForDate(tasks, DateTime.now()),
          AppColors.info,
        ),
        const SizedBox(height: 12),
        _buildTaskSection(
          'Завтра',
          _getTasksForDate(tasks, DateTime.now().add(const Duration(days: 1))),
          AppColors.warning,
        ),
      ],
    );
  }

  List<Map<String, dynamic>> _getTasksForDate(
    List<Map<String, dynamic>> tasks,
    DateTime date,
  ) {
    return tasks.where((t) => _isSameDay(t['date'] as DateTime, date)).toList();
  }

  Widget _buildTaskSection(
    String title,
    List<Map<String, dynamic>> tasks,
    Color bgColor,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 16),
          if (tasks.isEmpty)
            Text(
              'Нет задач',
              style: TextStyle(
                color: AppColors.textGrey.withValues(alpha: 0.8),
                fontSize: 15,
              ),
            )
          else
            ...tasks.map((task) {
              final index = _findTaskIndex(task);
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  children: [
                    SvgPicture.asset(
                      'assets/icons/${task['paw']}.svg',
                      width: 24,
                      height: 24,
                      colorFilter: ColorFilter.mode(
                        _getPawColor(task['paw'] as String),
                        BlendMode.srcIn,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        task['title'] as String,
                        style: const TextStyle(
                          fontSize: 16,
                          color: AppColors.textDark,
                          fontWeight: FontWeight.w500,
                          height: 1.4,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Checkbox(
                      value: task['completed'] as bool,
                      onChanged: (value) {
                        if (value != null && index != -1) {
                          ref.read(calendarProvider.notifier).toggleTask(index);
                        }
                      },
                      activeColor: AppColors.primaryBright,
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }

  int _findTaskIndex(Map<String, dynamic> task) {
    final tasks = ref.read(calendarProvider).tasks;
    return tasks.indexWhere(
      (t) =>
          _isSameDay(t['date'] as DateTime, task['date'] as DateTime) &&
          t['title'] == task['title'] &&
          t['paw'] == task['paw'],
    );
  }

  void _navigateToScreen(int index) {
    final routes = ['/home', '/care-tracker', '/calendar', '/profile'];
    if (index >= 0 && index < routes.length) {
      context.go(routes[index]);
    }
  }

  Widget _buildBottomNavBar() {
    const navItems = [
      'assets/icons/home.svg',
      'assets/icons/target.svg',
      'assets/icons/calendar.svg',
      'assets/icons/profile.svg',
    ];

    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(navItems.length, (index) {
          return GestureDetector(
            onTap: () {
              setState(() => _navIndex = index);
              _navigateToScreen(index);
            },
            child: SvgPicture.asset(
              navItems[index],
              width: 28,
              height: 28,
              colorFilter: ColorFilter.mode(
                index == _navIndex
                    ? AppColors.primaryBright
                    : AppColors.primary,
                BlendMode.srcIn,
              ),
            ),
          );
        }),
      ),
    );
  }

  void _showAddTaskModal(
    BuildContext context,
    CalendarNotifier notifier,
    DateTime initialDate,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => _AddTaskForm(
        notifier: notifier,
        initialDate: initialDate,
      ),
    );
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}

class _AddTaskForm extends StatefulWidget {
  final CalendarNotifier notifier;
  final DateTime initialDate;

  const _AddTaskForm({
    required this.notifier,
    required this.initialDate,
  });

  @override
  State<_AddTaskForm> createState() => _AddTaskFormState();
}

class _AddTaskFormState extends State<_AddTaskForm> {
  final _titleController = TextEditingController();
  String _selectedPaw = 'blue_paw';

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pawOptions = [
      {'name': 'blue_paw', 'color': AppColors.primaryBright, 'label': 'Синяя'},
      {'name': 'green_paw', 'color': AppColors.success, 'label': 'Зеленая'},
      {'name': 'yellow_paw', 'color': AppColors.warning, 'label': 'Желтая'},
      {'name': 'pink_paw', 'color': AppColors.secondary, 'label': 'Розовая'},
    ];

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        left: 24,
        right: 24,
        top: 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Новая задача',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryBright,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close, color: AppColors.textGrey),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            '${widget.initialDate.day}.${widget.initialDate.month}.${widget.initialDate.year}',
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textGrey,
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _titleController,
            autofocus: true,
            decoration: InputDecoration(
              hintText: 'Описание задачи',
              prefixIcon:
                  const Icon(Icons.edit_note, color: AppColors.primaryBright),
              filled: true,
              fillColor: AppColors.surface,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: BorderSide.none,
              ),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
          ),
          const SizedBox(height: 20),
          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Тип задачи',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textGrey,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: pawOptions.map((paw) {
              final isSelected = _selectedPaw == paw['name'];
              final pawColor = paw['color'] as Color;

              return GestureDetector(
                onTap: () =>
                    setState(() => _selectedPaw = paw['name'] as String),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? pawColor.withValues(alpha: 0.15)
                        : AppColors.background,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSelected ? pawColor : Colors.transparent,
                      width: 2,
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: pawColor.withValues(alpha: 0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ]
                        : [],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SvgPicture.asset(
                        'assets/icons/${paw['name']}.svg',
                        width: 24,
                        height: 24,
                        colorFilter: ColorFilter.mode(
                          pawColor,
                          BlendMode.srcIn,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        paw['label'] as String,
                        style: TextStyle(
                          color: isSelected ? pawColor : AppColors.textGrey,
                          fontWeight:
                              isSelected ? FontWeight.w600 : FontWeight.normal,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: _saveTask,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                textStyle:
                    const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
              ),
              child: const Text('Добавить задачу'),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  void _saveTask() {
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Введите описание задачи'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    widget.notifier.addTask(
      widget.initialDate,
      _titleController.text.trim(),
      _selectedPaw,
    );

    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Задача добавлена!'),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
