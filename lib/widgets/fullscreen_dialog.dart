import 'package:flutter/material.dart';

class FullscreenDialog extends StatefulWidget {
  final String title;
  final Widget? confirmButton;
  final Widget child;
  const FullscreenDialog(
      {super.key,
      required this.title,
      this.confirmButton,
      required this.child});

  @override
  State<FullscreenDialog> createState() => _FullscreenDialogState();
}

class _FullscreenDialogState extends State<FullscreenDialog> {
  @override
  Widget build(BuildContext context) {
    Widget header = Row(
      children: [
        IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(Icons.close)),
        Text('Select group', style: Theme.of(context).textTheme.titleLarge),
      ],
    );
    if (widget.confirmButton != null) {
      header = Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [header, widget.confirmButton!],
      );
    }
    return Dialog.fullscreen(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(8, 8, 8, 12),
            child: header,
          ),
          Expanded(child: widget.child),
        ],
      ),
    );
  }
}
