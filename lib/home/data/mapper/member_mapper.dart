// lib/home/data/mapper/member_mapper.dart

import 'package:tododok/home/domain/model/member.dart';

import '../dto/member_dto.dart';

extension MemberDtoMapper on MemberDto {
  Member toModel() {
    return Member(
      averageTypingSpeed: (averageWpm ?? 0).toDouble() * 5.0, // WPM을 분당 타수로 변환
      averageAccuracy: (averageAccuracy ?? 0).toDouble(),
      totalPracticeCount: (totalPracticeCount ?? 0).toInt(),
      totalChallengeCount: (totalChallengeCount ?? 0).toInt(),
      challengeWinCount: (challengeWinCount ?? 0).toInt(),
      bestTypingSpeed: (bestWpm ?? 0).toDouble() * 5.0, // WPM을 분당 타수로 변환
      bestAccuracy: (bestAccuracy ?? 0).toDouble(),
    );
  }
}

extension MemberModelMapper on Member {
  MemberDto toDto() {
    return MemberDto(
      averageWpm: averageTypingSpeed / 5.0, // 분당 타수를 WPM으로 변환 (Firebase 호환성)
      averageAccuracy: averageAccuracy,
      totalPracticeCount: totalPracticeCount,
      totalChallengeCount: totalChallengeCount,
      challengeWinCount: challengeWinCount,
      bestWpm: bestTypingSpeed / 5.0, // 분당 타수를 WPM으로 변환 (Firebase 호환성)
      bestAccuracy: bestAccuracy,
    );
  }
}
