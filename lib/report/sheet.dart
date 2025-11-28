import 'package:cdx_chat/cdx_chat.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'provider.dart';
import 'report.dart';

/// Bottom sheet for reporting a chat message.
///
/// This widget provides a two-step flow for reporting messages:
/// 1. Select a reason for reporting
/// 2. Optionally report or block the user
///
/// Example:
/// ```dart
/// showModalBottomSheet(
///   context: context,
///   isScrollControlled: true,
///   backgroundColor: Colors.transparent,
///   builder: (context) => ReportMessageBottomSheet(
///     chatId: 'chat-123',
///     messageId: 'msg-456',
///     userId: 'user-789',
///     currentUserId: 'user-012',
///     service: chatService,
///     theme: chatTheme,
///     textStyle: chatTextStyle,
///     appActions: chatAppActions,
///     onUserBlocked: () => print('User blocked'),
///   ),
/// );
/// ```
class ReportMessageBottomSheet extends StatelessWidget {
  /// ID of the chat containing the message.
  final String chatId;
  
  /// ID of the message being reported.
  final String messageId;
  
  /// ID of the user who created the message.
  final String userId;
  
  /// ID of the current user (who is reporting).
  final String currentUserId;
  
  /// Callback invoked when a user is blocked.
  final Function() onUserBlocked;
  
  /// The chat service for sending reports.
  final ChatService service;
  
  /// Optional custom theme.
  final ChatTheme? theme;
  
  /// Optional custom text style.
  final ChatTextStyle? textStyle;
  
  /// Optional custom app actions.
  final ChatAppActions? appActions;

  const ReportMessageBottomSheet({
    super.key,
    required this.chatId,
    required this.messageId,
    required this.userId,
    required this.currentUserId,
    required this.onUserBlocked,
    required this.service,
    this.theme,
    this.textStyle,
    this.appActions,
  });

  ChatTheme _getTheme(BuildContext context) {
    return theme ?? DefaultChatTheme(context);
  }

  ChatTextStyle _getTextStyle(BuildContext context) {
    return textStyle ?? DefaultChatTextStyle(context);
  }

  ChatAppActions _getAppActions() {
    return appActions ?? DefaultChatAppActions();
  }

  @override
  Widget build(BuildContext context) {
    final loc = CdxChatLocalizations.of(context)!;
    final chatTheme = _getTheme(context);
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.8,
      minChildSize: 0.4,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return PopScope(
          canPop: true,
          onPopInvokedWithResult: (didPop, result) {
            if (didPop) {
              FocusScope.of(context).unfocus();
            }
          },
          child: Container(
            decoration: BoxDecoration(
              color: chatTheme.mainBackground,
              borderRadius: chatTheme.cardRadius,
            ),
            child: SafeArea(child: _content(context, loc)),
          ),
        );
      },
    );
  }

  Widget _content(BuildContext context, CdxChatLocalizations loc) {
    final chatTheme = _getTheme(context);
    final chatTextStyle = _getTextStyle(context);
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            loc.report,
            style: chatTextStyle.bold18(color: chatTheme.mainText),
          ),
        ),
        Divider(
          color: chatTheme.minorText.withValues(alpha: 0.2),
          height: 1,
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
            child: ChangeNotifierProvider(
              create: (_) => ChatReportProvider(service, onUserBlocked),
              child: Builder(
                builder: (context) {
                  return Consumer<ChatReportProvider>(
                    builder: (context, provider, _) {
                      switch (provider.step) {
                        case ChatReportStep.reason:
                          return _reportReason(context, loc, provider);
                        case ChatReportStep.user:
                          return _reportUser(context, loc, provider);
                      }
                    },
                  );
                },
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _reportReason(
    BuildContext context,
    CdxChatLocalizations loc,
    ChatReportProvider provider,
  ) {
    final chatTheme = _getTheme(context);
    final chatTextStyle = _getTextStyle(context);
    return Column(
      mainAxisSize: MainAxisSize.max,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          loc.q_report_message,
          style: chatTextStyle.bold18(color: chatTheme.mainText),
        ),
        const SizedBox(height: 16),
        for (final reason in chatReportReasons)
          ListTile(
            title: Text(
              reason.label,
              style: chatTextStyle.normal14(color: chatTheme.mainText),
            ),
            leading: Radio<ChatReportReason>(
              value: reason,
              groupValue: provider.selectedReason,
              onChanged: (val) => provider.selectReason(val!),
              fillColor: WidgetStateProperty.resolveWith<Color>((Set<WidgetState> states) {
                if (states.contains(WidgetState.selected)) {
                  return chatTheme.primary;
                }
                return chatTheme.minorText;
              }),
            ),
            onTap: () => provider.selectReason(reason),
          ),
        const Spacer(),
        Selector<ChatReportProvider, ChatReportReason?>(
          selector: (context, provider) => provider.selectedReason,
          builder: (BuildContext context, ChatReportReason? value, Widget? child) =>
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: value != null ? provider.goToNextStep : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: chatTheme.primary,
                    foregroundColor: chatTheme.myBubbleTextStyle.color ?? chatTheme.mainText,
                    disabledBackgroundColor: chatTheme.minorText.withValues(alpha: 0.3),
                  ),
                  child: Text(loc.next),
                ),
              ),
        ),
      ],
    );
  }

  Widget _reportUser(
    BuildContext context,
    CdxChatLocalizations loc,
    ChatReportProvider provider,
  ) {
    final chatTheme = _getTheme(context);
    final chatTextStyle = _getTextStyle(context);
    final actions = _getAppActions();
    return Column(
      mainAxisSize: MainAxisSize.max,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          loc.q_report_user,
          style: chatTextStyle.bold18(color: chatTheme.mainText),
        ),
        const SizedBox(height: 16),
        CheckboxListTile(
          value: provider.reportUser,
          onChanged: provider.toggleReportUser,
          title: Text(
            loc.report_user,
            style: chatTextStyle.normal15(color: chatTheme.mainText),
          ),
          checkboxShape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
          ),
          side: BorderSide(
            color: chatTheme.minorText,
            width: 2,
          ),
        ),
        const SizedBox(height: 16),
        CheckboxListTile(
          value: provider.blockUser,
          onChanged: provider.toggleBlockUser,
          title: Text(
            loc.block_user,
            style: chatTextStyle.normal15(color: chatTheme.mainText),
          ),
          checkboxShape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
          ),
          side: BorderSide(
            color: chatTheme.minorText,
            width: 2,
          ),
        ),
        const Spacer(),
        Selector<ChatReportProvider, bool>(
          selector: (context, provider) => provider.loading,
          builder: (BuildContext context, bool loading, Widget? child) => SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: loading
                  ? null
                  : () async {
                      await provider.submitReport(chatId, messageId, userId, currentUserId);
                      if (context.mounted) {
                        Navigator.pop(context);
                        actions.showInfoSnackbar(context, loc.report_done);
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: chatTheme.primary,
                foregroundColor: chatTheme.myBubbleTextStyle.color ?? chatTheme.mainText,
                disabledBackgroundColor: chatTheme.minorText.withValues(alpha: 0.3),
              ),
              child: loading
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          chatTheme.myBubbleTextStyle.color ?? chatTheme.primary,
                        ),
                      ),
                    )
                  : Text(loc.end),
            ),
          ),
        ),
      ],
    );
  }
}

