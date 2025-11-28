# cdx_chat

[![pub package](https://img.shields.io/pub/v/cdx_chat.svg)](https://pub.dev/packages/cdx_chat)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Flutter](https://img.shields.io/badge/Flutter-%3E%3D1.17.0-blue.svg)](https://flutter.dev)

A comprehensive Flutter package for managing chat with support for messages, replies, user blocking, and real-time updates. Built with a clean, extensible architecture that follows Flutter best practices and requires zero external dependencies (except `provider` and `intl`).

## Features

- 💬 **Real-time Chat**: Stream-based message updates with automatic synchronization
- 💭 **Reply System**: Full support for replying to messages with preview
- 🚫 **User Blocking**: Block/unblock users functionality
- 📖 **Read Status**: Track unread message counts
- 🎨 **Highly Customizable**: Optional theme, text styles, and app actions customization
- 🌍 **Internationalization**: Support for multiple languages (English, Italian) with extensible localization
- 📦 **Clean Architecture**: Service-based architecture with dependency injection support
- 🧪 **Well Tested**: Comprehensive unit tests included
- 🔄 **Auto-scroll**: Smart scrolling to latest messages
- 🗑️ **Message Deletion**: Soft delete support for messages

## Installation

Add `cdx_chat` to your `pubspec.yaml`:

```yaml
dependencies:
  cdx_chat: ^0.0.1
  provider: ^6.1.5+1
  flutter_localizations:
    sdk: flutter
  intl: ^0.20.2
```

Then run:

```bash
flutter pub get
```

## Quick Start

### 1. Setup Localization

Add the localization delegates to your `MaterialApp`:

```dart
import 'package:cdx_chat/cdx_chat.dart';

MaterialApp(
  localizationsDelegates: [
    ...CdxChatLocalizations.localizationsDelegates,
    // Add your other delegates here
  ],
  supportedLocales: CdxChatLocalizations.supportedLocales,
  // ... rest of your app
)
```

### 2. Implement ChatService

Implement the `ChatService` interface to connect with your backend:

```dart
class MyChatService implements ChatService {
  @override
  Stream<List<ChatMessage>> watchMessages({
    required String chatId,
    int limit = 50,
    String? startAfterMessageId,
  }) async* {
    // Stream messages from your backend
    // Example with Firestore:
    yield* firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('createdAt')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ChatMessage.fromFirestore(doc))
            .toList());
  }
  
  @override
  Future<ChatMessage> sendMessage({
    required String chatId,
    required String authorId,
    required String text,
    String? replyToMessageId,
  }) async {
    // Send message to your API
    final response = await http.post('/api/chats/$chatId/messages', body: {
      'authorId': authorId,
      'text': text,
      'replyToMessageId': replyToMessageId,
    });
    return ChatMessage.fromJson(response.body);
  }
  
  @override
  Future<bool> deleteMessage({
    required String chatId,
    required String messageId,
  }) async {
    await http.delete('/api/chats/$chatId/messages/$messageId');
    return true;
  }
  
  @override
  Future<void> markAsRead({
    required String chatId,
    required String userId,
    required String lastReadMessageId,
    required DateTime lastReadAt,
  }) async {
    await http.post('/api/chats/$chatId/mark-read', body: {
      'userId': userId,
      'lastReadMessageId': lastReadMessageId,
      'lastReadAt': lastReadAt.toIso8601String(),
    });
  }
  
  @override
  Stream<int> watchUnreadCount({
    required String chatId,
    required String userId,
  }) async* {
    // Stream unread count from your backend
    yield* firestore
        .collection('chats')
        .doc(chatId)
        .collection('members')
        .doc(userId)
        .snapshots()
        .map((doc) => doc.data()?['unreadCount'] ?? 0);
  }
  
  @override
  Future<bool> blockUser({
    required String chatId,
    required String userId,
    required String blockedUserId,
  }) async {
    await http.post('/api/chats/$chatId/block', body: {
      'userId': userId,
      'blockedUserId': blockedUserId,
    });
    return true;
  }
  
  @override
  Future<bool> unblockUser({
    required String chatId,
    required String userId,
    required String blockedUserId,
  }) async {
    await http.delete('/api/chats/$chatId/block/$blockedUserId');
    return true;
  }
  
  @override
  Stream<Set<String>> watchBlockedUsers({
    required String chatId,
    required String userId,
  }) async* {
    // Stream blocked users from your backend
    yield* firestore
        .collection('chats')
        .doc(chatId)
        .collection('members')
        .doc(userId)
        .snapshots()
        .map((doc) => Set<String>.from(doc.data()?['blockedUsers'] ?? []));
  }
}
```

### 3. Setup and Use

```dart
import 'package:cdx_chat/cdx_chat.dart';
import 'package:flutter/material.dart';

class ChatPage extends StatelessWidget {
  final String chatId;
  final String currentUserId;
  
  const ChatPage({
    super.key,
    required this.chatId,
    required this.currentUserId,
  });
  
  @override
  Widget build(BuildContext context) {
    // Get services from DI container or create them
    final service = MyChatService();
    final config = const ChatConfig(
      maxMessageLength: 1000,
      maxLines: 20,
    );
    
    return Scaffold(
      appBar: AppBar(title: const Text('Chat')),
      body: ChatView(
        service: service,
        chatId: chatId,
        currentUserId: currentUserId,
        config: config,
      ),
    );
  }
}
```

**Alternative using Dependency Injection** (recommended for larger apps):

```dart
// Using a DI container (e.g., get_it, riverpod, etc.)
class ChatPage extends StatelessWidget {
  final String chatId;
  final String currentUserId;
  
  const ChatPage({
    super.key,
    required this.chatId,
    required this.currentUserId,
  });
  
  @override
  Widget build(BuildContext context) {
    // Get services from DI container
    final service = GetIt.instance<ChatService>();
    final config = GetIt.instance<ChatConfig>();
    
    return Scaffold(
      appBar: AppBar(title: const Text('Chat')),
      body: ChatView(
        service: service,
        chatId: chatId,
        currentUserId: currentUserId,
        config: config,
      ),
    );
  }
}
```

## Customization

### Theme Customization

Customize colors and styling through the `ChatTheme` interface:

```dart
class MyCustomTheme implements ChatTheme {
  @override
  Color get primary => Colors.blue;
  
  @override
  Color get mainText => Colors.white;
  
  @override
  Color get mainBackground => Colors.black;
  
  // ... implement all required properties
}

// Use it in ChatView
ChatView(
  // ... other parameters
  theme: MyCustomTheme(),
)
```

If not provided, the package uses `DefaultChatTheme` which automatically extracts colors from `Theme.of(context)`.

### App Actions Customization

Customize snackbars and dialogs:

```dart
class MyCustomAppActions implements ChatAppActions {
  @override
  void showErrorSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        action: SnackBarAction(
          label: 'OK',
          onPressed: () {},
        ),
      ),
    );
  }
  
  @override
  void showInfoSnackbar(BuildContext context, String message) {
    // Your custom implementation
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
    // Your custom dialog implementation
  }
  
  @override
  Widget? buildMessageAvatar(BuildContext context, ChatMessage message) {
    // Return custom avatar widget or null for default
    return null;
  }
  
  @override
  Widget? buildUserAvatar(BuildContext context, UserInfo user) {
    // Return custom avatar widget or null for default
    return null;
  }
}

// Use it in ChatView
ChatView(
  // ... other parameters
  appActions: MyCustomAppActions(),
)
```

### Text Style Customization

Customize text styles:

```dart
class MyCustomTextStyle implements ChatTextStyle {
  final BuildContext context;
  
  const MyCustomTextStyle(this.context);
  
  @override
  TextStyle bold18({Color? color, TextAlign? align}) {
    return TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.bold,
      color: color ?? Theme.of(context).colorScheme.onSurface,
      fontFamily: 'CustomFont',
    );
  }
  
  // Implement other methods: normal14, normal15, normal12
}

// Use it in ChatView
ChatView(
  // ... other parameters
  textStyle: MyCustomTextStyle(context),
)
```

### Custom Message Builder

Customize how messages are displayed:

```dart
ChatView(
  // ... other parameters
  messageBuilder: (context, message) {
    return MyCustomMessageWidget(message: message);
  },
)
```

## Architecture

The package follows clean architecture principles:

- **Models**: Immutable data classes (`ChatMessage`, `ChatReplySnapshot`, `UserInfo`, `ChatConfig`, `ChatTheme`, etc.)
- **Services**: Abstract interfaces (`ChatService`) for dependency inversion
- **Controllers**: Business logic layer (`ChatController`)
- **Providers**: State management (`ChatProvider`) using Provider pattern
- **Widgets**: Reusable UI components (`ChatView`, `MessageBubble`)

## API Reference

### Core Models

#### `ChatMessage`
Represents a chat message with all its properties:
- `id`: Unique identifier
- `chatId`: ID of the chat
- `authorId`: Author user ID
- `authorDisplayName`: Author display name
- `authorAvatarUrl`: Optional avatar URL
- `text`: Message text
- `createdAt`: Creation date
- `updatedAt`: Optional update date
- `isSystem`: Whether it's a system message
- `isDeleted`: Whether the message is deleted
- `replyToMessageId`: ID of the message being replied to
- `replyToSnapshot`: Snapshot of the replied message

#### `UserInfo`
Current user information:
- `uuid`: User unique identifier
- `name`: User display name
- `initials`: Generated initials from name

#### `ChatConfig`
Configuration for the chat module:
- `maxMessageLength`: Maximum characters allowed in a message
- `maxLines`: Maximum lines allowed in a message

### Services

#### `ChatService`
Abstract interface for chat operations. You must implement:
- `watchMessages()`: Stream messages for a chat
- `sendMessage()`: Send a new message
- `deleteMessage()`: Delete a message
- `markAsRead()`: Mark messages as read
- `watchUnreadCount()`: Stream unread message count
- `blockUser()`: Block a user
- `unblockUser()`: Unblock a user
- `watchBlockedUsers()`: Stream blocked users

### Widgets

#### `ChatView`
Main chat UI widget. Parameters:
- `service`: Chat service implementation
- `chatId`: ID of the chat
- `currentUserId`: ID of the current user
- `config`: Chat configuration
- `theme`: Optional custom theme
- `textStyle`: Optional custom text styles
- `appActions`: Optional custom app actions
- `messageBuilder`: Optional custom message builder
- `replyPreviewBuilder`: Optional custom reply preview builder
- `enableReply`: Whether reply functionality is enabled
- `listenUnreadCount`: Whether to listen to unread count

#### `MessageBubble`
Individual message widget. Displays message content, actions, and replies.

## Adding Custom Translations

To add support for additional languages:

1. Create a new ARB file in `lib/l10n/` (e.g., `app_fr.arb`)
2. Copy the structure from `app_en.arb`
3. Translate all the strings
4. Regenerate localizations: `flutter gen-l10n`

The delegate is extensible and can be combined with other localization delegates in your app.

## Requirements

- Flutter >= 1.17.0
- Dart >= 3.10.1
- `provider` package (^6.1.5+1)
- `intl` package (^0.19.0)

## Example

See the [example](example) directory for a complete working example.

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Links

- [GitHub Repository](https://github.com/FabrizioBilleciUNICT/cdx_chat)
- [Pub.dev Package](https://pub.dev/packages/cdx_chat)
- [Issue Tracker](https://github.com/FabrizioBilleciUNICT/cdx_chat/issues)
