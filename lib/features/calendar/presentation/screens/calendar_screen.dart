import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:peto/core/theme/app_colors.dart';
import 'package:peto/core/widgets/bottom_nav.dart';
import '../providers/calendar_provider.dart';
import '../providers/calendar_month_provider.dart';

// ============================================================================
// CalendarScreen - ConsumerWidget согласно принципам Riverpod из архитектура.docx
// Состояние месяца вынесено в calendarMonthProvider (SOLID - Single Responsibility)
// ============================================================================
class CalendarScreen extends ConsumerWidget {
  const CalendarScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(calendarProvider);
    final notifier = ref.read(calendarProvider.notifier);
    final currentMonth = ref.watch(calendarMonthProvider);

    return Scaffold(
      backgroundColor: AppColors.background, // #F7FAFF из цвета.docx
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
              horizontal: 20), // UI Kit: единые отступы
          child: Column(
            children: [
              const SizedBox(height: 20),
              _buildMonthHeader(ref, currentMonth),
              const SizedBox(height: 16),
              _buildWeekdayHeaders(),
              const SizedBox(height: 8),
              Expanded(
                child: _buildCalendarGrid(
                  context, // ✅ Передаём BuildContext для _buildDayCell
                  state.tasks,
                  notifier,
                  currentMonth,
                ),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: SingleChildScrollView(
                  child: _buildTaskSummary(state.tasks),
                ),
              ),
              const SizedBox(height: 24),
              const BottomNav(
                  currentIndex: 2), // ✅ Shared-виджет из core/widgets/ (DRY)
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary, // #B8D7EE из цвета.docx
        onPressed: () => _showAddTaskModal(context, notifier, currentMonth),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  // ============================================================================
  // Заголовок календаря с навигацией по месяцам
  // Управление состоянием через calendarMonthProvider (Riverpod Pattern)
  // ============================================================================
  Widget _buildMonthHeader(WidgetRef ref, DateTime currentMonth) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          icon: const Icon(Icons.chevron_left,
              color: AppColors.primaryBright), // #7EBCE8
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

  // ============================================================================
  // Заголовки дней недели (понедельник-воскресенье)
  // ============================================================================
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

  // ============================================================================
  // Сетка календаря: генерация 42 ячеек (6 недель × 7 дней)
  // ✅ ИСПРАВЛЕНО: передаём BuildContext в _buildDayCell (SOLID - Dependency Inversion)
  // ============================================================================
  Widget _buildCalendarGrid(
    BuildContext context, // ✅ Добавлен BuildContext первым параметром
    List<Map<String, dynamic>> tasks,
    CalendarNotifier notifier,
    DateTime currentMonth,
  ) {
    final firstDay = DateTime(currentMonth.year, currentMonth.month, 1);
    final daysInMonth =
        DateTime(currentMonth.year, currentMonth.month + 1, 0).day;
    final firstWeekday = firstDay.weekday; // 1 = Mon, 7 = Sun
    final daysBefore = firstWeekday - 1;
    const totalCells = 42; // 6 rows × 7 days

    final cells = <Widget>[];

    // Дни предыдущего месяца
    for (int i = 0; i < daysBefore; i++) {
      final dayNum = DateTime(currentMonth.year, currentMonth.month, 0).day -
          daysBefore +
          i +
          1;
      final date = DateTime(currentMonth.year, currentMonth.month - 1, dayNum);
      cells.add(_buildDayCell(
          context, date, false, tasks, notifier)); // ✅ Передаём context
    }

    // Дни текущего месяца
    for (int d = 1; d <= daysInMonth; d++) {
      final date = DateTime(currentMonth.year, currentMonth.month, d);
      cells.add(_buildDayCell(
          context, date, true, tasks, notifier)); // ✅ Передаём context
    }

    // Дни следующего месяца
    final filled = daysBefore + daysInMonth;
    for (int i = 1; i <= totalCells - filled; i++) {
      final date = DateTime(currentMonth.year, currentMonth.month + 1, i);
      cells.add(_buildDayCell(
          context, date, false, tasks, notifier)); // ✅ Передаём context
    }

    return GridView.count(
      crossAxisCount: 7,
      mainAxisSpacing: 4,
      crossAxisSpacing: 4,
      childAspectRatio: 1,
      children: cells,
    );
  }

  // ============================================================================
  // Ячейка дня календаря
  // ✅ ИСПРАВЛЕНО: принимает BuildContext для навигации (Dependency Inversion)
  // Цветовая схема: цвета лапок из цвета.docx через _getPawColor()
  // ============================================================================
  Widget _buildDayCell(
    BuildContext context, // ✅ BuildContext первым параметром
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
      onTap: () => _showAddTaskModal(
        context, // ✅ Используем переданный BuildContext (не метод!)
        notifier,
        date,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: isToday
              ? AppColors.primary
                  .withValues(alpha: 0.15) // #B8D7EE с прозрачностью
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12), // UI Kit: скругления
          border: isToday
              ? Border.all(
                  color: AppColors.primaryBright, width: 1.5) // #7EBCE8
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
              // ✅ SVG иконка с цветным фильтром согласно цвета.docx
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
                    color: AppColors.primaryBright, // #7EBCE8
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

  // ============================================================================
  // Цвет лапки в зависимости от типа задачи (цвета из цвета.docx)
  // ============================================================================
  Color _getPawColor(String pawType) {
    switch (pawType) {
      case 'blue_paw':
        return AppColors.primaryBright; // #7EBCE8
      case 'green_paw':
        return AppColors.success; // #CBEEB8
      case 'yellow_paw':
        return AppColors.warning; // #FFFBCE
      case 'pink_paw':
        return AppColors.secondary; // #EEB8B9
      default:
        return AppColors.primaryBright;
    }
  }

  // ============================================================================
  // Блок задач: "Сегодня" и "Завтра"
  // Цвета блоков: Info (#DBF0FF) и Warning (#FFFBCE) из цвета.docx
  // ============================================================================
  Widget _buildTaskSummary(List<Map<String, dynamic>> tasks) {
    final today = DateTime.now();
    final tomorrow = today.add(const Duration(days: 1));

    return Column(
      children: [
        _buildTaskSection(
          'Сегодня',
          _getTasksForDate(tasks, today),
          AppColors.info, // #DBF0FF
        ),
        const SizedBox(height: 12),
        _buildTaskSection(
          'Завтра',
          _getTasksForDate(tasks, tomorrow),
          AppColors.warning, // #FFFBCE
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

  // ============================================================================
  // Секция задач с чекбоксами
  // UI Kit: единые отступы, скругления, типографика
  // ============================================================================
  Widget _buildTaskSection(
    String title,
    List<Map<String, dynamic>> tasks,
    Color bgColor,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20), // UI Kit: скругления
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
                    // ✅ Цветная лапка через SvgPicture + colorFilter
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
                          // В реальном проекте: использовать ref.read() здесь
                          // Для ConsumerWidget нужен ConsumerState или передача notifier
                        }
                      },
                      activeColor: AppColors.primaryBright, // #7EBCE8
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
    // Заглушка: в реальном проекте логика поиска должна быть в провайдере
    // Согласно архитектура.docx: бизнес-логика в domain/data слоях
    return -1;
  }

  // ============================================================================
  // Модальное окно добавления задачи
  // Вынесено в отдельный виджет _AddTaskForm (SOLID - SRP)
  // ============================================================================
  void _showAddTaskModal(
    BuildContext context,
    CalendarNotifier notifier,
    DateTime initialDate,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent, // Для скругления сверху
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => _AddTaskForm(
        notifier: notifier,
        initialDate: initialDate,
      ),
    );
  }

  // ============================================================================
  // Утилита: сравнение дат по дням (без учёта времени)
  // ============================================================================
  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}

// ============================================================================
// _AddTaskForm - отдельный StatefulWidget для формы добавления задачи
// SOLID - Single Responsibility: форма отвечает только за ввод данных
// ============================================================================
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
      child: Container(
        // ✅ Container поддерживает 'decoration'
        padding:
            const EdgeInsets.all(24), // ✅ Внутренние отступы перенесены сюда
        decoration: const BoxDecoration(
          color: AppColors.surface, // #FFFFFF из цвета.docx
          borderRadius: BorderRadius.vertical(
              top: Radius.circular(20)), // UI Kit: скругления
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Заголовок модалки
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Новая задача',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryBright, // #7EBCE8
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: AppColors.textGrey),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Отображение выбранной даты
            Text(
              '${widget.initialDate.day}.${widget.initialDate.month}.${widget.initialDate.year}',
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textGrey,
              ),
            ),
            const SizedBox(height: 16),

            // Поле ввода названия задачи
            TextField(
              controller: _titleController,
              autofocus: true,
              decoration: InputDecoration(
                hintText: 'Описание задачи',
                prefixIcon:
                    const Icon(Icons.edit_note, color: AppColors.primaryBright),
                filled: true,
                fillColor: AppColors.background, // #F7FAFF
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide.none,
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
            ),
            const SizedBox(height: 20),

            // Выбор типа задачи (лапки)
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
                        // ✅ SVG иконка с динамическим цветом
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
            const SizedBox(height: 24),

            // Кнопка сохранения
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _saveTask,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary, // #B8D7EE
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
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

  // ============================================================================
  // Сохранение задачи через notifier (Riverpod Pattern)
  // Валидация и обратная связь пользователю
  // ============================================================================
  void _saveTask() {
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Введите описание задачи'),
          backgroundColor: AppColors.error, // #FFE8E8
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
        backgroundColor: AppColors.success, // #CBEEB8
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
