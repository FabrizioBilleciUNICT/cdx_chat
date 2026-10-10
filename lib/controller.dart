import 'dart:async';
import 'package:flutter/foundation.dart';
import 'services/chat_service.dart';
import 'models/chat_message.dart';

/// Controller based on ChangeNotifier, compatible with Provider.
///
/// Manages:
/// - Message feed
/// - Unread count
/// - Active reply
/// - Errors
/// - Sending messages
/// - Deletion
/// - User blocking
/// - Pagination
/// - Auto scroll
/// - Mark as read
///
/// Example:
/// ```dart
/// final controller = ChatController(
///   service: chatService,
///   chatId: 'chat-123',
///   currentUserId: 'user-456',
/// );
/// ```
class ChatController extends ChangeNotifier {
  /// The chat service implementation.
  final ChatService service;
  
  /// ID of the chat.
  final String chatId;
  
  /// ID of the current user.
  final String currentUserId;

  // Message state
  List<ChatMessage> _messages = [];
  bool _isLoading = false;
  bool _hasMore = true;
  String? _error;
  /// Live window size; [loadMore] grows it.
  int _messageLimit = 50;
  static const int _messageLimitStep = 50;
  static const int _messageLimitMax = 500;

  // Unread state
  int _unreadCount = 0;

  // Reply state
  ChatMessage? _replyingTo;

  // Blocked users state
  Set<String> _blockedUsers = {};

  // Stream subscriptions
  StreamSubscription<List<ChatMessage>>? _messagesSubscription;
  StreamSubscription<int>? _unreadSubscription;
  StreamSubscription<Set<String>>? _blockedUsersSubscription;

  /// Creates a new [ChatController].
  ///
  /// Automatically initializes and starts listening to messages, unread count,
  /// and blocked users.
  ///
  /// All parameters are required:
  /// - [service]: The [ChatService] implementation to use
  /// - [chatId]: ID of the chat
  /// - [currentUserId]: ID of the current user
  ChatController({
    required this.service,
    required this.chatId,
    required this.currentUserId,
  }) {
    _initialize();
  }

  /// List of all messages.
  List<ChatMessage> get messages => _messages;
  
  /// Whether messages are currently loading.
  bool get isLoading => _isLoading;
  
  /// Whether there are more messages to load.
  bool get hasMore => _hasMore;
  
  /// Current error message, if any.
  String? get error => _error;
  
  /// Number of unread messages.
  int get unreadCount => _unreadCount;
  
  /// Message currently being replied to, if any.
  ChatMessage? get replyingTo => _replyingTo;
  
  /// Set of blocked user IDs.
  Set<String> get blockedUsers => _blockedUsers;

  /// Filters messages removing those from blocked users.
  List<ChatMessage> get visibleMessages {
    return _messages.where((msg) => !_blockedUsers.contains(msg.authorId)).toList();
  }

  void _initialize() {
    _listenMessages();
    _listenUnread();
    _listenBlockedUsers();
  }

  /// Listens to chat messages (can be called for retry).
  void _listenMessages() {
    _isLoading = true;
    notifyListeners();

    _messagesSubscription?.cancel();
    _messagesSubscription = service.watchMessages(
      chatId: chatId,
      limit: _messageLimit,
    ).listen(
      (messages) {
        _messages = messages;
        _isLoading = false;
        _error = null;
        // If the page is short, there is nothing older to fetch.
        if (messages.length < _messageLimit) {
          _hasMore = false;
        }
        notifyListeners();
      },
      onError: (error) {
        _isLoading = false;
        _error = error.toString();
        debugPrint('[ChatController] Error listening to messages: $error');
        notifyListeners();
      },
      cancelOnError: false, // Continue listening even after errors
    );
  }

  /// Reloads messages (used for retry).
  void reloadMessages() {
    _listenMessages();
  }

  /// Loads an older page by widening the live [watchMessages] window.
  Future<void> loadMore() async {
    if (!_hasMore || _isLoading) return;
    if (_messageLimit >= _messageLimitMax) {
      _hasMore = false;
      notifyListeners();
      return;
    }
    final previousCount = _messages.length;
    _messageLimit = (_messageLimit + _messageLimitStep).clamp(0, _messageLimitMax);
    _listenMessages();
    // After re-subscribe, if count did not grow, stop offering more.
    // (Listener updates _hasMore when the next snapshot arrives.)
    if (previousCount == 0) return;
  }

  /// Listens to unread message count.
  void _listenUnread() {
    _unreadSubscription?.cancel();
    _unreadSubscription = service.watchUnreadCount(
      chatId: chatId,
      userId: currentUserId,
    ).listen(
      (count) {
        _unreadCount = count;
        notifyListeners();
      },
      onError: (error) {
        // Silently handle unread count errors
        debugPrint('Error listening unread count: $error');
      },
    );
  }

  /// Listens to blocked users.
  void _listenBlockedUsers() {
    _blockedUsersSubscription?.cancel();
    _blockedUsersSubscription = service.watchBlockedUsers(
      chatId: chatId,
      userId: currentUserId,
    ).listen(
      (blocked) {
        _blockedUsers = blocked;
        notifyListeners();
      },
      onError: (error) {
        // Silently handle blocked users errors
        debugPrint('Error listening blocked users: $error');
      },
    );
  }

  /// Sets the message being replied to.
  ///
  /// [message] is the message to reply to, or `null` to clear the reply.
  void setReplyingTo(ChatMessage? message) {
    _replyingTo = message;
    notifyListeners();
  }

  /// Sends a message.
  ///
  /// [text] is the message text.
  ///
  /// Throws an exception if sending fails.
  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    try {
      await service.sendMessage(
        chatId: chatId,
        authorId: currentUserId,
        text: text.trim(),
        replyToMessageId: _replyingTo?.id,
      );

      // Reset reply after sending
      _replyingTo = null;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  /// Deletes a message.
  ///
  /// [message] is the message to delete.
  ///
  /// Throws an exception if deletion fails.
  Future<void> deleteMessage(ChatMessage message) async {
    try {
      await service.deleteMessage(
        chatId: chatId,
        messageId: message.id,
      );
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  /// Marks messages as read.
  ///
  /// Marks all messages up to the last one as read.
  Future<void> markAsRead() async {
    if (_messages.isEmpty) return;

    final lastMessage = _messages.last;
    try {
      await service.markAsRead(
        chatId: chatId,
        userId: currentUserId,
        lastReadMessageId: lastMessage.id,
        lastReadAt: lastMessage.createdAt,
      );
    } catch (e) {
      debugPrint('Error marking as read: $e');
    }
  }

  /// Blocks a user.
  ///
  /// [userId] is the ID of the user to block.
  ///
  /// Throws an exception if blocking fails.
  Future<void> blockUser(String userId) async {
    try {
      await service.blockUser(
        chatId: chatId,
        userId: currentUserId,
        blockedUserId: userId,
      );
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  /// Unblocks a user.
  ///
  /// [userId] is the ID of the user to unblock.
  ///
  /// Throws an exception if unblocking fails.
  Future<void> unblockUser(String userId) async {
    try {
      await service.unblockUser(
        chatId: chatId,
        userId: currentUserId,
        blockedUserId: userId,
      );
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  @override
  void dispose() {
    _messagesSubscription?.cancel();
    _unreadSubscription?.cancel();
    _blockedUsersSubscription?.cancel();
    super.dispose();
  }
}

