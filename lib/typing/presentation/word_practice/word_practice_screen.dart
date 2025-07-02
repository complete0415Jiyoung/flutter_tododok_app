// lib/typing/presentation/word_practice/word_practice_screen.dart
// 기존 디자인 유지 + 강화된 포커스 기능

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
    with TickerProviderStateMixin, WidgetsBindingObserver {
  final TextEditingController _textController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  // 카운트다운 관련
  Timer? _countdownTimer;
  int _countdownSeconds = 3;
  bool _isCountingDown = false;
  late AnimationController _countdownAnimationController;
  late Animation<double> _scaleAnimation;

  // 포커스 관리용 변수들 (기존 코드에 추가)
  int _lastWordIndex = -1;
  Timer? _focusRetryTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

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

    // 초기 단어 인덱스 설정
    _lastWordIndex = widget.state.currentWordIndex;

    // 페이지 진입 후 바로 카운트다운 시작
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!widget.state.isGameRunning && !widget.state.isGameOver) {
        _startCountdown();
      }
    });
  }

  @override
  void didUpdateWidget(WordPracticeScreen oldWidget) {
    super.didUpdateWidget(oldWidget);

    // 게임 완료 감지 - 결과 화면으로 자동 이동
    // 모든 단어(targetWordCount만큼)를 완료하면 isGameOver가 true가 됨
    if (oldWidget.state.isGameOver != widget.state.isGameOver &&
        widget.state.isGameOver) {
      // 게임이 완료되면 결과 화면으로 자동 이동
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          widget.onAction(const WordPracticeAction.navigateToResult());
        }
      });
    }

    // 단어 인덱스 변경 감지 (다음 단어로 넘어갔을 때)
    if (widget.state.currentWordIndex != _lastWordIndex) {
      _lastWordIndex = widget.state.currentWordIndex;

      // 게임이 계속 진행 중이라면 포커스 요청
      if (widget.state.isGameRunning &&
          !widget.state.isPaused &&
          !widget.state.isGameOver) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _ensureFocus();
        });
      }
    }

    // 입력이 초기화되었을 때 텍스트 컨트롤러도 초기화
    if (widget.state.currentWordInput != _textController.text) {
      _textController.text = widget.state.currentWordInput;
      _textController.selection = TextSelection.fromPosition(
        TextPosition(offset: widget.state.currentWordInput.length),
      );
    }

    // 게임 상태 변경에 따른 포커스 관리
    if (widget.state.isGameRunning &&
        !widget.state.isPaused &&
        !widget.state.isGameOver &&
        !_focusNode.hasFocus &&
        !_isCountingDown) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _ensureFocus();
      });
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    // 앱이 백그라운드로 갔다가 돌아왔을 때 포커스 복구
    if (state == AppLifecycleState.resumed &&
        widget.state.isGameRunning &&
        !widget.state.isPaused &&
        !widget.state.isGameOver) {
      Future.delayed(const Duration(milliseconds: 200), () {
        _ensureFocus();
      });
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _countdownTimer?.cancel();
    _focusRetryTimer?.cancel();
    _countdownAnimationController.dispose();
    _focusNode.dispose();
    _textController.dispose();
    super.dispose();
  }

  void _ensureFocus() {
    if (mounted &&
        !_focusNode.hasFocus &&
        widget.state.isGameRunning &&
        !widget.state.isPaused &&
        !widget.state.isGameOver &&
        !_isCountingDown) {
      _focusNode.requestFocus();

      // 포커스 요청이 실패했을 경우를 대비한 재시도
      _focusRetryTimer?.cancel();
      _focusRetryTimer = Timer(const Duration(milliseconds: 100), () {
        if (mounted && !_focusNode.hasFocus) {
          _focusNode.requestFocus();
        }
      });
    }
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
        Future.delayed(const Duration(milliseconds: 200), () {
          _ensureFocus();
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
                  // 게임 재개 시 포커스 복구
                  Future.delayed(const Duration(milliseconds: 200), () {
                    _ensureFocus();
                  });
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

  Widget _buildCountdownDisplay() {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Theme.of(context).colorScheme.primary,
              boxShadow: [
                BoxShadow(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
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

  List<TextSpan> _buildColoredWordLetters(String word, String input) {
    final spans = <TextSpan>[];

    for (int i = 0; i < word.length; i++) {
      Color textColor;

      if (i < input.length) {
        // 입력된 글자 - 올바르면 검정색, 틀리면 빨간색
        textColor = input[i] == word[i] ? Colors.black : Colors.red;
      } else if (i == input.length) {
        // 현재 입력해야 할 글자 - 검정색보다 연하게
        textColor = Colors.black54;
      } else {
        // 아직 입력하지 않은 글자 - 더 연하게
        textColor = Colors.black38;
      }

      spans.add(
        TextSpan(
          text: word[i],
          style: Theme.of(context).textTheme.headlineLarge?.copyWith(
            color: textColor,
            fontWeight: FontWeight.bold,
            letterSpacing: 4.0,
          ),
        ),
      );
    }

    return spans;
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
        // 게임이 진행 중이 아니면 처리하지 않음
        if (!widget.state.isGameRunning ||
            widget.state.isPaused ||
            widget.state.isGameOver) {
          return;
        }

        // 현재 단어가 있으면 항상 제출 처리 (정답/오답 상관없이)
        if (widget.state.currentWord != null) {
          widget.onAction(const WordPracticeAction.submitCurrentWord());
          _textController.clear();

          // 햅틱 피드백
          HapticFeedback.lightImpact();

          // 다음 단어로 넘어간 후 입력창에 다시 포커스 (더 긴 지연)
          Future.delayed(const Duration(milliseconds: 200), () {
            _ensureFocus();
          });

          // 추가 재시도
          Future.delayed(const Duration(milliseconds: 400), () {
            if (mounted && !_focusNode.hasFocus && !widget.state.isGameOver) {
              _ensureFocus();
            }
          });
        }
      },
      // 포커스 관리 강화
      onTap: () {
        if (!_focusNode.hasFocus) {
          _ensureFocus();
        }
      },
      onTapOutside: (_) {
        // 입력 필드 외부를 탭해도 포커스 유지 (게임 중일 때만)
        if (widget.state.isGameRunning &&
            !widget.state.isPaused &&
            !widget.state.isGameOver) {
          _ensureFocus();
        }
      },
    );
  }
}
