import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:peto/core/theme/app_colors.dart';
import 'package:peto/features/home/presentation/providers/home_provider.dart';

// ============================================================================
// Модель записи (согласно domain-слою из архитектура.docx)
// ✅ ИСПРАВЛЕНО: убран 'const' т.к. конструктор содержит не-константные значения
// ============================================================================
class Appointment {
  final String id;
  final String type;
  final String title;
  final DateTime date;
  final TimeOfDay time;
  final String petId;
  final String? notes;
  final DateTime createdAt;

  // ✅ Убран 'const' — DateTime.now() не является константным выражением
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

// ============================================================================
// AppointmentForm - ConsumerStatefulWidget для доступа к homeProvider
// SOLID - Single Responsibility: форма отвечает только за ввод данных записи
// ============================================================================
class AppointmentForm extends ConsumerStatefulWidget {
  final String type;
  final String title;
  final Function(Appointment) onSaved;

  const AppointmentForm({
    super.key,
    required this.type,
    required this.title,
    required this.onSaved,
  });

  @override
  ConsumerState<AppointmentForm> createState() => _AppointmentFormState();
}

class _AppointmentFormState extends ConsumerState<AppointmentForm> {
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
          _buildFormHeader(),
          const SizedBox(height: 24),
          _buildPetSelector(pets),
          const SizedBox(height: 16),
          _buildDatePicker(),
          const SizedBox(height: 16),
          _buildTimePicker(),
          const SizedBox(height: 16),
          _buildNotesField(),
          const SizedBox(height: 24),
          _buildSaveButton(),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildFormHeader() {
    return Row(
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
    );
  }

  Color _getTypeColor(String type) {
    // ✅ Цветовая схема из цвета.docx
    switch (type) {
      case 'clinic':
        return AppColors.success; // #CBEEB8
      case 'grooming':
        return AppColors.info; // #DBF0FF
      case 'vaccination':
        return AppColors.secondary; // #EEB8B9
      case 'other':
        return AppColors.warning; // #FFFBCE
      default:
        return AppColors.primaryBright; // #7EBCE8
    }
  }

  Widget _buildPetSelector(List<Map<String, dynamic>> pets) {
    if (pets.isEmpty) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.surface, // #FFFFFF
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Row(
          children: [
            Icon(Icons.pets_outlined, color: AppColors.textGrey),
            SizedBox(width: 8),
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
                return DropdownMenuItem<String>(
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
            // ✅ ИСПРАВЛЕНО: правильный синтаксис Theme с именованным параметром 'data:'
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
          color: AppColors.background, // #F7FAFF
        ),
        child: Row(
          children: [
            Icon(
              Icons.calendar_today_outlined,
              color: _getTypeColor(widget.type),
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              '${_selectedDate.day}.${_selectedDate.month}.${_selectedDate.year}',
              style: const TextStyle(
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
            // ✅ ИСПРАВЛЕНО: правильный синтаксис Theme с именованным параметром 'data:'
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
            Icon(
              Icons.access_time_outlined,
              color: _getTypeColor(widget.type),
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              _selectedTime.format(context),
              style: const TextStyle(
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
          backgroundColor: AppColors.error, // #FFE8E8
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
