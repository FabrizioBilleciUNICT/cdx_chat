/// Minimal snapshot of a quoted message.
///
/// Used only to display the quote in UI without needing to fetch the original message.
///
/// Example:
/// ```dart
/// final snapshot = ChatReplySnapshot(
///   messageId: 'msg-1',
///   authorId: 'user-456',
///   authorDisplayName: 'John Doe',
///   textPreview: 'Original message text...',
///   createdAt: DateTime.now(),
/// );
/// ```
class ChatReplySnapshot {
  /// ID of the original message being replied to.
  final String messageId;
  
  /// ID of the author of the original message.
  final String authorId;
  
  /// Display name of the author of the original message.
  final String authorDisplayName;
  
  /// Optional avatar URL for the original message author.
  final String? authorAvatarUrl;
  
  /// Preview text of the original message (typically truncated).
  final String textPreview;
  
  /// Creation date of the original message.
  final DateTime createdAt;

  /// Creates a new [ChatReplySnapshot].
  ///
  /// All parameters except [authorAvatarUrl] are required.
  const ChatReplySnapshot({
    required this.messageId,
    required this.authorId,
    required this.authorDisplayName,
    this.authorAvatarUrl,
    required this.textPreview,
    required this.createdAt,
  });

  /// Creates a copy of this snapshot with the given fields replaced with new values.
  ///
  /// All fields are optional. If a field is not provided, the original value is kept.
  ChatReplySnapshot copyWith({
    String? messageId,
    String? authorId,
    String? authorDisplayName,
    String? authorAvatarUrl,
    String? textPreview,
    DateTime? createdAt,
  }) {
    return ChatReplySnapshot(
      messageId: messageId ?? this.messageId,
      authorId: authorId ?? this.authorId,
      authorDisplayName: authorDisplayName ?? this.authorDisplayName,
      authorAvatarUrl: authorAvatarUrl ?? this.authorAvatarUrl,
      textPreview: textPreview ?? this.textPreview,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChatReplySnapshot &&
          runtimeType == other.runtimeType &&
          messageId == other.messageId &&
          authorId == other.authorId &&
          authorDisplayName == other.authorDisplayName &&
          authorAvatarUrl == other.authorAvatarUrl &&
          textPreview == other.textPreview &&
          createdAt == other.createdAt;

  @override
  int get hashCode =>
      messageId.hashCode ^
      authorId.hashCode ^
      authorDisplayName.hashCode ^
      authorAvatarUrl.hashCode ^
      textPreview.hashCode ^
      createdAt.hashCode;
}

