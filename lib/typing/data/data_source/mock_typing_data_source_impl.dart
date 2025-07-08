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
      // === 한글 단어 연습 ===
      SentenceDto(
        id: 'ko_word_1',
        type: 'word',
        language: 'ko',
        content: '안녕하세요 반갑습니다 감사합니다 죄송합니다 괜찮습니다',
        difficulty: 1,
        wordCount: 5,
        category: '일상',
        createdAt: now,
      ),
      SentenceDto(
        id: 'ko_word_2',
        type: 'word',
        language: 'ko',
        content: '컴퓨터 프로그래밍 개발자 소프트웨어 알고리즘 데이터베이스',
        difficulty: 2,
        wordCount: 6,
        category: '기술',
        createdAt: now,
      ),
      SentenceDto(
        id: 'ko_word_3',
        type: 'word',
        language: 'ko',
        content: '학교 선생님 학생 공부 숙제 시험 교실 칠판',
        difficulty: 1,
        wordCount: 8,
        category: '교육',
        createdAt: now,
      ),
      SentenceDto(
        id: 'ko_word_4',
        type: 'word',
        language: 'ko',
        content: '운동 건강 병원 의사 간호사 약국 치료 수술',
        difficulty: 2,
        wordCount: 8,
        category: '건강',
        createdAt: now,
      ),
      SentenceDto(
        id: 'ko_word_5',
        type: 'word',
        language: 'ko',
        content: '기업 회사 사장 직원 회의 프로젝트 업무 성과 목표 전략',
        difficulty: 3,
        wordCount: 10,
        category: '비즈니스',
        createdAt: now,
      ),

      // === 한글 장문 연습 ===
      SentenceDto(
        id: 'ko_paragraph_1',
        type: 'paragraph',
        language: 'ko',
        content: '안녕하세요. 오늘은 정말 좋은 날씨입니다. 타자 연습을 통해 실력을 향상시켜보세요.',
        difficulty: 1,
        wordCount: 15,
        category: '일상',
        createdAt: now,
      ),
      SentenceDto(
        id: 'ko_paragraph_2',
        type: 'paragraph',
        language: 'ko',
        content:
            '컴퓨터 프로그래밍은 논리적 사고와 창의성을 요구하는 분야입니다. 끊임없는 학습과 연습을 통해 실력을 키울 수 있습니다.',
        difficulty: 2,
        wordCount: 25,
        category: '기술',
        createdAt: now,
      ),
      SentenceDto(
        id: 'ko_paragraph_3',
        type: 'paragraph',
        language: 'ko',
        content:
            '독서는 지식을 쌓고 상상력을 기르는 가장 좋은 방법 중 하나입니다. 다양한 분야의 책을 읽으며 시야를 넓혀보세요.',
        difficulty: 1,
        wordCount: 23,
        category: '교육',
        createdAt: now,
      ),
      SentenceDto(
        id: 'ko_paragraph_4',
        type: 'paragraph',
        language: 'ko',
        content:
            '건강한 생활을 위해서는 규칙적인 운동과 올바른 식습관이 중요합니다. 충분한 수면과 스트레스 관리도 필수적입니다.',
        difficulty: 2,
        wordCount: 22,
        category: '건강',
        createdAt: now,
      ),
      SentenceDto(
        id: 'ko_paragraph_5',
        type: 'paragraph',
        language: 'ko',
        content:
            '시간 관리는 성공적인 인생을 위한 필수 요소입니다. 계획을 세우고 우선순위를 정하여 효율적으로 시간을 활용해보세요.',
        difficulty: 2,
        wordCount: 24,
        category: '자기계발',
        createdAt: now,
      ),
      SentenceDto(
        id: 'ko_paragraph_6',
        type: 'paragraph',
        language: 'ko',
        content:
            '예술은 인간의 감정과 생각을 표현하는 아름다운 언어입니다. 음악, 미술, 문학 등 다양한 예술 형태를 감상해보세요.',
        difficulty: 2,
        wordCount: 24,
        category: '예술',
        createdAt: now,
      ),
      SentenceDto(
        id: 'ko_paragraph_7',
        type: 'paragraph',
        language: 'ko',
        content:
            '환경 보호는 우리 모두의 책임입니다. 작은 실천부터 시작하여 지구를 지키는 일에 동참해보세요. 재활용, 에너지 절약, 친환경 제품 사용 등 다양한 방법이 있습니다.',
        difficulty: 3,
        wordCount: 35,
        category: '환경',
        createdAt: now,
      ),
      SentenceDto(
        id: 'ko_paragraph_8',
        type: 'paragraph',
        language: 'ko',
        content:
            '인공지능 기술의 발달로 우리의 생활은 점점 더 편리해지고 있습니다. 하지만 동시에 새로운 도전과 과제들도 등장하고 있어 지속적인 관심과 준비가 필요합니다.',
        difficulty: 4,
        wordCount: 32,
        category: '기술',
        createdAt: now,
      ),
      SentenceDto(
        id: 'ko_paragraph_9',
        type: 'paragraph',
        language: 'ko',
        content:
            '팀워크는 현대 사회에서 매우 중요한 역량입니다. 서로 다른 배경과 경험을 가진 사람들이 함께 협력하여 더 큰 성과를 만들어낼 수 있습니다.',
        difficulty: 3,
        wordCount: 28,
        category: '비즈니스',
        createdAt: now,
      ),
      SentenceDto(
        id: 'ko_paragraph_10',
        type: 'paragraph',
        language: 'ko',
        content:
            '과학 기술의 발전은 인류 문명의 진보를 이끌어왔습니다. 새로운 발견과 혁신을 통해 더 나은 미래를 만들어가는 것이 우리의 목표입니다.',
        difficulty: 3,
        wordCount: 26,
        category: '과학',
        createdAt: now,
      ),
      SentenceDto(
        id: 'ko_paragraph_11',
        type: 'paragraph',
        language: 'ko',
        content:
            '스포츠는 건강한 신체와 정신을 기르는 데 도움이 됩니다. 개인 운동부터 팀 스포츠까지 다양한 활동을 통해 체력을 향상시키고 스트레스를 해소할 수 있습니다.',
        difficulty: 3,
        wordCount: 30,
        category: '스포츠',
        createdAt: now,
      ),
      SentenceDto(
        id: 'ko_paragraph_12',
        type: 'paragraph',
        language: 'ko',
        content:
            '글로벌 시대에 살고 있는 우리는 다양한 문화와 언어를 이해하고 소통하는 능력을 기러야 합니다. 외국어 학습은 새로운 기회를 열어주는 열쇠가 될 것입니다.',
        difficulty: 4,
        wordCount: 32,
        category: '교육',
        createdAt: now,
      ),

      // === 영문 단어 연습 ===
      SentenceDto(
        id: 'en_word_1',
        type: 'word',
        language: 'en',
        content: 'hello world welcome thank you please',
        difficulty: 1,
        wordCount: 5,
        category: 'basic',
        createdAt: now,
      ),
      SentenceDto(
        id: 'en_word_2',
        type: 'word',
        language: 'en',
        content: 'computer programming software development database',
        difficulty: 2,
        wordCount: 5,
        category: 'technology',
        createdAt: now,
      ),
      SentenceDto(
        id: 'en_word_3',
        type: 'word',
        language: 'en',
        content: 'school teacher student study homework exam classroom',
        difficulty: 1,
        wordCount: 7,
        category: 'education',
        createdAt: now,
      ),
      SentenceDto(
        id: 'en_word_4',
        type: 'word',
        language: 'en',
        content: 'exercise health hospital doctor nurse pharmacy treatment',
        difficulty: 2,
        wordCount: 7,
        category: 'health',
        createdAt: now,
      ),
      SentenceDto(
        id: 'en_word_5',
        type: 'word',
        language: 'en',
        content:
            'business company manager employee meeting project performance',
        difficulty: 3,
        wordCount: 7,
        category: 'business',
        createdAt: now,
      ),

      // === 영문 장문 연습 ===
      SentenceDto(
        id: 'en_paragraph_1',
        type: 'paragraph',
        language: 'en',
        content:
            'Hello and welcome to our typing practice program. Today is a great day to improve your typing skills.',
        difficulty: 1,
        wordCount: 18,
        category: 'basic',
        createdAt: now,
      ),
      SentenceDto(
        id: 'en_paragraph_2',
        type: 'paragraph',
        language: 'en',
        content:
            'Computer programming requires logical thinking and creativity. Through continuous learning and practice, you can develop your skills.',
        difficulty: 2,
        wordCount: 18,
        category: 'technology',
        createdAt: now,
      ),
      SentenceDto(
        id: 'en_paragraph_3',
        type: 'paragraph',
        language: 'en',
        content:
            'Reading is one of the best ways to gain knowledge and develop imagination. Read books from various fields to broaden your perspective.',
        difficulty: 2,
        wordCount: 22,
        category: 'education',
        createdAt: now,
      ),
      SentenceDto(
        id: 'en_paragraph_4',
        type: 'paragraph',
        language: 'en',
        content:
            'For a healthy lifestyle, regular exercise and proper diet are essential. Adequate sleep and stress management are also crucial.',
        difficulty: 2,
        wordCount: 19,
        category: 'health',
        createdAt: now,
      ),
      SentenceDto(
        id: 'en_paragraph_5',
        type: 'paragraph',
        language: 'en',
        content:
            'Time management is an essential element for a successful life. Make plans and set priorities to use your time efficiently.',
        difficulty: 2,
        wordCount: 20,
        category: 'business',
        createdAt: now,
      ),
      SentenceDto(
        id: 'en_paragraph_6',
        type: 'paragraph',
        language: 'en',
        content:
            'Art is a beautiful language that expresses human emotions and thoughts. Appreciate various art forms such as music, painting, and literature.',
        difficulty: 2,
        wordCount: 21,
        category: 'art',
        createdAt: now,
      ),
      SentenceDto(
        id: 'en_paragraph_7',
        type: 'paragraph',
        language: 'en',
        content:
            'Environmental protection is everyone\'s responsibility. Start with small actions to participate in protecting our planet. There are various ways including recycling, energy saving, and using eco-friendly products.',
        difficulty: 3,
        wordCount: 28,
        category: 'environment',
        createdAt: now,
      ),
      SentenceDto(
        id: 'en_paragraph_8',
        type: 'paragraph',
        language: 'en',
        content:
            'Artificial intelligence technology is making our lives more convenient. However, new challenges and tasks are emerging, requiring continuous attention and preparation.',
        difficulty: 3,
        wordCount: 22,
        category: 'technology',
        createdAt: now,
      ),
      SentenceDto(
        id: 'en_paragraph_9',
        type: 'paragraph',
        language: 'en',
        content:
            'Teamwork is a very important skill in modern society. People from different backgrounds and experiences can collaborate to achieve greater results.',
        difficulty: 3,
        wordCount: 21,
        category: 'business',
        createdAt: now,
      ),
      SentenceDto(
        id: 'en_paragraph_10',
        type: 'paragraph',
        language: 'en',
        content:
            'Scientific and technological advancement has driven the progress of human civilization. Our goal is to create a better future through new discoveries and innovations.',
        difficulty: 3,
        wordCount: 24,
        category: 'science',
        createdAt: now,
      ),
      SentenceDto(
        id: 'en_paragraph_11',
        type: 'paragraph',
        language: 'en',
        content:
            'Sports help develop healthy body and mind. From individual exercises to team sports, various activities can improve physical fitness and relieve stress.',
        difficulty: 3,
        wordCount: 22,
        category: 'sports',
        createdAt: now,
      ),
      SentenceDto(
        id: 'en_paragraph_12',
        type: 'paragraph',
        language: 'en',
        content:
            'Living in a global age, we must develop the ability to understand and communicate with diverse cultures and languages. Foreign language learning will be the key to opening new opportunities.',
        difficulty: 4,
        wordCount: 30,
        category: 'education',
        createdAt: now,
      ),

      // === 고급 난이도 문장 추가 ===
      SentenceDto(
        id: 'ko_paragraph_advanced_1',
        type: 'paragraph',
        language: 'ko',
        content:
            '빅데이터와 머신러닝 기술이 발전하면서 데이터 분석의 중요성이 크게 부각되고 있습니다. 기업들은 방대한 양의 데이터를 수집하고 분석하여 비즈니스 인사이트를 도출하고 있으며, 이를 통해 경쟁 우위를 확보하려고 노력하고 있습니다.',
        difficulty: 5,
        wordCount: 42,
        category: '기술',
        createdAt: now,
      ),
      SentenceDto(
        id: 'en_paragraph_advanced_1',
        type: 'paragraph',
        language: 'en',
        content:
            'The rapid advancement of big data and machine learning technologies has significantly highlighted the importance of data analysis. Companies are collecting and analyzing vast amounts of data to derive business insights and gain competitive advantages in the market.',
        difficulty: 5,
        wordCount: 35,
        category: 'technology',
        createdAt: now,
      ),
    ];
  }

  @override
  Future<List<SentenceDto>> fetchSentencesByType(String type) async {
    await _initializeIfNeeded();
    await Future.delayed(const Duration(milliseconds: 500));
    return _sentences.where((sentence) => sentence.type == type).toList();
  }

  @override
  Future<List<SentenceDto>> fetchSentencesByLanguage(String language) async {
    await _initializeIfNeeded();
    await Future.delayed(const Duration(milliseconds: 500));
    return _sentences
        .where((sentence) => sentence.language == language)
        .toList();
  }

  @override
  Future<List<SentenceDto>> fetchSentences(String type, String language) async {
    await _initializeIfNeeded();
    await Future.delayed(const Duration(milliseconds: 500));
    return _sentences
        .where(
          (sentence) => sentence.type == type && sentence.language == language,
        )
        .toList();
  }

  @override
  Future<SentenceDto> fetchSentenceById(String sentenceId) async {
    await _initializeIfNeeded();
    await Future.delayed(const Duration(milliseconds: 300));

    try {
      return _sentences.firstWhere((sentence) => sentence.id == sentenceId);
    } catch (e) {
      throw Exception('문장을 찾을 수 없습니다: $sentenceId');
    }
  }

  @override
  Future<SentenceDto> fetchRandomSentence(String type, String language) async {
    await _initializeIfNeeded();
    await Future.delayed(const Duration(milliseconds: 300));

    final filteredSentences = _sentences
        .where(
          (sentence) => sentence.type == type && sentence.language == language,
        )
        .toList();

    if (filteredSentences.isEmpty) {
      throw Exception('조건에 맞는 문장이 없습니다');
    }

    final randomIndex =
        DateTime.now().millisecondsSinceEpoch % filteredSentences.length;
    return filteredSentences[randomIndex];
  }

  @override
  Future<String> saveTypingResult(TypingResultDto result) async {
    await Future.delayed(const Duration(milliseconds: 500));

    final resultId = 'result_${DateTime.now().millisecondsSinceEpoch}';

    // copyWith 대신 새로운 인스턴스 생성
    final resultWithId = TypingResultDto(
      id: resultId,
      userId: result.userId,
      type: result.type,
      mode: result.mode,
      sentenceId: result.sentenceId,
      sentenceContent: result.sentenceContent,
      wpm: result.wpm,
      typingSpeed: result.typingSpeed,
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
    await Future.delayed(const Duration(milliseconds: 300));
    return _typingResults.where((result) => result.userId == userId).toList();
  }

  @override
  Future<List<TypingResultDto>> fetchRecentTypingResults(
    String userId,
    int limit,
  ) async {
    await Future.delayed(const Duration(milliseconds: 300));

    final userResults = _typingResults
        .where((result) => result.userId == userId)
        .toList();

    userResults.sort((a, b) => b.createdAt!.compareTo(a.createdAt!));

    return userResults.take(limit).toList();
  }

  @override
  Future<List<TypingResultDto>> fetchTypingResultsByMode(
    String userId,
    String mode,
  ) async {
    await Future.delayed(const Duration(milliseconds: 300));

    return _typingResults
        .where((result) => result.userId == userId && result.mode == mode)
        .toList();
  }

  @override
  Future<TypingResultDto?> fetchBestTypingSpeedResult(
    String userId,
    String mode,
  ) async {
    await Future.delayed(const Duration(milliseconds: 300));

    final userResults = _typingResults
        .where((result) => result.userId == userId && result.mode == mode)
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
        .where((result) => result.userId == userId && result.mode == mode)
        .toList();

    if (userResults.isEmpty) return null;

    userResults.sort((a, b) => (b.accuracy ?? 0).compareTo(a.accuracy ?? 0));
    return userResults.first;
  }
}
