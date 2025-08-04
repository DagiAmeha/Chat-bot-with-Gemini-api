import 'dart:developer' as dev;

import 'package:chat_bot/providers/chat_provider.dart';
import 'package:chat_bot/util/utilies.dart';
import 'package:chat_bot/widget/preview_images_widget.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

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

  // initialize the image picker
  final ImagePicker imagePicker = ImagePicker();

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
      widget.chatProvider.setImagesFileList([]);
      textFieldFocus.unfocus();
    }
  }

  // pick an image
  void pickImage() async {
    try {
      final pickedFile = await imagePicker.pickMultiImage(
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 95,
      );
      widget.chatProvider.setImagesFileList(pickedFile);
    } catch (error) {
      dev.log('Error picking image: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    bool hasImages =
        widget.chatProvider.imagesFileList != null &&
        widget.chatProvider.imagesFileList!.isNotEmpty;
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: Theme.of(context).textTheme.titleLarge!.color!,
        ),
      ),
      child: Column(
        children: [
          if (hasImages) const PreviewImagesWidget(),
          Row(
            children: [
              IconButton(
                onPressed: () {
                  if (hasImages) {
                    showMyAnimatedDialog(
                      context: context,
                      title: 'Delete Images',
                      content: 'Are you sure to delete the image',
                      actionText: 'Delete',
                      onActionPressed: (value) {
                        if (value) {
                          widget.chatProvider.setImagesFileList([]);
                        }
                      },
                    );
                  } else {
                    pickImage();
                  }
                },
                icon: Icon(hasImages ? Icons.delete_forever : Icons.image),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  focusNode: textFieldFocus,
                  controller: textController,
                  textInputAction: TextInputAction.send,
                  onSubmitted: widget.chatProvider.isLoading
                      ? null
                      : (value) {
                          if (value.isNotEmpty) {
                            sendChatMessage(
                              message: textController.text,
                              chatProvider: widget.chatProvider,
                              isTextOnly: hasImages ? false : true,
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
                onTap: widget.chatProvider.isLoading
                    ? null
                    : () {
                        if (textController.text.isNotEmpty) {
                          sendChatMessage(
                            message: textController.text,
                            chatProvider: widget.chatProvider,
                            isTextOnly: hasImages ? false : true,
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
        ],
      ),
    );
  }
}
