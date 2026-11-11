import 'package:intl/intl.dart';

/// Format tanggal & angka berbahasa Indonesia.
abstract final class Fmt {
  static final _time = DateFormat('HH.mm', 'id_ID');
  static final _dayMonth = DateFormat('d MMM', 'id_ID');
  static final _full = DateFormat('d MMM yyyy, HH.mm', 'id_ID');
  static final _weekday = DateFormat('EEE, d MMM', 'id_ID');

  /// "Hari ini, 10.24", "Kemarin", "Sen, 12 Okt", atau "12 Okt".
  static String relative(DateTime t, {DateTime? now}) {
    final n = now ?? DateTime.now();
    final days = _dayDiff(t, n);
    if (days == 0) return 'Hari ini, ${_time.format(t)}';
    if (days == 1) return 'Kemarin';
    if (days < 7) return _weekday.format(t);
    return _dayMonth.format(t);
  }

  static String full(DateTime t) => _full.format(t);

  /// Kelompok riwayat: Hari ini, Kemarin, Minggu ini, Lebih lama.
  static String group(DateTime t, {DateTime? now}) {
    final days = _dayDiff(t, now ?? DateTime.now());
    if (days == 0) return 'Hari ini';
    if (days == 1) return 'Kemarin';
    if (days < 7) return 'Minggu ini';
    return 'Lebih lama';
  }

  /// "0,85" — desimal dengan koma.
  static String decimal(double v, [int digits = 2]) => v.toStringAsFixed(digits).replaceAll('.', ',');

  static String percent(double v) => '${(v * 100).round()}%';

  /// Sapaan sesuai jam: pagi / siang / sore / malam.
  static String greeting([DateTime? now]) {
    final h = (now ?? DateTime.now()).hour;
    if (h < 11) return 'Selamat pagi,';
    if (h < 15) return 'Selamat siang,';
    if (h < 18) return 'Selamat sore,';
    return 'Selamat malam,';
  }

  static int _dayDiff(DateTime t, DateTime n) =>
      DateTime(n.year, n.month, n.day).difference(DateTime(t.year, t.month, t.day)).inDays;
}
