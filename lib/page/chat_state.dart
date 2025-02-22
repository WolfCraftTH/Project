// chat_state.dart
import 'package:dash_chat_2/dash_chat_2.dart';

class ChatState {
  static final ChatState _instance = ChatState._internal();
  factory ChatState() => _instance;
  ChatState._internal();

  final Map<String, List<ChatMessage>> _messageHistory = {};

  void saveMessages(String userId, List<ChatMessage> messages) {
    _messageHistory[userId] = List.from(messages);
  }

  List<ChatMessage> getMessages(String userId) {
    return List.from(_messageHistory[userId] ?? []);
  }

  void clearMessages(String userId) {
    _messageHistory.remove(userId);
  }
}
