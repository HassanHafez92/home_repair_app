// File: lib/widgets/caption_input_dialog.dart
// Purpose: Dialog for entering image captions.

import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

class CaptionInputDialog extends StatefulWidget {
  final String? initialCaption;

  const CaptionInputDialog({super.key, this.initialCaption});

  @override
  State<CaptionInputDialog> createState() => _CaptionInputDialogState();
}

class _CaptionInputDialogState extends State<CaptionInputDialog> {
  late TextEditingController _controller;
  final _maxLength = 100;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialCaption);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('addCaption'.tr()),
      content: TextField(
        controller: _controller,
        maxLength: _maxLength,
        maxLines: 3,
        decoration: InputDecoration(
          hintText: 'enterCaptionHint'.tr(),
          border: const OutlineInputBorder(),
          counterText: '${_controller.text.length}/$_maxLength',
        ),
        onChanged: (value) {
          setState(() {}); // Update counter
        },
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('cancel'.tr()),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(
              _controller.text.trim().isEmpty ? null : _controller.text.trim(),
            );
          },
          child: Text('save'.tr()),
        ),
      ],
    );
  }
}
