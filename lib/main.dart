

import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const AeroShiftApp());
}

class AeroShiftApp extends StatelessWidget {
  const AeroShiftApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AeroShift Chat',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1565C0),
        ),
        useMaterial3: true,
      ),
      home: const WelcomeScreen(),
    );
  }
}

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B1F3A),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.flight_takeoff,
                  size: 90,
                  color: Colors.white,
                ),
                const SizedBox(height: 30),
                const Text(
                  'AeroShift Chat',
                  style: TextStyle(
                    fontSize: 34,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Aircraft Maintenance Shift Handover',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white70,
                  ),
                ),

                const SizedBox(height: 60),
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const LoginScreen(),
                        ),
                      );
                    },
                    child: const Text(
                      'GET STARTED',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}



class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

Future<void> loginUser() async {
  final email = emailController.text.trim();
  final password = passwordController.text;

  if (email.isEmpty || password.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Please enter email and password'),
      ),
    );
    return;
  }

  try {
    final response = await http.post(
      Uri.parse('http://127.0.0.1:3000/login'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );

    if (!mounted) return;

    final data = jsonDecode(response.body);

   

if (response.statusCode == 200) {
  final user = data['user'];
final String token = data['token'] as String;
  Navigator.pushReplacement(
    context,
    MaterialPageRoute(
      builder: (context) => HomeScreen(
        userId: user['user_id'],
        fullName: user['full_name'],
        employeeCode: user['employee_code'],
token: token,
      ),
    ),
  );
}

 else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            data['message'] ?? 'Login failed',
          ),
        ),
      );
    }
  } catch (error) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Connection error: $error'),
      ),
    );
  }
}

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: const Color(0xFF0B1F3A),
      appBar: AppBar(
        title: const Text('Login'),
        backgroundColor: const Color(0xFF0B1F3A),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.flight_takeoff,
              size: 70,
              color: Colors.white,
            ),
            const SizedBox(height: 20),
            const Text(
              'Welcome Back',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 40),
            TextField(
  controller: emailController,
  style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Email',
                labelStyle: TextStyle(color: Colors.white70),
                prefixIcon: Icon(Icons.email, color: Colors.white),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
  controller: passwordController,
  obscureText: true,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Password',
                labelStyle: TextStyle(color: Colors.white70),
                prefixIcon: Icon(Icons.lock, color: Colors.white),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: loginUser,
                child: const Text(
                  'LOGIN',
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        const RegisterScreen(),
                  ),
                );
              },
              child: const Text(
                'CREATE ACCOUNT',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {

  final fullNameController = TextEditingController();
  final employeeCodeController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

Future<void> registerUser() async {
  final fullName = fullNameController.text.trim();
  final employeeCode = employeeCodeController.text.trim();
  final email = emailController.text.trim();
  final password = passwordController.text;

  if (fullName.isEmpty ||
      employeeCode.isEmpty ||
      email.isEmpty ||
      password.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Please fill in all fields'),
      ),
    );
    return;
  }



  try {
    final response = await http.post(
      Uri.parse('http://127.0.0.1:3000/register'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'full_name': fullName,
        'employee_code': employeeCode,
        'email': email,
        'password': password,
      }),
    );

    if (!mounted) return;

    final data = jsonDecode(response.body);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          data['message'] ?? 'Unknown response',
        ),
      ),
    );
  } catch (error) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Connection error: $error'),
      ),
    );
  }
}

  @override
  void dispose() {
    fullNameController.dispose();
    employeeCodeController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B1F3A),
      appBar: AppBar(
        title: const Text('Register'),
        backgroundColor: const Color(0xFF0B1F3A),
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          const SizedBox(height: 30),
          const Icon(
            Icons.person_add,
            size: 70,
            color: Colors.white,
          ),
          const SizedBox(height: 20),
          const Text(
            'Create Account',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 35),
          
_field('Full Name', Icons.person, controller: fullNameController),
_field('Employee Code', Icons.badge, controller: employeeCodeController),
_field('Email', Icons.email, controller: emailController),
_field('Password', Icons.lock,
    password: true, controller: passwordController),

          const SizedBox(height: 30),
          SizedBox(
            height: 55,
            child: ElevatedButton(
              onPressed: registerUser,
              child: const Text('REGISTER'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _field(
    String label,
    IconData icon, {
    bool password = false,
    required TextEditingController controller,
  }) {
    return TextField(
      controller: controller,
      obscureText: password,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white70),
        prefixIcon: Icon(icon, color: Colors.white),
        enabledBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Colors.white54),
        ),
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Colors.white),
        ),
      ),
    );
  }
 }



class HomeScreen extends StatelessWidget {
  final int userId;
  final String fullName;
  final String? employeeCode;
  final String token;

  const HomeScreen({
    super.key,
    required this.userId,
    required this.fullName,
    required this.employeeCode,
    required this.token,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B1F3A),
      appBar: AppBar(
        title: const Text('AeroShift Chat'),
        backgroundColor: const Color(0xFF0B1F3A),
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          
Text(
  'Welcome, $fullName',
  style: const TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: Colors.white,
  ),
),

          const SizedBox(height: 30),
          Card(
            child: ListTile(
              leading: const Icon(Icons.chat),
              title: const Text('Messages'),
              subtitle: const Text('Chat with your colleagues'),
              trailing: const Icon(Icons.arrow_forward_ios),
              
onTap: () {
  Navigator.push(
    context,
    MaterialPageRoute(

builder: (context) => MessagesScreen(
  currentUserId: userId,
  token: token,
),
),
  );
},

            ),
          ),
          const SizedBox(height: 15),
          Card(
            child: ListTile(
              leading: const Icon(Icons.flight),
              title: const Text('Shift Handover'),
              subtitle: const Text('Aircraft maintenance handovers'),
              trailing: const Icon(Icons.arrow_forward_ios),
              
onTap: () {},

            ),
          ),
        ],
      ),
    );
  }
}

class MessagesScreen extends StatefulWidget {
  final int currentUserId;
  final String token;

  const MessagesScreen({
    super.key,
    required this.currentUserId,
    required this.token,
  });



  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  List<dynamic> users = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchUsers();
  }

  Future<void> fetchUsers() async {
    try {
      
final response = await http.get(
  Uri.parse('http://127.0.0.1:3000/users'),
  headers: {
    'Authorization': 'Bearer ${widget.token}',
  },
);


      if (response.statusCode == 200) {
        if (!mounted) return;

        setState(() {
          
users = (jsonDecode(response.body) as List)
    .where((user) => user['user_id'] != widget.currentUserId)
    .toList();

          isLoading = false;
        });
      } else {
        throw Exception('Failed to load users');
      }
    } catch (error) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Messages'),
        backgroundColor: const Color(0xFF0B1F3A),
        foregroundColor: Colors.white,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: users.length,
              itemBuilder: (context, index) {
                final user = users[index];

                return ListTile(
                  leading: const CircleAvatar(
                    child: Icon(Icons.person),
                  ),
                  title: Text(user['full_name']),
                  subtitle: Text(
                    'Employee Code: ${user['employee_code']}',
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  
onTap: () {
  Navigator.push(
    context,
    MaterialPageRoute(
     
builder: (context) => ChatScreen(
  colleagueName: user['full_name'],
  receiverId: user['user_id'],
  currentUserId: widget.currentUserId,
  token: widget.token,
),

    ),
  );
},

                );
              },
            ),
    );
  }
}



class ChatScreen extends StatefulWidget {
  final String colleagueName;
  final int receiverId;
  final int currentUserId;
  final String token;

  const ChatScreen({
    super.key,
    required this.colleagueName,
    required this.receiverId,
    required this.currentUserId,
    required this.token,
  });


  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController messageController =
      TextEditingController();

  List<dynamic> messages = [];
  bool isLoadingMessages = true;
  int? conversationId;

Timer? messageTimer;

 
@override
void initState() {
  super.initState();

  loadMessages();

  messageTimer = Timer.periodic(
    const Duration(seconds: 3),
    (timer) {
      if (mounted && !isLoadingMessages) {
        loadMessages();
      }
    },
  );
}


  Future<void> loadMessages() async {
    try {
      final conversationResponse = await http.get(
        Uri.parse(
          'http://127.0.0.1:3000/conversations/with/${widget.receiverId}',
        ),
        headers: {
          'Authorization': 'Bearer ${widget.token}',
        },
      );

      if (conversationResponse.statusCode != 200) {
        throw Exception('Failed to find conversation');
      }

      final conversationData = jsonDecode(
        conversationResponse.body,
      );

      final int? id = conversationData['conversation_id'];

      if (id == null) {
        if (!mounted) return;

        setState(() {
          conversationId = null;
          messages = [];
          isLoadingMessages = false;
        });
        return;
      }

      final messagesResponse = await http.get(
        Uri.parse('http://127.0.0.1:3000/messages/$id'),
        headers: {
          'Authorization': 'Bearer ${widget.token}',
        },
      );

      if (messagesResponse.statusCode != 200) {
        throw Exception('Failed to load messages');
      }

      if (!mounted) return;

      setState(() {
        conversationId = id;
        messages = jsonDecode(messagesResponse.body) as List;
        isLoadingMessages = false;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        isLoadingMessages = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading messages: $error')),
      );
    }
  }

  bool isSending = false;

  Future<void> sendMessage() async {
    final content = messageController.text.trim();

    if (content.isEmpty || isSending) return;

    setState(() {
      isSending = true;
    });

    try {
      final response = await http.post(
        Uri.parse('http://127.0.0.1:3000/messages'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${widget.token}',
        },
        body: jsonEncode({
          'receiver_id': widget.receiverId,
          'content': content,
        }),
      );

      if (response.statusCode != 201) {
        throw Exception('Failed to send message: ${response.statusCode}');
      }

      if (!mounted) return;

      messageController.clear();
      await loadMessages();

    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error sending message: $error'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          isSending = false;
        });
      }
    }
  }


@override
void dispose() {
  messageTimer?.cancel();
  messageController.dispose();
  super.dispose();
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.colleagueName),
        backgroundColor: const Color(0xFF0B1F3A),
        foregroundColor: Colors.white,
      ),
      
body: Column(
  children: [
    
Expanded(
  child: isLoadingMessages
      ? const Center(
          child: CircularProgressIndicator(),
        )
      : messages.isEmpty
          ? const Center(
              child: Text('No messages yet'),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final message = messages[index];

                final bool isMine =
                    message['sender_id'] == widget.currentUserId;

                return Align(
                  alignment: isMine
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    padding: const EdgeInsets.all(12),
                    constraints: BoxConstraints(
                      maxWidth:
                          MediaQuery.of(context).size.width * 0.75,
                    ),
                    decoration: BoxDecoration(
                      color: isMine
                          ? const Color(0xFF0B1F3A)
                          : Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      message['content'].toString(),
                      style: TextStyle(
                        color: isMine
                            ? Colors.white
                            : Colors.black87,
                        fontSize: 16,
                      ),
                    ),
                  ),
                );
              },
            ),
),

    Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: messageController,
              decoration: const InputDecoration(
                hintText: 'Type a message...',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          const SizedBox(width: 8),
         
IconButton(
  icon: const Icon(Icons.send),
  color: const Color(0xFF0B1F3A),
  onPressed: isSending ? null : sendMessage,
),

        ],
      ),
    ),
  ],
),

    );
  }
}

