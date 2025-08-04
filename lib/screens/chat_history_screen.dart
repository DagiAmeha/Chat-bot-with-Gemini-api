import 'package:chat_bot/hive/boxes.dart';
import 'package:chat_bot/hive/chat_history.dart';
import 'package:chat_bot/util/utilies.dart';
import 'package:chat_bot/widget/chat_history_widget.dart';
import 'package:chat_bot/widget/empty_history_widget.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class ChatHistoryScreen extends StatefulWidget {
  const ChatHistoryScreen({super.key});

  @override
  State<ChatHistoryScreen> createState() => _ChatHistoryScreenState();
}

class _ChatHistoryScreenState extends State<ChatHistoryScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        centerTitle: true,
        title: const Text('Chat history'),
      ),
      body: ValueListenableBuilder<Box<ChatHistory>>(
        valueListenable: Boxes.getChatHistory().listenable(),
        builder: (context, box, _) {
          final chatHistory = box.values
              .toList()
              .cast<ChatHistory>()
              .reversed
              .toList();
          return chatHistory.isEmpty
              ? const EmptyHistoryWidget()
              : Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ListView.builder(
                    itemCount: chatHistory.length,
                    itemBuilder: (context, index) {
                      final chat = chatHistory[index];
                      return ChathistoryWiget(chat: chat);
                    },
                  ),
                );
        },
      ),
    );
  }
}
