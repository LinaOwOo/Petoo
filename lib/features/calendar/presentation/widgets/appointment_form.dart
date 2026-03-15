import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:peto/core/theme/app_colors.dart';
import '../providers/calendar_provider.dart';

class Appointment {
  final String id;
  final String type; // 'clinic', 'grooming', 'vaccination', 'other'
  final String title;
  final DateTime date;
  final TimeOfDay time;
  final String petId;
  final String? notes;
  final DateTime createdAt;

  Appointment({
    required this.id,
    required this.type,
    required this.title,
    required this.date,
    required this.time,
    required this.petId,
    this.notes,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Appointment copyWith({
    String? id,
    String? type,
    String? title,
    DateTime? date,
    TimeOfDay? time,
    String? petId,
    String? notes,
    DateTime? createdAt,
  }) {
    return Appointment(
      id: id ?? this.id,
      type: type ?? this.type,
      title: title ?? this.title,
      date: date ?? this.date,
      time: time ?? this.time,
      petId: petId ?? this.petId,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

class _AppointmentForm extends ConsumerStatefulWidget {
  final String type;
  final String title;
  final Function(Appointment) onSaved;

  const _AppointmentForm({
    required this.type,
    required this.title,
    required this.onSaved,
  });

  @override
  ConsumerState<_AppointmentForm> createState() => _AppointmentFormState();
}

class _AppointmentFormState extends ConsumerState<_AppointmentForm> {
  final _notesController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  String? _selectedPetId;

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final homeState = ref.watch(homeProvider);
    final pets = homeState.pets;

    // Авто-выбор первого питомца если есть
    _selectedPetId ??= pets.isNotEmpty ? pets.first['id'] as String? : null;

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
          // Заголовок
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                widget.title,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: _getTypeColor(widget.type),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close, color: AppColors.textGrey),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Выбор питомца
          _buildPetSelector(pets),
          const SizedBox(height: 16),

          // Выбор даты
          _buildDatePicker(),
          const SizedBox(height: 16),

          // Выбор времени
          _buildTimePicker(),
          const SizedBox(height: 16),

          // Заметки (опционально)
          _buildNotesField(),
          const SizedBox(height: 24),

          // Кнопка сохранения
          _buildSaveButton(),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Color _getTypeColor(String type) {
    switch (type) {
      case 'clinic':
        return AppColors.success;
      case 'grooming':
        return AppColors.info;
      case 'vaccination':
        return AppColors.secondary;
      case 'other':
        return AppColors.warning;
      default:
        return AppColors.primaryBright;
    }
  }

  Widget _buildPetSelector(List<Map<String, dynamic>> pets) {
    if (pets.isEmpty) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            const Icon(Icons.pets_outlined, color: AppColors.textGrey),
            const SizedBox(width: 8),
            Text(
              'Сначала добавьте питомца',
              style: TextStyle(color: AppColors.textGrey),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Питомец',
          style: TextStyle(
            fontSize: 14,
            color: AppColors.textGrey,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(20),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedPetId,
              isExpanded: true,
              items: pets.map((pet) {
                return DropdownMenuItem(
                  value: pet['id'] as String,
                  child: Row(
                    children: [
                      const Icon(Icons.pets,
                          size: 16, color: AppColors.primaryBright),
                      const SizedBox(width: 8),
                      Text(pet['name'] as String),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() => _selectedPetId = value);
                }
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDatePicker() {
    return GestureDetector(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: _selectedDate,
          firstDate: DateTime.now(),
          lastDate: DateTime.now().add(const Duration(days: 365)),
          builder: (context, child) {
            return Theme(
              data: Theme.of(context).copyWith(
                colorScheme: ColorScheme.light(
                  primary: _getTypeColor(widget.type),
                ),
              ),
              child: child!,
            );
          },
        );
        if (picked != null) {
          setState(() => _selectedDate = picked);
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          border: Border.all(color: _getTypeColor(widget.type), width: 1.5),
          borderRadius: BorderRadius.circular(20),
          color: AppColors.background,
        ),
        child: Row(
          children: [
            Icon(Icons.calendar_today_outlined,
                color: _getTypeColor(widget.type), size: 20),
            const SizedBox(width: 8),
            Text(
              '${_selectedDate.day}.${_selectedDate.month}.${_selectedDate.year}',
              style: TextStyle(
                color: AppColors.textDark,
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimePicker() {
    return GestureDetector(
      onTap: () async {
        final picked = await showTimePicker(
          context: context,
          initialTime: _selectedTime,
          builder: (context, child) {
            return Theme(
              data: Theme.of(context).copyWith(
                colorScheme: ColorScheme.light(
                  primary: _getTypeColor(widget.type),
                ),
              ),
              child: child!,
            );
          },
        );
        if (picked != null) {
          setState(() => _selectedTime = picked);
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          border: Border.all(color: _getTypeColor(widget.type), width: 1.5),
          borderRadius: BorderRadius.circular(20),
          color: AppColors.background,
        ),
        child: Row(
          children: [
            Icon(Icons.access_time_outlined,
                color: _getTypeColor(widget.type), size: 20),
            const SizedBox(width: 8),
            Text(
              _selectedTime.format(context),
              style: TextStyle(
                color: AppColors.textDark,
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotesField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Заметки (опционально)',
          style: TextStyle(
            fontSize: 14,
            color: AppColors.textGrey,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _notesController,
          maxLines: 3,
          decoration: InputDecoration(
            hintText: 'Дополнительная информация...',
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
      ],
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _saveAppointment,
        style: ElevatedButton.styleFrom(
          backgroundColor: _getTypeColor(widget.type),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
        ),
        child: Text('Записать на ${widget.title.toLowerCase()}'),
      ),
    );
  }

  void _saveAppointment() {
    if (_selectedPetId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Выберите питомца'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final appointment = Appointment(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: widget.type,
      title: widget.title,
      date: _selectedDate,
      time: _selectedTime,
      petId: _selectedPetId!,
      notes: _notesController.text.trim().isEmpty
          ? null
          : _notesController.text.trim(),
    );

    widget.onSaved(appointment);
    Navigator.pop(context);
  }
}
