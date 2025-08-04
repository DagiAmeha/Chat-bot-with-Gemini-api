import 'package:chat_bot/models/message.dart';
import 'package:chat_bot/providers/chat_provider.dart';
import 'package:chat_bot/util/utilies.dart';
import 'package:chat_bot/widget/assistance_message_widget.dart';
import 'package:chat_bot/widget/bottom_chat_field.dart';
import 'package:chat_bot/widget/my_message_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  // controller for the input field
  final TextEditingController _messageController = TextEditingController();

  final ScrollController _scrollController = ScrollController();

  void scrollToBottom() {
    // Delay until after the frame is fully rendered and ListView is attached
    Future.delayed(Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        try {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        } catch (e) {
          // Optional: Log the error if you're debugging
          debugPrint('Scroll error: $e');
        }
      } else {
        debugPrint('ScrollController not attached yet');
      }
    });
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final chatProvider = Provider.of<ChatProvider>(context, listen: false);
      chatProvider.addListener(() {
        scrollToBottom();
      });
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ChatProvider>(
      builder: (context, chatProvider, child) {
        if (chatProvider.inChatMessages!.isNotEmpty) {
          scrollToBottom();
        }

        // auto scroll to bottom when new messages are addedl

        return Scaffold(
          appBar: AppBar(
            backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
            centerTitle: true,
            title: const Text('Chat with Gemini'),
            actions: [
              if (chatProvider.inChatMessages!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: CircleAvatar(
                    child: IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: () async {
                        showMyAnimatedDialog(
                          context: context,
                          title: 'Start New Chat',
                          content: 'Are you sure you want to start a new chat',
                          actionText: 'Yes',
                          onActionPressed: (value) async {
                            if (value) {
                              await chatProvider.prepareChatRoom(
                                isNewChat: true,
                                chatId: '',
                              );
                            }
                          },
                        );
                      },
                    ),
                  ),
                ),
            ],
          ),
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  Expanded(
                    child: chatProvider.inChatMessages!.isEmpty
                        ? const Center(child: Text('No messages yet'))
                        : ListView.builder(
                            controller: _scrollController,
                            itemCount: chatProvider.inChatMessages?.length,
                            itemBuilder: (context, index) {
                              final message =
                                  chatProvider.inChatMessages![index];
                              return message.role == Role.user.name
                                  ? MyMessageWidget(message: message)
                                  : AssistanceMessageWidget(
                                      message: message.message.toString(),
                                    );
                            },
                          ),
                  ),

                  // input field
                  BottomChatField(chatProvider: chatProvider),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
