import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import '../models/annotation.dart';

class AnnotationDialog extends StatefulWidget {
  final String? initialText;
  final String? initialColor;
  final bool isEditing;

  const AnnotationDialog({
    super.key,
    this.initialText,
    this.initialColor,
    this.isEditing = false,
  });

  @override
  State<AnnotationDialog> createState() => _AnnotationDialogState();
}

class _AnnotationDialogState extends State<AnnotationDialog> {
  final TextEditingController _textController = TextEditingController();
  Color _selectedColor = Colors.yellow;
  bool _isColorPickerOpen = false;

  @override
  void initState() {
    super.initState();
    _textController.text = widget.initialText ?? '';
    if (widget.initialColor != null) {
      _selectedColor = Color(int.parse(widget.initialColor!, radix: 16) + 0xFF000000);
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.isEditing ? '编辑标注' : '添加标注'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _textController,
              decoration: const InputDecoration(
                labelText: '标注内容',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Text('标注颜色：'),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _isColorPickerOpen = !_isColorPickerOpen;
                    });
                  },
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: _selectedColor,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.grey),
                    ),
                  ),
                ),
              ],
            ),
            if (_isColorPickerOpen)
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: ColorPicker(
                  pickerColor: _selectedColor,
                  onColorChanged: (color) {
                    setState(() {
                      _selectedColor = color;
                    });
                  },
                  enableAlpha: false,
                  showLabel: false,
                  pickerAreaHeightPercent: 0.8,
                ),
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('取消'),
        ),
        TextButton(
          onPressed: () {
            if (_textController.text.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('请输入标注内容')),
              );
              return;
            }
            Navigator.of(context).pop({
              'text': _textController.text,
              'color': _selectedColor.value.toRadixString(16).substring(2),
            });
          },
          child: const Text('确定'),
        ),
      ],
    );
  }
} 