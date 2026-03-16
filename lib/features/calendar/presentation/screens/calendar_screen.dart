import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:peto/core/theme/app_colors.dart';
import 'package:peto/core/widgets/bottom_nav.dart';
import '../providers/calendar_provider.dart';
import '../providers/calendar_month_provider.dart';

class CalendarScreen extends ConsumerStatefulWidget {
  const CalendarScreen({super.key});

  @override
  ConsumerState<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends ConsumerState<CalendarScreen> {
  DateTime _selectedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(calendarProvider);
    final notifier = ref.read(calendarProvider.notifier);
    final currentMonth = ref.watch(calendarMonthProvider);

    final dayTasks = state.tasks
        .where((t) => _isSameDay(t['date'] as DateTime, _selectedDate))
        .toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              const SizedBox(height: 20),
              _buildMonthHeader(ref, currentMonth),
              const SizedBox(height: 16),
              _buildWeekdayHeaders(),
              const SizedBox(height: 8),
              Expanded(
                child: _buildCalendarGrid(
                  state.tasks,
                  notifier,
                  currentMonth,
                ),
              ),
              const SizedBox(height: 16),
              _buildAddButton(context, notifier),
              if (dayTasks.isNotEmpty) ...[
                const SizedBox(height: 16),
                Expanded(
                  child: SingleChildScrollView(
                    child: _buildTaskSummary(dayTasks),
                  ),
                ),
              ],
              const SizedBox(height: 24),
              const BottomNav(currentIndex: 2),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMonthHeader(WidgetRef ref, DateTime currentMonth) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          icon: const Icon(Icons.chevron_left, color: AppColors.primaryBright),
          onPressed: () {
            ref.read(calendarMonthProvider.notifier).previousMonth();
          },
        ),
        Text(
          _getMonthName(currentMonth),
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.primaryBright,
          ),
        ),
        IconButton(
          icon: const Icon(Icons.chevron_right, color: AppColors.primaryBright),
          onPressed: () {
            ref.read(calendarMonthProvider.notifier).nextMonth();
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
    DateTime currentMonth,
  ) {
    final firstDay = DateTime(currentMonth.year, currentMonth.month, 1);
    final daysInMonth =
        DateTime(currentMonth.year, currentMonth.month + 1, 0).day;
    final firstWeekday = firstDay.weekday;
    final daysBefore = firstWeekday - 1;
    const totalCells = 42;

    final cells = <Widget>[];

    for (int i = 0; i < daysBefore; i++) {
      final dayNum = DateTime(currentMonth.year, currentMonth.month, 0).day -
          daysBefore +
          i +
          1;
      final date = DateTime(currentMonth.year, currentMonth.month - 1, dayNum);
      cells.add(_buildDayCell(date, false, tasks, notifier));
    }

    for (int d = 1; d <= daysInMonth; d++) {
      final date = DateTime(currentMonth.year, currentMonth.month, d);
      cells.add(_buildDayCell(date, true, tasks, notifier));
    }

    final filled = daysBefore + daysInMonth;
    for (int i = 1; i <= totalCells - filled; i++) {
      final date = DateTime(currentMonth.year, currentMonth.month + 1, i);
      cells.add(_buildDayCell(date, false, tasks, notifier));
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
    CalendarNotifier notifier,
  ) {
    final dayTasks =
        tasks.where((t) => _isSameDay(t['date'] as DateTime, date)).toList();
    final isToday = _isSameDay(date, DateTime.now());
    final pawIcon =
        dayTasks.isNotEmpty ? dayTasks.first['paw'] as String? : null;

    return GestureDetector(
      onTap: () {
        setState(() => _selectedDate = date);
      },
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
            if (pawIcon != null) ...[
              const SizedBox(height: 2),
              SvgPicture.asset(
                'assets/icons/$pawIcon.svg',
                width: 14,
                height: 14,
                colorFilter: ColorFilter.mode(
                  _getPawColor(pawIcon),
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
      case 'yellow_paw':
        return AppColors.warning;
      case 'pink_paw':
        return AppColors.secondary;
      default:
        return AppColors.primaryBright;
    }
  }

  Widget _buildAddButton(BuildContext context, CalendarNotifier notifier) {
    return Center(
      child: GestureDetector(
        onTap: () => _showAddTaskModal(context, notifier),
        child: Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: AppColors.primary,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Icon(Icons.add, color: Colors.white, size: 28),
        ),
      ),
    );
  }

  Widget _buildTaskSummary(List<Map<String, dynamic>> tasks) {
    return Column(
      children: [
        _buildTaskSection(
          _getDayTitle(_selectedDate),
          tasks,
        ),
      ],
    );
  }

  String _getDayTitle(DateTime date) {
    final now = DateTime.now();
    final tomorrow = now.add(const Duration(days: 1));
    if (_isSameDay(date, now)) return 'Сегодня';
    if (_isSameDay(date, tomorrow)) return 'Завтра';
    return '${date.day}.${date.month}.${date.year}';
  }

  Widget _buildTaskSection(String title, List<Map<String, dynamic>> tasks) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.info,
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
          ...tasks.map((task) {
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
                      if (value != null) {
                        final id = task['id'] as String;
                        ref.read(calendarProvider.notifier).toggleTaskById(id);
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

  void _showAddTaskModal(BuildContext context, CalendarNotifier notifier) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => _AddTaskForm(
        notifier: notifier,
        initialDate: _selectedDate,
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
  bool _hasReminder = false;

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
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
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
                fillColor: AppColors.background,
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
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
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
                            fontWeight: isSelected
                                ? FontWeight.w600
                                : FontWeight.normal,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Text(
                  'Напомнить',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textGrey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Spacer(),
                Switch(
                  value: _hasReminder,
                  onChanged: (v) => setState(() => _hasReminder = v),
                  activeThumbColor: AppColors.primaryBright,
                ),
              ],
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
                      borderRadius: BorderRadius.circular(20)),
                  textStyle: const TextStyle(
                      fontWeight: FontWeight.w600, fontSize: 16),
                ),
                child: const Text('Добавить задачу'),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
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
      hasReminder: _hasReminder,
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
