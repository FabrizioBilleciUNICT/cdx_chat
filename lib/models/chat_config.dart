/// Configuration for the chat module.
///
/// This class holds configuration settings that affect chat behavior,
/// such as message length limits and validation rules.
///
/// Example:
/// ```dart
/// const config = ChatConfig(
///   maxMessageLength: 1000,
///   maxLines: 20,
/// );
/// ```
class ChatConfig {
  /// Maximum length of a message in characters.
  ///
  /// Default is 1000 characters.
  final int maxMessageLength;
  
  /// Maximum number of lines allowed in a message.
  ///
  /// Default is 20 lines.
  final int maxLines;
  
  /// Creates a new [ChatConfig].
  ///
  /// [maxMessageLength] is the maximum number of characters allowed in a message.
  /// [maxLines] is the maximum number of lines allowed in a message.
  const ChatConfig({
    this.maxMessageLength = 1000,
    this.maxLines = 20,
  });
}

