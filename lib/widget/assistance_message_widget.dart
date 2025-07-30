import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class AssistanceMessageWidget extends StatelessWidget {
  const AssistanceMessageWidget({super.key, required this.message});

  final String message;
  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.8,
        ),
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceVariant,
          borderRadius: BorderRadius.circular(18),
        ),
        child: message.isEmpty
            ? const SizedBox(
                width: 50,
                child: SpinKitThreeBounce(color: Colors.blue, size: 20.0),
              )
            : MarkdownBody(selectable: true, data: message),
      ),
    );
  }
}
