import 'package:flutter/material.dart';
import '../models/chat_message.dart';
import '../models/chat_theme.dart';

/// Default message bubble widget.
///
/// This is ONLY a default: it can be replaced via builder.
///
/// Supports:
/// - Avatar
/// - Author name
/// - My/other bubbles
/// - Reply preview
/// - System messages
/// - Deleted messages
/// - Long-press → reply
/// - Applied theme
class MessageBubble extends StatelessWidget {
  /// The message to display.
  final ChatMessage message;
  
  /// ID of the current user.
  final String currentUserId;
  
  /// Theme to use for styling.
  final ChatTheme theme;
  
  /// Callback when bubble is long-pressed.
  final VoidCallback? onLongPress;
  
  /// Callback when avatar is tapped.
  final VoidCallback? onAvatarTap;
  
  /// Whether to show the avatar.
  final bool showAvatar;
  
  /// Whether to show the author name.
  final bool showAuthorName;

  /// Creates a new [MessageBubble].
  const MessageBubble({
    super.key,
    required this.message,
    required this.currentUserId,
    required this.theme,
    this.onLongPress,
    this.onAvatarTap,
    this.showAvatar = true,
    this.showAuthorName = true,
  });

  bool get isMyMessage => message.authorId == currentUserId;
  bool get isSystem => message.isSystem;
  bool get isDeleted => message.isDeleted;

  @override
  Widget build(BuildContext context) {
    if (isSystem) {
      return _buildSystemMessage();
    }

    if (isDeleted) {
      return _buildDeletedMessage();
    }

    return GestureDetector(
      onLongPress: onLongPress,
      child: Row(
        mainAxisAlignment: isMyMessage 
            ? MainAxisAlignment.end 
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMyMessage && showAvatar) _buildAvatar(),
          Flexible(
            child: Column(
              crossAxisAlignment: isMyMessage 
                  ? CrossAxisAlignment.end 
                  : CrossAxisAlignment.start,
              children: [
                if (showAuthorName && !isMyMessage) _buildAuthorName(),
                const SizedBox(height: 4),
                _buildBubble(),
              ],
            ),
          ),
          if (isMyMessage && showAvatar) _buildAvatar(),
        ],
      ),
    );
  }

  Widget _buildSystemMessage() {
    return Center(
      child: Container(
        padding: theme.systemBubblePadding,
        decoration: BoxDecoration(
          color: theme.systemBubbleColor,
          borderRadius: BorderRadius.circular(theme.systemBubbleBorderRadius),
        ),
        child: Text(
          message.text,
          style: theme.systemBubbleTextStyle,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildDeletedMessage() {
    return Center(
      child: Container(
        padding: theme.otherBubblePadding,
        decoration: BoxDecoration(
          color: theme.deletedBubbleColor,
          borderRadius: BorderRadius.circular(theme.deletedBubbleBorderRadius),
        ),
        child: Text(
          'Message deleted',
          style: theme.deletedBubbleTextStyle,
        ),
      ),
    );
  }

  Widget _buildAvatar() {
    return GestureDetector(
      onTap: onAvatarTap,
      child: Container(
        width: theme.avatarRadius * 2,
        height: theme.avatarRadius * 2,
        margin: EdgeInsets.only(
          left: isMyMessage ? 8 : 0,
          right: isMyMessage ? 0 : 8,
        ),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: theme.avatarBackgroundColor,
          image: message.authorAvatarUrl != null
              ? DecorationImage(
                  image: NetworkImage(message.authorAvatarUrl!),
                  fit: BoxFit.cover,
                )
              : null,
        ),
        child: message.authorAvatarUrl == null
            ? Center(
                child: Text(
                  message.authorDisplayName.isNotEmpty
                      ? message.authorDisplayName[0].toUpperCase()
                      : '?',
                  style: TextStyle(
                    color: theme.otherBubbleTextStyle.color,
                    fontSize: theme.avatarRadius * 0.6,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )
            : null,
      ),
    );
  }

  Widget _buildAuthorName() {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 2),
      child: Text(
        message.authorDisplayName,
        style: isMyMessage
            ? theme.myBubbleAuthorStyle
            : theme.otherBubbleAuthorStyle,
      ),
    );
  }

  Widget _buildBubble() {
    final bubbleColor = isMyMessage 
        ? theme.myBubbleColor 
        : theme.otherBubbleColor;
    final textStyle = isMyMessage 
        ? theme.myBubbleTextStyle 
        : theme.otherBubbleTextStyle;
    final padding = isMyMessage 
        ? theme.myBubblePadding 
        : theme.otherBubblePadding;
    final borderRadius = isMyMessage 
        ? theme.myBubbleBorderRadius 
        : theme.otherBubbleBorderRadius;

    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: bubbleColor,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(borderRadius),
          topRight: Radius.circular(borderRadius),
          bottomLeft: Radius.circular(
            isMyMessage ? borderRadius : 4,
          ),
          bottomRight: Radius.circular(
            isMyMessage ? 4 : borderRadius,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (message.replyToSnapshot != null) _buildReplyPreview(),
          Text(
            message.text,
            style: textStyle,
          ),
        ],
      ),
    );
  }

  Widget _buildReplyPreview() {
    final snapshot = message.replyToSnapshot!;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: theme.replyPadding,
      decoration: BoxDecoration(
        color: theme.replyIndicatorColor,
        borderRadius: BorderRadius.circular(theme.replyBorderRadius),
        border: Border(
          left: BorderSide(
            color: theme.replyIndicatorColor,
            width: 3,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            snapshot.authorDisplayName,
            style: theme.replyAuthorStyle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            snapshot.textPreview,
            style: theme.replyTextStyle,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
