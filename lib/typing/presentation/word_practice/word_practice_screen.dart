// lib/typing/presentation/word_practice/word_practice_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../shared/styles/app_colors_style.dart';
import '../../../shared/styles/app_text_style.dart';
import '../../../shared/styles/app_dimensions.dart';
import 'word_practice_state.dart';
import 'word_practice_action.dart';

class WordPracticeScreen extends StatefulWidget {
  final WordPracticeState state;
  final void Function(WordPracticeAction action) onAction;

  const WordPracticeScreen({
    super.key,
    required this.state,
    required this.onAction,
  });

  @override
  State<WordPracticeScreen> createState() => _WordPracticeScreenState();
}

class _WordPracticeScreenState extends State<WordPracticeScreen>
    with TickerProviderStateMixin {
  final TextEditingController _textController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final ScrollController _scrollController = ScrollController();

  // 애니메이션 컨트롤러들
  late AnimationController _slideAnimationController;
  late AnimationController _completionAnimationController;
  late AnimationController _countdownAnimationController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<Color?> _colorAnimation;
  late Animation<double> _countdownScaleAnimation;

  // 자동 시작 타이머
  Timer? _autoStartTimer;
  int _countdownSeconds = 3;
  bool _isCountingDown = false;
  bool _hasStartedCountdown = false;

  @override
  void initState() {
    super.initState();

    // 애니메이션 컨트롤러 초기화
    _slideAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _completionAnimationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _countdownAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _slideAnimation =
        Tween<Offset>(begin: Offset.zero, end: const Offset(-1.0, 0.0)).animate(
          CurvedAnimation(
            parent: _slideAnimationController,
            curve: Curves.easeInOut,
          ),
        );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(
        parent: _completionAnimationController,
        curve: Curves.elasticOut,
      ),
    );

    _colorAnimation = ColorTween(
      begin: AppColorsStyle.surface,
      end: Colors.green.withOpacity(0.2),
    ).animate(_completionAnimationController);

    _countdownScaleAnimation = Tween<double>(begin: 0.5, end: 1.2).animate(
      CurvedAnimation(
        parent: _countdownAnimationController,
        curve: Curves.elasticOut,
      ),
    );

    // 포커스 노드에 리스너 추가 (포커스 변화 감지)
    _focusNode.addListener(_onFocusChanged);
  }

  void _onFocusChanged() {
    // 게임 중에 포커스를 잃으면 다시 요청
    if (widget.state.isGameRunning && !_focusNode.hasFocus) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && widget.state.isGameRunning) {
          _focusNode.requestFocus();
        }
      });
    }
  }

  @override
  void didUpdateWidget(WordPracticeScreen oldWidget) {
    super.didUpdateWidget(oldWidget);

    // 단어가 로드되었고 아직 카운트다운을 시작하지 않았으면 시작
    if (!_hasStartedCountdown &&
        widget.state.wordSequence.isNotEmpty &&
        !widget.state.isGameRunning &&
        !widget.state.isGameOver) {
      _hasStartedCountdown = true;
      _startAutoCountdown();
    }

    // 게임이 시작되었을 때 포커스 설정
    if (oldWidget.state.isGameRunning != widget.state.isGameRunning &&
        widget.state.isGameRunning) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _focusNode.requestFocus();
        }
      });
    }

    // 현재 단어가 변경되었을 때 해당 위치로 스크롤
    if (oldWidget.state.currentWordIndex != widget.state.currentWordIndex) {
      _scrollToCurrentWord();
    }

    if (oldWidget.state.currentWordInputStatus != WordInputStatus.complete &&
        widget.state.currentWordInputStatus == WordInputStatus.complete) {
      _onWordCompleted();
    }
    if (oldWidget.state.isGameOver != widget.state.isGameOver &&
        widget.state.isGameOver) {
      // 잠시 대기 후 결과 화면으로 자동 이동
      Future.delayed(const Duration(milliseconds: 1000), () {
        if (mounted) {
          widget.onAction(const WordPracticeAction.navigateToResult());
        }
      });
    }

    // 입력이 초기화되었을 때 텍스트 컨트롤러도 초기화
    if (widget.state.currentWordInput.isEmpty &&
        _textController.text.isNotEmpty) {
      _textController.clear();
    }

    // 게임이 실행 중일 때 포커스 유지
    if (widget.state.isGameRunning && !_focusNode.hasFocus) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _focusNode.requestFocus();
      });
    }

    // 게임이 재시작된 후 포커스 설정 (추가)
    if (oldWidget.state.isGameRunning == true &&
        widget.state.isGameRunning == false &&
        !widget.state.isGameOver) {
      // 게임이 중지되었지만 게임오버가 아닌 경우 (재시작 상황)
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && !_focusNode.hasFocus) {
          _focusNode.requestFocus();
        }
      });
    }

    // 카운트다운이 끝나고 게임이 시작될 때 포커스 설정 강화
    if (oldWidget.state.isGameRunning != widget.state.isGameRunning &&
        widget.state.isGameRunning) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          // 기존 포커스 해제 후 다시 설정
          _focusNode.unfocus();
          Future.delayed(const Duration(milliseconds: 100), () {
            if (mounted) {
              _focusNode.requestFocus();
            }
          });
        }
      });
    }

    // 입력 필드가 활성화될 때마다 포커스 확인 (추가)
    if (widget.state.isGameRunning &&
        !widget.state.isPaused &&
        !widget.state.isGameOver) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && !_focusNode.hasFocus) {
          _focusNode.requestFocus();
        }
      });
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    _focusNode.removeListener(_onFocusChanged); // 리스너 제거
    _focusNode.dispose();
    _scrollController.dispose();
    _slideAnimationController.dispose();
    _completionAnimationController.dispose();
    _countdownAnimationController.dispose();
    _autoStartTimer?.cancel();
    super.dispose();
  }

  void _onTextChanged(String value) {
    widget.onAction(WordPracticeAction.updateInput(value));
  }

  void _startAutoCountdown() {
    if (_isCountingDown) return;

    _isCountingDown = true;
    _countdownSeconds = 3;

    _autoStartTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _countdownAnimationController.forward().then((_) {
        _countdownAnimationController.reset();
      });

      setState(() {
        _countdownSeconds--;
      });

      if (_countdownSeconds <= 0) {
        timer.cancel();
        _isCountingDown = false;
        // 게임 시작
        widget.onAction(const WordPracticeAction.startGame());

        // 게임 시작 후 입력창에 포커스 설정
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            _focusNode.requestFocus();
          }
        });
      }
    });
  }

  void _cancelAutoCountdown() {
    _autoStartTimer?.cancel();
    _autoStartTimer = null;
    if (mounted) {
      setState(() {
        _isCountingDown = false;
        _countdownSeconds = 3;
      });
    }
  }

  Future<void> _scrollToCurrentWord() async {
    if (!_scrollController.hasClients) return;

    // 키보드 상태 확인
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    final isKeyboardVisible = keyboardHeight > 0;

    // 현재 단어의 인덱스 계산 (완료된 단어 + 현재 단어)
    final currentIndex = widget.state.completedWords.length;

    // 각 카드의 실제 너비 (카드 너비 + 좌우 마진)
    const cardWidth = 200.0; // 카드 너비
    const cardMargin = 16.0; // 좌우 마진 (8 * 2)
    const totalCardWidth = cardWidth + cardMargin; // 실제 카드 간격

    // 목표 스크롤 위치 계산
    final screenWidth = MediaQuery.of(context).size.width;
    // 화면 중앙에 현재 카드가 오도록 계산
    final centerOffset = screenWidth * 0.5;
    final targetPosition =
        (currentIndex * totalCardWidth) - centerOffset + (cardWidth * 0.5);

    // 스크롤 범위 내에서 조정
    final maxScroll = _scrollController.position.maxScrollExtent;
    final minScroll = 0.0;
    final adjustedPosition = targetPosition.clamp(minScroll, maxScroll);

    await _scrollController.animateTo(
      adjustedPosition,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  Future<void> _onWordCompleted() async {
    // 완성 애니메이션 실행
    await _completionAnimationController.forward();

    // 잠시 대기 (사용자가 완성을 인지할 시간)
    await Future.delayed(const Duration(milliseconds: 500));

    // 단어 제출 액션 호출
    widget.onAction(const WordPracticeAction.submitCurrentWord());

    // 다음 단어로 스크롤 (submitCurrentWord 후에)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToCurrentWord();
    });

    // 애니메이션 리셋
    _completionAnimationController.reset();

    // 텍스트 입력 필드 초기화 및 포커스
    _textController.clear();
    _focusNode.requestFocus();
  }

  void _onSubmit() {
    if (widget.state.currentWord != null &&
        _textController.text.trim().isNotEmpty) {
      // 올바른 입력인 경우 - 자동으로 이미 처리됨 (didUpdateWidget에서)
      if (widget.state.currentWordInputStatus == WordInputStatus.complete) {
        // 이미 자동으로 처리되므로 아무것도 하지 않음
        return;
      }

      // 틀린 입력이거나 완료되지 않은 경우 - 수동으로 제출
      _onWordCompleted();
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      // 뒤로가기 처리 개선: 카운트다운 중이거나 게임 중일 때만 확인
      canPop: !_isCountingDown && !widget.state.isGameRunning,
      onPopInvoked: (didPop) async {
        if (didPop) return;

        // 카운트다운 중이면 취소하고 뒤로가기 허용
        if (_isCountingDown) {
          _cancelAutoCountdown();
          if (context.mounted) {
            Navigator.of(context).pop();
          }
          return;
        }

        // 게임 중이면 확인 다이얼로그 표시
        if (widget.state.isGameRunning) {
          final shouldExit = await _showExitDialog(context);
          if (shouldExit && context.mounted) {
            widget.onAction(const WordPracticeAction.endGame());
            Navigator.of(context).pop();
          }
        }
      },
      child: Scaffold(
        backgroundColor: AppColorsStyle.background,
        appBar: _buildAppBar(),
        resizeToAvoidBottomInset: true,
        body: SafeArea(
          child: Stack(
            children: [
              // 메인 게임 화면
              Column(
                children: [
                  _buildProgressBar(),
                  _buildStatsRow(),
                  const SizedBox(height: AppDimensions.paddingMD),
                  Expanded(child: _buildCarouselGameArea()),
                  const SizedBox(height: AppDimensions.paddingMD),
                ],
              ),

              // 카운트다운 오버레이
              if (_isCountingDown) _buildCountdownOverlay(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCountdownOverlay() {
    return Container(
      color: Colors.black.withOpacity(0.8),
      child: Center(
        child: AnimatedBuilder(
          animation: _countdownAnimationController,
          builder: (context, child) {
            return Transform.scale(
              scale: _countdownScaleAnimation.value,
              child: Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColorsStyle.primary.withOpacity(0.9),
                      AppColorsStyle.primary.withOpacity(0.7),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: AppColorsStyle.primary.withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '게임 시작!',
                      style: AppTextStyle.heading3.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      '$_countdownSeconds',
                      style: AppTextStyle.heading1.copyWith(
                        color: Colors.white,
                        fontSize: 72,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: 120,
                      child: LinearProgressIndicator(
                        value: (4 - _countdownSeconds) / 3,
                        backgroundColor: Colors.white.withOpacity(0.3),
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          Colors.white,
                        ),
                        minHeight: 4,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: _cancelAutoCountdown,
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 8,
                        ),
                      ),
                      child: const Text('취소'),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppColorsStyle.surface,
      elevation: 0,
      title: Text(
        '단어 연습',
        style: AppTextStyle.heading4.copyWith(color: AppColorsStyle.onSurface),
      ),
      actions: [
        PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert),
          onSelected: (value) {
            switch (value) {
              case 'restart':
                widget.onAction(const WordPracticeAction.restartGame());
                break;
              case 'home':
                widget.onAction(const WordPracticeAction.navigateToHome());
                break;
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'restart',
              child: Row(
                children: [
                  Icon(Icons.refresh),
                  SizedBox(width: 8),
                  Text('다시 시작'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'home',
              child: Row(
                children: [Icon(Icons.home), SizedBox(width: 8), Text('홈으로')],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildProgressBar() {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingMD),
      child: LinearProgressIndicator(
        value: widget.state.progress,
        backgroundColor: AppColorsStyle.surfaceVariant,
        valueColor: const AlwaysStoppedAnimation<Color>(AppColorsStyle.primary),
      ),
    );
  }

  Widget _buildStatsRow() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingMD),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildStatItem('WPM', widget.state.wpm.toStringAsFixed(1)),
          _buildStatItem('정확도', '${widget.state.accuracy.toStringAsFixed(1)}%'),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: AppTextStyle.numberMedium.copyWith(
            color: AppColorsStyle.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: AppTextStyle.bodySmall.copyWith(
            color: AppColorsStyle.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildCarouselGameArea() {
    if (widget.state.wordSequence.isEmpty) {
      return _buildLoadingOrEmpty();
    }

    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingMD),
      child: Column(
        children: [
          Expanded(child: _buildWordCarousel()),
          if (!widget.state.isGameOver) _buildInputArea(),
        ],
      ),
    );
  }

  Widget _buildWordCarousel() {
    final allWords = [
      ...widget.state.completedWords.map(
        (w) => {'word': w, 'status': 'completed'},
      ),
      if (widget.state.currentWord != null)
        {'word': widget.state.currentWord!, 'status': 'current'},
      ...widget.state.remainingWords.map(
        (w) => {'word': w, 'status': 'upcoming'},
      ),
    ];

    return AnimatedBuilder(
      animation: _completionAnimationController,
      builder: (context, child) {
        return SingleChildScrollView(
          controller: _scrollController,
          scrollDirection: Axis.horizontal,
          physics: widget.state.isGameOver
              ? const ClampingScrollPhysics() // 게임 종료 시 사용자 스크롤 허용
              : const NeverScrollableScrollPhysics(), // 게임 중에는 프로그래밍적 스크롤만
          child: Row(
            children: allWords.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              final word = item['word'] as dynamic;
              final status = item['status'] as String;

              return _buildWordCard(word, status, index);
            }).toList(),
          ),
        );
      },
    );
  }

  Widget _buildWordCard(dynamic word, String status, int index) {
    Color cardColor;
    Color textColor;
    Color borderColor;
    IconData? icon;

    switch (status) {
      case 'completed':
        cardColor = Colors.green.withOpacity(0.1);
        textColor = Colors.green;
        borderColor = Colors.green.withOpacity(0.3);
        icon = Icons.check_circle;
        break;
      case 'current':
        cardColor = AppColorsStyle.primary.withOpacity(0.1);
        textColor = AppColorsStyle.primary;
        borderColor = AppColorsStyle.primary;
        icon = null;
        break;
      case 'upcoming':
        cardColor = AppColorsStyle.surfaceVariant.withOpacity(0.5);
        textColor = AppColorsStyle.onSurfaceVariant;
        borderColor = AppColorsStyle.onSurfaceVariant.withOpacity(0.2);
        icon = null;
        break;
      default:
        cardColor = AppColorsStyle.surface;
        textColor = AppColorsStyle.onSurface;
        borderColor = Colors.grey;
        icon = null;
    }

    // 현재 단어일 때 완성 애니메이션 적용
    final isCurrentWord = status == 'current';
    final animationValue = isCurrentWord
        ? _completionAnimationController.value
        : 0.0;
    final scale = isCurrentWord ? 1.0 + (animationValue * 0.1) : 1.0;

    return Transform.scale(
      scale: scale,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: 200, // 고정 너비로 스크롤 계산 정확도 향상
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
        padding: EdgeInsets.symmetric(
          horizontal: 16,
          vertical: status == 'current' ? 20 : 16,
        ),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: borderColor,
            width: status == 'current' ? 3 : 1,
          ),
          boxShadow: status == 'current'
              ? [
                  BoxShadow(
                    color: AppColorsStyle.primary.withOpacity(0.2),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(icon, color: textColor, size: 20),
              const SizedBox(height: 4),
            ],

            // 현재 단어일 때 글자별 색상 표시, 아닐 때는 일반 텍스트
            if (status == 'current')
              _buildColoredWordText(word.text, widget.state.currentWordInput)
            else
              Text(
                word.text,
                textAlign: TextAlign.center,
                style: AppTextStyle.bodyLarge.copyWith(
                  color: textColor,
                  fontWeight: status == 'current'
                      ? FontWeight.bold
                      : FontWeight.w500,
                  fontSize: status == 'current' ? 20 : 16,
                ),
              ),

            if (status == 'current') ...[
              const SizedBox(height: 6),

              if (widget.state.currentWordInput.isNotEmpty) ...[
                const SizedBox(height: 8),
                _buildInputProgress(word.text, widget.state.currentWordInput),
                const SizedBox(height: 6),
                _buildMiniInputProgress(
                  word.text,
                  widget.state.currentWordInput,
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }

  // 글자별 색상을 적용한 단어 텍스트 위젯
  Widget _buildColoredWordText(String targetWord, String userInput) {
    List<TextSpan> spans = [];

    for (int i = 0; i < targetWord.length; i++) {
      Color charColor;
      FontWeight fontWeight = FontWeight.bold;

      if (i < userInput.length) {
        // 사용자가 입력한 부분
        if (targetWord[i].toLowerCase() == userInput[i].toLowerCase()) {
          // 올바른 글자 - 초록색
          charColor = Colors.green;
        } else {
          // 틀린 글자 - 빨간색
          charColor = Colors.red;
        }
      } else {
        // 아직 입력하지 않은 부분 - 기본 색상
        charColor = AppColorsStyle.primary;
        fontWeight = FontWeight.w500;
      }

      spans.add(
        TextSpan(
          text: targetWord[i],
          style: TextStyle(
            color: charColor,
            fontWeight: fontWeight,
            fontSize: 20,
          ),
        ),
      );
    }

    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(children: spans, style: AppTextStyle.bodyLarge),
    );
  }

  Widget _buildInputProgress(String targetWord, String userInput) {
    // 입력 진행률 표시 제거 - 빈 위젯 반환
    return const SizedBox.shrink();
  }

  Widget _buildMiniInputProgress(String targetWord, String userInput) {
    // 점으로 된 진행률 표시 제거 - 빈 위젯 반환
    return const SizedBox.shrink();
  }

  Widget _buildLoadingOrEmpty() {
    return Center(
      child: widget.state.availableSentences.when(
        data: (_) => Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(
              width: 40,
              height: 40,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                valueColor: AlwaysStoppedAnimation<Color>(
                  AppColorsStyle.primary,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              '단어를 준비하고 있습니다...',
              style: AppTextStyle.bodyMedium.copyWith(
                color: AppColorsStyle.onSurfaceVariant,
              ),
            ),
          ],
        ),
        loading: () => Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(
              width: 40,
              height: 40,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                valueColor: AlwaysStoppedAnimation<Color>(
                  AppColorsStyle.primary,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              '단어를 불러오고 있습니다...',
              style: AppTextStyle.bodyMedium.copyWith(
                color: AppColorsStyle.onSurfaceVariant,
              ),
            ),
          ],
        ),
        error: (error, _) => Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text('오류가 발생했습니다: $error'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => widget.onAction(
                WordPracticeAction.initialize(widget.state.language),
              ),
              child: const Text('다시 시도'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _textController,
            obscureText: false,
            focusNode: _focusNode,
            enabled: widget.state.isGameRunning,
            autofocus: true, // 자동 포커스 활성화
            keyboardType: TextInputType.text,
            textInputAction: TextInputAction.done,
            keyboardAppearance: Brightness.light,
            decoration: InputDecoration(
              hintText:
                  widget.state.currentWordInputStatus == WordInputStatus.error
                  ? '틀렸습니다! 엔터를 눌러 다음 단어로 넘어가세요'
                  : '단어를 입력하세요',
              hintStyle: TextStyle(
                color:
                    widget.state.currentWordInputStatus == WordInputStatus.error
                    ? Colors.red.withOpacity(0.7)
                    : AppColorsStyle.onSurfaceVariant.withOpacity(0.7),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: _getCurrentWordBorderColor(),
                  width: 2,
                ),
              ),
              suffixIcon: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (widget.state.currentWordInputStatus ==
                      WordInputStatus.complete)
                    const Icon(Icons.check_circle, color: Colors.green)
                  else if (widget.state.currentWordInputStatus ==
                      WordInputStatus.error) ...[
                    const Icon(Icons.error, color: Colors.red),
                    const SizedBox(width: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                    ),
                  ],
                  const Padding(
                    padding: EdgeInsets.only(right: 8),
                    child: Icon(
                      Icons.keyboard_return,
                      color: Colors.grey,
                      size: 20,
                    ),
                  ),
                ],
              ),
            ),
            onChanged: _onTextChanged,
            onSubmitted: (_) => _onSubmit(),

            // 키보드가 자동으로 올라오도록 보장
            onTap: () {
              if (!_focusNode.hasFocus) {
                _focusNode.requestFocus();
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildControlButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingMD),
      child: Row(
        children: [
          if (widget.state.isGameOver) ...[
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => widget.onAction(
                  const WordPracticeAction.navigateToResult(),
                ),
                icon: const Icon(Icons.assessment),
                label: const Text('결과 보기'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () =>
                    widget.onAction(const WordPracticeAction.restartGame()),
                icon: const Icon(Icons.refresh),
                label: const Text('다시'),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Future<bool> _showExitDialog(BuildContext context) async {
    return await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: const Row(
                children: [
                  Icon(
                    Icons.warning_amber_rounded,
                    color: Colors.orange,
                    size: 28,
                  ),
                  SizedBox(width: 8),
                  Text('게임 종료'),
                ],
              ),
              content: const Text(
                '게임이 진행 중입니다.\n정말로 나가시겠습니까?\n\n현재 점수와 진행 상황이 저장되지 않습니다.',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text(
                    '계속하기',
                    style: TextStyle(color: AppColorsStyle.primary),
                  ),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('나가기'),
                ),
              ],
            );
          },
        ) ??
        false;
  }

  Color _getCurrentWordBorderColor() {
    switch (widget.state.currentWordInputStatus) {
      case WordInputStatus.typing:
        return AppColorsStyle.primary;
      case WordInputStatus.complete:
        return Colors.green;
      case WordInputStatus.error:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Color _getWordChipColor(WordStatus status) {
    switch (status) {
      case WordStatus.correct:
        return Colors.green;
      case WordStatus.incorrect:
        return Colors.red;
      case WordStatus.skipped:
        return Colors.orange;
      default:
        return AppColorsStyle.onSurfaceVariant;
    }
  }
}
