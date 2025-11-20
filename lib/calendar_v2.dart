import 'package:calendar_view/calendar_view.dart';
import 'package:flutter/material.dart';
import 'dart:convert';

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
  CalendarEventData? _selectedEvent;
  bool _showEventsPanel = false;

  // Simular datos desde JSON
  final String _sampleEventsJson = '''
  {
    "events": [
      {
        "title": "Consulta con cardiólogo",
        "date": "2024-01-15",
        "description": "Control anual de rutina. Llevar estudios anteriores.",
        "startTime": "2024-01-15T10:00:00",
        "endTime": "2024-01-15T11:00:00",
        "color": "blue"
      },
      {
        "title": "Tomar antibiótico",
        "date": "2024-01-16",
        "description": "Completar tratamiento de 7 días. Tomar después de alimentos.",
        "startTime": "2024-01-16T08:00:00",
        "endTime": "2024-01-16T08:30:00",
        "color": "green"
      },
      {
        "title": "Revisión dental",
        "date": "2024-01-18",
        "description": "Limpieza dental semestral.",
        "startTime": "2024-01-18T14:00:00",
        "endTime": "2024-01-18T15:00:00",
        "color": "teal"
      }
    ]
  }
  ''';

  @override
  void initState() {
    super.initState();
    _loadEventsFromJson();
    _loadEventsForDate(_selectedDate);
  }

  void _loadEventsFromJson() {
    try {
      final Map<String, dynamic> data = json.decode(_sampleEventsJson);
      final List<dynamic> events = data['events'];

      for (var eventData in events) {
        final event = CalendarEventData(
          title: eventData['title'],
          date: DateTime.parse(eventData['date']),
          description: eventData['description'],
          startTime: DateTime.parse(eventData['startTime']),
          endTime: DateTime.parse(eventData['endTime']),
          color: _getColorFromString(eventData['color']),
        );
        _eventController.add(event);
      }

      // Agregar también los eventos de muestra programáticos
      _addMedicineSchedule();
    } catch (e) {
      print('Error loading events from JSON: $e');
      _addSampleEvents();
    }
  }

  Color _getColorFromString(String colorName) {
    switch (colorName) {
      case 'blue':
        return Colors.blue.shade600;
      case 'green':
        return Colors.green.shade600;
      case 'teal':
        return Colors.teal.shade600;
      case 'orange':
        return Colors.orange.shade600;
      case 'purple':
        return Colors.purple.shade600;
      case 'red':
        return Colors.red.shade600;
      default:
        return Colors.blue.shade600;
    }
  }

  void _addSampleEvents() {
    final events = [
      CalendarEventData(
        title: "Consulta médica",
        date: DateTime.now(),
        description: "Control anual con cardiólogo",
        startTime: DateTime.now().add(const Duration(hours: 1)),
        endTime: DateTime.now().add(const Duration(hours: 2)),
        color: Colors.blue.shade600,
      ),
      CalendarEventData(
        title: "Tomar medicina",
        date: DateTime.now().add(const Duration(days: 1)),
        description: "Antibiótico cada 8 horas",
        startTime: DateTime.now().add(const Duration(days: 1, hours: 8)),
        endTime: DateTime.now().add(
          const Duration(days: 1, hours: 8, minutes: 30),
        ),
        color: Colors.green.shade600,
      ),
    ];
    _eventController.addAll(events);
  }

  void _addMedicineSchedule() {
    final startDate = DateTime.now();
    final endDate = DateTime.now().add(const Duration(days: 5));

    DateTime currentDate = startDate;
    while (currentDate.isBefore(endDate)) {
      for (int hour = 8; hour < 24; hour += 8) {
        final event = CalendarEventData(
          title: "Medicina control",
          date: currentDate,
          description: "Tomar con un vaso de agua. No saltar dosis.",
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
          color: Colors.green.shade600,
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

  void _showEventsForDate(DateTime date) {
    setState(() {
      _selectedDate = date;
      _selectedEvent = null;
      _showEventsPanel = true;
    });
    _loadEventsForDate(date);
  }

  void _hideEventsPanel() {
    setState(() {
      _showEventsPanel = false;
      _selectedEvent = null;
    });
  }

  void _showEventDetails(CalendarEventData event) {
    setState(() {
      _selectedEvent = event;
      _showEventsPanel = true;
    });
  }

  Color _getRandomColor() {
    final colors = [
      Colors.blue.shade600,
      Colors.green.shade600,
      Colors.orange.shade600,
      Colors.purple.shade600,
      Colors.red.shade600,
      Colors.teal.shade600,
      Colors.indigo.shade600,
    ];
    return colors[DateTime.now().millisecond % colors.length];
  }

  // ========== UI COMPONENTS ==========

  Widget _buildCalendarView() {
    final calendarView = switch (_currentView) {
      CalendarViewType.month => MonthView(
        minMonth: DateTime(2020),
        maxMonth: DateTime(2030),
        initialMonth: _selectedDate,
        cellAspectRatio: 1.3,
        onPageChange: (date, pageIndex) {
          _showEventsForDate(date);
        },
        onCellTap: (events, date) {
          _showEventsForDate(date);
        },
        startDay: WeekDays.monday,
        onEventTap: (event, date) {
          _showEventDetails(event);
        },
        onDateLongPress: (date) {
          _showAddEventDialog(date);
        },
      ),
      CalendarViewType.week => WeekView(
        minDay: DateTime(2020),
        maxDay: DateTime(2030),
        initialDay: _selectedDate,
        onPageChange: (date, pageIndex) {
          _showEventsForDate(date);
        },
        onDateTap: (date) {
          _showEventsForDate(date);
        },
        onEventTap: (events, date) {
          _showEventDetails(events.first);
        },
        startDay: WeekDays.monday,
      ),
      CalendarViewType.day => DayView(
        minDay: DateTime(2020),
        maxDay: DateTime(2030),
        initialDay: _selectedDate,
        onPageChange: (date, pageIndex) {
          _showEventsForDate(date);
        },
        onDateTap: (date) {
          _showEventsForDate(date);
        },
        onEventTap: (event, date) {
          _showEventDetails(event.first);
        },
        onTimestampTap: (date) {
          final time = TimeOfDay(hour: date.hour, minute: date.minute);
          _showAddEventDialog(date, time);
        },
      ),
    };

    return Stack(
      children: [calendarView, if (_showEventsPanel) _buildEventsPanel()],
    );
  }

  Widget _buildEventsPanel() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        height: _selectedEvent != null ? 400 : 300,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: Column(
          children: [
            // Header del panel
            _buildPanelHeader(),
            Expanded(
              child: _selectedEvent != null
                  ? _buildEventDetails()
                  : _buildEventsList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPanelHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Row(
        children: [
          if (_selectedEvent != null)
            IconButton(
              icon: const Icon(Icons.arrow_back, size: 20),
              onPressed: () {
                setState(() {
                  _selectedEvent = null;
                });
              },
            )
          else
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                color: Colors.grey.shade400,
                borderRadius: BorderRadius.circular(2),
              ),
            ),

          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _selectedEvent != null
                  ? 'Detalles del Evento'
                  : 'Eventos del ${_formatDate(_selectedDate)}',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, size: 20),
            onPressed: _hideEventsPanel,
          ),
        ],
      ),
    );
  }

  Widget _buildEventsList() {
    return Column(
      children: [
        // Botón agregar evento
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: ElevatedButton.icon(
            onPressed: () => _showAddEventDialog(_selectedDate),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue.shade600,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              minimumSize: const Size(double.infinity, 50),
            ),
            icon: const Icon(Icons.add, size: 20),
            label: const Text(
              'Agregar Evento',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ),

        Expanded(
          child: _selectedEvents.isEmpty
              ? _buildEmptyState()
              : ListView.builder(
                  padding: const EdgeInsets.only(bottom: 20),
                  itemCount: _selectedEvents.length,
                  itemBuilder: (context, index) {
                    final event = _selectedEvents[index];
                    return _buildEventItem(event);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.event_available, size: 64, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(
            'No hay eventos',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Agrega un evento para esta fecha',
            style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }

  Widget _buildEventItem(CalendarEventData event) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        elevation: 1,
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 8,
          ),
          leading: Container(
            width: 4,
            decoration: BoxDecoration(
              color: event.color ?? Colors.blue.shade600,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          title: Text(
            event.title ?? 'Sin título',
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (event.description != null) ...[
                const SizedBox(height: 4),
                Text(
                  event.description!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                ),
              ],
              const SizedBox(height: 4),
              Text(
                '${_formatTime(event.startTime)} - ${_formatTime(event.endTime)}',
                style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
              ),
            ],
          ),
          trailing: Icon(Icons.chevron_right, color: Colors.grey.shade400),
          onTap: () => _showEventDetails(event),
        ),
      ),
    );
  }

  Widget _buildEventDetails() {
    if (_selectedEvent == null) return const SizedBox.shrink();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header del evento
          Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: _selectedEvent!.color ?? Colors.blue.shade600,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  _selectedEvent!.title ?? 'Evento',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Información del evento
          _buildDetailItem(
            Icons.description_outlined,
            'Descripción',
            _selectedEvent!.description ?? "No disponible",
          ),
          const SizedBox(height: 20),

          _buildDetailItem(
            Icons.calendar_today_outlined,
            'Fecha',
            _formatDate(_selectedEvent!.date),
          ),
          const SizedBox(height: 20),

          Row(
            children: [
              Expanded(
                child: _buildDetailItem(
                  Icons.access_time_outlined,
                  'Hora inicio',
                  _formatTime(_selectedEvent!.startTime),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildDetailItem(
                  Icons.access_time_outlined,
                  'Hora fin',
                  _formatTime(_selectedEvent!.endTime),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          _buildDetailItem(
            Icons.timer_outlined,
            'Duración',
            _calculateDuration(
              _selectedEvent!.startTime,
              _selectedEvent!.endTime,
            ),
          ),
          const SizedBox(height: 32),

          // Botón eliminar
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                _eventController.remove(_selectedEvent!);
                _loadEventsForDate(_selectedDate);
                _hideEventsPanel();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Evento eliminado'),
                    backgroundColor: Colors.red.shade600,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade50,
                foregroundColor: Colors.red.shade600,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: Colors.red.shade200),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: const Text(
                'Eliminar Evento',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailItem(IconData icon, String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 18, color: Colors.grey.shade600),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
                fontSize: 14,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Padding(
          padding: const EdgeInsets.only(left: 26),
          child: Text(
            value,
            style: const TextStyle(color: Colors.black87, fontSize: 15),
          ),
        ),
      ],
    );
  }

  // ========== MAIN BUILD ==========

  @override
  Widget build(BuildContext context) {
    return CalendarControllerProvider(
      controller: _eventController,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: const Text(
            'Mi Calendario',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          backgroundColor: Colors.white,
          elevation: 0,
          foregroundColor: Colors.grey.shade800,
          actions: [
            IconButton(
              icon: Icon(Icons.medical_services, color: Colors.green.shade600),
              onPressed: _showAddMedicineDialog,
              tooltip: 'Agregar medicina',
            ),
            PopupMenuButton<CalendarViewType>(
              onSelected: (type) {
                setState(() {
                  _currentView = type;
                  _selectedEvent = null;
                  _showEventsPanel = false;
                });
              },
              icon: Icon(Icons.view_week, color: Colors.grey.shade600),
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: CalendarViewType.month,
                  child: Row(
                    children: [
                      Icon(
                        Icons.calendar_view_month,
                        color: Colors.grey.shade600,
                      ),
                      const SizedBox(width: 12),
                      const Text('Vista Mensual'),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: CalendarViewType.week,
                  child: Row(
                    children: [
                      Icon(
                        Icons.calendar_view_week,
                        color: Colors.grey.shade600,
                      ),
                      const SizedBox(width: 12),
                      const Text('Vista Semanal'),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: CalendarViewType.day,
                  child: Row(
                    children: [
                      Icon(Icons.view_day, color: Colors.grey.shade600),
                      const SizedBox(width: 12),
                      const Text('Vista Diaria'),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
        body: _buildCalendarView(),
        floatingActionButton: _showEventsPanel
            ? null
            : FloatingActionButton(
                onPressed: () => _showAddEventDialog(_selectedDate),
                backgroundColor: Colors.blue.shade600,
                foregroundColor: Colors.white,
                elevation: 2,
                child: const Icon(Icons.add),
              ),
      ),
    );
  }

  // ========== UTILITY METHODS ==========

  String _formatDate(DateTime? date) {
    if (date == null) return "No disponible";
    final months = [
      'Ene',
      'Feb',
      'Mar',
      'Abr',
      'May',
      'Jun',
      'Jul',
      'Ago',
      'Sep',
      'Oct',
      'Nov',
      'Dic',
    ];
    return '${date.day} de ${months[date.month - 1]} de ${date.year}';
  }

  String _formatTime(DateTime? time) {
    if (time == null) return "No disponible";
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  String _calculateDuration(DateTime? start, DateTime? end) {
    if (start == null || end == null) return "No disponible";
    final duration = end.difference(start);
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    if (hours > 0) {
      return minutes > 0 ? '$hours h $minutes min' : '$hours h';
    } else {
      return '$minutes min';
    }
  }

  // ========== DIALOG METHODS ==========

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
    int recurrenceInterval = 1;
    int recurrenceTimesPerDay = 1;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => Container(
          height: MediaQuery.of(context).size.height * 0.9,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.grey),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Nuevo Evento',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[800],
                      ),
                    ),
                    const Spacer(),
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
                          _loadEventsForDate(_selectedDate);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue.shade600,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        isRecurring ? 'Agregar' : 'Guardar',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Fecha seleccionada
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.calendar_today,
                              color: Colors.blue.shade600,
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              '${date.day}/${date.month}/${date.year}',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: Colors.blue.shade800,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Título
                      Text(
                        'Título del evento*',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[800],
                            ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: titleController,
                        decoration: InputDecoration(
                          hintText: 'Ej: Consulta médica, Tomar medicina...',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.blue.shade600),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Descripción
                      Text(
                        'Descripción',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[800],
                            ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: descriptionController,
                        maxLines: 3,
                        decoration: InputDecoration(
                          hintText: 'Agregar detalles adicionales...',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.blue.shade600),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Horarios
                      Row(
                        children: [
                          Expanded(
                            child: _buildTimeSelector(
                              'Hora inicio',
                              startTime,
                              (pickedTime) {
                                if (pickedTime != null) {
                                  setDialogState(() {
                                    startTime = pickedTime;
                                    endTime = TimeOfDay(
                                      hour: pickedTime.hour + 1,
                                      minute: pickedTime.minute,
                                    );
                                  });
                                }
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildTimeSelector('Hora fin', endTime, (
                              pickedTime,
                            ) {
                              if (pickedTime != null) {
                                setDialogState(() {
                                  endTime = pickedTime;
                                });
                              }
                            }),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Recordatorio
                      _buildSettingItem(
                        icon: Icons.notifications,
                        title: 'Recordatorio',
                        subtitle: reminderMinutes == 0
                            ? 'Sin recordatorio'
                            : reminderMinutes == 1440
                            ? '1 día antes'
                            : '$reminderMinutes minutos antes',
                        onTap: () {
                          showModalBottomSheet(
                            context: context,
                            builder: (context) => _buildReminderSelector(
                              reminderMinutes,
                              (value) {
                                setDialogState(() {
                                  reminderMinutes = value;
                                });
                                Navigator.of(context).pop();
                              },
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 16),

                      // Evento recurrente
                      _buildSettingItem(
                        icon: Icons.repeat,
                        title: 'Evento recurrente',
                        subtitle: isRecurring ? 'Activado' : 'Desactivado',
                        trailing: Switch(
                          value: isRecurring,
                          onChanged: (value) {
                            setDialogState(() {
                              isRecurring = value;
                            });
                          },
                          activeColor: Colors.blue.shade600,
                        ),
                      ),

                      if (isRecurring) ...[
                        const SizedBox(height: 16),
                        _buildRecurrenceSettings(
                          recurrenceInterval,
                          recurrenceDays,
                          recurrenceTimesPerDay,
                          (interval, days, times) {
                            setDialogState(() {
                              recurrenceInterval = interval;
                              recurrenceDays = days;
                              recurrenceTimesPerDay = times;
                            });
                          },
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTimeSelector(
    String title,
    TimeOfDay time,
    Function(TimeOfDay?) onTimeSelected,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: Colors.grey[800],
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () async {
            final TimeOfDay? pickedTime = await showTimePicker(
              context: context,
              initialTime: time,
            );
            onTimeSelected(pickedTime);
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(Icons.access_time, color: Colors.grey.shade600, size: 20),
                const SizedBox(width: 12),
                Text(
                  '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: Colors.grey.shade800,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSettingItem({
    required IconData icon,
    required String title,
    required String subtitle,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.grey.shade600, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade800,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                  ),
                ],
              ),
            ),
            if (trailing != null) trailing,
          ],
        ),
      ),
    );
  }

  Widget _buildReminderSelector(int currentValue, Function(int) onChanged) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Recordatorio',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          ...[
            _buildReminderOption(
              0,
              'Sin recordatorio',
              currentValue,
              onChanged,
            ),
            _buildReminderOption(5, '5 minutos antes', currentValue, onChanged),
            _buildReminderOption(
              10,
              '10 minutos antes',
              currentValue,
              onChanged,
            ),
            _buildReminderOption(
              15,
              '15 minutos antes',
              currentValue,
              onChanged,
            ),
            _buildReminderOption(
              30,
              '30 minutos antes',
              currentValue,
              onChanged,
            ),
            _buildReminderOption(60, '1 hora antes', currentValue, onChanged),
            _buildReminderOption(1440, '1 día antes', currentValue, onChanged),
          ],
        ],
      ),
    );
  }

  Widget _buildReminderOption(
    int value,
    String text,
    int currentValue,
    Function(int) onChanged,
  ) {
    return ListTile(
      leading: Radio<int>(
        value: value,
        groupValue: currentValue,
        onChanged: (v) => onChanged(v!),
        activeColor: Colors.blue.shade600,
      ),
      title: Text(text),
      onTap: () => onChanged(value),
    );
  }

  Widget _buildRecurrenceSettings(
    int interval,
    int days,
    int times,
    Function(int, int, int) onChanged,
  ) {
    return Column(
      children: [
        _buildRecurrenceItem(
          'Repetir cada',
          '$interval día(s)',
          interval,
          (newValue) => onChanged(newValue, days, times),
        ),
        const SizedBox(height: 12),
        _buildRecurrenceItem(
          'Por cuántos días',
          '$days día(s)',
          days,
          (newValue) => onChanged(interval, newValue, times),
        ),
        const SizedBox(height: 12),
        _buildRecurrenceItem(
          'Veces por día',
          '$times vez(es)',
          times,
          (newValue) => onChanged(interval, days, newValue),
        ),
      ],
    );
  }

  Widget _buildRecurrenceItem(
    String title,
    String value,
    int current,
    Function(int) onChanged,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(value, style: TextStyle(color: Colors.grey.shade600)),
              ],
            ),
          ),
          Row(
            children: [
              IconButton(
                icon: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.remove, size: 16),
                ),
                onPressed: current > 1 ? () => onChanged(current - 1) : null,
              ),
              Container(
                width: 40,
                alignment: Alignment.center,
                child: Text(
                  '$current',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              IconButton(
                icon: Container(
                  decoration: BoxDecoration(
                    color: Colors.blue.shade100,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.add, size: 16, color: Colors.blue.shade600),
                ),
                onPressed: () => onChanged(current + 1),
              ),
            ],
          ),
        ],
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
        backgroundColor: Colors.green.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
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
        backgroundColor: Colors.green.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
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

  void _showAddMedicineDialog() {
    final medicineController = TextEditingController();
    final commentController = TextEditingController();
    DateTime startDate = DateTime.now();
    int days = 7;
    int hoursInterval = 8;
    TimeOfDay firstDose = const TimeOfDay(hour: 8, minute: 0);
    int reminderMinutes = 15;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => Container(
          height: MediaQuery.of(context).size.height * 0.9,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.grey),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Agregar Horario de Medicina',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Colors.black87,
                      ),
                    ),
                    const Spacer(),
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
                          _loadEventsForDate(_selectedDate);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green.shade600,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Agregar',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
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
              ),
            ],
          ),
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
          color: Colors.green.shade600,
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
        backgroundColor: Colors.green.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
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
