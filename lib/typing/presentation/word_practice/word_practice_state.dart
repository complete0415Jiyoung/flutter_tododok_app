// lib/typing/presentation/word_practice/word_practice_state.dart
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../domain/model/sentence.dart';

part 'word_practice_state.freezed.dart';

@freezed
class WordPracticeState with _$WordPracticeState {
  const WordPracticeState({
    this.availableSentences = const AsyncLoading(),
    this.fallingWords = const [],
    this.userInput = '',
    this.score = 0,
    this.lives = 3,
    this.level = 1,
    this.isGameRunning = false,
    this.isGameOver = false,
    this.gameStartTime,
    this.language = 'ko',
    this.correctWordsCount = 0,
    this.missedWordsCount = 0,
    this.totalWordsSpawned = 0,
    this.gameSpeed = 1.0,
    this.cpm = 0.0,
    this.accuracy = 0.0,
    this.totalCharactersTyped = 0,
  });

  /// 사용 가능한 문장들 (단어 풀)
  @override
  final AsyncValue<List<Sentence>> availableSentences;

  /// 현재 떨어지고 있는 단어들
  @override
  final List<FallingWord> fallingWords;

  /// 사용자 현재 입력
  @override
  final String userInput;

  /// 점수
  @override
  final int score;

  /// 남은 생명
  @override
  final int lives;

  /// 현재 레벨
  @override
  final int level;

  /// 게임 진행 중 여부
  @override
  final bool isGameRunning;

  /// 게임 오버 여부
  @override
  final bool isGameOver;

  /// 게임 시작 시간
  @override
  final DateTime? gameStartTime;

  /// 선택된 언어
  @override
  final String language;

  /// 맞춘 단어 수
  @override
  final int correctWordsCount;

  /// 놓친 단어 수
  @override
  final int missedWordsCount;

  /// 총 생성된 단어 수
  @override
  final int totalWordsSpawned;

  /// 게임 속도 (떨어지는 속도)
  @override
  final double gameSpeed;

  /// 현재 CPM (Characters Per Minute) - 실시간 계산된 값
  @override
  final double cpm;

  /// 현재 정확도 (0-100) - 실시간 계산된 값
  @override
  final double accuracy;

  /// 총 입력한 글자 수
  @override
  final int totalCharactersTyped;

  /// 게임 진행 시간 (초)
  double get elapsedSeconds {
    if (gameStartTime == null) return 0.0;
    final endTime = isGameOver
        ? gameStartTime!.add(
            Duration(
              seconds: (DateTime.now().difference(gameStartTime!).inSeconds),
            ),
          )
        : DateTime.now();
    return endTime.difference(gameStartTime!).inMilliseconds / 1000.0;
  }

  /// 게임 초기화 가능 여부
  bool get canStart => !isGameRunning && !isGameOver;

  /// 게임 일시정지 가능 여부
  bool get canPause => isGameRunning;

  /// 생명이 위험한 상태인지 (1개 이하)
  bool get isLowLife => lives <= 1;

  /// 고득점 상태인지 (1000점 이상)
  bool get isHighScore => score >= 1000;

  /// 고속 타자 상태인지 (200 CPM 이상)
  bool get isFastTyper => cpm >= 200.0;

  /// 완벽한 정확도인지 (100%)
  bool get isPerfectAccuracy => accuracy >= 100.0;

  /// 우수한 정확도인지 (90% 이상)
  bool get isGoodAccuracy => accuracy >= 90.0;

  /// 게임이 진행 중이고 단어가 떨어지고 있는지
  bool get hasActiveWords => isGameRunning && fallingWords.isNotEmpty;

  /// 현재 레벨의 목표 단어 수 (레벨업 기준)
  int get currentLevelTarget {
    switch (level) {
      case 1:
        return 3;
      case 2:
        return 8;
      case 3:
        return 15;
      case 4:
        return 25;
      default:
        return level * 15; // 레벨 5+: 75, 90, 105...
    }
  }

  /// 현재 레벨의 목표 CPM (레벨업 기준)
  double get currentLevelCpmTarget {
    switch (level) {
      case 1:
        return 0.0; // 레벨 1은 CPM 조건 없음
      case 2:
        return 100.0; // 100 CPM
      case 3:
        return 180.0; // 180 CPM
      case 4:
        return 250.0; // 250 CPM
      default:
        return 250.0 + ((level - 4) * 50.0); // 레벨 5+: 300, 350, 400...
    }
  }

  /// 레벨업까지 남은 단어 수
  int get wordsUntilLevelUp {
    final remaining = currentLevelTarget - correctWordsCount;
    return remaining > 0 ? remaining : 0;
  }

  /// 레벨업까지 필요한 CPM
  double get cpmUntilLevelUp {
    final remaining = currentLevelCpmTarget - cpm;
    return remaining > 0 ? remaining : 0.0;
  }

  /// WPM 계산 (참고용)
  double get wpm => cpm / 5.0; // 평균 5글자 = 1단어

  /// 오타율 (%)
  double get errorRate => totalWordsSpawned > 0
      ? (missedWordsCount / totalWordsSpawned) * 100
      : 0.0;

  /// 타자 레벨 (CPM 기준)
  String get typingLevel {
    if (cpm < 100) return '초급';
    if (cpm < 200) return '중급';
    if (cpm < 300) return '고급';
    if (cpm < 400) return '상급';
    return '전문가';
  }
}

/// 떨어지는 단어 모델
@freezed
class FallingWord with _$FallingWord {
  const FallingWord({
    required this.id,
    required this.text,
    required this.x,
    required this.y,
    required this.speed,
    this.isMatched = false,
  });

  /// 고유 ID
  @override
  final String id;

  /// 단어 텍스트
  @override
  final String text;

  /// X 좌표 (0.0 ~ 1.0, 화면 너비 비율)
  @override
  final double x;

  /// Y 좌표 (0.0 ~ 1.0, 화면 높이 비율)
  @override
  final double y;

  /// 떨어지는 속도
  @override
  final double speed;

  /// 매칭된 상태 (입력 중)
  @override
  final bool isMatched;

  /// 화면 하단에 도달했는지 확인
  bool get hasReachedBottom => y >= 1.0;

  /// 화면 중간 지점에 도달했는지 (경고용)
  bool get isInDangerZone => y >= 0.7;

  /// 위험 지역에 도달했는지 (곧 바닥에 닿을 예정)
  bool get isNearBottom => y >= 0.9;

  /// 다음 프레임의 Y 좌표 계산
  double getNextY(double deltaTime) => y + (speed * deltaTime);

  /// 바닥에 닿기까지 남은 시간 (초)
  double get timeUntilBottom => speed > 0 ? (1.0 - y) / speed : double.infinity;

  /// 단어 길이 (글자 수)
  int get characterCount => text.length;

  /// 짧은 단어인지 (3글자 이하)
  bool get isShort => characterCount <= 3;

  /// 긴 단어인지 (7글자 이상)
  bool get isLong => characterCount >= 7;

  /// 단어의 난이도 (길이 기준)
  int get difficulty {
    if (isShort) return 1;
    if (isLong) return 3;
    return 2;
  }
}
