/// Information about the current user.
///
/// This class holds basic user information needed for chat operations.
///
/// Example:
/// ```dart
/// const user = UserInfo(
///   uuid: 'user-123',
///   name: 'John Doe',
/// );
/// ```
class UserInfo {
  /// Unique identifier for the user.
  final String uuid;
  
  /// Display name of the user.
  final String name;
  
  /// Creates a new [UserInfo] instance.
  ///
  /// Both [uuid] and [name] are required.
  const UserInfo({
    required this.uuid,
    required this.name,
  });
  
  /// Gets the user's initials for display in avatars.
  ///
  /// For names with multiple words, takes the first letter of the first two words.
  /// For single words, takes the first 1-2 characters.
  /// Returns '??' if the name is empty.
  ///
  /// Examples:
  /// - "John Doe" -> "JD"
  /// - "Alice" -> "AL"
  /// - "A" -> "A"
  /// - "" -> "??"
  String get initials {
    if (name.isEmpty) return '??';
    final words = name.trim().split(RegExp(r'\s+'));
    if (words.length >= 2) {
      return (words[0][0] + words[1][0]).toUpperCase();
    }
    return name.length >= 2 
        ? name.substring(0, 2).toUpperCase()
        : name.substring(0, 1).toUpperCase();
  }
}

