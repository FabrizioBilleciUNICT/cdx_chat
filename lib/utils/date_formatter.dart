import 'package:intl/intl.dart';

/// Utility class for formatting dates.
///
/// This provides a simple way to format dates without relying on
/// external extension methods.
class DateFormatter {
  /// Formats a [DateTime] using the given [pattern] and optional [locale].
  ///
  /// Example:
  /// ```dart
  /// final formatted = DateFormatter.format(
  ///   DateTime.now(),
  ///   'dd/MM/yyyy HH:mm',
  ///   locale: 'it',
  /// );
  /// ```
  static String format(DateTime date, String pattern, {String? locale}) {
    final formatter = DateFormat(pattern, locale);
    return formatter.format(date);
  }
}

