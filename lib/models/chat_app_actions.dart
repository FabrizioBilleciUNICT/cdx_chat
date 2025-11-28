import 'package:flutter/material.dart';
import 'chat_message.dart';
import 'user_info.dart';

/// Callbacks for app-level actions like showing snackbars and dialogs.
///
/// This interface allows the chat package to interact with the host app
/// for displaying messages and confirmation dialogs. If not provided, the
/// package will use default Flutter implementations.
abstract class ChatAppActions {
  /// Shows an error snackbar with the given message.
  void showErrorSnackbar(BuildContext context, String message);

  /// Shows an info snackbar with the given message.
  void showInfoSnackbar(BuildContext context, String message);

  /// Shows a confirmation dialog.
  ///
  /// [title] The title of the dialog.
  /// [message] The message to display.
  /// [confirmText] The text for the confirm button.
  /// [cancelText] The text for the cancel button.
  /// [onConfirm] Callback when the user confirms (receives true if confirmed).
  void showConfirmationDialog({
    required BuildContext context,
    required String title,
    required String message,
    required String confirmText,
    required String cancelText,
    required void Function(bool) onConfirm,
  });

  /// Builds a custom avatar widget for the given [message].
  ///
  /// Return `null` to fallback to the default avatar.
  Widget? buildMessageAvatar(BuildContext context, ChatMessage message);

  /// Builds a custom avatar widget for the current user (used in the input field).
  ///
  /// Return `null` to fallback to the default avatar.
  Widget? buildUserAvatar(BuildContext context, UserInfo user);
}

/// Default implementation of [ChatAppActions] using Flutter's standard widgets.
class DefaultChatAppActions implements ChatAppActions {
  const DefaultChatAppActions();

  @override
  void showErrorSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.error,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  void showInfoSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  void showConfirmationDialog({
    required BuildContext context,
    required String title,
    required String message,
    required String confirmText,
    required String cancelText,
    required void Function(bool) onConfirm,
  }) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              onConfirm(false);
            },
            child: Text(cancelText),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              onConfirm(true);
            },
            child: Text(confirmText),
          ),
        ],
      ),
    );
  }

  @override
  Widget? buildMessageAvatar(BuildContext context, ChatMessage message) => null;

  @override
  Widget? buildUserAvatar(BuildContext context, UserInfo user) => null;
}

