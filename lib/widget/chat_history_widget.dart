import 'package:chat_bot/hive/chat_history.dart';
import 'package:chat_bot/providers/chat_provider.dart';
import 'package:chat_bot/util/utilies.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ChathistoryWiget extends StatelessWidget {
  const ChathistoryWiget({super.key, required this.chat});

  final ChatHistory chat;
  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.only(left: 10.0, right: 10.0),
        leading: Icon(Icons.chat),
        title: Text(chat.prompt, maxLines: 1),
        subtitle: Text(chat.response, maxLines: 2),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: () async {
          final chatProvider = context.read<ChatProvider>();

          await chatProvider.prepareChatRoom(
            isNewChat: false,
            chatId: chat.chatId,
          );
          chatProvider.setCurrentIndex(1);
          chatProvider.pageController.jumpToPage(1);
        },
        onLongPress: () {
          showMyAnimatedDialog(
            context: context,
            title: 'Delete Chat',
            content: "Are you sure to you want to delete the chat?",
            actionText: "Delete",
            onActionPressed: (value) async {
              if (value) {
                await context.read<ChatProvider>().deleteChatMessages(
                  chatId: chat.chatId,
                );

                await chat.delete();
              }
            },
          );
        },
      ),
    );
  }
}
