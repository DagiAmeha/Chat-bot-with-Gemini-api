import 'package:chat_bot/providers/chat_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class EmptyHistoryWidget extends StatelessWidget {
  const EmptyHistoryWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: GestureDetector(
        onTap: () async {
          final chatProvider = context.read<ChatProvider>();

          await chatProvider.prepareChatRoom(isNewChat: false, chatId: '');
          chatProvider.setCurrentIndex(1);
          chatProvider.pageController.jumpToPage(1);
        },
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            color: Theme.of(context).colorScheme.primary,
          ),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text('No chat found, start a new chat!'),
          ),
        ),
      ),
    );
  }
}
