import 'dart:async';
import 'package:cdx_chat/cdx_chat.dart';

/// Example implementation of ChatService using in-memory storage.
///
/// This is a simple implementation for demonstration purposes.
/// It stores messages in memory and simulates network delays.
///
/// In a real application, you would implement this interface to call your
/// backend API. For example:
///
/// ```dart
/// class ApiChatService implements ChatService {
///   final ApiClient _api;
///
///   @override
///   Stream<List<ChatMessage>> watchMessages(...) async* {
///     // Stream messages from your backend
///   }
///   // ... implement other methods
/// }
/// ```
class ExampleChatService implements ChatService {
  final Map<String, List<ChatMessage>> _messagesByChat = {};
  final Map<String, int> _unreadCounts = {};
  final Map<String, Set<String>> _blockedUsers = {};
  final Map<String, StreamController<List<ChatMessage>>> _messageControllers = {};
  int _nextId = 1;

  @override
  Stream<List<ChatMessage>> watchMessages({
    required String chatId,
    int limit = 50,
    String? startAfterMessageId,
  }) {
    // Create a stream controller for this chat if it doesn't exist
    if (!_messageControllers.containsKey(chatId)) {
      _messageControllers[chatId] = StreamController<List<ChatMessage>>.broadcast();
      _messagesByChat.putIfAbsent(chatId, () => []);
      // Emit initial messages
      Future.microtask(() {
        _messageControllers[chatId]!.add(_messagesByChat[chatId]!);
      });
    }

    return _messageControllers[chatId]!.stream;
  }

  @override
  Future<ChatMessage> sendMessage({
    required String chatId,
    required String authorId,
    required String text,
    String? replyToMessageId,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));

    ChatReplySnapshot? replySnapshot;
    if (replyToMessageId != null) {
      final replyTo = _messagesByChat[chatId]
          ?.firstWhere((m) => m.id == replyToMessageId, orElse: () => _messagesByChat[chatId]!.first);
      if (replyTo != null) {
        replySnapshot = ChatReplySnapshot(
          messageId: replyTo.id,
          authorId: replyTo.authorId,
          authorDisplayName: replyTo.authorDisplayName,
          authorAvatarUrl: replyTo.authorAvatarUrl,
          textPreview: replyTo.text.length > 50 
              ? '${replyTo.text.substring(0, 50)}...' 
              : replyTo.text,
          createdAt: replyTo.createdAt,
        );
      }
    }

    final message = ChatMessage(
      id: 'msg_${_nextId++}',
      chatId: chatId,
      authorId: authorId,
      authorDisplayName: _getAuthorName(authorId),
      authorAvatarUrl: null,
      text: text,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      isSystem: false,
      isDeleted: false,
      replyToMessageId: replyToMessageId,
      replyToSnapshot: replySnapshot,
    );

    _messagesByChat.putIfAbsent(chatId, () => []).add(message);
    _notifyMessagesChanged(chatId);

    return message;
  }

  @override
  Future<bool> deleteMessage({
    required String chatId,
    required String messageId,
  }) async {
    await Future.delayed(const Duration(milliseconds: 200));

    final messages = _messagesByChat[chatId];
    if (messages == null) return false;

    final index = messages.indexWhere((m) => m.id == messageId);
    if (index == -1) return false;

    messages[index] = messages[index].copyWith(
      isDeleted: true,
      text: '',
      updatedAt: DateTime.now(),
    );

    _notifyMessagesChanged(chatId);
    return true;
  }

  @override
  Future<void> markAsRead({
    required String chatId,
    required String userId,
    required String lastReadMessageId,
    required DateTime lastReadAt,
  }) async {
    await Future.delayed(const Duration(milliseconds: 100));
    _unreadCounts['$chatId:$userId'] = 0;
  }

  @override
  Stream<int> watchUnreadCount({
    required String chatId,
    required String userId,
  }) {
    final key = '$chatId:$userId';
    _unreadCounts.putIfAbsent(key, () => 0);
    
    return Stream.periodic(
      const Duration(seconds: 1),
      (_) => _unreadCounts[key] ?? 0,
    );
  }

  @override
  Future<bool> blockUser({
    required String chatId,
    required String userId,
    required String blockedUserId,
  }) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final key = '$chatId:$userId';
    _blockedUsers.putIfAbsent(key, () => {}).add(blockedUserId);
    return true;
  }

  @override
  Future<bool> unblockUser({
    required String chatId,
    required String userId,
    required String blockedUserId,
  }) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final key = '$chatId:$userId';
    _blockedUsers[key]?.remove(blockedUserId);
    return true;
  }

  @override
  Stream<Set<String>> watchBlockedUsers({
    required String chatId,
    required String userId,
  }) {
    final key = '$chatId:$userId';
    _blockedUsers.putIfAbsent(key, () => {});
    
    return Stream.periodic(
      const Duration(seconds: 1),
      (_) => Set<String>.from(_blockedUsers[key] ?? {}),
    );
  }

  void _notifyMessagesChanged(String chatId) {
    final controller = _messageControllers[chatId];
    if (controller != null && !controller.isClosed) {
      controller.add(List.from(_messagesByChat[chatId] ?? []));
    }
  }

  String _getAuthorName(String authorId) {
    final names = {
      'user-1': 'John Doe',
      'user-2': 'Jane Smith',
      'user-3': 'Bob Johnson',
    };
    return names[authorId] ?? 'User $authorId';
  }

  void dispose() {
    for (final controller in _messageControllers.values) {
      controller.close();
    }
    _messageControllers.clear();
  }
}

