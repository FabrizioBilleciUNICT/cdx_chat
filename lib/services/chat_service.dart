import 'dart:async';
import '../models/chat_message.dart';

/// Abstract interface that defines all backend-side behavior for chat.
///
/// Concrete implementations can use Firestore, REST, Supabase, etc.
///
/// Example:
/// ```dart
/// class MyChatService implements ChatService {
///   @override
///   Stream<List<ChatMessage>> watchMessages({
///     required String chatId,
///     int limit = 50,
///     String? startAfterMessageId,
///   }) {
///     // Your implementation
///   }
///   // ... implement other methods
/// }
/// ```
abstract class ChatService {
  /// Paginated stream of messages for a chat.
  ///
  /// - [chatId]: ID of the chat
  /// - [limit]: Maximum number of messages to return
  /// - [startAfterMessageId]: ID of the message to start after (for pagination)
  ///
  /// Returns a stream that emits lists of messages ordered from oldest to newest.
  Stream<List<ChatMessage>> watchMessages({
    required String chatId,
    int limit = 50,
    String? startAfterMessageId,
  });

  /// Sends a new message.
  ///
  /// - [chatId]: ID of the chat
  /// - [authorId]: ID of the author
  /// - [text]: Message text
  /// - [replyToMessageId]: ID of the message being replied to (optional)
  ///
  /// Returns the created message or throws an exception on error.
  Future<ChatMessage> sendMessage({
    required String chatId,
    required String authorId,
    required String text,
    String? replyToMessageId,
  });

  /// Deletes a message (soft delete).
  ///
  /// - [chatId]: ID of the chat
  /// - [messageId]: ID of the message to delete
  ///
  /// Returns true if the operation succeeded.
  Future<bool> deleteMessage({
    required String chatId,
    required String messageId,
  });

  /// Marks messages as read.
  ///
  /// - [chatId]: ID of the chat
  /// - [userId]: ID of the user reading
  /// - [lastReadMessageId]: ID of the last read message
  /// - [lastReadAt]: Timestamp of the last read
  ///
  /// Typical implementation: update on chat members document.
  Future<void> markAsRead({
    required String chatId,
    required String userId,
    required String lastReadMessageId,
    required DateTime lastReadAt,
  });

  /// Stream of unread message count.
  ///
  /// - [chatId]: ID of the chat
  /// - [userId]: ID of the user
  ///
  /// Returns a stream that emits the number of unread messages.
  Stream<int> watchUnreadCount({
    required String chatId,
    required String userId,
  });

  /// Blocks a user.
  ///
  /// - [chatId]: ID of the chat
  /// - [userId]: ID of the user blocking
  /// - [blockedUserId]: ID of the user to block
  ///
  /// Returns true if the operation succeeded.
  Future<bool> blockUser({
    required String chatId,
    required String userId,
    required String blockedUserId,
  });

  /// Unblocks a user.
  ///
  /// - [chatId]: ID of the chat
  /// - [userId]: ID of the user unblocking
  /// - [blockedUserId]: ID of the user to unblock
  ///
  /// Returns true if the operation succeeded.
  Future<bool> unblockUser({
    required String chatId,
    required String userId,
    required String blockedUserId,
  });

  /// Stream of blocked users.
  ///
  /// - [chatId]: ID of the chat
  /// - [userId]: ID of the user
  ///
  /// Returns a stream that emits a set of blocked user IDs.
  Stream<Set<String>> watchBlockedUsers({
    required String chatId,
    required String userId,
  });
}

