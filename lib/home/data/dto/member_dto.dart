// lib/home/data/dto/member_dto.dart
import 'package:json_annotation/json_annotation.dart';

part 'member_dto.g.dart';

@JsonSerializable()
class MemberDto {
  const MemberDto({
    this.averageWpm,
    this.averageAccuracy,
    this.totalPracticeCount,
    this.totalChallengeCount,
    this.challengeWinCount,
    this.bestWpm,
    this.bestAccuracy,
  });

  final num? averageWpm;
  final num? averageAccuracy;
  final num? totalPracticeCount;
  final num? totalChallengeCount;
  final num? challengeWinCount;
  final num? bestWpm;
  final num? bestAccuracy;

  factory MemberDto.fromJson(Map<String, dynamic> json) =>
      _$MemberDtoFromJson(json);
  Map<String, dynamic> toJson() => _$MemberDtoToJson(this);
}
