import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:googleapis_auth/auth_io.dart';

// Обработчик фоновых уведомлений
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print('Background message received: ${message.notification?.title}');
}

// Загрузка Service Account из JSON
Future<AutoRefreshingAuthClient> getAuthClient() async {
  final credentials = ServiceAccountCredentials.fromJson({
    "type": "service_account",
    "project_id": "zamemo-30e45",
    "private_key_id": "a25635537e6a21e900e2d4471fd613c30b7b8023",
    "private_key": "-----BEGIN PRIVATE KEY-----\nMIIEvQIBADANBgkqhkiG9w0BAQEFAASCBKcwggSjAgEAAoIBAQDQOO1bu6PcT7A7\nVta+dd6R2KjnKdwqauVNK4YkzqVFLiGP4QP+kHcKka2JpBvtZd4WL40YAE74LgJp\n14UzOOnI8J/ORCFujMfCKvX12ONnZq0cXhfouiW5qW5oKrXzw2T6pDU2Awd+EI9a\nLqA32ZvYa+7Ssmjjn5MGK6VGhvpwUsJ3w9g4/mTttOkDM2XA+HSJ9Gg3BqcfDRhK\nSCregsF2UFPIFZE4IaXGeqQ+rScX0v8WlGvuYw11lWlubjN5StKQWPX849t/Tz60\nCbqaavpEk6I/AmsAkNkn7udDhZkRIiuANR8bhLz4xfs55+dNYSJyp2/vYLbXB/9i\n7CEEl/tBAgMBAAECggEAGCXp/SADTmsdfJxDFl6UG+T9HaYApxizlCIOkhk3GJFT\nihyl+nFlpN+lORfDt2H/giIsolJy1hx74iuBAqJAlrG1TtYe7HO+PPn/gW4QXW8O\nd4JAEpj4BBKuv7zoUidggCLoGuX6CfhAr8xFf4Soqs5FqcDQIkng4q/QIKBJzhnN\nR4qlQJyu2twL7y9HfZYWwMLFWIWI3zb9wIEfrCvLKlQUQDYtt7wP8Sv6pDfyhYUV\nptGp6aPn7zuaBTG1kAEWdpQcGP3nXqJD4tfoOabBOEbXO2w50CBVo7b7AUSHqxIo\nJEpUvyV9AD0AnVFRoOWvgc/3lQgLADkZkodRlZEYAwKBgQD5MpGEOE2bMboltbQD\ncOgpWE95ZwqvJ8yK23cxQPDjBdYj6/mZnsny6TYWUDkF6JyKJh9+y9Zx363uqdgh\nOzqURHOMUbEdHEDJ6u2N5ghFZzP7GG99nEKSVnd+NJ7fJaK9jMU71S/Ejb8yIuuA\nZ8tzzSivx9nGWkEL7uvurAyeXwKBgQDV6AST/WRUvQs5NzFjMWkNGzHFQX8hQGWw\nIB9dK2fjymq1GJIgQY7QNdZWHR32hvwDRAt6HhetnhrEyn1bW93wvPKCVl68r0qH\nAP7V1jhFgtFLsffhkw0pDvuJli8PfFHEMgk0/O5RzW2nwCw/wEV0dfzPG/hP2VlF\nwDFvmbaKXwKBgGYPYOuvB5HNLvjszzotjtgIFBybqBOOkEY6ljl06HOCW27A4awa\nDYnQG9fNqV0TJLGr5XBP2ZcvzhOWOi96C4bX9h79AjXy8VIBRqO8F50dJHvtSRQ/\n4EAA69WjhYHM7zcEpW7Y5ERy7WCCTsN7PydBWi2MA1QqeMODaduJWW2vAoGBAKJA\ndtCGYQdByfShX+3cudF+MjdsofDn9voss32pggkwLdamB5k+AQUAAU+akHLCGwCj\nKY18q/s+tRFWgtW8jlGgENc6imvXDtHuuF4dOtvHCdi/6sWJFG9zdOr9Jz84zpDi\nX0d5H5CfITEgPLAyuLxJDvVOQwDWXbfhu93qG6NDAoGAQXF9APxjPq4PTzUJVMol\nFkj2UvhqkTqi8zM410OgAdteceB4eKmfuG1aMjv0WqTCfm2ie9zoTBMqB6WwhkfE\n8qNCZLxRVZc69sskvD7QdDtAfpJ4TOEZm+OyErkR3jzPZtpmgnnMrYbnRDQL6xBy\nFA/Iwlr5t1WTbBAVwdYyWFA=\n-----END PRIVATE KEY-----\n",
    "client_email": "firebase-adminsdk-fbsvc@zamemo-30e45.iam.gserviceaccount.com",
    "client_id": "114931322345875301441",
    "auth_uri": "https://accounts.google.com/o/oauth2/auth",
    "token_uri": "https://oauth2.googleapis.com/token",
    "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
    "client_x509_cert_url": "https://www.googleapis.com/robot/v1/metadata/x509/firebase-adminsdk-fbsvc%40zamemo-30e45.iam.gserviceaccount.com",
    "universe_domain": "googleapis.com"
  });
  final scopes = ['https://www.googleapis.com/auth/firebase.messaging'];
  return await clientViaServiceAccount(credentials, scopes);
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  final prefs = await SharedPreferences.getInstance();
  final userId = prefs.getString('user_id');
  runApp(MyApp(initialUserId: userId));
}

class MyApp extends StatelessWidget {
  final String? initialUserId;

  MyApp({this.initialUserId});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Zamemo Mobile',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: initialUserId != null ? NotesScreen(userId: initialUserId!) : LoginScreen(),
    );
  }
}

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final String loginUrl = "http://192.168.0.104:8080/api/login";

  Future<void> login() async {
    try {
      final response = await http.post(
        Uri.parse(loginUrl),
        headers: {"Content-Type": "application/x-www-form-urlencoded"},
        body: {
          "username": _usernameController.text,
          "password": _passwordController.text,
        },
      );
      print('Login response status: ${response.statusCode}');
      print('Login response body: ${response.body}');
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        var userId = data['user_id'].toString();
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_id', userId);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => NotesScreen(userId: userId)),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка входа: ${response.statusCode}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка сети: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Вход')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(labelText: 'Логин'),
            ),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: 'Пароль'),
              obscureText: true,
            ),
            ElevatedButton(
              onPressed: login,
              child: Text('Войти'),
            ),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => RegisterScreen()),
                );
              },
              child: Text('Регистрация'),
            ),
          ],
        ),
      ),
    );
  }
}

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final String registerUrl = "http://192.168.0.104:8080/register";

  Future<void> register() async {
    try {
      final response = await http.post(
        Uri.parse(registerUrl),
        headers: {"Content-Type": "application/x-www-form-urlencoded"},
        body: {
          "username": _usernameController.text,
          "password": _passwordController.text,
        },
      );
      if (response.statusCode == 303) {
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка регистрации')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка сети: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Регистрация')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(labelText: 'Логин'),
            ),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: 'Пароль'),
              obscureText: true,
            ),
            ElevatedButton(
              onPressed: register,
              child: Text('Зарегистрироваться'),
            ),
          ],
        ),
      ),
    );
  }
}

class NotesScreen extends StatefulWidget {
  final String userId;

  NotesScreen({required this.userId});

  @override
  _NotesScreenState createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  List<dynamic> notes = [];
  final String apiUrl = "http://192.168.0.104:8080/api/notes";
  final _searchController = TextEditingController();
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  @override
  void initState() {
    super.initState();
    fetchNotes("");
    Timer.periodic(Duration(seconds: 5), (timer) => fetchNotes(""));
    setupPushNotifications();
  }

  Future<void> setupPushNotifications() async {
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    print('User granted permission: ${settings.authorizationStatus}');

    String? token = await _firebaseMessaging.getToken();
    print('FCM Token: $token');

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Foreground message received: ${message.notification?.title}');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${message.notification?.title}: ${message.notification?.body}')),
      );
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('Message clicked: ${message.notification?.title}');
    });

    RemoteMessage? initialMessage = await _firebaseMessaging.getInitialMessage();
    if (initialMessage != null) {
      print('Initial message: ${initialMessage.notification?.title}');
    }
  }

  Future<void> fetchNotes(String query) async {
    try {
      final url = query.isEmpty ? apiUrl : "$apiUrl?q=$query";
      final response = await http.get(
        Uri.parse(url),
        headers: {"Cookie": "user_id=${widget.userId}"},
      );
      print('Fetch notes response status: ${response.statusCode}');
      print('Fetch notes response body: ${response.body}');
      if (response.statusCode == 200) {
        final decodedBody = utf8.decode(response.bodyBytes);
        final data = jsonDecode(decodedBody);
        if (data != null && data is List) {
          setState(() {
            notes = data;
          });
        } else {
          print('Fetch notes: Received null or invalid list');
          setState(() {
            notes = [];
          });
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка загрузки заметок: ${response.statusCode}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка сети: $e')),
      );
      setState(() {
        notes = [];
      });
    }
  }

  Future<void> createNote(String title, String content, String? reminder, List<String> categories) async {
    try {
      String? formattedReminder = reminder != null
          ? DateTime.parse(reminder).toUtc().toString().substring(0, 16).replaceAll(" ", "T")
          : null;
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          "Content-Type": "application/json; charset=UTF-8",
          "Cookie": "user_id=${widget.userId}",
        },
        body: utf8.encode(jsonEncode({
          "title": title,
          "content": content,
          "reminder_at": formattedReminder,
          "categories": categories,
        })),
      );
      print('Create note request body: ${jsonEncode({"title": title, "content": content, "reminder_at": formattedReminder, "categories": categories})}');
      print('Create note response status: ${response.statusCode}');
      print('Create note response body: ${response.body}');
      if (response.statusCode == 201) {
        fetchNotes("");
        await sendPushNotification(title, content, formattedReminder); // Добавлен await для отладки
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка создания заметки: ${response.statusCode}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка сети: $e')),
      );
    }
  }

  Future<void> sendPushNotification(String title, String content, String? reminder) async {
    if (reminder == null) return; // Отправляем только если есть дата
    String? token = await _firebaseMessaging.getToken();
    if (token == null) {
      print('Ошибка: FCM токен не получен');
      return;
    }
    print('Sending push notification to token: $token');
    try {
      final client = await getAuthClient();
      final response = await client.post(
        Uri.parse('https://fcm.googleapis.com/v1/projects/zamemo-30e45/messages:send'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'message': {
            'token': token,
            'notification': {
              'title': title,
              'body': content,
            },
          },
        }),
      );
      print('Push notification response status: ${response.statusCode}');
      print('Push notification response body: ${response.body}');
      client.close();
    } catch (e) {
      print('Ошибка отправки уведомления: $e');
    }
  }

  Future<void> deleteNote(int noteId) async {
    try {
      final response = await http.post(
        Uri.parse("http://192.168.0.104:8080/delete-note"),
        headers: {
          "Content-Type": "application/x-www-form-urlencoded",
          "Cookie": "user_id=${widget.userId}",
        },
        body: {"id": noteId.toString()},
      );
      print('Delete note response status: ${response.statusCode}');
      print('Delete note response body: ${response.body}');
      if (response.statusCode == 303 || response.statusCode == 200) {
        fetchNotes("");
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка удаления: ${response.statusCode}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка сети: $e')),
      );
      fetchNotes("");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Мои заметки'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () async {
              final prefs = await SharedPreferences.getInstance();
              await prefs.remove('user_id');
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => LoginScreen()),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Поиск заметок',
                suffixIcon: IconButton(
                  icon: Icon(Icons.search),
                  onPressed: () => fetchNotes(_searchController.text),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: CreateNoteForm(onSubmit: createNote),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: notes.length,
              itemBuilder: (context, index) {
                final note = notes[index];
                return ListTile(
                  title: Text(note['title'] ?? 'Без заголовка'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(note['content'] ?? 'Без содержания'),
                      if (note['reminder_at'] != null)
                        Text('Напоминание: ${note['reminder_at']}'),
                      if (note['categories'] != null && note['categories'].isNotEmpty)
                        Text('Категории: ${note['categories'].join(", ")}'),
                    ],
                  ),
                  trailing: IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () => deleteNote(note['id']),
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EditNoteScreen(
                          note: note,
                          userId: widget.userId,
                          onUpdate: () => fetchNotes(""),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class CreateNoteForm extends StatefulWidget {
  final Function(String, String, String?, List<String>) onSubmit;

  CreateNoteForm({required this.onSubmit});

  @override
  _CreateNoteFormState createState() => _CreateNoteFormState();
}

class _CreateNoteFormState extends State<CreateNoteForm> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final _categoriesController = TextEditingController();
  DateTime? _selectedDateTime;

  Future<void> _selectDateTime(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2023),
      lastDate: DateTime(2030),
    );
    if (pickedDate != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );
      if (pickedTime != null) {
        setState(() {
          _selectedDateTime = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          controller: _titleController,
          decoration: InputDecoration(labelText: 'Заголовок'),
        ),
        TextField(
          controller: _contentController,
          decoration: InputDecoration(labelText: 'Содержание'),
        ),
        Row(
          children: [
            Expanded(
              child: Text(
                _selectedDateTime == null
                    ? 'Напоминание не выбрано'
                    : 'Напоминание: ${_selectedDateTime.toString().substring(0, 16)}',
              ),
            ),
            ElevatedButton(
              onPressed: () => _selectDateTime(context),
              child: Text('Выбрать дату и время'),
            ),
          ],
        ),
        TextField(
          controller: _categoriesController,
          decoration: InputDecoration(labelText: 'Категории (через запятую)'),
        ),
        ElevatedButton(
          onPressed: () {
            final categories = _categoriesController.text.split(',').map((e) => e.trim()).toList();
            String? reminder = _selectedDateTime != null
                ? _selectedDateTime.toString().substring(0, 16)
                : null;
            widget.onSubmit(
              _titleController.text,
              _contentController.text,
              reminder,
              categories,
            );
            _titleController.clear();
            _contentController.clear();
            _categoriesController.clear();
            setState(() {
              _selectedDateTime = null;
            });
          },
          child: Text('Создать'),
        ),
      ],
    );
  }
}

class EditNoteScreen extends StatefulWidget {
  final Map<String, dynamic> note;
  final String userId;
  final VoidCallback onUpdate;

  EditNoteScreen({required this.note, required this.userId, required this.onUpdate});

  @override
  _EditNoteScreenState createState() => _EditNoteScreenState();
}

class _EditNoteScreenState extends State<EditNoteScreen> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final _categoriesController = TextEditingController();
  DateTime? _selectedDateTime;

  @override
  void initState() {
    super.initState();
    _titleController.text = widget.note['title'] ?? '';
    _contentController.text = widget.note['content'] ?? '';
    _categoriesController.text = (widget.note['categories'] as List?)?.join(', ') ?? '';
    if (widget.note['reminder_at'] != null) {
      _selectedDateTime = DateTime.tryParse(widget.note['reminder_at']);
    }
  }

  Future<void> _selectDateTime(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDateTime ?? DateTime.now(),
      firstDate: DateTime(2023),
      lastDate: DateTime(2030),
    );
    if (pickedDate != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: _selectedDateTime != null
            ? TimeOfDay.fromDateTime(_selectedDateTime!)
            : TimeOfDay.now(),
      );
      if (pickedTime != null) {
        setState(() {
          _selectedDateTime = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
        });
      }
    }
  }

  Future<void> updateNote() async {
    try {
      final response = await http.post(
        Uri.parse("http://192.168.0.104:8080/update-note"),
        headers: {
          "Content-Type": "application/x-www-form-urlencoded",
          "Cookie": "user_id=${widget.userId}",
        },
        body: {
          "id": widget.note['id'].toString(),
          "title": _titleController.text,
          "content": _contentController.text,
          "reminder": _selectedDateTime != null ? _selectedDateTime.toString().substring(0, 16) : "",
          "categories": _categoriesController.text,
        },
      );
      if (response.statusCode == 303) {
        widget.onUpdate();
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка обновления: ${response.statusCode}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка сети: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Редактировать заметку')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: InputDecoration(labelText: 'Заголовок'),
            ),
            TextField(
              controller: _contentController,
              decoration: InputDecoration(labelText: 'Содержание'),
            ),
            Row(
              children: [
                Expanded(
                  child: Text(
                    _selectedDateTime == null
                        ? 'Напоминание не выбрано'
                        : 'Напоминание: ${_selectedDateTime.toString().substring(0, 16)}',
                  ),
                ),
                ElevatedButton(
                  onPressed: () => _selectDateTime(context),
                  child: Text('Выбрать дату и время'),
                ),
              ],
            ),
            TextField(
              controller: _categoriesController,
              decoration: InputDecoration(labelText: 'Категории (через запятую)'),
            ),
            ElevatedButton(
              onPressed: updateNote,
              child: Text('Сохранить'),
            ),
          ],
        ),
      ),
    );
  }
}