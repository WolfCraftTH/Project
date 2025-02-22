import 'package:flutter/material.dart';
import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:http/http.dart' as http;
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';
import 'home_page.dart';
import 'book_page.dart';
import 'chat_state.dart';

class AIChatPage extends StatefulWidget {
  final String apiUrl;

  const AIChatPage({
    Key? key,
    required this.apiUrl,
  }) : super(key: key);

  @override
  _AIChatPageState createState() => _AIChatPageState();
}

class _AIChatPageState extends State<AIChatPage>
    with AutomaticKeepAliveClientMixin {
  final List<ChatMessage> messages = [];
  late ChatUser user;
  final ChatUser ai = ChatUser(id: "ai", firstName: "AI Assistant");
  bool _isLoading = false;
  late SharedPreferences prefs;
  final ChatState chatState = ChatState();
  final _storage = const FlutterSecureStorage();
  String? _userId;
  String? _userName;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _initializeUserAndChat();
  }

  Future<void> _initializeUserAndChat() async {
    await _loadUserData();
    await _initializeChat();
  }

  Future<void> _loadUserData() async {
    try {
      final String? userId = await _storage.read(key: 'user_id');
      final String? userData = await _storage.read(key: 'user_data');

      if (userId != null && userData != null) {
        final Map<String, dynamic> userMap = json.decode(userData);
        setState(() {
          _userId = userId;
          _userName = userMap['name'] ?? userId;
          user = ChatUser(
            id: userId,
            firstName: _userName ?? userId,
          );
        });
      } else {
        throw Exception('ไม่พบข้อมูลผู้ใช้ กรุณาเข้าสู่ระบบใหม่');
      }
    } catch (e) {
      debugPrint('Error loading user data: $e');
      _showError('ไม่สามารถโหลดข้อมูลผู้ใช้ได้ กรุณาลองใหม่อีกครั้ง');
      if (mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil(
          '/login',
          (route) => false,
        );
      }
    }
  }

  Future<void> _initializeChat() async {
    if (_userId == null) return;

    // ลองโหลดข้อความจาก Global State ก่อน
    final cachedMessages = chatState.getMessages(_userId!);
    if (cachedMessages.isNotEmpty) {
      setState(() {
        messages.clear();
        messages.addAll(cachedMessages);
      });
      return;
    }

    // ถ้าไม่มีใน Global State ให้โหลดจาก SharedPreferences
    try {
      prefs = await SharedPreferences.getInstance();
      await _loadMessages();
    } catch (e) {
      debugPrint('Error initializing chat: $e');
    }
  }

  Future<void> _loadMessages() async {
    if (_userId == null) return;

    try {
      final String? savedMessagesJson =
          prefs.getString('chat_history_$_userId');
      if (savedMessagesJson != null) {
        final List<dynamic> savedMessages = jsonDecode(savedMessagesJson);
        final loadedMessages = savedMessages
            .map((messageMap) => ChatMessage(
                  text: messageMap['text'],
                  user: ChatUser(
                    id: messageMap['userId'],
                    firstName: messageMap['userFirstName'],
                  ),
                  createdAt: DateTime.parse(messageMap['createdAt']),
                ))
            .toList();

        setState(() {
          messages.clear();
          messages.addAll(loadedMessages);
        });

        chatState.saveMessages(_userId!, messages);
      }
    } catch (e) {
      debugPrint('Error loading messages: $e');
    }
  }

  Future<void> _saveMessages() async {
    if (_userId == null) return;

    try {
      final List<Map<String, dynamic>> messagesList = messages
          .map((message) => {
                'text': message.text,
                'userId': message.user.id,
                'userFirstName': message.user.firstName,
                'createdAt': message.createdAt.toIso8601String(),
              })
          .toList();

      await prefs.setString(
        'chat_history_$_userId',
        jsonEncode(messagesList),
      );

      chatState.saveMessages(_userId!, messages);
    } catch (e) {
      debugPrint('Error saving messages: $e');
    }
  }

  Future<void> getAIResponse(String message) async {
    if (_userId == null) {
      _showError('กรุณาเข้าสู่ระบบก่อนใช้งาน');
      return;
    }

    try {
      final uri = Uri.parse('${widget.apiUrl}/chat');

      setState(() {
        _isLoading = true;
      });

      final request = http.Request('POST', uri);
      request.headers['Content-Type'] = 'application/json';
      request.body = jsonEncode({
        'message': message,
        'user_id': _userId,
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

        String fullResponse = '';
        await for (var chunk
            in streamedResponse.stream.transform(utf8.decoder)) {
          try {
            final data = jsonDecode(chunk);
            final response = data['response'] as String;
            fullResponse += response;

            setState(() {
              messages[0] = ChatMessage(
                text: fullResponse,
                user: ai,
                createdAt: aiMessage.createdAt,
              );
            });
          } catch (e) {
            debugPrint('Error parsing chunk: $e');
          }
        }
        await _saveMessages();
      } else {
        _showError(
            'เกิดข้อผิดพลาดในการเชื่อมต่อ: ${streamedResponse.statusCode}');
      }
    } catch (e) {
      _showError('เกิดข้อผิดพลาด: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showError(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  Future<void> sendMessage(ChatMessage message) async {
    setState(() {
      messages.insert(0, message);
    });
    await _saveMessages();
    await getAIResponse(message.text);
  }

  void _navigateToPage(Widget page) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => page),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    if (_userId == null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "AI Chat",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color.fromARGB(255, 103, 80, 164),
      ),
      body: Column(
        children: [
          if (_isLoading)
            const LinearProgressIndicator(
              backgroundColor: Color.fromARGB(255, 103, 80, 164),
            ),
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
            selectedIndex: 1,
            onTabChange: (index) {
              if (index == 0) {
                _navigateToPage(const HomePage());
              } else if (index == 2) {
                _navigateToPage(const BookPage());
              }
            },
            tabs: const [
              GButton(icon: Icons.home, text: 'หน้าหลัก'),
              GButton(icon: Icons.comment, text: 'AI แชท'),
              GButton(icon: Icons.book, text: 'จองหนังสือ'),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _saveMessages();
    super.dispose();
  }
}
