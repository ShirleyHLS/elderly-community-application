import 'package:elderly_community/utils/constants/colors.dart';
import 'package:flutter/material.dart';

class ExpandableText extends StatefulWidget {
  final String text;
  final int maxLines;

  const ExpandableText({
    super.key,
    required this.text,
    this.maxLines = 3,
  });

  @override
  _ExpandableTextState createState() => _ExpandableTextState();
}

class _ExpandableTextState extends State<ExpandableText> {
  bool isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final textSpan = TextSpan(
          text: widget.text,
          style: Theme.of(context).textTheme.bodyMedium,
        );
        final textPainter = TextPainter(
          text: textSpan,
          maxLines: widget.maxLines,
          textDirection: TextDirection.ltr,
        )..layout(maxWidth: constraints.maxWidth);

        final isOverflowing = textPainter.didExceedMaxLines;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.text,
              style: Theme.of(context).textTheme.bodyMedium,
              maxLines: isExpanded ? null : widget.maxLines,
              overflow:
                  isExpanded ? TextOverflow.visible : TextOverflow.ellipsis,
            ),
            if (isOverflowing)
              Align(
                alignment: Alignment.centerLeft,
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      isExpanded = !isExpanded;
                    });
                  },
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 5),
                    child: Row(children: [
                      Text(
                        isExpanded ? "Read Less" : "Read More",
                        style: TextStyle(
                          color: ECColors.buttonPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(width: 5),
                      Icon(
                        Icons.keyboard_arrow_right,
                        color: ECColors.buttonPrimary,
                      ),
                    ]),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
