/// A reason for reporting a chat message.
///
/// Each report reason has an ID (used for server communication) and
/// a label (displayed to the user).
///
/// Example:
/// ```dart
/// const reason = ChatReportReason('spam', 'Spam or misleading content');
/// ```
class ChatReportReason {
  /// Unique identifier for this report reason.
  ///
  /// This ID is sent to the server when submitting a report.
  final String id;
  
  /// Human-readable label for this report reason.
  ///
  /// This is displayed to the user in the report dialog.
  final String label;
  
  /// Creates a new [ChatReportReason].
  ///
  /// [id] is the unique identifier.
  /// [label] is the display text.
  const ChatReportReason(this.id, this.label);
}

/// Predefined list of report reasons for chat messages.
///
/// These are the standard reasons users can select when reporting a message.
/// The labels are in Italian; they should be localized based on the app's language.
///
/// To customize, create your own list with localized labels:
/// ```dart
/// final localizedReasons = [
///   ChatReportReason('spam', localizations.report_reason_spam),
///   ChatReportReason('hate', localizations.report_reason_hate),
///   // ...
/// ];
/// ```
const List<ChatReportReason> chatReportReasons = [
  ChatReportReason('spam', 'Spam o contenuto fuorviante'),
  ChatReportReason('hate', 'Incitamento all\'odio o violenza'),
  ChatReportReason('harassment', 'Molestie o bullismo'),
];

