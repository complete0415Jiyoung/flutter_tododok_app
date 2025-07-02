// lib/typing/data/data_source/mock_typing_data_source_impl.dart
import '../dto/sentence_dto.dart';
import '../dto/typing_result_dto.dart';
import 'typing_data_source.dart';

class MockTypingDataSourceImpl implements TypingDataSource {
  final List<SentenceDto> _sentences = [];
  final List<TypingResultDto> _typingResults = [];
  bool _initialized = false;

  Future<void> _initializeIfNeeded() async {
    if (_initialized) return;

    // Mock 문장 데이터 초기화
    _sentences.addAll(_generateMockSentences());
    _initialized = true;
  }

  List<SentenceDto> _generateMockSentences() {
    final now = DateTime.now();
    return [
      // 한글 단어 연습
      SentenceDto(
        id: 'ko_word_1',
        type: 'word',
        language: 'ko',
        content: '안녕하세요 반갑습니다 감사합니다 죄송합니다 괜찮습니다 컴퓨터 프로그래밍 개발자 소프트웨어 알고리즘',
        difficulty: 1,
        wordCount: 10,
        category: '인사말',
        createdAt: now,
      ),
      SentenceDto(
        id: 'ko_word_2',
        type: 'word',
        language: 'ko',
        content: '컴퓨터 프로그래밍 개발자 소프트웨어 알고리즘 컴퓨터 프로그래밍 개발자 소프트웨어 알고리즘',
        difficulty: 3,
        wordCount: 10,
        category: 'IT용어',
        createdAt: now,
      ),

      // 한글 장문 연습
      SentenceDto(
        id: 'ko_paragraph_1',
        type: 'paragraph',
        language: 'ko',
        content:
            '타자 연습은 컴퓨터를 사용하는 현대인에게 필수적인 기술입니다. 빠르고 정확한 타자 실력은 업무 효율성을 크게 향상시킵니다.',
        difficulty: 2,
        wordCount: 25,
        category: '일반',
        createdAt: now,
      ),

      // 영문 단어 연습
      SentenceDto(
        id: 'en_word_1',
        type: 'word',
        language: 'en',
        content: 'hello world computer programming software development',
        difficulty: 2,
        wordCount: 6,
        category: 'basic',
        createdAt: now,
      ),

      // 영문 장문 연습
      SentenceDto(
        id: 'en_paragraph_1',
        type: 'paragraph',
        language: 'en',
        content:
            'Typing practice is an essential skill for modern computer users. Good typing speed and accuracy can significantly improve your productivity.',
        difficulty: 3,
        wordCount: 20,
        category: 'general',
        createdAt: now,
      ),
    ];
  }

  @override
  Future<List<SentenceDto>> fetchSentencesByType(String type) async {
    await _initializeIfNeeded();
    await Future.delayed(const Duration(milliseconds: 300));

    return _sentences.where((s) => s.type == type).toList();
  }

  @override
  Future<List<SentenceDto>> fetchSentencesByLanguage(String language) async {
    await _initializeIfNeeded();
    await Future.delayed(const Duration(milliseconds: 300));

    return _sentences.where((s) => s.language == language).toList();
  }

  @override
  Future<List<SentenceDto>> fetchSentences(String type, String language) async {
    await _initializeIfNeeded();
    await Future.delayed(const Duration(milliseconds: 300));

    return _sentences
        .where((s) => s.type == type && s.language == language)
        .toList();
  }

  @override
  Future<SentenceDto> fetchSentenceById(String sentenceId) async {
    await _initializeIfNeeded();
    await Future.delayed(const Duration(milliseconds: 200));

    final sentence = _sentences.firstWhere(
      (s) => s.id == sentenceId,
      orElse: () => throw Exception('문장을 찾을 수 없습니다: $sentenceId'),
    );

    return sentence;
  }

  @override
  Future<SentenceDto> fetchRandomSentence(String type, String language) async {
    await _initializeIfNeeded();
    await Future.delayed(const Duration(milliseconds: 200));

    final filtered = _sentences
        .where((s) => s.type == type && s.language == language)
        .toList();

    if (filtered.isEmpty) {
      throw Exception('조건에 맞는 문장이 없습니다: type=$type, language=$language');
    }

    filtered.shuffle();
    return filtered.first;
  }

  @override
  Future<String> saveTypingResult(TypingResultDto result) async {
    await Future.delayed(const Duration(milliseconds: 500));

    final resultId = 'result_${DateTime.now().millisecondsSinceEpoch}';
    final resultWithId = TypingResultDto(
      id: resultId,
      userId: result.userId,
      type: result.type,
      mode: result.mode,
      sentenceId: result.sentenceId,
      sentenceContent: result.sentenceContent,
      wpm: result.wpm,
      accuracy: result.accuracy,
      typoCount: result.typoCount,
      totalCharacters: result.totalCharacters,
      correctCharacters: result.correctCharacters,
      duration: result.duration,
      language: result.language,
      createdAt: result.createdAt ?? DateTime.now(),
    );

    _typingResults.add(resultWithId);
    return resultId;
  }

  @override
  Future<List<TypingResultDto>> fetchUserTypingResults(String userId) async {
    await Future.delayed(const Duration(milliseconds: 400));

    return _typingResults.where((r) => r.userId == userId).toList()..sort(
      (a, b) => (b.createdAt ?? DateTime.now()).compareTo(
        a.createdAt ?? DateTime.now(),
      ),
    );
  }

  @override
  Future<List<TypingResultDto>> fetchRecentTypingResults(
    String userId,
    int limit,
  ) async {
    await Future.delayed(const Duration(milliseconds: 300));

    final userResults = _typingResults.where((r) => r.userId == userId).toList()
      ..sort(
        (a, b) => (b.createdAt ?? DateTime.now()).compareTo(
          a.createdAt ?? DateTime.now(),
        ),
      );

    return userResults.take(limit).toList();
  }

  @override
  Future<List<TypingResultDto>> fetchTypingResultsByMode(
    String userId,
    String mode,
  ) async {
    await Future.delayed(const Duration(milliseconds: 300));

    return _typingResults
        .where((r) => r.userId == userId && r.mode == mode)
        .toList()
      ..sort(
        (a, b) => (b.createdAt ?? DateTime.now()).compareTo(
          a.createdAt ?? DateTime.now(),
        ),
      );
  }

  @override
  Future<TypingResultDto?> fetchBestWpmResult(
    String userId,
    String mode,
  ) async {
    await Future.delayed(const Duration(milliseconds: 300));

    final userResults = _typingResults
        .where((r) => r.userId == userId && r.mode == mode)
        .toList();

    if (userResults.isEmpty) return null;

    userResults.sort((a, b) => (b.wpm ?? 0).compareTo(a.wpm ?? 0));
    return userResults.first;
  }

  @override
  Future<TypingResultDto?> fetchBestAccuracyResult(
    String userId,
    String mode,
  ) async {
    await Future.delayed(const Duration(milliseconds: 300));

    final userResults = _typingResults
        .where((r) => r.userId == userId && r.mode == mode)
        .toList();

    if (userResults.isEmpty) return null;

    userResults.sort((a, b) => (b.accuracy ?? 0).compareTo(a.accuracy ?? 0));
    return userResults.first;
  }

  @override
  Future<TypingResultDto?> fetchBestTypingSpeedResult(
    // 메서드명 변경
    String userId,
    String mode,
  ) async {
    await Future.delayed(const Duration(milliseconds: 300));

    final userResults = _typingResults
        .where((r) => r.userId == userId && r.mode == mode)
        .toList();

    if (userResults.isEmpty) return null;

    // typingSpeed 기준으로 정렬 (분당 타수가 높은 순)
    userResults.sort(
      (a, b) => (b.typingSpeed ?? 0).compareTo(a.typingSpeed ?? 0),
    );
    return userResults.first;
  }
}
