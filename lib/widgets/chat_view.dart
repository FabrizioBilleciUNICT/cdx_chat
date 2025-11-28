import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../services/chat_service.dart';
import '../models/chat_message.dart';
import '../models/chat_theme.dart';
import '../models/chat_config.dart';
import '../models/chat_app_actions.dart' show ChatAppActions, DefaultChatAppActions;
import '../models/chat_text_style.dart';
import '../controller.dart';
import '../provider.dart';
import '../l10n/app_localizations.dart';
import 'message_bubble.dart';

/// Complete and configurable widget for chat.
///
/// Features:
/// - Smart scrolling
/// - Multiline input area
/// - Reply bar
/// - Pagination
/// - Customizable builders
/// - Error and loading handling
///
/// Example:
/// ```dart
/// ChatView(
///   service: chatService,
///   chatId: 'chat-123',
///   currentUserId: 'user-456',
///   config: chatConfig,
/// )
/// ```
class ChatView extends StatefulWidget {
  /// The chat service implementation.
  final ChatService service;
  
  /// ID of the chat.
  final String chatId;
  
  /// ID of the current user.
  final String currentUserId;
  
  /// Configuration for the chat module.
  final ChatConfig config;
  
  /// Optional custom theme.
  final ChatTheme? theme;
  
  /// Optional custom text style.
  final ChatTextStyle? textStyle;
  
  /// Optional custom app actions.
  final ChatAppActions? appActions;
  
  /// Custom message builder.
  final Widget Function(BuildContext, ChatMessage)? messageBuilder;
  
  /// Custom reply preview builder.
  final Widget Function(BuildContext, ChatMessage)? replyPreviewBuilder;
  
  /// Whether reply functionality is enabled.
  final bool enableReply;
  
  /// Whether to listen to unread count.
  final bool listenUnreadCount;
  
  /// Custom input decoration.
  final InputDecoration? inputDecoration;
  
  /// Custom send icon.
  final Widget? sendIcon;
  
  /// Callback when a message is sent.
  final VoidCallback? onMessageSent;
  
  /// Callback when an error occurs.
  final VoidCallback? onError;

  /// Custom loading indicator builder.
  /// If not provided, uses default CircularProgressIndicator.
  final Widget Function(BuildContext)? loadingBuilder;

  /// Creates a new [ChatView].
  const ChatView({
    super.key,
    required this.service,
    required this.chatId,
    required this.currentUserId,
    required this.config,
    this.theme,
    this.textStyle,
    this.appActions,
    this.messageBuilder,
    this.replyPreviewBuilder,
    this.enableReply = true,
    this.listenUnreadCount = true,
    this.inputDecoration,
    this.sendIcon,
    this.onMessageSent,
    this.onError,
    this.loadingBuilder,
  });

  @override
  State<ChatView> createState() => _ChatViewState();
}

class _ChatViewState extends State<ChatView> {
  late final ChatController _controller;
  late final ChatProvider _provider;
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();
  
  bool _isNearBottom = true;
  bool _isInitialLoad = true;

  @override
  void initState() {
    super.initState();
    _controller = ChatController(
      service: widget.service,
      chatId: widget.chatId,
      currentUserId: widget.currentUserId,
    );
    
    _provider = ChatProvider(
      controller: _controller,
      chatId: widget.chatId,
      config: widget.config,
    );
    
    _scrollController.addListener(_onScroll);
    _focusNode.addListener(_onFocusChange);
    
    // Scroll to bottom after first load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom(animated: false);
      _isInitialLoad = false;
    });
  }

  void _onScroll() {
    if (_scrollController.hasClients) {
      final maxScroll = _scrollController.position.maxScrollExtent;
      final currentScroll = _scrollController.position.pixels;
      final threshold = 100.0;
      
      _isNearBottom = (maxScroll - currentScroll) < threshold;
      
      // Mark as read when near bottom
      if (_isNearBottom && _controller.messages.isNotEmpty) {
        _controller.markAsRead();
      }
    }
  }

  void _onFocusChange() {
    if (_focusNode.hasFocus) {
      // Scroll to bottom when keyboard opens
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted) {
          _scrollToBottom();
        }
      });
    }
  }

  void _scrollToBottom({bool animated = true}) {
    if (_scrollController.hasClients) {
      if (animated) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      } else {
        _scrollController.jumpTo(
          _scrollController.position.maxScrollExtent,
        );
      }
    }
  }

  Future<void> _sendMessage() async {
    final loc = CdxChatLocalizations.of(context);
    if (loc == null) return;
    
    final appActions = widget.appActions ?? const DefaultChatAppActions();
    
    await _provider.sendMessage(
      loc,
      onInputError: (error) {
        appActions.showErrorSnackbar(context, error);
      },
    );
    
    // Scroll to bottom after sending
    _scrollToBottom();
    
    widget.onMessageSent?.call();
  }

  void _handleReply(ChatMessage message) {
    if (widget.enableReply) {
      _provider.setReplyTo(message);
      _focusNode.requestFocus();
    }
  }

  void _cancelReply() {
    _provider.setReplyTo(null);
  }

  ChatTheme get _theme {
    return widget.theme ?? DefaultChatTheme(context);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _focusNode.dispose();
    _controller.dispose();
    _provider.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _provider,
      child: Consumer<ChatProvider>(
        builder: (context, provider, child) {
          // Auto scroll when new messages arrive (if near bottom)
          if (!_isInitialLoad && _isNearBottom && provider.messages.isNotEmpty) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _scrollToBottom();
            });
          }

          return GestureDetector(
            onTap: () {
              // Unfocus when tapping outside the input field
              _focusNode.unfocus();
            },
            behavior: HitTestBehavior.translucent,
            child: Column(
              children: [
                // Message list
                Expanded(
                  child: _buildMessagesList(provider),
                ),
                
                // Reply preview bar
                if (provider.replyingTo != null)
                  _buildReplyBar(provider.replyingTo!),
                
                // Input area
                _buildInputArea(provider),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildMessagesList(ChatProvider provider) {
    final loc = CdxChatLocalizations.of(context);
    
    if (provider.isLoading && provider.messages.isEmpty) {
      if (widget.loadingBuilder != null) {
        return Center(
          child: widget.loadingBuilder!(context),
        );
      }
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (provider.error != null && provider.messages.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              loc?.error_loading_messages ?? 'Error loading messages',
              style: TextStyle(color: _theme.otherBubbleTextStyle.color),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () {
                provider.reloadMessages();
              },
              child: Text(loc?.retry ?? 'Retry'),
            ),
          ],
        ),
      );
    }

    if (provider.messages.isEmpty) {
      return Center(
        child: Text(
          loc?.no_messages ?? 'No messages',
          style: TextStyle(color: _theme.otherBubbleTextStyle.color),
        ),
      );
    }

    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        // Load more messages when scrolling up
        if (notification is ScrollUpdateNotification) {
          if (_scrollController.hasClients) {
            final position = _scrollController.position;
            // pixels == 0 means we're at the top (older messages)
            if (position.pixels < 200 && 
                provider.hasMore && 
                !provider.isLoading) {
              _controller.loadMore();
            }
          }
        }
        return false;
      },
      child: ListView.builder(
        controller: _scrollController,
        reverse: false, // Older messages at top, newer at bottom
        padding: _theme.listPadding,
        itemCount: provider.messages.length + (provider.isLoading ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == provider.messages.length) {
            if (widget.loadingBuilder != null) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: widget.loadingBuilder!(context),
                ),
              );
            }
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: CircularProgressIndicator(),
              ),
            );
          }

          final message = provider.messages[index];
          final isLast = index == provider.messages.length - 1;
          final showDateSeparator = index == 0 || 
              !_isSameDay(provider.messages[index - 1].createdAt, message.createdAt);

          return Column(
            children: [
              if (showDateSeparator) _buildDateSeparator(message),
              Padding(
                padding: EdgeInsets.only(
                  bottom: isLast ? 0 : _theme.messageSpacing,
                ),
                child: widget.messageBuilder != null
                    ? widget.messageBuilder!(context, message)
                    : MessageBubble(
                        message: message,
                        currentUserId: widget.currentUserId,
                        theme: _theme,
                        onLongPress: widget.enableReply
                            ? () => _handleReply(message)
                            : null,
                        showAvatar: true,
                        showAuthorName: true,
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildReplyBar(ChatMessage message) {
    final loc = CdxChatLocalizations.of(context);
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: _theme.replyIndicatorColor,
        border: Border(
          top: BorderSide(color: _theme.inputBorderColor),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: widget.replyPreviewBuilder != null
                ? widget.replyPreviewBuilder!(context, message)
                : Container(
                    padding: _theme.replyPadding,
                    decoration: BoxDecoration(
                      color: _theme.replyIndicatorColor,
                      borderRadius: BorderRadius.circular(_theme.replyBorderRadius),
                      border: Border(
                        left: BorderSide(
                          color: _theme.replyIndicatorColor,
                          width: 3,
                        ),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${loc?.replying_to ?? 'Replying to'} ${message.authorDisplayName}',
                          style: _theme.replyAuthorStyle,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          message.text,
                          style: _theme.replyTextStyle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
          ),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: _cancelReply,
            iconSize: 20,
          ),
        ],
      ),
    );
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  String _formatDateHeader(DateTime date) {
    final loc = CdxChatLocalizations.of(context);
    if (loc == null) {
      // Fallback if localizations are not available
      final locale = Localizations.localeOf(context);
      return DateFormat('EEEE d MMMM yyyy', locale.toString()).format(date);
    }

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final messageDate = DateTime(date.year, date.month, date.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final locale = Localizations.localeOf(context);

    if (messageDate == today) {
      return loc.today;
    } else if (messageDate == yesterday) {
      return loc.yesterday;
    } else {
      // Format: "Monday, 15 January 2024" or similar based on locale
      return DateFormat('EEEE d MMMM yyyy', locale.toString()).format(date);
    }
  }

  Widget _buildDateSeparator(ChatMessage message) {
    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 12),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: _theme.minorText.withOpacity(0.2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          _formatDateHeader(message.createdAt),
          style: TextStyle(
            color: _theme.minorText,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildInputArea(ChatProvider provider) {
    final loc = CdxChatLocalizations.of(context);
    
    return Container(
      padding: _theme.inputPadding,
      decoration: BoxDecoration(
        color: _theme.inputBackgroundColor,
        border: Border(
          top: BorderSide(color: _theme.inputBorderColor),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: TextField(
              controller: provider.inputController,
              focusNode: _focusNode,
              maxLines: null,
              minLines: 1,
              style: TextStyle(color: _theme.inputTextColor),
              decoration: widget.inputDecoration ??
                  InputDecoration(
                    hintText: loc?.type_a_message ?? 'Type a message...',
                    hintStyle: TextStyle(
                      color: _theme.inputTextColor.withOpacity(0.5),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(_theme.inputBorderRadius),
                      borderSide: BorderSide(color: _theme.inputBorderColor),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(_theme.inputBorderRadius),
                      borderSide: BorderSide(color: _theme.inputBorderColor),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(_theme.inputBorderRadius),
                      borderSide: BorderSide(color: _theme.inputBorderColor),
                    ),
                    filled: true,
                    fillColor: _theme.inputBackgroundColor,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
              onSubmitted: (_) {
                if (provider.inputController.text.trim().isNotEmpty) {
                  _sendMessage();
                }
              },
            ),
          ),
          const SizedBox(width: 8),
          ValueListenableBuilder<TextEditingValue>(
            valueListenable: provider.inputController,
            builder: (context, value, child) {
              final hasText = value.text.trim().isNotEmpty;
              return IconButton(
                icon: widget.sendIcon ?? const Icon(Icons.send),
                onPressed: hasText ? _sendMessage : null,
                color: hasText ? _theme.myBubbleColor : _theme.inputTextColor.withOpacity(0.3),
              );
            },
          ),
        ],
      ),
    );
  }
}

