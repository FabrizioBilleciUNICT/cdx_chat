import 'package:cdx_chat/cdx_chat.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ChatMessage', () {
    test('should create a message with all required fields', () {
      final message = ChatMessage(
        id: '1',
        chatId: 'chat-1',
        authorId: 'user-1',
        authorDisplayName: 'John Doe',
        text: 'Test message',
        createdAt: DateTime(2024, 1, 1),
      );

      expect(message.id, '1');
      expect(message.chatId, 'chat-1');
      expect(message.authorId, 'user-1');
      expect(message.authorDisplayName, 'John Doe');
      expect(message.text, 'Test message');
      expect(message.isSystem, false);
      expect(message.isDeleted, false);
      expect(message.replyToMessageId, isNull);
      expect(message.replyToSnapshot, isNull);
    });

    test('should identify reply messages correctly', () {
      final replySnapshot = ChatReplySnapshot(
        messageId: 'msg-1',
        authorId: 'user-2',
        authorDisplayName: 'Jane Smith',
        textPreview: 'Original message',
        createdAt: DateTime(2024, 1, 1),
      );

      final message = ChatMessage(
        id: '2',
        chatId: 'chat-1',
        authorId: 'user-1',
        authorDisplayName: 'John Doe',
        text: 'Reply message',
        createdAt: DateTime(2024, 1, 2),
        replyToMessageId: 'msg-1',
        replyToSnapshot: replySnapshot,
      );

      expect(message.isReply, true);
      expect(message.replyToMessageId, 'msg-1');
      expect(message.replyToSnapshot, isNotNull);
    });

    test('should create copy with modified fields', () {
      final original = ChatMessage(
        id: '1',
        chatId: 'chat-1',
        authorId: 'user-1',
        authorDisplayName: 'John Doe',
        text: 'Original',
        createdAt: DateTime(2024, 1, 1),
      );

      final modified = original.copyWith(
        text: 'Modified',
        isDeleted: true,
      );

      expect(modified.id, original.id);
      expect(modified.text, 'Modified');
      expect(modified.isDeleted, true);
      expect(modified.chatId, original.chatId);
    });

    test('should handle system messages', () {
      final systemMessage = ChatMessage(
        id: '1',
        chatId: 'chat-1',
        authorId: 'system',
        authorDisplayName: 'System',
        text: 'System message',
        createdAt: DateTime(2024, 1, 1),
        isSystem: true,
      );

      expect(systemMessage.isSystem, true);
    });

    test('should handle deleted messages', () {
      final deletedMessage = ChatMessage(
        id: '1',
        chatId: 'chat-1',
        authorId: 'user-1',
        authorDisplayName: 'John Doe',
        text: 'Deleted',
        createdAt: DateTime(2024, 1, 1),
        isDeleted: true,
      );

      expect(deletedMessage.isDeleted, true);
    });
  });

  group('ChatReplySnapshot', () {
    test('should create a reply snapshot with all fields', () {
      final snapshot = ChatReplySnapshot(
        messageId: 'msg-1',
        authorId: 'user-1',
        authorDisplayName: 'John Doe',
        textPreview: 'Preview text',
        createdAt: DateTime(2024, 1, 1),
      );

      expect(snapshot.messageId, 'msg-1');
      expect(snapshot.authorId, 'user-1');
      expect(snapshot.authorDisplayName, 'John Doe');
      expect(snapshot.textPreview, 'Preview text');
      expect(snapshot.authorAvatarUrl, isNull);
    });

    test('should create copy with modified fields', () {
      final original = ChatReplySnapshot(
        messageId: 'msg-1',
        authorId: 'user-1',
        authorDisplayName: 'John Doe',
        textPreview: 'Original',
        createdAt: DateTime(2024, 1, 1),
      );

      final modified = original.copyWith(
        textPreview: 'Modified',
      );

      expect(modified.messageId, original.messageId);
      expect(modified.textPreview, 'Modified');
    });
  });
}

