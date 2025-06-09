// lib/home/data/mapper/member_mapper.dart

import 'package:tododok/home/domain/model/member.dart';

import '../dto/member_dto.dart';

extension MemberDtoMapper on MemberDto {
  Member toModel() {
    return Member(
      averageWpm: (averageWpm ?? 0).toDouble(),
      averageAccuracy: (averageAccuracy ?? 0).toDouble(),
      totalPracticeCount: (totalPracticeCount ?? 0).toInt(),
      totalChallengeCount: (totalChallengeCount ?? 0).toInt(),
      challengeWinCount: (challengeWinCount ?? 0).toInt(),
      bestWpm: (bestWpm ?? 0).toDouble(),
      bestAccuracy: (bestAccuracy ?? 0).toDouble(),
    );
  }
}

extension MemberModelMapper on Member {
  MemberDto toDto() {
    return MemberDto(
      averageWpm: averageWpm,
      averageAccuracy: averageAccuracy,
      totalPracticeCount: totalPracticeCount,
      totalChallengeCount: totalChallengeCount,
      challengeWinCount: challengeWinCount,
      bestWpm: bestWpm,
      bestAccuracy: bestAccuracy,
    );
  }
}
