import 'package:chat_bot/models/message.dart';
import 'package:flutter/material.dart';

class MyMessageWidget extends StatelessWidget {
  const MyMessageWidget({super.key, required this.message});

  final Message message;
  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.7,
        ),
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primaryContainer,
          borderRadius: BorderRadius.circular(18),
        ),
        child: MarkdownBody(selectable: true, data: message.message.toString()),
      ),
    );
  }
}
