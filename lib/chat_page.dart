import 'package:flutter/material.dart';
import 'package:flutter_chat_google_ai/chatImage/chat_with_image.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'widgets/chat_bubble.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});
  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final model = GenerativeModel(
      model: 'gemini-pro', apiKey: 'AIzaSyCemWq4HMckBt9903Ug6bunb2AQ7kJ0gC8');
  final messageController = TextEditingController();
  bool isLoading = false;

  List<ChatBubble> messages = [
    const ChatBubble(
      direction: Direction.left,
      message: 'Halo, saya Gemini AI. Ada yang bisa saya bantu?',
      photoUrl: 'https://i.pravatar.cc/150?img=47',
      type: BubbleType.alone,
    ),
  ];

  void sendMessage() async {
    if (messageController.text.isEmpty) return;
    setState(() => isLoading = true);

    messages.add(ChatBubble(
      direction: Direction.right,
      message: messageController.text,
      type: BubbleType.alone,
    ));

    try {
      final response =
          await model.generateContent([Content.text(messageController.text)]);
      messages.add(ChatBubble(
        direction: Direction.left,
        message: response.text ?? 'Tidak dapat memproses pesan',
        photoUrl: 'https://i.pravatar.cc/150?img=47',
        type: BubbleType.alone,
      ));
    } catch (_) {
      messages.add(const ChatBubble(
        direction: Direction.left,
        message: 'Terjadi kesalahan',
        photoUrl: 'https://i.pravatar.cc/150?img=47',
        type: BubbleType.alone,
      ));
    }

    messageController.clear();
    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: const Text(
            'Gemini AI ✨',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          iconTheme: const IconThemeData(color: Colors.white),
          backgroundColor: Colors.blueGrey,
        ),
        drawer: Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              const DrawerHeader(
                decoration: BoxDecoration(
                  color: Colors.blueGrey,
                ),
                child: Text(
                  'Gemini Chat',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                  ),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.home),
                title: const Text('Home'),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.image),
                title: const Text('Chat with image'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ChatImage(),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
        body: Column(
          children: [
            Expanded(
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(
                    parent: BouncingScrollPhysics()),
                reverse: true,
                padding: const EdgeInsets.all(10),
                children: messages.reversed.toList(),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: messageController,
                      decoration:
                          const InputDecoration(hintText: 'Type a message...'),
                    ),
                  ),
                  isLoading
                      ? const CircularProgressIndicator.adaptive()
                      : IconButton(
                          icon: const Icon(Icons.send), onPressed: sendMessage),
                ],
              ),
            ),
          ],
        ),
      );
}
