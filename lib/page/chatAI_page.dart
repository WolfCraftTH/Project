import 'package:flutter/material.dart';
import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:http/http.dart' as http;
import 'package:google_nav_bar/google_nav_bar.dart';
import 'dart:convert';
import 'home_page.dart';
import 'book_page.dart';

class AIChatPage extends StatefulWidget {
  final String apiUrl;
  final String userId;

  const AIChatPage({
    Key? key,
    required this.apiUrl,
    required this.userId,
  }) : super(key: key);

  @override
  _AIChatPageState createState() => _AIChatPageState();
}

class _AIChatPageState extends State<AIChatPage> {
  final List<ChatMessage> messages = [];
  late final ChatUser user;
  final ChatUser ai = ChatUser(id: "2", firstName: "AI Assistant");
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    user = ChatUser(id: "test@gmail.com", firstName: widget.userId);
  }

  Future<void> getAIResponse(String message) async {
    try {
      final uri = Uri.parse('${widget.apiUrl}/chat');

      setState(() {
        _isLoading = true;
      });

      final request = http.Request('POST', uri);
      request.headers['Content-Type'] = 'application/json';
      request.body = jsonEncode({
        'message': message,
        'user_id': user.firstName,
      });

      final streamedResponse = await request.send();

      if (streamedResponse.statusCode == 200) {
        final aiMessage = ChatMessage(
          text: '',
          user: ai,
          createdAt: DateTime.now(),
        );

        setState(() {
          messages.insert(0, aiMessage);
        });

        await for (var chunk
            in streamedResponse.stream.transform(utf8.decoder)) {
          try {
            final data = jsonDecode(chunk);
            final response = data['response'] as String;

            setState(() {
              messages[0] = ChatMessage(
                text: messages[0].text + response,
                user: ai,
                createdAt: messages[0].createdAt,
              );
            });
          } catch (e) {
            print('Error parsing chunk: $e');
          }
        }
      } else {
        setState(() {
          messages.insert(
              0,
              ChatMessage(
                text:
                    'เกิดข้อผิดพลาดในการเชื่อมต่อ: ${streamedResponse.statusCode}',
                user: ai,
                createdAt: DateTime.now(),
              ));
        });
      }
    } catch (e) {
      setState(() {
        messages.insert(
            0,
            ChatMessage(
              text: 'เกิดข้อผิดพลาด: $e',
              user: ai,
              createdAt: DateTime.now(),
            ));
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void sendMessage(ChatMessage message) async {
    setState(() {
      messages.insert(0, message);
      _isLoading = true;
    });

    await getAIResponse(message.text);

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "AI Chat",
          style: TextStyle(
            color: Color.fromARGB(255, 255, 255, 255),
          ),
        ),
        backgroundColor: const Color.fromARGB(255, 103, 80, 164),
      ),
      body: Column(
        children: [
          if (_isLoading) const LinearProgressIndicator(),
          Expanded(
            child: DashChat(
              currentUser: user,
              onSend: sendMessage,
              messages: messages,
              inputOptions: const InputOptions(
                sendOnEnter: true,
                alwaysShowSend: true,
              ),
              messageOptions: const MessageOptions(
                showTime: true,
                containerColor: Color.fromARGB(255, 103, 80, 164),
                textColor: Colors.white,
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        color: const Color.fromARGB(255, 103, 80, 164),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 20),
          child: GNav(
            backgroundColor: const Color.fromARGB(255, 103, 80, 164),
            color: Colors.white,
            activeColor: Colors.white,
            tabBackgroundColor: const Color.fromARGB(200, 102, 46, 145),
            gap: 6,
            padding: const EdgeInsets.all(16),
            onTabChange: (index) {
              if (index == 0) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const HomePage(),
                  ),
                );
              } else if (index == 2) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const BookPage(),
                  ),
                );
              }
            },
            tabs: const [
              GButton(
                icon: Icons.home,
                text: 'Home',
              ),
              GButton(
                icon: Icons.comment,
                text: 'AI Chat',
              ),
              GButton(
                icon: Icons.book,
                text: 'จองหนังสือ',
              )
            ],
            selectedIndex: 1,
          ),
        ),
      ),
    );
  }
}

class LoginPage extends StatefulWidget {
  final String apiUrl;

  const LoginPage({
    Key? key,
    required this.apiUrl,
  }) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  Future<void> _login() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.post(
        Uri.parse('${widget.apiUrl}/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': _usernameController.text,
          'password': _passwordController.text,
        }),
      );

      final data = jsonDecode(response.body);

      if (data['status'] == 'success') {
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => AIChatPage(
              apiUrl: widget.apiUrl,
              userId: data['user_id'].toString(),
            ),
          ),
        );
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['message'])),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('เกิดข้อผิดพลาด: $e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('เข้าสู่ระบบ'),
        backgroundColor: const Color.fromARGB(255, 103, 80, 164),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _usernameController,
              decoration: const InputDecoration(
                labelText: 'ชื่อผู้ใช้',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(
                labelText: 'รหัสผ่าน',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _isLoading ? null : _login,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 103, 80, 164),
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              ),
              child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('เข้าสู่ระบบ'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
