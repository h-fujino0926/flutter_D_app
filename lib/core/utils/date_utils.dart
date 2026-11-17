import 'package:intl/intl.dart';

/// 締切の状態（付箋の見た目の切り替えに使う）
enum DueState { none, normal, soon, overdue }

/// 時刻を指定しなかった日付は「その日の 23:59:59（端末のローカル時刻）」として保存する。
DateTime endOfDay(DateTime date) =>
    DateTime(date.year, date.month, date.day, 23, 59, 59);

/// 日付と時刻（任意）から保存用の DateTime を作る。
DateTime combineDateTime(DateTime date, {int? hour, int? minute}) {
  if (hour == null) return endOfDay(date);
  return DateTime(date.year, date.month, date.day, hour, minute ?? 0);
}

/// 締切が近い（24時間以内）／過ぎているかを判定する。
DueState dueStateOf(DateTime? dueAt, {DateTime? now}) {
  if (dueAt == null) return DueState.none;
  final current = now ?? DateTime.now();
  final due = dueAt.toLocal();
  if (current.isAfter(due)) return DueState.overdue;
  if (due.difference(current) <= const Duration(hours: 24)) return DueState.soon;
  return DueState.normal;
}

/// 画面表示用の日時文字列（例：11/20(木) 18:00 ／ 時刻なしなら 11/20(木)）
String formatDue(DateTime? value, {required bool hasTime}) {
  if (value == null) return '';
  final local = value.toLocal();
  final date = DateFormat('M/d(E)', 'ja').format(local);
  return hasTime ? '$date ${DateFormat('HH:mm').format(local)}' : date;
}

/// 通知などの日時表示（例：11/17 09:30）
String formatDateTime(DateTime value) =>
    DateFormat('M/d HH:mm').format(value.toLocal());

/// DB に送る形式（UTC の ISO 8601）
String? toDbTimestamp(DateTime? value) => value?.toUtc().toIso8601String();
