import 'package:flutter/material.dart';
import 'package:peto/core/theme/app_colors.dart';

enum AppointmentType { clinic, grooming, vaccination, other }

class Appointment {
  final String id;
  final AppointmentType type;
  final String title;
  final DateTime date;
  final TimeOfDay time;
  final String petId;
  final String? notes;

  Appointment({
    required this.id,
    required this.type,
    required this.title,
    required this.date,
    required this.time,
    required this.petId,
    this.notes,
  });
}

class AppointmentModal extends StatefulWidget {
  final AppointmentType type;
  final String title;
  final Function(Appointment) onSaved;

  const AppointmentModal({
    super.key,
    required this.type,
    required this.title,
    required this.onSaved,
  });

  @override
  State<AppointmentModal> createState() => _AppointmentModalState();
}

class _AppointmentModalState extends State<AppointmentModal> {
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  String? _selectedPetId; // В реальном проекте — список питомцев из провайдера
  final _notesController = TextEditingController();

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Color _getTypeColor() {
    switch (widget.type) {
      case AppointmentType.clinic:
        return AppColors.success;
      case AppointmentType.grooming:
        return AppColors.info;
      case AppointmentType.vaccination:
        return AppColors.secondary;
      case AppointmentType.other:
        return AppColors.warning;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        left: 24,
        right: 24,
        top: 24,
      ),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildHeader(),
          const SizedBox(height: 24),
          _buildPetSelector(),
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

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          widget.title,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: _getTypeColor(),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.close, color: AppColors.textGrey),
          onPressed: () => Navigator.pop(context),
        ),
      ],
    );
  }

  Widget _buildPetSelector() {
    // Заглушка: в реальном проекте — список из homeProvider
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          const Icon(Icons.pets, color: AppColors.primaryBright),
          const SizedBox(width: 8),
          const Text('Выберите питомца',
              style: TextStyle(color: AppColors.textGrey)),
          const Spacer(),
          Icon(Icons.arrow_drop_down, color: _getTypeColor()),
        ],
      ),
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
          builder: (ctx, child) => Theme(
            data: Theme.of(ctx).copyWith(
              colorScheme: ColorScheme.light(primary: _getTypeColor()),
            ),
            child: child!,
          ),
        );
        if (picked != null && mounted) {
          setState(() => _selectedDate = picked);
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          border: Border.all(color: _getTypeColor(), width: 1.5),
          borderRadius: BorderRadius.circular(20),
          color: AppColors.background,
        ),
        child: Row(
          children: [
            Icon(Icons.calendar_today_outlined,
                color: _getTypeColor(), size: 20),
            const SizedBox(width: 8),
            Text(
              '${_selectedDate.day}.${_selectedDate.month}.${_selectedDate.year}',
              style: const TextStyle(
                  color: AppColors.textDark,
                  fontWeight: FontWeight.w500,
                  fontSize: 14),
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
          builder: (ctx, child) => Theme(
            data: Theme.of(ctx).copyWith(
              colorScheme: ColorScheme.light(primary: _getTypeColor()),
            ),
            child: child!,
          ),
        );
        if (picked != null && mounted) {
          setState(() => _selectedTime = picked);
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          border: Border.all(color: _getTypeColor(), width: 1.5),
          borderRadius: BorderRadius.circular(20),
          color: AppColors.background,
        ),
        child: Row(
          children: [
            Icon(Icons.access_time_outlined, color: _getTypeColor(), size: 20),
            const SizedBox(width: 8),
            Text(
              _selectedTime.format(context),
              style: const TextStyle(
                  color: AppColors.textDark,
                  fontWeight: FontWeight.w500,
                  fontSize: 14),
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
              fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _notesController,
          maxLines: 3,
          decoration: InputDecoration(
            hintText: 'Дополнительная информация...',
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
          backgroundColor: _getTypeColor(),
          foregroundColor: Colors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
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
            backgroundColor: AppColors.error),
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
