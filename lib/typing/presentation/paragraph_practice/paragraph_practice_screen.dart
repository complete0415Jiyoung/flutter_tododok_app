// lib/typing/presentation/paragraph_practice/paragraph_practice_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tododok/shared/styles/app_colors_style.dart';
import 'package:tododok/shared/styles/app_dimensions.dart';
import 'package:tododok/shared/styles/app_text_style.dart';
import '../../domain/model/sentence.dart';
import 'paragraph_practice_action.dart';
import 'paragraph_practice_state.dart';

class ParagraphPracticeScreen extends StatefulWidget {
  final ParagraphPracticeState state;
  final void Function(ParagraphPracticeAction action) onAction;

  const ParagraphPracticeScreen({
    super.key,
    required this.state,
    required this.onAction,
  });

  @override
  State<ParagraphPracticeScreen> createState() =>
      _ParagraphPracticeScreenState();
}

class _ParagraphPracticeScreenState extends State<ParagraphPracticeScreen>
    with WidgetsBindingObserver, TickerProviderStateMixin {
  late final TextEditingController _textController;
  late final FocusNode _focusNode;
  late final ScrollController _scrollController;
  late AnimationController _countdownController;
  late Animation<double> _countdownAnimation;

  int _countdownValue = 3;
  bool _showCountdown = false;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController();
    _focusNode = FocusNode();
    _scrollController = ScrollController();

    // 카운트다운 애니메이션 설정
    _countdownController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );
    _countdownAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _countdownController, curve: Curves.easeOut),
    );

    WidgetsBinding.instance.addObserver(this);
    _focusNode.addListener(_onFocusChange);

    // 위젯이 생성된 후 포커스 설정
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if ((widget.state.isStarted ?? false) &&
          !(widget.state.isPaused ?? false)) {
        _focusNode.requestFocus();
      }
    });
  }

  @override
  void didUpdateWidget(ParagraphPracticeScreen oldWidget) {
    super.didUpdateWidget(oldWidget);

    // 상태 변화에 따른 텍스트 컨트롤러 동기화
    final currentInput = widget.state.userInput ?? '';
    if (currentInput != _textController.text) {
      _textController.text = currentInput;
      _textController.selection = TextSelection.fromPosition(
        TextPosition(offset: currentInput.length),
      );
    }

    // 연습 시작 시 카운트다운 시작
    final oldStarted = oldWidget.state.isStarted ?? false;
    final newStarted = widget.state.isStarted ?? false;
    if (!oldStarted && newStarted && !_showCountdown) {
      _startCountdown();
    }

    // 연습 시작 시 포커스 설정
    if (!oldStarted && newStarted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _focusNode.requestFocus();
      });
    }
  }

  void _startCountdown() async {
    setState(() {
      _showCountdown = true;
      _countdownValue = 3;
    });

    for (int i = 3; i > 0; i--) {
      setState(() {
        _countdownValue = i;
      });

      _countdownController.reset();
      await _countdownController.forward();

      if (i > 1) {
        await Future.delayed(const Duration(milliseconds: 100));
      }
    }

    setState(() {
      _showCountdown = false;
    });

    // 카운트다운 완료 후 포커스 설정
    _focusNode.requestFocus();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    // 앱이 다시 활성화될 때 포커스 복원
    if (state == AppLifecycleState.resumed &&
        (widget.state.isStarted ?? false) &&
        !(widget.state.isPaused ?? false)) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _focusNode.requestFocus();
      });
    }
  }

  void _onFocusChange() {
    // 연습 중에 포커스를 잃으면 다시 요청
    if ((widget.state.isStarted ?? false) &&
        !(widget.state.isPaused ?? false) &&
        !_focusNode.hasFocus) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted &&
            (widget.state.isStarted ?? false) &&
            !(widget.state.isPaused ?? false)) {
          _focusNode.requestFocus();
        }
      });
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _focusNode.removeListener(_onFocusChange);
    _textController.dispose();
    _focusNode.dispose();
    _scrollController.dispose();
    _countdownController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColorsStyle.surface,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          // 진행바 (앱바 바로 하단)
          _buildProgressBar(),
          // 진행상황 표시
          _buildStatsSection(),
          // 메인 컨텐츠
          Expanded(child: _buildBody()),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: const Text('연습 모드'),
      backgroundColor: const Color(0xFF4A5568), // 다크 블루 색상
      foregroundColor: Colors.white,
      elevation: 0,
      actions: [
        _buildLanguageToggle(),
        PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert),
          onSelected: (value) {
            switch (value) {
              case 'restart':
                widget.onAction(
                  const ParagraphPracticeAction.restartPractice(),
                );
              case 'random':
                widget.onAction(
                  const ParagraphPracticeAction.selectRandomSentence(),
                );
              case 'home':
                widget.onAction(const ParagraphPracticeAction.navigateToHome());
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(value: 'restart', child: Text('다시 시작')),
            const PopupMenuItem(value: 'random', child: Text('랜덤 문장')),
            const PopupMenuItem(value: 'home', child: Text('홈으로')),
          ],
        ),
      ],
    );
  }

  Widget _buildLanguageToggle() {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      child: TextButton(
        onPressed: () {
          final currentLang = widget.state.language ?? 'ko';
          final newLanguage = currentLang == 'ko' ? 'en' : 'ko';
          widget.onAction(ParagraphPracticeAction.changeLanguage(newLanguage));
        },
        child: Text(
          (widget.state.language ?? 'ko') == 'ko' ? '한글' : 'ENG',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  // 진행바 (앱바 바로 하단)
  Widget _buildProgressBar() {
    return Container(
      height: 4,
      color: Colors.grey[300],
      child: FractionallySizedBox(
        alignment: Alignment.centerLeft,
        widthFactor: widget.state.progress,
        child: Container(
          color: const Color(0xFFE59400), // 오렌지 색상
        ),
      ),
    );
  }

  // 진행상황 표시 (속도, 정확도, 시간)
  Widget _buildStatsSection() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      color: const Color(0xFF4A5568), // 다크 블루 배경
      child: Stack(
        children: [
          // 일반 통계 표시
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildStatItem(
                _formatTime(widget.state.elapsedSeconds),
                '',
                Colors.white,
              ),
              _buildStatItem(
                '${(widget.state.typingSpeed ?? 0.0).toInt()}',
                '',
                const Color(0xFFE59400), // 오렌지 색상
              ),
              _buildStatItem(
                '${(widget.state.accuracy ?? 0.0).toInt()}%',
                '',
                Colors.white,
              ),
            ],
          ),
          // 카운트다운 오버레이
          if (_showCountdown)
            Positioned.fill(
              child: Container(
                color: const Color(0xFF4A5568).withOpacity(0.9),
                child: Center(
                  child: AnimatedBuilder(
                    animation: _countdownAnimation,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: 0.8 + (_countdownAnimation.value * 0.4),
                        child: Opacity(
                          opacity: 1.0 - (_countdownAnimation.value * 0.3),
                          child: Text(
                            _countdownValue.toString(),
                            style: const TextStyle(
                              fontSize: 48,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFE59400),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String value, String label, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        if (label.isNotEmpty)
          Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }

  // 시간을 mm:ss 형식으로 포맷
  String _formatTime(double seconds) {
    final int minutes = (seconds / 60).floor();
    final int remainingSeconds = (seconds % 60).floor();
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  Widget _buildBody() {
    if (widget.state.isCompleted == true) {
      return _buildCompletedView();
    }

    if (widget.state.isPaused == true) {
      return _buildPausedView();
    }

    return SafeArea(
      child: SingleChildScrollView(
        controller: _scrollController,
        padding: const EdgeInsets.all(AppDimensions.paddingLG),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!(widget.state.isStarted ?? false)) ...[
              _buildSentenceSelection(),
              const SizedBox(height: AppDimensions.spacing24),
              _buildCurrentSentencePreview(),
              const SizedBox(height: AppDimensions.spacing24),
              _buildStartButton(),
            ] else ...[
              _buildPracticeContent(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSentenceSelection() {
    final asyncSentences = widget.state.availableSentences;

    // AsyncValue에 when이 없을 때 대체 구현
    if (asyncSentences.hasError) {
      return Center(child: Text('문장을 불러오는데 실패했습니다: ${asyncSentences.error}'));
    }
    if (asyncSentences.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    final sentences = asyncSentences.value ?? [];
    final currentSentence = widget.state.currentSentence;

    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingLG),
      decoration: BoxDecoration(
        color: AppColorsStyle.cardBackground,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
        boxShadow: const [
          BoxShadow(
            color: AppColorsStyle.shadow,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('연습할 문장 선택', style: AppTextStyle.heading4),
              TextButton(
                onPressed: () => widget.onAction(
                  const ParagraphPracticeAction.selectRandomSentence(),
                ),
                child: const Text('랜덤 선택'),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.spacing16),
          DropdownButtonFormField<String>(
            value: currentSentence?.id,
            decoration: const InputDecoration(
              labelText: '문장',
              border: OutlineInputBorder(),
            ),
            items: sentences.map((sentence) {
              return DropdownMenuItem(
                value: sentence.id,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      sentence.content.length > 50
                          ? '${sentence.content.substring(0, 50)}...'
                          : sentence.content,
                      style: AppTextStyle.bodyMedium,
                    ),
                    Text(
                      '난이도: ${sentence.difficulty} | ${sentence.content.length}글자',
                      style: AppTextStyle.labelSmall.copyWith(
                        color: AppColorsStyle.textTertiary,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
            onChanged: (sentenceId) {
              if (sentenceId != null) {
                widget.onAction(
                  ParagraphPracticeAction.selectSentence(sentenceId),
                );
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentSentencePreview() {
    final sentence = widget.state.currentSentence;
    if (sentence == null) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppDimensions.paddingLG),
      decoration: BoxDecoration(
        color: AppColorsStyle.containerBackground,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
        border: Border.all(color: AppColorsStyle.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColorsStyle.primary,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusSM),
                ),
                child: Text(
                  '난이도 ${sentence.difficulty}',
                  style: AppTextStyle.labelSmall.copyWith(
                    color: AppColorsStyle.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.spacing12),
          Text(
            sentence.content,
            style: AppTextStyle.typingText.copyWith(fontSize: 16, height: 1.8),
          ),
          const SizedBox(height: AppDimensions.spacing12),
          Text(
            '총 ${sentence.content.length}글자 | ${sentence.wordCount}단어',
            style: AppTextStyle.labelMedium.copyWith(
              color: AppColorsStyle.textTertiary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStartButton() {
    return Center(
      child: SizedBox(
        width: 200,
        height: 50,
        child: ElevatedButton(
          onPressed: widget.state.currentSentence != null
              ? () => widget.onAction(
                  const ParagraphPracticeAction.startPractice(),
                )
              : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColorsStyle.primary,
            foregroundColor: AppColorsStyle.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
            ),
          ),
          child: const Text(
            '연습 시작',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  Widget _buildPracticeContent() {
    final sentence = widget.state.currentSentence;
    if (sentence == null) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 현재 입력해야 하는 타자 영역
        _buildTypingArea(),
        const SizedBox(height: AppDimensions.spacing24),
        // 입력창 (타자 영역 바로 아래)
        _buildInputField(),
        const SizedBox(height: AppDimensions.spacing12),
        Text(
          '입력된 글자: ${(widget.state.userInput ?? '').length} / ${widget.state.totalSentenceLength}',
          style: AppTextStyle.labelMedium.copyWith(
            color: AppColorsStyle.textSecondary,
          ),
        ),
      ],
    );
  }

  // State에서 미리 분할된 데이터를 사용하여 타자 영역 표시
  Widget _buildTypingArea() {
    final currentLineText = widget.state.currentLineText;
    final nextLineText = widget.state.nextLineText;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppDimensions.paddingLG),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 현재 입력할 줄 (강조)
          if (currentLineText.isNotEmpty) ...[
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFE59400), width: 2),
              ),
              child: _buildHighlightedCurrentLine(),
            ),
            const SizedBox(height: 16),
          ],

          // 다음 줄 미리보기
          const Text('Next', style: AppTextStyle.labelMedium),
          Text(
            nextLineText,
            style: AppTextStyle.bodySmall.copyWith(color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  // 현재 줄의 하이라이트 표시 (State 데이터 활용)
  Widget _buildHighlightedCurrentLine() {
    final userInput = widget.state.userInput ?? '';
    final currentLineText = widget.state.currentLineText;
    final currentLineStartPosition = widget.state.currentLineStartPosition;
    final currentLinePosition = widget.state.currentLinePosition;

    final List<TextSpan> spans = [];

    for (int i = 0; i < currentLineText.length; i++) {
      final globalIndex = currentLineStartPosition + i;
      Color textColor;
      Color? backgroundColor;

      if (i < currentLinePosition && globalIndex < userInput.length) {
        // 사용자가 입력한 부분
        if (userInput[globalIndex] == currentLineText[i]) {
          // 올바른 입력 - 파란색
          textColor = Colors.blue;
        } else {
          // 틀린 입력 - 빨간색
          textColor = Colors.red;
          backgroundColor = Colors.red.withOpacity(0.2);
        }
      } else if (i == currentLinePosition) {
        // 현재 입력해야 할 글자
        textColor = Colors.black;
        backgroundColor = Colors.orange.withOpacity(0.4);
      } else {
        // 아직 입력하지 않은 부분 - 검정색
        textColor = Colors.black;
      }

      spans.add(
        TextSpan(
          text: currentLineText[i],
          style: TextStyle(
            color: textColor,
            backgroundColor: backgroundColor,
            fontSize: 20,
            height: 1.5,
            fontWeight: FontWeight.w500,
          ),
        ),
      );
    }

    return RichText(text: TextSpan(children: spans));
  }

  // 입력창
  Widget _buildInputField() {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingLG),
      decoration: BoxDecoration(
        color: const Color(0xFF4A5568), // 다크 블루
        borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
      ),
      child: TextField(
        controller: _textController,
        focusNode: _focusNode,
        onChanged: (value) {
          widget.onAction(ParagraphPracticeAction.updateInput(value));

          // 입력 완료 체크
          final sentence = widget.state.currentSentence;
          if (sentence != null && value.length >= sentence.content.length) {
            widget.onAction(const ParagraphPracticeAction.completePractice());
          }
        },
        decoration: const InputDecoration(
          border: InputBorder.none,
          hintText: '여기에 입력하세요...',
          hintStyle: TextStyle(color: Colors.grey),
        ),
        style: const TextStyle(fontSize: 16, color: Colors.white),
        maxLines: 2,
        autofocus: true,
        textInputAction: TextInputAction.done,
      ),
    );
  }

  Widget _buildPausedView() {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(AppDimensions.paddingXL),
        margin: const EdgeInsets.all(AppDimensions.paddingLG),
        decoration: BoxDecoration(
          color: AppColorsStyle.cardBackground,
          borderRadius: BorderRadius.circular(AppDimensions.radiusXL),
          boxShadow: const [
            BoxShadow(
              color: AppColorsStyle.shadow,
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.pause_circle,
              size: 64,
              color: AppColorsStyle.primary,
            ),
            const SizedBox(height: AppDimensions.spacing16),
            const Text('연습 일시정지', style: AppTextStyle.heading3),
            const SizedBox(height: AppDimensions.spacing24),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                ElevatedButton(
                  onPressed: () => widget.onAction(
                    const ParagraphPracticeAction.resumePractice(),
                  ),
                  child: const Text('계속하기'),
                ),
                const SizedBox(width: AppDimensions.spacing16),
                OutlinedButton(
                  onPressed: () => widget.onAction(
                    const ParagraphPracticeAction.restartPractice(),
                  ),
                  child: const Text('다시 시작'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompletedView() {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(AppDimensions.paddingXL),
        margin: const EdgeInsets.all(AppDimensions.paddingLG),
        decoration: BoxDecoration(
          color: AppColorsStyle.cardBackground,
          borderRadius: BorderRadius.circular(AppDimensions.radiusXL),
          boxShadow: const [
            BoxShadow(
              color: AppColorsStyle.shadow,
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.check_circle,
              size: 64,
              color: AppColorsStyle.success,
            ),
            const SizedBox(height: AppDimensions.spacing16),
            const Text('연습 완료!', style: AppTextStyle.heading3),
            const SizedBox(height: AppDimensions.spacing24),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                ElevatedButton(
                  onPressed: () => widget.onAction(
                    const ParagraphPracticeAction.navigateToResult(),
                  ),
                  child: const Text('결과 보기'),
                ),
                const SizedBox(width: AppDimensions.spacing16),
                OutlinedButton(
                  onPressed: () => widget.onAction(
                    const ParagraphPracticeAction.restartPractice(),
                  ),
                  child: const Text('다시 시작'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
