import 'package:flutter/material.dart';

/// Theme configuration for the chat package.
///
/// This interface allows customization of colors and styling used throughout
/// the chat widgets. If not provided, the package will use default values
/// based on the current [Theme] from the [BuildContext].
abstract class ChatTheme {
  /// Primary color used for avatars and accent elements.
  Color get primary;

  /// Main text color (typically used for backgrounds in dark mode).
  Color get mainText;

  /// Main background color (typically used for text in dark mode).
  Color get mainBackground;

  /// Error color for delete actions and error messages.
  Color get error;

  /// Minor text color for secondary text.
  Color get minorText;

  /// Border radius for card elements.
  BorderRadius get cardRadius;

  /// Background color for the chat view.
  Color get backgroundColor;

  /// Background color for the input field.
  Color get inputBackgroundColor;

  /// Text color for the input field.
  Color get inputTextColor;

  /// Border color for the input field.
  Color get inputBorderColor;

  /// Color for my message bubbles.
  Color get myBubbleColor;

  /// Text style for my message bubbles.
  TextStyle get myBubbleTextStyle;

  /// Author name style for my messages.
  TextStyle get myBubbleAuthorStyle;

  /// Border radius for my message bubbles.
  double get myBubbleBorderRadius;

  /// Padding for my message bubbles.
  EdgeInsets get myBubblePadding;

  /// Color for other users' message bubbles.
  Color get otherBubbleColor;

  /// Text style for other users' message bubbles.
  TextStyle get otherBubbleTextStyle;

  /// Author name style for other users' messages.
  TextStyle get otherBubbleAuthorStyle;

  /// Border radius for other users' message bubbles.
  double get otherBubbleBorderRadius;

  /// Padding for other users' message bubbles.
  EdgeInsets get otherBubblePadding;

  /// Color for system message bubbles.
  Color get systemBubbleColor;

  /// Text style for system message bubbles.
  TextStyle get systemBubbleTextStyle;

  /// Border radius for system message bubbles.
  double get systemBubbleBorderRadius;

  /// Padding for system message bubbles.
  EdgeInsets get systemBubblePadding;

  /// Color for deleted message bubbles.
  Color get deletedBubbleColor;

  /// Text style for deleted message bubbles.
  TextStyle get deletedBubbleTextStyle;

  /// Border radius for deleted message bubbles.
  double get deletedBubbleBorderRadius;

  /// Avatar radius.
  double get avatarRadius;

  /// Background color for avatars.
  Color get avatarBackgroundColor;

  /// Color for reply indicator.
  Color get replyIndicatorColor;

  /// Text style for reply author name.
  TextStyle get replyAuthorStyle;

  /// Text style for reply preview text.
  TextStyle get replyTextStyle;

  /// Padding for reply indicator.
  EdgeInsets get replyPadding;

  /// Border radius for reply indicator.
  double get replyBorderRadius;

  /// Spacing between messages.
  double get messageSpacing;

  /// Padding for the message list.
  EdgeInsets get listPadding;

  /// Padding for the input field.
  EdgeInsets get inputPadding;

  /// Border radius for the input field.
  double get inputBorderRadius;

  /// Maximum height for the input field.
  double get inputMaxHeight;
}

/// Default implementation of [ChatTheme] that uses [Theme.of].
///
/// This implementation extracts colors from the current Flutter theme,
/// making it compatible with any Material Design theme.
class DefaultChatTheme implements ChatTheme {
  final BuildContext context;

  const DefaultChatTheme(this.context);

  @override
  Color get primary => Theme.of(context).colorScheme.primary;

  @override
  Color get mainText => Theme.of(context).colorScheme.surface;

  @override
  Color get mainBackground => Theme.of(context).colorScheme.onSurface;

  @override
  Color get error => Theme.of(context).colorScheme.error;

  @override
  Color get minorText => Theme.of(context).colorScheme.onSurface.withOpacity(0.6);

  @override
  BorderRadius get cardRadius => const BorderRadius.vertical(
    top: Radius.circular(16),
  );

  @override
  Color get backgroundColor => Theme.of(context).scaffoldBackgroundColor;

  @override
  Color get inputBackgroundColor {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor = Theme.of(context).colorScheme.surface;
    return isDark ? surfaceColor.withOpacity(0.7) : surfaceColor;
  }

  @override
  Color get inputTextColor => Theme.of(context).colorScheme.onSurface;

  @override
  Color get inputBorderColor => Theme.of(context).dividerColor;

  @override
  Color get myBubbleColor => Theme.of(context).colorScheme.primary;

  @override
  TextStyle get myBubbleTextStyle => Theme.of(context).textTheme.bodyMedium!.copyWith(
    color: Theme.of(context).colorScheme.onPrimary,
  );

  @override
  TextStyle get myBubbleAuthorStyle => Theme.of(context).textTheme.labelSmall!.copyWith(
    color: Theme.of(context).colorScheme.onPrimary.withOpacity(0.8),
    fontWeight: FontWeight.bold,
  );

  @override
  double get myBubbleBorderRadius => 16;

  @override
  EdgeInsets get myBubblePadding => const EdgeInsets.symmetric(horizontal: 12, vertical: 8);

  @override
  Color get otherBubbleColor {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor = Theme.of(context).colorScheme.surface;
    return isDark ? surfaceColor.withOpacity(0.8) : surfaceColor;
  }

  @override
  TextStyle get otherBubbleTextStyle => Theme.of(context).textTheme.bodyMedium!.copyWith(
    color: Theme.of(context).colorScheme.onSurface,
  );

  @override
  TextStyle get otherBubbleAuthorStyle => Theme.of(context).textTheme.labelSmall!.copyWith(
    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
    fontWeight: FontWeight.bold,
  );

  @override
  double get otherBubbleBorderRadius => 16;

  @override
  EdgeInsets get otherBubblePadding => const EdgeInsets.symmetric(horizontal: 12, vertical: 8);

  @override
  Color get systemBubbleColor => Theme.of(context).colorScheme.secondary.withOpacity(0.2);

  @override
  TextStyle get systemBubbleTextStyle => Theme.of(context).textTheme.bodySmall!.copyWith(
    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
    fontStyle: FontStyle.italic,
  );

  @override
  double get systemBubbleBorderRadius => 12;

  @override
  EdgeInsets get systemBubblePadding => const EdgeInsets.symmetric(horizontal: 12, vertical: 6);

  @override
  Color get deletedBubbleColor {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor = Theme.of(context).colorScheme.surface;
    return isDark ? surfaceColor.withOpacity(0.3) : surfaceColor.withOpacity(0.5);
  }

  @override
  TextStyle get deletedBubbleTextStyle => Theme.of(context).textTheme.bodySmall!.copyWith(
    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
    fontStyle: FontStyle.italic,
  );

  @override
  double get deletedBubbleBorderRadius => 16;

  @override
  double get avatarRadius => 20;

  @override
  Color get avatarBackgroundColor => Theme.of(context).colorScheme.primary.withOpacity(0.2);

  @override
  Color get replyIndicatorColor => Theme.of(context).colorScheme.primary.withOpacity(0.2);

  @override
  TextStyle get replyAuthorStyle => Theme.of(context).textTheme.labelSmall!.copyWith(
    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
    fontWeight: FontWeight.bold,
  );

  @override
  TextStyle get replyTextStyle => Theme.of(context).textTheme.bodySmall!.copyWith(
    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
  );

  @override
  EdgeInsets get replyPadding => const EdgeInsets.all(8);

  @override
  double get replyBorderRadius => 8;

  @override
  double get messageSpacing => 8;

  @override
  EdgeInsets get listPadding => const EdgeInsets.symmetric(horizontal: 16, vertical: 8);

  @override
  EdgeInsets get inputPadding => const EdgeInsets.symmetric(horizontal: 16, vertical: 12);

  @override
  double get inputBorderRadius => 24;

  @override
  double get inputMaxHeight => 120;
}

