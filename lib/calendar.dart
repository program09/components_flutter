import 'package:calendar_view/calendar_view.dart';
import 'package:flutter/material.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  final EventController _eventController = EventController();
  CalendarViewType _currentView = CalendarViewType.month;
  DateTime _selectedDate = DateTime.now();
  List<CalendarEventData> _selectedEvents = [];

  @override
  void initState() {
    super.initState();
    _addSampleEvents();
    _loadEventsForDate(_selectedDate);
  }

  void _addSampleEvents() {
    final events = [
      CalendarEventData(
        title: "Consulta médica",
        date: DateTime.now(),
        description: "Control anual con cardiólogo",
        startTime: DateTime.now().add(const Duration(hours: 1)),
        endTime: DateTime.now().add(const Duration(hours: 2)),
        color: Colors.blue,
      ),
      CalendarEventData(
        title: "Tomar medicina",
        date: DateTime.now().add(const Duration(days: 1)),
        description: "Antibiótico cada 8 horas",
        startTime: DateTime.now().add(const Duration(days: 1, hours: 8)),
        endTime: DateTime.now().add(
          const Duration(days: 1, hours: 8, minutes: 30),
        ),
        color: Colors.green,
      ),
    ];

    _eventController.addAll(events);

    // Agregar eventos recurrentes de ejemplo
    _addMedicineSchedule();
  }

  void _addMedicineSchedule() {
    // Medicina cada 8 horas por 5 días
    final startDate = DateTime.now();
    final endDate = DateTime.now().add(const Duration(days: 5));

    DateTime currentDate = startDate;
    while (currentDate.isBefore(endDate)) {
      for (int hour = 8; hour < 24; hour += 8) {
        final event = CalendarEventData(
          title: "Tomar medicina",
          date: currentDate,
          description: "Antibiótico - Dosis cada 8 horas",
          startTime: DateTime(
            currentDate.year,
            currentDate.month,
            currentDate.day,
            hour,
            0,
          ),
          endTime: DateTime(
            currentDate.year,
            currentDate.month,
            currentDate.day,
            hour,
            30,
          ),
          color: Colors.green,
        );
        _eventController.add(event);
      }
      currentDate = currentDate.add(const Duration(days: 1));
    }
  }

  void _loadEventsForDate(DateTime date) {
    final allEvents = _eventController.events;
    _selectedEvents = allEvents.where((event) {
      final eventDate = event.date;
      return eventDate.year == date.year &&
          eventDate.month == date.month &&
          eventDate.day == date.day;
    }).toList();
    setState(() {});
  }

  Color _getRandomColor() {
    final colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.red,
      Colors.teal,
      Colors.indigo,
      Colors.amber,
      Colors.cyan,
      Colors.deepOrange,
    ];
    return colors[DateTime.now().millisecond % colors.length];
  }

  void _showAddEventDialog(DateTime date, [TimeOfDay? initialTime]) {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    TimeOfDay startTime = initialTime ?? const TimeOfDay(hour: 10, minute: 0);
    TimeOfDay endTime = initialTime != null
        ? TimeOfDay(hour: initialTime.hour + 1, minute: initialTime.minute)
        : const TimeOfDay(hour: 11, minute: 0);
    int reminderMinutes = 15;
    bool isRecurring = false;
    int recurrenceDays = 1;
    int recurrenceInterval = 1; // días
    int recurrenceTimesPerDay = 1; // veces por día

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(
            'Agregar Evento - ${date.day}/${date.month}/${date.year}',
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    labelText: 'Título del evento*',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Descripción',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: ListTile(
                        title: const Text('Hora inicio'),
                        subtitle: Text(
                          '${startTime.hour.toString().padLeft(2, '0')}:${startTime.minute.toString().padLeft(2, '0')}',
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.access_time, size: 20),
                          onPressed: () async {
                            final TimeOfDay? pickedTime = await showTimePicker(
                              context: context,
                              initialTime: startTime,
                            );
                            if (pickedTime != null) {
                              setDialogState(() {
                                startTime = pickedTime;
                                // Ajustar hora fin automáticamente
                                endTime = TimeOfDay(
                                  hour: pickedTime.hour + 1,
                                  minute: pickedTime.minute,
                                );
                              });
                            }
                          },
                        ),
                      ),
                    ),
                    Expanded(
                      child: ListTile(
                        title: const Text('Hora fin'),
                        subtitle: Text(
                          '${endTime.hour.toString().padLeft(2, '0')}:${endTime.minute.toString().padLeft(2, '0')}',
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.access_time, size: 20),
                          onPressed: () async {
                            final TimeOfDay? pickedTime = await showTimePicker(
                              context: context,
                              initialTime: endTime,
                            );
                            if (pickedTime != null) {
                              setDialogState(() {
                                endTime = pickedTime;
                              });
                            }
                          },
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ListTile(
                  title: const Text('Recordatorio'),
                  subtitle: Text('$reminderMinutes minutos antes'),
                  trailing: DropdownButton<int>(
                    value: reminderMinutes,
                    items: [0, 5, 10, 15, 30, 60, 120, 1440]
                        .map(
                          (minutes) => DropdownMenuItem(
                            value: minutes,
                            child: Text(
                              minutes == 0
                                  ? 'Sin recordatorio'
                                  : minutes == 1440
                                  ? '1 día antes'
                                  : '$minutes minutos antes',
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      setDialogState(() {
                        reminderMinutes = value!;
                      });
                    },
                  ),
                ),
                const SizedBox(height: 16),
                SwitchListTile(
                  title: const Text('Evento recurrente'),
                  subtitle: const Text('Repetir este evento'),
                  value: isRecurring,
                  onChanged: (value) {
                    setDialogState(() {
                      isRecurring = value;
                    });
                  },
                ),
                if (isRecurring) ...[
                  const SizedBox(height: 12),
                  ListTile(
                    title: const Text('Repetir cada'),
                    subtitle: Text('$recurrenceInterval día(s)'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.remove, size: 20),
                          onPressed: () {
                            if (recurrenceInterval > 1) {
                              setDialogState(() {
                                recurrenceInterval--;
                              });
                            }
                          },
                        ),
                        Text('$recurrenceInterval'),
                        IconButton(
                          icon: const Icon(Icons.add, size: 20),
                          onPressed: () {
                            setDialogState(() {
                              recurrenceInterval++;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                  ListTile(
                    title: const Text('Por cuántos días'),
                    subtitle: Text('$recurrenceDays día(s)'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.remove, size: 20),
                          onPressed: () {
                            if (recurrenceDays > 1) {
                              setDialogState(() {
                                recurrenceDays--;
                              });
                            }
                          },
                        ),
                        Text('$recurrenceDays'),
                        IconButton(
                          icon: const Icon(Icons.add, size: 20),
                          onPressed: () {
                            setDialogState(() {
                              recurrenceDays++;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                  ListTile(
                    title: const Text('Veces por día'),
                    subtitle: Text('$recurrenceTimesPerDay vez(es)'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.remove, size: 20),
                          onPressed: () {
                            if (recurrenceTimesPerDay > 1) {
                              setDialogState(() {
                                recurrenceTimesPerDay--;
                              });
                            }
                          },
                        ),
                        Text('$recurrenceTimesPerDay'),
                        IconButton(
                          icon: const Icon(Icons.add, size: 20),
                          onPressed: () {
                            setDialogState(() {
                              recurrenceTimesPerDay++;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                if (titleController.text.isNotEmpty) {
                  if (isRecurring) {
                    _addRecurringEvent(
                      title: titleController.text,
                      description: descriptionController.text,
                      startDate: date,
                      recurrenceDays: recurrenceDays,
                      recurrenceInterval: recurrenceInterval,
                      timesPerDay: recurrenceTimesPerDay,
                      startTime: startTime,
                      endTime: endTime,
                      reminderMinutes: reminderMinutes,
                    );
                  } else {
                    _addSingleEvent(
                      title: titleController.text,
                      description: descriptionController.text,
                      date: date,
                      startTime: startTime,
                      endTime: endTime,
                      reminderMinutes: reminderMinutes,
                    );
                  }
                  Navigator.of(context).pop();
                }
              },
              child: Text(isRecurring ? 'Agregar Recurrente' : 'Guardar'),
            ),
          ],
        ),
      ),
    );
  }

  void _addSingleEvent({
    required String title,
    required String description,
    required DateTime date,
    required TimeOfDay startTime,
    required TimeOfDay endTime,
    required int reminderMinutes,
  }) {
    final startDateTime = DateTime(
      date.year,
      date.month,
      date.day,
      startTime.hour,
      startTime.minute,
    );

    final endDateTime = DateTime(
      date.year,
      date.month,
      date.day,
      endTime.hour,
      endTime.minute,
    );

    final event = CalendarEventData(
      title: title,
      date: date,
      description: _buildEventDescription(description, reminderMinutes),
      startTime: startDateTime,
      endTime: endDateTime,
      color: _getRandomColor(),
    );

    _eventController.add(event);
    _loadEventsForDate(_selectedDate);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Evento "$title" agregado'),
        action: SnackBarAction(
          label: 'Deshacer',
          onPressed: () {
            _eventController.remove(event);
            _loadEventsForDate(_selectedDate);
          },
        ),
      ),
    );
  }

  void _addRecurringEvent({
    required String title,
    required String description,
    required DateTime startDate,
    required int recurrenceDays,
    required int recurrenceInterval,
    required int timesPerDay,
    required TimeOfDay startTime,
    required TimeOfDay endTime,
    required int reminderMinutes,
  }) {
    final List<CalendarEventData> events = [];
    int eventsCreated = 0;

    for (int day = 0; day < recurrenceDays; day += recurrenceInterval) {
      final currentDate = startDate.add(Duration(days: day));

      for (int timeIndex = 0; timeIndex < timesPerDay; timeIndex++) {
        final timeOffset = timeIndex * (24 ~/ timesPerDay);
        final eventStartTime = TimeOfDay(
          hour: (startTime.hour + timeOffset) % 24,
          minute: startTime.minute,
        );
        final eventEndTime = TimeOfDay(
          hour: (endTime.hour + timeOffset) % 24,
          minute: endTime.minute,
        );

        final startDateTime = DateTime(
          currentDate.year,
          currentDate.month,
          currentDate.day,
          eventStartTime.hour,
          eventStartTime.minute,
        );

        final endDateTime = DateTime(
          currentDate.year,
          currentDate.month,
          currentDate.day,
          eventEndTime.hour,
          eventEndTime.minute,
        );

        final event = CalendarEventData(
          title: timesPerDay > 1
              ? '$title (${timeIndex + 1}/$timesPerDay)'
              : title,
          date: currentDate,
          description: _buildEventDescription(description, reminderMinutes),
          startTime: startDateTime,
          endTime: endDateTime,
          color: _getRandomColor(),
        );

        events.add(event);
        eventsCreated++;
      }
    }

    _eventController.addAll(events);
    _loadEventsForDate(_selectedDate);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$eventsCreated eventos recurrentes agregados'),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  String _buildEventDescription(String description, int reminderMinutes) {
    String reminderText = '';
    if (reminderMinutes > 0) {
      if (reminderMinutes == 1440) {
        reminderText = 'Recordatorio: 1 día antes';
      } else if (reminderMinutes >= 60) {
        final hours = reminderMinutes ~/ 60;
        reminderText = 'Recordatorio: $hours hora(s) antes';
      } else {
        reminderText = 'Recordatorio: $reminderMinutes minutos antes';
      }
    }

    return description.isNotEmpty
        ? '$description\n$reminderText'
        : reminderText.isNotEmpty
        ? reminderText
        : 'Sin descripción';
  }

  void _showEventDetails(CalendarEventData event) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(event.title ?? 'Evento'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow(
                'Descripción:',
                event.description ?? "No disponible",
              ),
              _buildDetailRow('Fecha:', _formatDate(event.date)),
              _buildDetailRow('Hora inicio:', _formatTime(event.startTime)),
              _buildDetailRow('Hora fin:', _formatTime(event.endTime)),
              _buildDetailRow(
                'Duración:',
                _calculateDuration(event.startTime, event.endTime),
              ),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                height: 20,
                decoration: BoxDecoration(
                  color: event.color ?? Colors.blue,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cerrar'),
          ),
          TextButton(
            onPressed: () {
              _eventController.remove(event);
              _loadEventsForDate(_selectedDate);
              Navigator.of(context).pop();
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('Evento eliminado')));
            },
            child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return "No disponible";
    return "${date.day}/${date.month}/${date.year}";
  }

  String _formatTime(DateTime? time) {
    if (time == null) return "No disponible";
    return "${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}";
  }

  String _calculateDuration(DateTime? start, DateTime? end) {
    if (start == null || end == null) return "No disponible";

    final duration = end.difference(start);
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);

    if (hours > 0) {
      return minutes > 0 ? '$hours h $minutes min' : '$hours horas';
    } else {
      return '$minutes minutos';
    }
  }

  Widget _buildCalendarView() {
    switch (_currentView) {
      case CalendarViewType.month:
        return MonthView(
          minMonth: DateTime(2020),
          maxMonth: DateTime(2030),
          initialMonth: _selectedDate,
          cellAspectRatio: 1.2,
          onPageChange: (date, pageIndex) {
            setState(() {
              _selectedDate = date;
            });
            _loadEventsForDate(date);
          },
          onCellTap: (events, date) {
            setState(() {
              _selectedDate = date;
            });
            _loadEventsForDate(date);
          },
          startDay: WeekDays.monday,
          onEventTap: (event, date) {
            _showEventDetails(event);
          },
          onDateLongPress: (date) {
            _showAddEventDialog(date);
          },
        );
      case CalendarViewType.week:
        return WeekView(
          minDay: DateTime(2020),
          maxDay: DateTime(2030),
          initialDay: _selectedDate,
          onPageChange: (date, pageIndex) {
            setState(() {
              _selectedDate = date;
            });
            _loadEventsForDate(date);
          },
          onDateTap: (date) {
            setState(() {
              _selectedDate = date;
            });
            _loadEventsForDate(date);
          },
          onEventTap: (events, date) {
            _showEventDetails(events.first);
          },
          startDay: WeekDays.monday,
        );
      case CalendarViewType.day:
        return DayView(
          minDay: DateTime(2020),
          maxDay: DateTime(2030),
          initialDay: _selectedDate,
          onPageChange: (date, pageIndex) {
            setState(() {
              _selectedDate = date;
            });
            _loadEventsForDate(date);
          },
          onDateTap: (date) {
            setState(() {
              _selectedDate = date;
            });
            _loadEventsForDate(date);
          },
          onEventTap: (event, date) {
            _showEventDetails(event.first);
          },
          onTimestampTap: (date) {
            final time = TimeOfDay(hour: date.hour, minute: date.minute);
            _showAddEventDialog(date, time);
          },
        );
    }
  }

  Widget _buildEventsList() {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: Colors.grey[50],
        border: const Border(top: BorderSide(color: Colors.grey)),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Text(
                  'Eventos para ${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.add_circle, color: Colors.blue),
                  onPressed: () => _showAddEventDialog(_selectedDate),
                  tooltip: 'Agregar evento',
                ),
              ],
            ),
          ),
          Expanded(
            child: _selectedEvents.isEmpty
                ? const Center(
                    child: Text(
                      'No hay eventos para esta fecha',
                      style: TextStyle(color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.only(bottom: 16),
                    itemCount: _selectedEvents.length,
                    itemBuilder: (context, index) {
                      final event = _selectedEvents[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 4,
                        ),
                        child: ListTile(
                          leading: Container(
                            width: 8,
                            decoration: BoxDecoration(
                              color: event.color ?? Colors.blue,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          title: Text(
                            event.title ?? 'Sin título',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (event.description != null)
                                Text(
                                  event.description!,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              const SizedBox(height: 4),
                              Text(
                                '${_formatTime(event.startTime)} - ${_formatTime(event.endTime)}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.info_outline, size: 20),
                            onPressed: () => _showEventDetails(event),
                          ),
                          onTap: () => _showEventDetails(event),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CalendarControllerProvider(
      controller: _eventController,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Calendario Médico'),
          actions: [
            IconButton(
              icon: const Icon(Icons.medical_services),
              onPressed: () => _showAddMedicineDialog(),
              tooltip: 'Agregar horario de medicina',
            ),
            PopupMenuButton<CalendarViewType>(
              onSelected: (type) {
                setState(() {
                  _currentView = type;
                });
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: CalendarViewType.month,
                  child: Text('Vista Mensual'),
                ),
                const PopupMenuItem(
                  value: CalendarViewType.week,
                  child: Text('Vista Semanal'),
                ),
                const PopupMenuItem(
                  value: CalendarViewType.day,
                  child: Text('Vista Diaria'),
                ),
              ],
            ),
          ],
        ),
        body: Column(
          children: [
            Expanded(child: _buildCalendarView()),
            _buildEventsList(),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => _showAddEventDialog(_selectedDate),
          child: const Icon(Icons.add),
          tooltip: 'Agregar evento',
        ),
      ),
    );
  }

  void _showAddMedicineDialog() {
    final medicineController = TextEditingController();
    final commentController = TextEditingController();
    DateTime startDate = DateTime.now();
    int days = 7;
    int hoursInterval = 8;
    TimeOfDay firstDose = const TimeOfDay(hour: 8, minute: 0);
    int reminderMinutes = 15;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Agregar Horario de Medicina'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: medicineController,
                  decoration: const InputDecoration(
                    labelText: 'Nombre de la medicina*',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: commentController,
                  decoration: const InputDecoration(
                    labelText: 'Comentario (opcional)',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 12),
                ListTile(
                  title: const Text('Fecha de inicio'),
                  subtitle: Text(
                    '${startDate.day}/${startDate.month}/${startDate.year}',
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.calendar_today),
                    onPressed: () async {
                      final DateTime? pickedDate = await showDatePicker(
                        context: context,
                        initialDate: startDate,
                        firstDate: DateTime.now(),
                        lastDate: DateTime(2030),
                      );
                      if (pickedDate != null) {
                        setDialogState(() {
                          startDate = pickedDate;
                        });
                      }
                    },
                  ),
                ),
                ListTile(
                  title: const Text('Primera dosis del día'),
                  subtitle: Text(
                    '${firstDose.hour.toString().padLeft(2, '0')}:${firstDose.minute.toString().padLeft(2, '0')}',
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.access_time),
                    onPressed: () async {
                      final TimeOfDay? pickedTime = await showTimePicker(
                        context: context,
                        initialTime: firstDose,
                      );
                      if (pickedTime != null) {
                        setDialogState(() {
                          firstDose = pickedTime;
                        });
                      }
                    },
                  ),
                ),
                ListTile(
                  title: const Text('Cada cuántas horas'),
                  subtitle: Text('$hoursInterval hora(s)'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove),
                        onPressed: () {
                          if (hoursInterval > 1) {
                            setDialogState(() {
                              hoursInterval--;
                            });
                          }
                        },
                      ),
                      Text('$hoursInterval'),
                      IconButton(
                        icon: const Icon(Icons.add),
                        onPressed: () {
                          setDialogState(() {
                            hoursInterval++;
                          });
                        },
                      ),
                    ],
                  ),
                ),
                ListTile(
                  title: const Text('Días de tratamiento'),
                  subtitle: Text('$days día(s)'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove),
                        onPressed: () {
                          if (days > 1) {
                            setDialogState(() {
                              days--;
                            });
                          }
                        },
                      ),
                      Text('$days'),
                      IconButton(
                        icon: const Icon(Icons.add),
                        onPressed: () {
                          setDialogState(() {
                            days++;
                          });
                        },
                      ),
                    ],
                  ),
                ),
                ListTile(
                  title: const Text('Recordatorio'),
                  subtitle: Text('$reminderMinutes minutos antes'),
                  trailing: DropdownButton<int>(
                    value: reminderMinutes,
                    items: [5, 10, 15, 30, 60]
                        .map(
                          (minutes) => DropdownMenuItem(
                            value: minutes,
                            child: Text('$minutes minutos antes'),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      setDialogState(() {
                        reminderMinutes = value!;
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                if (medicineController.text.isNotEmpty) {
                  _addMedicineRecurringEvent(
                    medicineName: medicineController.text,
                    comment: commentController.text,
                    startDate: startDate,
                    days: days,
                    hoursInterval: hoursInterval,
                    firstDoseTime: firstDose,
                    reminderMinutes: reminderMinutes,
                  );
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Agregar Horario'),
            ),
          ],
        ),
      ),
    );
  }

  void _addMedicineRecurringEvent({
    required String medicineName,
    required String comment,
    required DateTime startDate,
    required int days,
    required int hoursInterval,
    required TimeOfDay firstDoseTime,
    required int reminderMinutes,
  }) {
    final List<CalendarEventData> events = [];
    int eventsCreated = 0;
    final endDate = startDate.add(Duration(days: days));

    DateTime currentDate = startDate;
    while (currentDate.isBefore(endDate)) {
      int doseCount = 1;

      for (int hour = firstDoseTime.hour; hour < 24; hour += hoursInterval) {
        final doseTime = TimeOfDay(
          hour: hour % 24,
          minute: firstDoseTime.minute,
        );

        final startDateTime = DateTime(
          currentDate.year,
          currentDate.month,
          currentDate.day,
          doseTime.hour,
          doseTime.minute,
        );

        final endDateTime = startDateTime.add(const Duration(minutes: 30));

        final description = comment.isNotEmpty
            ? 'Medicina: $medicineName\nComentario: $comment'
            : 'Medicina: $medicineName';

        final event = CalendarEventData(
          title: 'Tomar $medicineName (Dosis $doseCount)',
          date: currentDate,
          description: _buildEventDescription(description, reminderMinutes),
          startTime: startDateTime,
          endTime: endDateTime,
          color: Colors.green,
        );

        events.add(event);
        eventsCreated++;
        doseCount++;
      }

      currentDate = currentDate.add(const Duration(days: 1));
    }

    _eventController.addAll(events);
    _loadEventsForDate(_selectedDate);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Horario de $medicineName agregado ($eventsCreated dosis)',
        ),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  void dispose() {
    _eventController.dispose();
    super.dispose();
  }
}

enum CalendarViewType { month, week, day }
