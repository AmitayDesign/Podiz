extension ZwspString on String {
  /// Inserts a Zero Width Space (ZWSP) character between every character.
  ///
  /// This character is intended for invisible word separation and for line break control.
  /// It has no width, but its presence between two characters does not prevent increased letter spacing in justification
  String useCorrectEllipsis() => replaceAllMapped(
        RegExp('[A-Za-z0-9]'),
        (match) => '${match[0]}\u200B',
      );
}
