// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class CdxChatLocalizationsEn extends CdxChatLocalizations {
  CdxChatLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get chat => 'Chat';

  @override
  String get type_a_message => 'Type a message...';

  @override
  String get send => 'Send';

  @override
  String get replying_to => 'Replying to';

  @override
  String get delete => 'Delete';

  @override
  String get delete_message => 'Delete message';

  @override
  String get q_delete_message =>
      'Are you sure you want to delete this message?';

  @override
  String get confirm => 'Confirm';

  @override
  String get cancel => 'Cancel';

  @override
  String get block_user => 'Block user';

  @override
  String get unblock_user => 'Unblock user';

  @override
  String get q_block_user => 'Are you sure you want to block this user?';

  @override
  String get q_unblock_user => 'Are you sure you want to unblock this user?';

  @override
  String get message_empty => 'Message cannot be empty';

  @override
  String message_too_long(int maxLength) {
    return 'Message cannot exceed $maxLength characters';
  }

  @override
  String message_too_many_lines(int maxLines) {
    return 'Message cannot exceed $maxLines lines';
  }

  @override
  String get no_messages => 'No messages';

  @override
  String get error_loading_messages => 'Error loading messages';

  @override
  String get retry => 'Retry';

  @override
  String get message_deleted => 'Message deleted';

  @override
  String get error_sending_message => 'Error sending message';

  @override
  String get today => 'Today';

  @override
  String get yesterday => 'Yesterday';
}
