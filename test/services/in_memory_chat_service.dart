import 'dart:async';
import 'package:cdx_chat/cdx_chat.dart';

/// In-memory implementation of ChatService for testing
class InMemoryChatService implements ChatService {
  final Map<String, List<ChatMessage>> _messagesByChat = {};
  final Map<String, StreamController<List<ChatMessage>>> _messageControllers = {};
  final Map<String, int> _unreadCounts = {};
  final Map<String, Set<String>> _blockedUsers = {};
  final Map<String, StreamController<Set<String>>> _blockedUsersControllers = {};
  int _nextId = 1;

  @override
  Stream<List<ChatMessage>> watchMessages({
    required String chatId,
    int limit = 50,
    String? startAfterMessageId,
  }) {
    if (!_messageControllers.containsKey(chatId)) {
      _messageControllers[chatId] = StreamController<List<ChatMessage>>.broadcast();
      _messagesByChat.putIfAbsent(chatId, () => []);
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
    await Future.delayed(const Duration(milliseconds: 100));

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
    await Future.delayed(const Duration(milliseconds: 100));

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
    await Future.delayed(const Duration(milliseconds: 100));
    final key = '$chatId:$userId';
    _blockedUsers.putIfAbsent(key, () => {}).add(blockedUserId);
    _notifyBlockedUsersChanged(key);
    return true;
  }

  @override
  Future<bool> unblockUser({
    required String chatId,
    required String userId,
    required String blockedUserId,
  }) async {
    await Future.delayed(const Duration(milliseconds: 100));
    final key = '$chatId:$userId';
    _blockedUsers[key]?.remove(blockedUserId);
    _notifyBlockedUsersChanged(key);
    return true;
  }

  @override
  Stream<Set<String>> watchBlockedUsers({
    required String chatId,
    required String userId,
  }) {
    final key = '$chatId:$userId';
    _blockedUsers.putIfAbsent(key, () => {});
    if (!_blockedUsersControllers.containsKey(key)) {
      _blockedUsersControllers[key] = StreamController<Set<String>>.broadcast();
      Future.microtask(() {
        _blockedUsersControllers[key]!.add(Set<String>.from(_blockedUsers[key] ?? {}));
      });
    }
    return _blockedUsersControllers[key]!.stream;
  }

  void _notifyBlockedUsersChanged(String key) {
    final controller = _blockedUsersControllers[key];
    if (controller != null && !controller.isClosed) {
      controller.add(Set<String>.from(_blockedUsers[key] ?? {}));
    }
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

  /// Clear all data (useful for test cleanup)
  void clear() {
    for (final controller in _messageControllers.values) {
      controller.close();
    }
    for (final controller in _blockedUsersControllers.values) {
      controller.close();
    }
    _messageControllers.clear();
    _blockedUsersControllers.clear();
    _messagesByChat.clear();
    _unreadCounts.clear();
    _blockedUsers.clear();
    _nextId = 1;
  }

  @override
  Future<void> reportMessage({
    required String chatId,
    required String messageId,
    required String reasonId
  }) async {}

  @override
  Future<void> reportUser({
    required String chatId,
    required String userId
  }) async {}
}

