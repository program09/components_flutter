// main.dart
// A simplified Flutter app for "Acompañamiento Digital para Pacientes Crónicos"
// Incluye: journey interaction (flujo por pasos), perfil paciente, registro de síntomas,
// recordatorios de medicación (esquema), contenido educativo y mensajería básica.
// Paquetes sugeridos (añadir en pubspec.yaml):
//   provider: ^6.0.0
//   shared_preferences: ^2.0.15
//   flutter_local_notifications: ^12.0.0
//   intl: ^0.18.0
// NOTA: para notificaciones locales y scheduling debes configurar permisos nativos (Android/iOS).

import 'package:flutter/material.dart';
import 'package:journey_unit/components.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

// --------------------------- Models ---------------------------
class JourneyStep {
  final String id;
  final String title;
  final String description;
  final IconData icon;

  JourneyStep({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
  });
}

class PatientProfile {
  String name;
  int age;
  String condition;

  PatientProfile({
    required this.name,
    required this.age,
    required this.condition,
  });

  Map<String, dynamic> toJson() => {
    'name': name,
    'age': age,
    'condition': condition,
  };
  static PatientProfile fromJson(Map<String, dynamic> j) =>
      PatientProfile(name: j['name'], age: j['age'], condition: j['condition']);
}

class SymptomRecord {
  final DateTime date;
  final String symptom;
  final int severity; // 1-10

  SymptomRecord({
    required this.date,
    required this.symptom,
    required this.severity,
  });

  Map<String, dynamic> toJson() => {
    'date': date.toIso8601String(),
    'symptom': symptom,
    'severity': severity,
  };
  static SymptomRecord fromJson(Map<String, dynamic> j) => SymptomRecord(
    date: DateTime.parse(j['date']),
    symptom: j['symptom'],
    severity: j['severity'],
  );
}

// --------------------------- App State ---------------------------
class AppState extends ChangeNotifier {
  PatientProfile? profile;
  List<SymptomRecord> symptoms = [];
  List<String> messages = [];
  int currentJourneyIndex = 0;

  // Journey definition (could be dynamic per condition)
  final List<JourneyStep> journey = [
    JourneyStep(
      id: 'onboarding',
      title: 'Bienvenida',
      description: 'Presentación y objetivos del acompañamiento',
      icon: Icons.emoji_people,
    ),
    JourneyStep(
      id: 'evaluacion',
      title: 'Evaluación inicial',
      description: 'Registrar historial y síntomas',
      icon: Icons.medical_information,
    ),
    JourneyStep(
      id: 'plan',
      title: 'Plan de cuidado',
      description: 'Plan personalizado con metas',
      icon: Icons.event_note,
    ),
    JourneyStep(
      id: 'seguimiento',
      title: 'Seguimiento',
      description: 'Registro diario y alertas',
      icon: Icons.track_changes,
    ),
    JourneyStep(
      id: 'educacion',
      title: 'Educación',
      description: 'Contenido y recursos',
      icon: Icons.menu_book,
    ),
  ];

  // Persistence
  Future<void> loadFromStorage() async {
    final prefs = await SharedPreferences.getInstance();
    final profileStr = prefs.getString('profile');
    if (profileStr != null) {
      profile = PatientProfile.fromJson(json.decode(profileStr));
    }
    final symptomsStr = prefs.getString('symptoms');
    if (symptomsStr != null) {
      final list = json.decode(symptomsStr) as List;
      symptoms = list.map((e) => SymptomRecord.fromJson(e)).toList();
    }
    final messagesStr = prefs.getString('messages');
    if (messagesStr != null) {
      messages = List<String>.from(json.decode(messagesStr));
    }
    currentJourneyIndex = prefs.getInt('currentJourneyIndex') ?? 0;
    notifyListeners();
  }

  Future<void> saveToStorage() async {
    final prefs = await SharedPreferences.getInstance();
    if (profile != null)
      prefs.setString('profile', json.encode(profile!.toJson()));
    prefs.setString(
      'symptoms',
      json.encode(symptoms.map((s) => s.toJson()).toList()),
    );
    prefs.setString('messages', json.encode(messages));
    prefs.setInt('currentJourneyIndex', currentJourneyIndex);
  }

  void updateProfile(PatientProfile p) {
    profile = p;
    saveToStorage();
    notifyListeners();
  }

  void addSymptom(SymptomRecord r) {
    symptoms.insert(0, r);
    saveToStorage();
    notifyListeners();
  }

  void addMessage(String m) {
    messages.add(m);
    saveToStorage();
    notifyListeners();
  }

  void setJourneyIndex(int i) {
    currentJourneyIndex = i.clamp(0, journey.length - 1);
    saveToStorage();
    notifyListeners();
  }
}

// --------------------------- UI ---------------------------
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final appState = AppState();
  await appState.loadFromStorage();

  runApp(ChangeNotifierProvider(create: (_) => appState, child: MyApp()));
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Acompañamiento Digital - Pacientes Crónicos',
      theme: ThemeData(primarySwatch: Colors.teal),
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final state = Provider.of<AppState>(context);
    return Scaffold(
      appBar: AppBar(title: Text('Acompañamiento Digital')),
      drawer: AppDrawer(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Hola, ${state.profile?.name ?? 'Paciente'}'),
            SizedBox(height: 12),
            Text('Progreso del journey'),
            SizedBox(height: 8),
            JourneyProgress(),
            SizedBox(height: 16),
            Expanded(child: QuickActions()),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => SymptomTrackerScreen()),
        ),
      ),
    );
  }
}

class AppDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final state = Provider.of<AppState>(context, listen: false);
    return Drawer(
      child: ListView(
        children: [
          DrawerHeader(
            decoration: BoxDecoration(color: Colors.teal),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  state.profile?.name ?? 'Paciente',
                  style: TextStyle(color: Colors.white, fontSize: 20),
                ),
                SizedBox(height: 8),
                Text(
                  state.profile?.condition ?? 'Condición no registrada',
                  style: TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ),
          ListTile(
            leading: Icon(Icons.list),
            title: Text('Journey'),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => JourneyScreen()),
            ),
          ),
          ListTile(
            leading: Icon(Icons.healing),
            title: Text('Registro de síntomas'),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => SymptomHistoryScreen()),
            ),
          ),
          ListTile(
            leading: Icon(Icons.medication),
            title: Text('Medicaciones'),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => MedicationScreen()),
            ),
          ),
          ListTile(
            leading: Icon(Icons.menu_book),
            title: Text('Educación'),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => EducationScreen()),
            ),
          ),
          ListTile(
            leading: Icon(Icons.message),
            title: Text('Mensajes'),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => MessagesScreen()),
            ),
          ),
          ListTile(
            leading: Icon(Icons.person),
            title: Text('Perfil'),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => ProfileScreen()),
            ),
          ),
          ListTile(
            leading: Icon(Icons.settings),
            title: Text('Ajustes'),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => ComponentsScreen()),
            ),
          ),
        ],
      ),
    );
  }
}

class JourneyProgress extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final state = Provider.of<AppState>(context);
    final current = state.currentJourneyIndex;
    return Column(
      children: state.journey.asMap().entries.map((e) {
        final idx = e.key;
        final step = e.value;
        final completed = idx < current;
        final active = idx == current;
        return ListTile(
          leading: CircleAvatar(child: Icon(step.icon)),
          title: Text(step.title),
          subtitle: Text(step.description),
          trailing: active
              ? Icon(Icons.arrow_forward)
              : (completed
                    ? Icon(Icons.check_circle, color: Colors.green)
                    : Icon(Icons.lock)),
          onTap: () {
            state.setJourneyIndex(idx);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => JourneyStepDetail(step: step, index: idx),
              ),
            );
          },
        );
      }).toList(),
    );
  }
}

class JourneyScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final state = Provider.of<AppState>(context);
    return Scaffold(
      appBar: AppBar(title: Text('Journey completo')),
      body: ListView.builder(
        itemCount: state.journey.length,
        itemBuilder: (context, index) {
          final s = state.journey[index];
          return Card(
            child: ListTile(
              leading: Icon(s.icon),
              title: Text(s.title),
              subtitle: Text(s.description),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => JourneyStepDetail(step: s, index: index),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class JourneyStepDetail extends StatelessWidget {
  final JourneyStep step;
  final int index;
  JourneyStepDetail({required this.step, required this.index});
  @override
  Widget build(BuildContext context) {
    final state = Provider.of<AppState>(context, listen: false);
    return Scaffold(
      appBar: AppBar(title: Text(step.title)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(step.icon, size: 36),
                SizedBox(width: 12),
                Expanded(child: Text(step.description)),
              ],
            ),
            SizedBox(height: 20),
            Expanded(
              child: Text(
                'Aquí van actividades interactivas, cuestionarios y recursos específicos de esta etapa.',
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: () {
                    state.setJourneyIndex(index - 1);
                    Navigator.pop(context);
                  },
                  child: Text('Anterior'),
                ),
                ElevatedButton(
                  onPressed: () {
                    state.setJourneyIndex(index + 1);
                    Navigator.pop(context);
                  },
                  child: Text('Marcar como completado'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class QuickActions extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Card(
          child: ListTile(
            leading: Icon(Icons.healing),
            title: Text('Registrar síntoma'),
            subtitle: Text('Toma nota de cómo te sientes hoy'),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => SymptomTrackerScreen()),
            ),
          ),
        ),
        Card(
          child: ListTile(
            leading: Icon(Icons.medication),
            title: Text('Recordatorios de medicación'),
            subtitle: Text('Ver o añadir recordatorios'),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => MedicationScreen()),
            ),
          ),
        ),
        Card(
          child: ListTile(
            leading: Icon(Icons.menu_book),
            title: Text('Material educativo'),
            subtitle: Text('Aprende sobre tu condición'),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => EducationScreen()),
            ),
          ),
        ),
      ],
    );
  }
}

class SymptomTrackerScreen extends StatefulWidget {
  @override
  State<SymptomTrackerScreen> createState() => _SymptomTrackerScreenState();
}

class _SymptomTrackerScreenState extends State<SymptomTrackerScreen> {
  final _formKey = GlobalKey<FormState>();
  String symptom = '';
  int severity = 5;

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<AppState>(context);
    return Scaffold(
      appBar: AppBar(title: Text('Registrar síntoma')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Síntoma (ej: dolor, fatiga)',
                    ),
                    onSaved: (v) => symptom = v ?? '',
                    validator: (v) =>
                        (v == null || v.isEmpty) ? 'Describe el síntoma' : null,
                  ),
                  SizedBox(height: 12),
                  Text('Severidad: \$severity'),
                  Slider(
                    value: severity.toDouble(),
                    min: 1,
                    max: 10,
                    divisions: 9,
                    label: '$severity',
                    onChanged: (v) => setState(() => severity = v.toInt()),
                  ),
                  SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        _formKey.currentState!.save();
                        final record = SymptomRecord(
                          date: DateTime.now(),
                          symptom: symptom,
                          severity: severity,
                        );
                        state.addSymptom(record);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Síntoma guardado')),
                        );
                        Navigator.pop(context);
                      }
                    },
                    child: Text('Guardar'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SymptomHistoryScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final state = Provider.of<AppState>(context);
    return Scaffold(
      appBar: AppBar(title: Text('Historial de síntomas')),
      body: ListView.builder(
        itemCount: state.symptoms.length,
        itemBuilder: (context, i) {
          final s = state.symptoms[i];
          return ListTile(
            leading: CircleAvatar(child: Text(s.severity.toString())),
            title: Text(s.symptom),
            subtitle: Text(s.date.toLocal().toString()),
          );
        },
      ),
    );
  }
}

class MedicationScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // For brevity this is a placeholder. In a real app allow CRUD for meds + notification scheduling.
    return Scaffold(
      appBar: AppBar(title: Text('Medicaciones y recordatorios')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Aquí puedes añadir medicaciones y programar recordatorios.'),
            SizedBox(height: 12),
            Text(
              'Nota: Para recordatorios configure el paquete flutter_local_notifications y permisos nativos.',
            ),
          ],
        ),
      ),
    );
  }
}

class EducationScreen extends StatelessWidget {
  final List<Map<String, String>> items = [
    {
      'title': 'Autocuidado',
      'body': 'Consejos básicos para el autocuidado diario.',
    },
    {
      'title': 'Alimentación',
      'body': 'Recomendaciones nutricionales según la condición.',
    },
    {'title': 'Actividad física', 'body': 'Ejercicios adaptados y seguros.'},
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Recursos educativos')),
      body: ListView.builder(
        itemCount: items.length,
        itemBuilder: (context, i) => Card(
          child: ListTile(
            title: Text(items[i]['title']!),
            subtitle: Text(items[i]['body']!),
          ),
        ),
      ),
    );
  }
}

class MessagesScreen extends StatelessWidget {
  final TextEditingController _ctrl = TextEditingController();
  @override
  Widget build(BuildContext context) {
    final state = Provider.of<AppState>(context);
    return Scaffold(
      appBar: AppBar(title: Text('Mensajes')),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: state.messages.length,
              itemBuilder: (c, i) => ListTile(title: Text(state.messages[i])),
            ),
          ),
          Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _ctrl,
                    decoration: InputDecoration(hintText: 'Escribe un mensaje'),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: () {
                    if (_ctrl.text.trim().isNotEmpty) {
                      state.addMessage(_ctrl.text.trim());
                      _ctrl.clear();
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ProfileScreen extends StatefulWidget {
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  String name = '';
  int age = 30;
  String condition = '';

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<AppState>(context);
    name = state.profile?.name ?? name;
    age = state.profile?.age ?? age;
    condition = state.profile?.condition ?? condition;

    return Scaffold(
      appBar: AppBar(title: Text('Perfil')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                initialValue: name,
                decoration: InputDecoration(labelText: 'Nombre'),
                onSaved: (v) => name = v ?? '',
              ),
              TextFormField(
                initialValue: age.toString(),
                decoration: InputDecoration(labelText: 'Edad'),
                keyboardType: TextInputType.number,
                onSaved: (v) => age = int.tryParse(v ?? '') ?? age,
              ),
              TextFormField(
                initialValue: condition,
                decoration: InputDecoration(labelText: 'Condición crónica'),
                onSaved: (v) => condition = v ?? '',
              ),
              SizedBox(height: 12),
              ElevatedButton(
                onPressed: () {
                  _formKey.currentState!.save();
                  state.updateProfile(
                    PatientProfile(name: name, age: age, condition: condition),
                  );
                  Navigator.pop(context);
                },
                child: Text('Guardar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SettingsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Ajustes')),
      body: Center(
        child: Text(
          'Ajustes de la aplicación (idioma, notificaciones, privacidad)',
        ),
      ),
    );
  }
}

// --------------------------- END ---------------------------
// Esta app es una base funcional. Para producción:
// - Añadir validaciones más robustas y manejo de errores.
// - Implementar notificaciones locales y recordatorios con flutter_local_notifications.
// - Añadir autenticación (Firebase/Auth propia) si es necesario.
// - Proteger datos sensibles y cumplir con regulaciones locales (ej. GDPR / GDPR-like / Leyes de salud locales).
// - Añadir tests unitarios y de widget.
// - Diseñar flujos específicos por condición crónica (diabetes, EPOC, hipertensión, etc.)
