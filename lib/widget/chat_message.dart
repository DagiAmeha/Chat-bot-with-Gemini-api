import 'package:chat_bot/models/message.dart';
import 'package:chat_bot/providers/chat_provider.dart';
import 'package:chat_bot/widget/assistance_message_widget.dart';
import 'package:chat_bot/widget/my_message_widget.dart';
import 'package:flutter/material.dart';

class ChatMessage extends StatelessWidget {
  const ChatMessage({
    super.key,
    required this.scrollController,
    required this.chatProvider,
  });

  final ScrollController scrollController;
  final ChatProvider chatProvider;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: scrollController,
      itemCount: chatProvider.inChatMessages!.length,
      itemBuilder: (context, index) {
        final message = chatProvider.inChatMessages![index];
        return message.role == Role.user.name
            ? MyMessageWidget(message: message)
            : AssistanceMessageWidget(message: message.message.toString());
      },
    );
  }
}
