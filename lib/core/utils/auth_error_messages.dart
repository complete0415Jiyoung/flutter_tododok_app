/// 인증 관련 모든 에러 메시지를 중앙 관리하는 상수 클래스
class AuthErrorMessages {
  const AuthErrorMessages._();

  // 로그인 관련 메시지
  static const String loginFailed = '로그인에 실패했습니다';
  static const String noLoggedInUser = '로그인된 사용자가 없습니다';
  static const String invalidCredentials = '이메일 또는 비밀번호가 올바르지 않습니다';
  static const String userNotFound = '등록되지 않은 이메일입니다';
  static const String wrongPassword = '비밀번호가 올바르지 않습니다';

  // 회원가입 관련 메시지
  static const String signUpFailed = '회원가입에 실패했습니다';
  static const String emailAlreadyInUse = '이미 사용 중인 이메일입니다';
  static const String weakPassword = '비밀번호가 너무 간단합니다';
  static const String invalidEmail = '올바르지 않은 이메일 형식입니다';

  // 닉네임 관련 메시지
  static const String nicknameAlreadyInUse = '이미 사용 중인 닉네임입니다';
  static const String invalidNickname = '닉네임은 2-20자의 한글, 영문, 숫자만 사용 가능합니다';
  static const String nicknameRequired = '닉네임을 입력해주세요';

  // 계정 상태 관련 메시지
  static const String userDisabled = '비활성화된 계정입니다';
  static const String accountDeleted = '삭제된 계정입니다';
  static const String requiresRecentLogin = '보안을 위해 다시 로그인해주세요';

  // 네트워크 관련 메시지
  static const String networkError = '네트워크 연결을 확인해주세요';
  static const String timeoutError = '요청 시간이 초과되었습니다';
  static const String serverError = '서버 오류가 발생했습니다';

  // 제한 관련 메시지
  static const String tooManyRequests = '너무 많은 요청이 발생했습니다. 잠시 후 다시 시도해주세요';
  static const String rateLimitExceeded = '요청 한도를 초과했습니다';

  // 유효성 검사 관련 메시지
  static const String emailRequired = '이메일을 입력해주세요';
  static const String passwordRequired = '비밀번호를 입력해주세요';
  static const String passwordTooShort = '비밀번호는 최소 6자 이상이어야 합니다';
  static const String passwordMismatch = '비밀번호가 일치하지 않습니다';

  // 일반 오류 메시지
  static const String unknownError = '알 수 없는 오류가 발생했습니다';
  static const String operationNotAllowed = '허용되지 않은 작업입니다';
  static const String invalidAction = '잘못된 요청입니다';

  // 권한 관련 메시지
  static const String permissionDenied = '권한이 없습니다';
  static const String unauthorized = '인증이 필요합니다';
  static const String forbidden = '접근이 금지되었습니다';

  // FCM 토큰 관련 메시지
  static const String fcmTokenFailed = '알림 토큰 등록에 실패했습니다';
  static const String fcmPermissionDenied = '알림 권한이 거부되었습니다';
}
