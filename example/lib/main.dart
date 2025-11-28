import 'package:cdx_chat/cdx_chat.dart';
import 'package:flutter/material.dart';
import 'services/example_chat_service.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CDX Chat Example',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      localizationsDelegates: [
        ...CdxChatLocalizations.localizationsDelegates,
      ],
      supportedLocales: CdxChatLocalizations.supportedLocales,
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Service implementation (in-memory for this example)
  final ExampleChatService _service = ExampleChatService();
  
  late final ChatConfig _config;
  late final UserInfo _user;

  @override
  void initState() {
    super.initState();
    
    // Configuration for chat module
    // In a real app, this would come from your app's configuration
    _config = const ChatConfig(
      maxMessageLength: 1000,
      maxLines: 20,
    );
    
    // Current user information
    // In a real app, this would come from your authentication system
    _user = const UserInfo(
      uuid: 'user-1',
      name: 'John Doe',
    );
  }

  @override
  void dispose() {
    _service.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('CDX Chat Example'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Welcome to CDX Chat Example',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            const Text(
              'Tap the button below to open the chat',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 40),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ChatPage(
                      service: _service,
                      chatId: 'chat-1',
                      currentUserId: _user.uuid,
                      config: _config,
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.chat),
              label: const Text('Open Chat'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ChatPage extends StatelessWidget {
  final ChatService service;
  final String chatId;
  final String currentUserId;
  final ChatConfig config;

  const ChatPage({
    super.key,
    required this.service,
    required this.chatId,
    required this.currentUserId,
    required this.config,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat'),
      ),
      body: ChatView(
        service: service,
        chatId: chatId,
        currentUserId: currentUserId,
        config: config,
      ),
    );
  }
}

