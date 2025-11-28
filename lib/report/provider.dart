import 'package:cdx_chat/cdx_chat.dart';
import 'package:flutter/material.dart';
import 'report.dart';

/// Steps in the report flow.
enum ChatReportStep {
  /// First step: selecting the reason for reporting.
  reason,
  
  /// Second step: choosing to report/block the user.
  user,
}

/// Provider for managing the chat message/user reporting flow.
///
/// This provider manages the state of the reporting dialog, including
/// the selected reason, whether to report the user, and whether to block them.
///
/// Example:
/// ```dart
/// final provider = ChatReportProvider(
///   chatService,
///   () => print('User was blocked'),
/// );
/// ```
class ChatReportProvider extends ChangeNotifier {
  /// The service for sending reports.
  final ChatService service;
  
  /// Callback invoked when a user is blocked.
  final Function() onUserBlocked;
  
  /// Creates a new [ChatReportProvider].
  ///
  /// [service] is used to send the report to the server.
  /// [onUserBlocked] is called when a user is successfully blocked.
  ChatReportProvider(this.service, this.onUserBlocked);

  /// The reason selected for reporting the message.
  ///
  /// `null` if no reason has been selected yet.
  ChatReportReason? selectedReason;
  
  /// The current step in the report flow.
  ///
  /// Starts at [ChatReportStep.reason] and moves to [ChatReportStep.user] after
  /// a reason is selected.
  ChatReportStep step = ChatReportStep.reason;
  
  /// Whether to block the user.
  bool _blockUser = false;
  
  /// Whether the user should be blocked.
  bool get blockUser => _blockUser;
  
  /// Whether to report the user.
  bool _reportUser = false;
  
  /// Whether the user should be reported.
  bool get reportUser => _reportUser;
  
  /// Whether a report submission is in progress.
  bool _loading = false;
  
  /// Whether a report is currently being submitted.
  bool get loading => _loading;

  /// Selects a reason for reporting the message.
  ///
  /// [reason] is the [ChatReportReason] selected by the user.
  void selectReason(ChatReportReason reason) {
    selectedReason = reason;
    notifyListeners();
  }

  /// Toggles whether to report the user.
  ///
  /// [value] is the new value. If `null`, defaults to `false`.
  void toggleReportUser(bool? value) {
    _reportUser = value ?? false;
    notifyListeners();
  }

  /// Toggles whether to block the user.
  ///
  /// [value] is the new value. If `null`, defaults to `false`.
  void toggleBlockUser(bool? value) {
    _blockUser = value ?? false;
    notifyListeners();
  }

  /// Advances to the next step in the report flow.
  ///
  /// Only advances if a reason has been selected.
  /// Moves from [ChatReportStep.reason] to [ChatReportStep.user].
  void goToNextStep() {
    if (selectedReason != null) {
      step = ChatReportStep.user;
      notifyListeners();
    }
  }

  /// Resets the report provider to its initial state.
  ///
  /// Clears the selected reason, resets all flags, and returns to the first step.
  void reset() {
    selectedReason = null;
    _reportUser = false;
    _blockUser = false;
    step = ChatReportStep.reason;
    notifyListeners();
  }

  /// Submits the report to the server.
  ///
  /// Sends the report for the message and optionally reports/blocks the user
  /// based on the current state.
  ///
  /// [chatId] is the ID of the chat.
  /// [messageId] is the ID of the message being reported.
  /// [userId] is the ID of the user who created the message.
  /// [currentUserId] is the ID of the current user (who is reporting).
  ///
  /// After submission, resets the provider state and calls [onUserBlocked]
  /// if the user was blocked.
  Future<void> submitReport(String chatId, String messageId, String userId, String currentUserId) async {
    _loading = true;
    notifyListeners();
    try {
      await service.reportMessage(
        chatId: chatId,
        messageId: messageId,
        reasonId: selectedReason!.id,
      );
      if (_reportUser) {
        await service.reportUser(chatId: chatId, userId: userId);
      }
      if (_blockUser) {
        await service.blockUser(
          chatId: chatId,
          userId: currentUserId,
          blockedUserId: userId,
        );
        onUserBlocked();
      }
    } finally {
      _loading = false;
      notifyListeners();
      reset();
    }
  }
}

