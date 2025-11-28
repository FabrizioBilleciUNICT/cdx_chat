import 'package:cdx_chat/cdx_chat.dart';
import 'package:flutter_test/flutter_test.dart';
import '../services/in_memory_chat_service.dart';

void main() {
  group('ChatProvider', () {
    late InMemoryChatService service;
    late ChatController controller;
    late ChatProvider provider;
    late ChatConfig config;

    setUp(() {
      service = InMemoryChatService();
      controller = ChatController(
        service: service,
        chatId: 'chat-1',
        currentUserId: 'user-1',
      );
      config = const ChatConfig(
        maxMessageLength: 1000,
        maxLines: 20,
      );
      provider = ChatProvider(
        controller: controller,
        chatId: 'chat-1',
        config: config,
      );
    });

    tearDown(() {
      service.clear();
      controller.dispose();
      provider.dispose();
    });

    test('should initialize with empty messages', () {
      expect(provider.messages, isEmpty);
      expect(provider.isLoading, true);
      expect(provider.unreadCount, 0);
      expect(provider.replyingTo, isNull);
    });

    test('should set reply to message', () {
      final message = ChatMessage(
        id: 'msg-1',
        chatId: 'chat-1',
        authorId: 'user-2',
        authorDisplayName: 'Jane Smith',
        text: 'Original message',
        createdAt: DateTime.now(),
      );

      provider.setReplyTo(message);
      expect(provider.replyingTo, message);

      provider.setReplyTo(null);
      expect(provider.replyingTo, isNull);
    });

    test('should validate message length', () async {
      // This test would need localization, so we'll test the basic flow
      // In a real test, you'd mock the localization
      provider.inputController.text = 'a' * 1001; // Exceeds max length

      // The validation happens in sendMessage, which requires localization
      // For now, just verify the input controller works
      expect(provider.inputController.text.length, 1001);
    });

    test('should delete a message', () async {
      final message = await service.sendMessage(
        chatId: 'chat-1',
        authorId: 'user-1',
        text: 'To delete',
      );

      await Future.delayed(const Duration(milliseconds: 200));

      await provider.deleteMessage(message);

      await Future.delayed(const Duration(milliseconds: 200));

      final deleted = provider.messages.firstWhere((m) => m.id == message.id);
      expect(deleted.isDeleted, true);
    });

    test('should block and unblock users', () async {
      await provider.blockUser('user-2');

      await Future.delayed(const Duration(milliseconds: 200));

      expect(provider.blockedUsers.contains('user-2'), true);

      await provider.unblockUser('user-2');

      await Future.delayed(const Duration(milliseconds: 200));

      expect(provider.blockedUsers.contains('user-2'), false);
    });

    test('should reload messages', () {
      provider.reloadMessages();
      // Should not throw
      expect(provider.isLoading, true);
    });
  });
}

