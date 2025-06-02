import 'package:firebase_auth/firebase_auth.dart';
import '../../shared/models/result.dart';

/// 인증 관련 예외를 Failure로 변환하는 유틸리티
class AuthExceptionMapper {
  const AuthExceptionMapper._();

  /// FirebaseAuthException을 Failure로 매핑
  static Failure mapAuthException(Object error, StackTrace stackTrace) {
    if (error is FirebaseAuthException) {
      return _mapFirebaseAuthException(error, stackTrace);
    }

    // 일반 예외는 기본 매퍼 사용
    return mapExceptionToFailure(error, stackTrace);
  }

  /// FirebaseAuthException 전용 매핑
  static Failure _mapFirebaseAuthException(
    FirebaseAuthException error,
    StackTrace stackTrace,
  ) {
    switch (error.code) {
      case 'user-not-found':
        return Failure(
          FailureType.notFound,
          '등록되지 않은 이메일입니다',
          cause: error,
          stackTrace: stackTrace,
        );

      case 'wrong-password':
        return Failure(
          FailureType.unauthorized,
          '비밀번호가 올바르지 않습니다',
          cause: error,
          stackTrace: stackTrace,
        );

      case 'email-already-in-use':
        return Failure(
          FailureType.validation,
          '이미 사용 중인 이메일입니다',
          cause: error,
          stackTrace: stackTrace,
        );

      case 'weak-password':
        return Failure(
          FailureType.validation,
          '비밀번호가 너무 간단합니다',
          cause: error,
          stackTrace: stackTrace,
        );

      case 'invalid-email':
        return Failure(
          FailureType.validation,
          '올바르지 않은 이메일 형식입니다',
          cause: error,
          stackTrace: stackTrace,
        );

      case 'user-disabled':
        return Failure(
          FailureType.unauthorized,
          '비활성화된 계정입니다',
          cause: error,
          stackTrace: stackTrace,
        );

      case 'too-many-requests':
        return Failure(
          FailureType.client,
          '너무 많은 요청이 발생했습니다. 잠시 후 다시 시도해주세요',
          cause: error,
          stackTrace: stackTrace,
        );

      case 'network-request-failed':
        return Failure(
          FailureType.network,
          '네트워크 연결을 확인해주세요',
          cause: error,
          stackTrace: stackTrace,
        );

      case 'requires-recent-login':
        return Failure(
          FailureType.unauthorized,
          '보안을 위해 다시 로그인해주세요',
          cause: error,
          stackTrace: stackTrace,
        );

      default:
        return Failure(
          FailureType.unknown,
          '인증 오류가 발생했습니다: ${error.message ?? "알 수 없는 오류"}',
          cause: error,
          stackTrace: stackTrace,
        );
    }
  }

  /// 이메일 유효성 검사
  static bool validateEmail(String email) {
    final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    return emailRegex.hasMatch(email);
  }

  /// 비밀번호 유효성 검사 (최소 6자)
  static bool validatePassword(String password) {
    return password.length >= 6;
  }

  /// 닉네임 유효성 검사 (2-20자, 한글/영문/숫자)
  static bool validateNickname(String nickname) {
    if (nickname.length < 2 || nickname.length > 20) return false;
    final nicknameRegex = RegExp(r'^[가-힣a-zA-Z0-9]+$');
    return nicknameRegex.hasMatch(nickname);
  }
}
