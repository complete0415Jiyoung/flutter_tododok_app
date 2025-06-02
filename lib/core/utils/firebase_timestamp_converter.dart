import 'package:cloud_firestore/cloud_firestore.dart';

/// Firebase Timestamp와 Dart DateTime 간 변환을 처리하는 유틸리티
class FirebaseTimestampConverter {
  const FirebaseTimestampConverter._();

  /// Firestore Timestamp를 DateTime으로 변환 (fromJson용)
  static DateTime? timestampFromJson(dynamic timestamp) {
    if (timestamp == null) return null;

    if (timestamp is Timestamp) {
      return timestamp.toDate();
    }

    if (timestamp is Map<String, dynamic>) {
      // Firestore에서 가져온 Timestamp 객체가 Map 형태일 때
      final seconds = timestamp['_seconds'] as int?;
      final nanoseconds = timestamp['_nanoseconds'] as int?;

      if (seconds != null) {
        return DateTime.fromMillisecondsSinceEpoch(
          seconds * 1000 + (nanoseconds ?? 0) ~/ 1000000,
        );
      }
    }

    if (timestamp is String) {
      // ISO 8601 문자열 형태일 때
      try {
        return DateTime.parse(timestamp);
      } catch (e) {
        return null;
      }
    }

    if (timestamp is int) {
      // Unix timestamp (milliseconds)일 때
      try {
        return DateTime.fromMillisecondsSinceEpoch(timestamp);
      } catch (e) {
        return null;
      }
    }

    return null;
  }

  /// DateTime을 Firestore Timestamp로 변환 (toJson용)
  static dynamic timestampToJson(DateTime? dateTime) {
    if (dateTime == null) return null;
    return Timestamp.fromDate(dateTime);
  }

  /// 현재 시간을 Firestore Timestamp로 반환
  static Timestamp now() {
    return Timestamp.now();
  }

  /// 서버 타임스탬프 (FieldValue.serverTimestamp())
  static FieldValue serverTimestamp() {
    return FieldValue.serverTimestamp();
  }

  /// DateTime을 Unix timestamp (milliseconds)로 변환
  static int dateTimeToMillis(DateTime dateTime) {
    return dateTime.millisecondsSinceEpoch;
  }

  /// Unix timestamp (milliseconds)를 DateTime으로 변환
  static DateTime millisToDateTime(int millis) {
    return DateTime.fromMillisecondsSinceEpoch(millis);
  }

  /// 두 DateTime 간의 차이를 Duration으로 반환
  static Duration timeDifference(DateTime start, DateTime end) {
    return end.difference(start);
  }

  /// DateTime이 특정 기간 이내인지 확인
  static bool isWithinDuration(DateTime dateTime, Duration duration) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    return difference.abs() <= duration;
  }

  /// DateTime을 사용자 친화적인 상대 시간 문자열로 변환
  static String toRelativeTimeString(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays}일 전';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}시간 전';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}분 전';
    } else {
      return '방금 전';
    }
  }
}
