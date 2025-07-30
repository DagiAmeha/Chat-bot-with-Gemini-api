import 'dart:math';
import 'dart:developer' as dev;

import 'package:chat_bot/providers/chat_provider.dart';
import 'package:flutter/material.dart';

class BottomChatField extends StatefulWidget {
  const BottomChatField({super.key, required this.chatProvider});

  final ChatProvider chatProvider;
  @override
  State<BottomChatField> createState() => _BottomChatFieldState();
}

class _BottomChatFieldState extends State<BottomChatField> {
  // controller for the input field
  final TextEditingController textController = TextEditingController();

  // focus node for the input field
  final FocusNode textFieldFocus = FocusNode();

  @override
  void dispose() {
    textController.dispose();
    textFieldFocus.dispose();
    super.dispose();
  }

  Future<void> sendChatMessage({
    required String message,
    required ChatProvider chatProvider,
    required bool isTextOnly,
  }) async {
    try {
      await chatProvider.sendMessage(message: message, isTextOnly: isTextOnly);
    } catch (error) {
      // Handle error
      dev.log('Error sending message: $error');
    } finally {
      textController.clear();
      textFieldFocus.unfocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: Theme.of(context).textTheme.titleLarge!.color!,
        ),
      ),
      child: Row(
        children: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.image)),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              focusNode: textFieldFocus,
              controller: textController,
              textInputAction: TextInputAction.send,
              onSubmitted: (value) {
                if (value.isNotEmpty) {
                  sendChatMessage(
                    message: textController.text,
                    chatProvider: widget.chatProvider,
                    isTextOnly: true,
                  );
                }
              },
              decoration: InputDecoration.collapsed(
                hintText: 'Enter a prompt',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              if (textController.text.isNotEmpty) {
                sendChatMessage(
                  message: textController.text,
                  chatProvider: widget.chatProvider,
                  isTextOnly: true,
                );
              }
            },
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                borderRadius: BorderRadius.circular(20),
              ),
              margin: const EdgeInsets.all(5.0),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: const Icon(Icons.arrow_upward, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
