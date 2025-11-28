import 'chat_reply_snapshot.dart';

/// Represents a chat message with support for replies and system messages.
///
/// A message can be either a regular user message, a system message, or a deleted message.
/// Messages can also be replies to other messages, indicated by [replyToMessageId] and [replyToSnapshot].
///
/// Example:
/// ```dart
/// final message = ChatMessage(
///   id: 'msg-1',
///   chatId: 'chat-123',
///   authorId: 'user-456',
///   authorDisplayName: 'John Doe',
///   text: 'Hello!',
///   createdAt: DateTime.now(),
/// );
/// ```
class ChatMessage {
  /// Unique identifier for this message.
  final String id;
  
  /// ID of the chat this message belongs to.
  final String chatId;
  
  /// ID of the user who created this message.
  final String authorId;
  
  /// Display name of the user who created this message.
  final String authorDisplayName;
  
  /// Optional avatar URL for the message author.
  final String? authorAvatarUrl;
  
  /// The text content of the message.
  final String text;
  
  /// Date and time when the message was created.
  final DateTime createdAt;
  
  /// Optional date and time when the message was last updated.
  final DateTime? updatedAt;
  
  /// Whether this is a system message (e.g., "User joined").
  final bool isSystem;
  
  /// Whether this message has been deleted (soft delete).
  final bool isDeleted;
  
  /// ID of the message this is replying to, if any.
  ///
  /// `null` for regular messages, non-null for replies.
  final String? replyToMessageId;
  
  /// Snapshot of the message being replied to, if any.
  ///
  /// Contains minimal information needed to display the reply preview.
  /// `null` for regular messages, non-null for replies.
  final ChatReplySnapshot? replyToSnapshot;

  /// Creates a new [ChatMessage].
  ///
  /// Required parameters:
  /// - [id]: Unique identifier
  /// - [chatId]: ID of the chat
  /// - [authorId]: ID of the message author
  /// - [authorDisplayName]: Display name of the author
  /// - [text]: Message text content
  /// - [createdAt]: Creation date and time
  ///
  /// Optional parameters:
  /// - [authorAvatarUrl]: Avatar URL for the author
  /// - [updatedAt]: Last update date and time
  /// - [isSystem]: Whether this is a system message (default: false)
  /// - [isDeleted]: Whether this message is deleted (default: false)
  /// - [replyToMessageId]: ID of the message being replied to
  /// - [replyToSnapshot]: Snapshot of the replied message
  const ChatMessage({
    required this.id,
    required this.chatId,
    required this.authorId,
    required this.authorDisplayName,
    this.authorAvatarUrl,
    required this.text,
    required this.createdAt,
    this.updatedAt,
    this.isSystem = false,
    this.isDeleted = false,
    this.replyToMessageId,
    this.replyToSnapshot,
  });

  /// Creates a copy of this message with the given fields replaced with new values.
  ///
  /// All fields are optional. If a field is not provided, the original value is kept.
  ChatMessage copyWith({
    String? id,
    String? chatId,
    String? authorId,
    String? authorDisplayName,
    String? authorAvatarUrl,
    String? text,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isSystem,
    bool? isDeleted,
    String? replyToMessageId,
    ChatReplySnapshot? replyToSnapshot,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      chatId: chatId ?? this.chatId,
      authorId: authorId ?? this.authorId,
      authorDisplayName: authorDisplayName ?? this.authorDisplayName,
      authorAvatarUrl: authorAvatarUrl ?? this.authorAvatarUrl,
      text: text ?? this.text,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isSystem: isSystem ?? this.isSystem,
      isDeleted: isDeleted ?? this.isDeleted,
      replyToMessageId: replyToMessageId ?? this.replyToMessageId,
      replyToSnapshot: replyToSnapshot ?? this.replyToSnapshot,
    );
  }

  /// Whether this message is a reply to another message.
  ///
  /// Returns `true` if both [replyToMessageId] and [replyToSnapshot] are not null.
  bool get isReply => replyToMessageId != null && replyToSnapshot != null;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChatMessage &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          chatId == other.chatId &&
          authorId == other.authorId &&
          authorDisplayName == other.authorDisplayName &&
          authorAvatarUrl == other.authorAvatarUrl &&
          text == other.text &&
          createdAt == other.createdAt &&
          updatedAt == other.updatedAt &&
          isSystem == other.isSystem &&
          isDeleted == other.isDeleted &&
          replyToMessageId == other.replyToMessageId &&
          replyToSnapshot == other.replyToSnapshot;

  @override
  int get hashCode =>
      id.hashCode ^
      chatId.hashCode ^
      authorId.hashCode ^
      authorDisplayName.hashCode ^
      authorAvatarUrl.hashCode ^
      text.hashCode ^
      createdAt.hashCode ^
      updatedAt.hashCode ^
      isSystem.hashCode ^
      isDeleted.hashCode ^
      replyToMessageId.hashCode ^
      replyToSnapshot.hashCode;
}

