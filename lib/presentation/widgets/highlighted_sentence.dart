import 'package:flutter/material.dart';

/// Renders a sentence without changing its font size and underlines the
/// vocabulary word wherever it appears as a complete word or phrase.
class HighlightedSentence extends StatelessWidget {
  final String sentence;
  final String word;
  final TextStyle style;
  final TextStyle? highlightedStyle;
  final TextAlign textAlign;
  final int? maxLines;

  const HighlightedSentence({
    super.key,
    required this.sentence,
    required this.word,
    required this.style,
    this.highlightedStyle,
    this.textAlign = TextAlign.start,
    this.maxLines,
  });

  @override
  Widget build(BuildContext context) {
    final underlineStyle =
        highlightedStyle ??
        style.copyWith(
          decoration: TextDecoration.underline,
          decorationThickness: 2,
        );

    return Text.rich(
      TextSpan(
        style: style,
        children: buildHighlightedSentenceSpans(
          sentence,
          word,
          highlightedStyle: underlineStyle,
        ),
      ),
      textAlign: textAlign,
      softWrap: true,
      maxLines: maxLines,
      overflow: TextOverflow.clip,
    );
  }
}

final RegExp _wordCharacterPattern = RegExp(
  r'^[\p{L}\p{M}\p{N}_]$',
  unicode: true,
);

/// Splits [sentence] into normal and underlined spans.
///
/// Matching is case-insensitive, but a word is only highlighted when the
/// characters around it are not part of another word. This prevents a short
/// vocabulary item such as "he" from being highlighted inside "the".
List<InlineSpan> buildHighlightedSentenceSpans(
  String sentence,
  String word, {
  TextStyle? highlightedStyle,
}) {
  if (sentence.isEmpty || word.trim().isEmpty) {
    return [TextSpan(text: sentence)];
  }

  final target = word.trim();
  final matcher = RegExp(
    RegExp.escape(target),
    caseSensitive: false,
    unicode: true,
  );
  final spans = <InlineSpan>[];
  var cursor = 0;

  for (final match in matcher.allMatches(sentence)) {
    if (!_isCompleteWordMatch(sentence, match.start, match.end)) {
      continue;
    }

    if (match.start > cursor) {
      spans.add(TextSpan(text: sentence.substring(cursor, match.start)));
    }
    spans.add(
      TextSpan(
        text: sentence.substring(match.start, match.end),
        style:
            highlightedStyle ??
            const TextStyle(decoration: TextDecoration.underline),
      ),
    );
    cursor = match.end;
  }

  if (cursor == 0) {
    return [TextSpan(text: sentence)];
  }
  if (cursor < sentence.length) {
    spans.add(TextSpan(text: sentence.substring(cursor)));
  }
  return spans;
}

bool _isCompleteWordMatch(String sentence, int start, int end) {
  return !_isWordCharacterAt(sentence, start - 1) &&
      !_isWordCharacterAt(sentence, end);
}

bool _isWordCharacterAt(String value, int index) {
  if (index < 0 || index >= value.length) {
    return false;
  }

  // A boundary is checked only at either side of a match. Handling a
  // surrogate pair here keeps non-BMP letters from being treated as
  // punctuation by the one-code-unit String index operation.
  final codeUnit = value.codeUnitAt(index);
  if (codeUnit >= 0xD800 && codeUnit <= 0xDBFF && index + 1 < value.length) {
    return _wordCharacterPattern.hasMatch(value.substring(index, index + 2));
  }
  return _wordCharacterPattern.hasMatch(value[index]);
}
