import 'package:flutter/material.dart';
import '../models/annotation.dart';

class AnnotationOverlay extends StatelessWidget {
  final List<Annotation> annotations;
  final Function(Annotation) onAnnotationTap;
  final Function(Annotation) onAnnotationLongPress;

  const AnnotationOverlay({
    super.key,
    required this.annotations,
    required this.onAnnotationTap,
    required this.onAnnotationLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: annotations.map((annotation) {
        return Positioned(
          left: annotation.position.dx,
          top: annotation.position.dy,
          child: GestureDetector(
            onTap: () => onAnnotationTap(annotation),
            onLongPress: () => onAnnotationLongPress(annotation),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Color(int.parse(annotation.color, radix: 16) + 0xFF000000)
                    .withOpacity(0.3),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                annotation.text,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
} 