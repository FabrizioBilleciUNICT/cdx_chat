import 'package:cdx_chat/cdx_chat.dart';
import 'package:flutter_test/flutter_test.dart';
import '../services/in_memory_chat_service.dart';

void main() {
  group('ChatController', () {
    late InMemoryChatService service;
    late ChatController controller;

    setUp(() {
      service = InMemoryChatService();
      controller = ChatController(
        service: service,
        chatId: 'chat-1',
        currentUserId: 'user-1',
      );
    });

    tearDown(() {
      service.clear();
      controller.dispose();
    });

    test('should initialize with empty messages', () {
      expect(controller.messages, isEmpty);
      expect(controller.isLoading, true);
      expect(controller.unreadCount, 0);
      expect(controller.replyingTo, isNull);
    });

    test('should send a message', () async {
      await service.sendMessage(
        chatId: 'chat-1',
        authorId: 'user-1',
        text: 'Test message',
      );

      // Wait for stream to emit
      await Future.delayed(const Duration(milliseconds: 200));

      expect(controller.messages.length, 1);
      expect(controller.messages.first.text, 'Test message');
    });

    test('should set replying to message', () {
      final message = ChatMessage(
        id: 'msg-1',
        chatId: 'chat-1',
        authorId: 'user-2',
        authorDisplayName: 'Jane Smith',
        text: 'Original message',
        createdAt: DateTime.now(),
      );

      controller.setReplyingTo(message);
      expect(controller.replyingTo, message);

      controller.setReplyingTo(null);
      expect(controller.replyingTo, isNull);
    });

    test('should send message with reply', () async {
      // First send an original message
      final original = await service.sendMessage(
        chatId: 'chat-1',
        authorId: 'user-2',
        text: 'Original',
      );

      await Future.delayed(const Duration(milliseconds: 200));

      // Set as replying to
      controller.setReplyingTo(original);

      // Send reply
      await controller.sendMessage('Reply message');

      await Future.delayed(const Duration(milliseconds: 200));

      expect(controller.replyingTo, isNull); // Should be cleared after sending
    });

    test('should delete a message', () async {
      final message = await service.sendMessage(
        chatId: 'chat-1',
        authorId: 'user-1',
        text: 'To delete',
      );

      await Future.delayed(const Duration(milliseconds: 200));

      await controller.deleteMessage(message);

      await Future.delayed(const Duration(milliseconds: 200));

      final deleted = controller.messages.firstWhere((m) => m.id == message.id);
      expect(deleted.isDeleted, true);
    });

    test('should block and unblock users', () async {
      await controller.blockUser('user-2');

      await Future.delayed(const Duration(milliseconds: 200));

      expect(controller.blockedUsers.contains('user-2'), true);

      await controller.unblockUser('user-2');

      await Future.delayed(const Duration(milliseconds: 200));

      expect(controller.blockedUsers.contains('user-2'), false);
    });

    test('should filter blocked users from visible messages', () async {
      // Send messages from different users
      await service.sendMessage(
        chatId: 'chat-1',
        authorId: 'user-1',
        text: 'Message 1',
      );
      await service.sendMessage(
        chatId: 'chat-1',
        authorId: 'user-2',
        text: 'Message 2',
      );
      await service.sendMessage(
        chatId: 'chat-1',
        authorId: 'user-3',
        text: 'Message 3',
      );

      await Future.delayed(const Duration(milliseconds: 200));

      // Block user-2
      await controller.blockUser('user-2');

      await Future.delayed(const Duration(milliseconds: 200));

      // Visible messages should not include user-2's messages
      final visible = controller.visibleMessages;
      expect(visible.any((m) => m.authorId == 'user-2'), false);
      expect(visible.any((m) => m.authorId == 'user-1'), true);
      expect(visible.any((m) => m.authorId == 'user-3'), true);
    });

    test('should reload messages', () async {
      controller.reloadMessages();
      // Should not throw
      expect(controller.isLoading, true);
    });
  });
}

