// lib/typing/presentation/word_practice/word_practice_screen.dart
// 기본 버전 (캐러셀 없음)

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:tododok/typing/presentation/word_practice/word_practice_action.dart';
import 'package:tododok/typing/presentation/word_practice/word_practice_state.dart';
import 'word_practice_state.dart';
import 'word_practice_action.dart';
import 'widgets/real_time_stats_widget.dart';
import 'widgets/simple_progress_bar_widget.dart';

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

  // 카운트다운 관련
  Timer? _countdownTimer;
  int _countdownSeconds = 3;
  bool _isCountingDown = false;
  late AnimationController _countdownAnimationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    // 카운트다운 애니메이션 컨트롤러 초기화
    _countdownAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.2).animate(
      CurvedAnimation(
        parent: _countdownAnimationController,
        curve: Curves.elasticOut,
      ),
    );

    // 페이지 진입 후 바로 카운트다운 시작
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!widget.state.isGameRunning && !widget.state.isGameOver) {
        _startCountdown();
      }
    });
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _countdownAnimationController.dispose();
    super.dispose();
  }

  void _startCountdown() {
    if (_isCountingDown) return;

    setState(() {
      _isCountingDown = true;
      _countdownSeconds = 3;
    });

    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      // 애니메이션 실행
      _countdownAnimationController.forward().then((_) {
        _countdownAnimationController.reset();
      });

      setState(() {
        _countdownSeconds--;
      });

      if (_countdownSeconds <= 0) {
        timer.cancel();
        setState(() {
          _isCountingDown = false;
        });

        // 게임 시작
        widget.onAction(const WordPracticeAction.startGame());

        // 입력 필드에 포커스
        Future.delayed(const Duration(milliseconds: 100), () {
          if (mounted) {
            _focusNode.requestFocus();
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('단어 연습'),
        actions: [
          if (widget.state.isGameRunning)
            IconButton(
              icon: Icon(
                widget.state.isPaused ? Icons.play_arrow : Icons.pause,
              ),
              onPressed: () {
                if (widget.state.isPaused) {
                  widget.onAction(const WordPracticeAction.resumeGame());
                } else {
                  widget.onAction(const WordPracticeAction.pauseGame());
                }
              },
            ),
          // 항상 표시되는 restart 아이콘
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              widget.onAction(const WordPracticeAction.restartGame());
              // 재시작 시 다시 카운트다운
              Future.delayed(const Duration(milliseconds: 100), () {
                if (mounted) {
                  _startCountdown();
                }
              });
            },
          ),
        ],
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      body: Column(
        children: [
          // 앱바 바로 아래에 진행바 배치 (카운트다운 중에도 표시)
          if (widget.state.isGameRunning ||
              widget.state.isGameOver ||
              _isCountingDown)
            SimpleProgressBarWidget(state: widget.state),

          // 나머지 컨텐츠
          Expanded(
            child: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    // 실시간 통계 표시 (카운트다운 중에도 표시하되, 카운트다운 상태 전달)
                    if (widget.state.isGameRunning ||
                        widget.state.isGameOver ||
                        _isCountingDown)
                      RealTimeStatsWidget(
                        state: widget.state,
                        isCountingDown: _isCountingDown,
                      ),

                    const SizedBox(height: 24),

                    // 카운트다운 또는 현재 단어 표시
                    if (_isCountingDown)
                      _buildCountdownDisplay()
                    else if (widget.state.currentWord != null)
                      _buildCurrentWordDisplay(),

                    const SizedBox(height: 24),

                    // 입력 필드 (게임 중이고 카운트다운 중이 아닐 때만)
                    if (widget.state.isGameRunning &&
                        !widget.state.isPaused &&
                        !_isCountingDown)
                      _buildInputField(),

                    const SizedBox(height: 16),

                    // 게임 제어 버튼 제거됨 (앱바의 restart로 대체)
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentWordDisplay() {
    final currentWord = widget.state.currentWord!.text;
    final userInput = widget.state.currentWordInput;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(
            '현재 단어',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(
                context,
              ).colorScheme.onPrimaryContainer.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 12),

          // 글자별 색상 표시 (자연스러운 간격)
          RichText(
            text: TextSpan(
              children: _buildColoredWordLetters(currentWord, userInput),
            ),
          ),
        ],
      ),
    );
  }

  // 글자별로 색상을 적용한 TextSpan들 생성
  List<TextSpan> _buildColoredWordLetters(
    String currentWord,
    String userInput,
  ) {
    final spans = <TextSpan>[];

    for (int i = 0; i < currentWord.length; i++) {
      final char = currentWord[i];
      Color textColor;

      if (i < userInput.length) {
        // 사용자가 입력한 부분
        if (userInput[i] == char) {
          // 올바른 입력 - 자연스러운 검정색
          textColor = Colors.black;
        } else {
          // 잘못된 입력 (오타) - 빨간색만
          textColor = Colors.red;
        }
      } else {
        // 아직 입력하지 않은 글자 - 회색
        textColor = Colors.grey;
      }

      spans.add(
        TextSpan(
          text: char,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: textColor,
            fontSize: 28,
          ),
        ),
      );
    }

    return spans;
  }

  // 카운트다운 표시 (숫자만 깔끔하게)
  Widget _buildCountdownDisplay() {
    return Container(
      height: 200,
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Center(
        child: AnimatedBuilder(
          animation: _scaleAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Theme.of(context).colorScheme.primary,
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(
                        context,
                      ).colorScheme.primary.withOpacity(0.3),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    _countdownSeconds.toString(),
                    style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 48,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildInputField() {
    return TextField(
      controller: _textController,
      focusNode: _focusNode,
      autofocus: true,
      style: Theme.of(context).textTheme.titleLarge,
      decoration: const InputDecoration(
        hintText: '단어를 입력하세요...',
        border: OutlineInputBorder(),
      ),
      onChanged: (value) {
        widget.onAction(WordPracticeAction.updateInput(value));
      },
      onSubmitted: (value) {
        if (widget.state.currentWordInputStatus == WordInputStatus.complete) {
          widget.onAction(const WordPracticeAction.submitCurrentWord());
          _textController.clear();

          // 다음 단어로 넘어간 후 입력창에 다시 포커스
          Future.delayed(const Duration(milliseconds: 50), () {
            if (mounted) {
              _focusNode.requestFocus();
            }
          });
        }
      },
    );
  }
}
