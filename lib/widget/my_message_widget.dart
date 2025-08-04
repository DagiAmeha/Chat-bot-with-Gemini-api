import 'dart:io';

import 'package:chat_bot/models/message.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

class MyMessageWidget extends StatelessWidget {
  const MyMessageWidget({super.key, required this.message});

  final Message message;

  @override
  Widget build(BuildContext context) {
    final images = message.imagesUrls;

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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (images.isNotEmpty)
              SizedBox(
                height: 80,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: images.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4.0),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.file(
                          File(images[index]),
                          width: 80,
                          height: 80,
                          fit: BoxFit.cover,
                        ),
                      ),
                    );
                  },
                ),
              ),
            if (images.isNotEmpty) const SizedBox(height: 8),
            MarkdownBody(selectable: true, data: message.message.toString()),
          ],
        ),
      ),
    );
  }
}
