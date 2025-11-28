import 'package:flutter/material.dart';
import 'controller.dart';
import 'models/chat_message.dart';
import 'models/chat_config.dart';
import 'l10n/app_localizations.dart';

/// Provider for managing chat state and UI interactions.
///
/// This class manages the state of messages for a specific chat.
/// It handles loading, sending, replying, and deleting messages,
/// and notifies listeners when the state changes.
///
/// Example:
/// ```dart
/// final provider = ChatProvider(
///   controller: chatController,
///   chatId: 'chat-123',
///   config: chatConfig,
/// );
/// ```
class ChatProvider with ChangeNotifier {
  /// The controller for chat operations.
  final ChatController controller;
  
  /// The ID of the chat this provider manages messages for.
  final String chatId;
  
  /// Configuration for the chat module.
  final ChatConfig config;
  
  /// Text editing controller for the message input field.
  final TextEditingController inputController = TextEditingController();
  
  /// Listener callback for controller changes.
  void _onControllerChange() {
    notifyListeners();
  }
  
  /// Creates a new [ChatProvider].
  ///
  /// Automatically sets up listeners on [inputController] and [controller] to notify listeners
  /// when input changes or when the controller state changes.
  ///
  /// All parameters are required:
  /// - [controller]: The [ChatController] to use for operations
  /// - [chatId]: The ID of the chat to manage messages for
  /// - [config]: The [ChatConfig] for validation and configuration
  ChatProvider({
    required this.controller,
    required this.chatId,
    required this.config,
  }) {
    inputController.addListener(() {
      notifyListeners();
    });
    // Listen to controller changes to propagate them to UI
    controller.addListener(_onControllerChange);
  }

  /// The list of visible messages (filtered by blocked users).
  List<ChatMessage> get messages => controller.visibleMessages;

  /// Whether messages are currently loading.
  bool get isLoading => controller.isLoading;

  /// Whether there are more messages to load.
  bool get hasMore => controller.hasMore;

  /// Current error message, if any.
  String? get error => controller.error;

  /// Number of unread messages.
  int get unreadCount => controller.unreadCount;

  /// Message currently being replied to, if any.
  ChatMessage? get replyingTo => controller.replyingTo;

  /// Set of blocked user IDs.
  Set<String> get blockedUsers => controller.blockedUsers;

  /// Sets the message to reply to.
  ///
  /// When a user starts replying to a message, call this method with that message.
  /// Set to `null` to cancel the reply.
  ///
  /// [message] is the message to reply to, or `null` to clear the reply target.
  void setReplyTo(ChatMessage? message) {
    controller.setReplyingTo(message);
    notifyListeners();
  }

  /// Sends a message or reply based on the current state.
  ///
  /// Validates the content in [inputController], then either:
  /// - Sends a new message if [replyingTo] is `null`
  /// - Sends a reply if [replyingTo] is not `null`
  ///
  /// After sending, clears the input field and resets [replyingTo] if it was set.
  ///
  /// [loc] is the [CdxChatLocalizations] instance for error messages.
  /// [onInputError] is a callback that will be called with an error message
  /// if validation fails.
  ///
  /// If the input is empty, this method returns without doing anything.
  Future<void> sendMessage(
    CdxChatLocalizations loc, {
    required void Function(String) onInputError,
  }) async {
    final text = inputController.text.trim();
    if (text.isEmpty) {
      onInputError(loc.message_empty);
      return;
    }

    // Validate message length
    if (text.length > config.maxMessageLength) {
      onInputError(loc.message_too_long(config.maxMessageLength));
      return;
    }

    // Validate number of lines
    final lines = text.split('\n');
    if (lines.length > config.maxLines) {
      onInputError(loc.message_too_many_lines(config.maxLines));
      return;
    }

    try {
      await controller.sendMessage(text);
      inputController.clear();
      controller.setReplyingTo(null);
      notifyListeners();
    } catch (e) {
      onInputError(loc.error_sending_message);
    }
  }

  /// Deletes a message.
  ///
  /// [message] is the message to delete.
  ///
  /// Throws an exception if deletion fails.
  Future<void> deleteMessage(ChatMessage message) async {
    await controller.deleteMessage(message);
    notifyListeners();
  }

  /// Marks messages as read.
  ///
  /// Marks all messages up to the last one as read.
  Future<void> markAsRead() async {
    await controller.markAsRead();
    notifyListeners();
  }

  /// Blocks a user.
  ///
  /// [userId] is the ID of the user to block.
  ///
  /// Throws an exception if blocking fails.
  Future<void> blockUser(String userId) async {
    await controller.blockUser(userId);
    notifyListeners();
  }

  /// Unblocks a user.
  ///
  /// [userId] is the ID of the user to unblock.
  ///
  /// Throws an exception if unblocking fails.
  Future<void> unblockUser(String userId) async {
    await controller.unblockUser(userId);
    notifyListeners();
  }

  /// Reloads messages (used for retry).
  void reloadMessages() {
    controller.reloadMessages();
    notifyListeners();
  }

  @override
  void dispose() {
    controller.removeListener(_onControllerChange);
    inputController.dispose();
    super.dispose();
  }
}

