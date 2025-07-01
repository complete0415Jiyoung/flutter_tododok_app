// lib/typing/presentation/paragraph_practice/paragraph_practice_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../shared/styles/app_colors_style.dart';
import '../../../shared/styles/app_text_style.dart';
import '../../../shared/styles/app_dimensions.dart';
import 'paragraph_practice_state.dart';
import 'paragraph_practice_action.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
    with WidgetsBindingObserver {
  final TextEditingController _textController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    // 포커스 리스너 추가
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void didUpdateWidget(ParagraphPracticeScreen oldWidget) {
    super.didUpdateWidget(oldWidget);

    // 입력이 초기화되었을 때 텍스트 컨트롤러도 초기화
    if (widget.state.userInput != _textController.text) {
      _textController.text = widget.state.userInput;
      _textController.selection = TextSelection.fromPosition(
        TextPosition(offset: widget.state.userInput.length),
      );
    }

    // 연습 중일 때 포커스 유지
    if (widget.state.isStarted &&
        !widget.state.isPaused &&
        !_focusNode.hasFocus) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _focusNode.requestFocus();
      });
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    // 앱이 다시 활성화될 때 포커스 복원
    if (state == AppLifecycleState.resumed &&
        widget.state.isStarted &&
        !widget.state.isPaused) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _focusNode.requestFocus();
      });
    }
  }

  void _onFocusChange() {
    // 연습 중에 포커스를 잃으면 다시 요청
    if (widget.state.isStarted &&
        !widget.state.isPaused &&
        !_focusNode.hasFocus) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && widget.state.isStarted && !widget.state.isPaused) {
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColorsStyle.surface,
      appBar: _buildAppBar(),
      body: SafeArea(child: _buildBody()),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: const Text('장문 연습'),
      actions: [
        _buildLanguageToggle(),
        if (widget.state.canPause)
          IconButton(
            icon: const Icon(Icons.pause),
            onPressed: () =>
                widget.onAction(const ParagraphPracticeAction.pausePractice()),
          ),
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
              value: 'random',
              child: Row(
                children: [
                  Icon(Icons.shuffle),
                  SizedBox(width: 8),
                  Text('랜덤 문장'),
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

  Widget _buildLanguageToggle() {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.language),
      onSelected: (language) {
        widget.onAction(ParagraphPracticeAction.changeLanguage(language));
      },
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 'ko',
          child: Row(
            children: [
              if (widget.state.language == 'ko')
                const Icon(Icons.check, color: AppColorsStyle.primary),
              const SizedBox(width: 8),
              const Text('한글'),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'en',
          child: Row(
            children: [
              if (widget.state.language == 'en')
                const Icon(Icons.check, color: AppColorsStyle.primary),
              const SizedBox(width: 8),
              const Text('English'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBody() {
    return widget.state.availableSentences.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) => _buildErrorView(error.toString()),
      data: (sentences) {
        if (widget.state.isCompleted) {
          return _buildCompletedView();
        } else if (widget.state.isPaused) {
          return _buildPausedView();
        } else if (widget.state.canStart) {
          return _buildStartView();
        } else {
          return _buildPracticeView();
        }
      },
    );
  }

  Widget _buildErrorView(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            size: 64,
            color: AppColorsStyle.error,
          ),
          const SizedBox(height: AppDimensions.spacing16),
          const Text('문장을 불러올 수 없습니다', style: AppTextStyle.heading4),
          const SizedBox(height: AppDimensions.spacing8),
          Text(
            error,
            style: AppTextStyle.bodyMedium.textSecondary,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppDimensions.spacing24),
          ElevatedButton(
            onPressed: () => widget.onAction(
              ParagraphPracticeAction.initialize(widget.state.language),
            ),
            child: const Text('다시 시도'),
          ),
        ],
      ),
    );
  }

  Widget _buildStartView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppDimensions.paddingLG),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSentenceSelector(),
          const SizedBox(height: AppDimensions.spacing24),
          _buildCurrentSentencePreview(),
          const SizedBox(height: AppDimensions.spacing32),
          _buildStartButton(),
        ],
      ),
    );
  }

  Widget _buildSentenceSelector() {
    final sentences = widget.state.availableSentences.value ?? [];
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
                      style: AppTextStyle.labelSmall.textTertiary,
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
              const Text('미리보기', style: AppTextStyle.labelLarge),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColorsStyle.primary,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusSM),
                ),
                child: Text(
                  '난이도 ${sentence.difficulty}',
                  style: AppTextStyle.labelSmall.withColor(
                    AppColorsStyle.white,
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
            style: AppTextStyle.labelMedium.textTertiary,
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
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25),
            ),
          ),
          child: const Text('연습 시작', style: AppTextStyle.buttonLarge),
        ),
      ),
    );
  }

  Widget _buildPracticeView() {
    return Column(
      children: [
        _buildStatsBar(),
        _buildProgressBar(),
        Expanded(child: _buildTypingArea()),
        _buildInputArea(),
      ],
    );
  }

  Widget _buildStatsBar() {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingMD),
      color: AppColorsStyle.containerBackground,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(
            'WPM',
            widget.state.wpm.toStringAsFixed(0),
            Icons.speed,
          ),
          _buildStatItem(
            '정확도',
            '${widget.state.accuracy.toStringAsFixed(1)}%',
            Icons.check_circle,
          ),
          _buildStatItem(
            '시간',
            _formatTime(widget.state.elapsedSeconds),
            Icons.timer,
          ),
          _buildStatItem(
            '진행률',
            '${widget.state.progressPercent.toStringAsFixed(0)}%',
            Icons.trending_up,
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: AppColorsStyle.primary, size: 20),
        const SizedBox(height: 4),
        Text(
          value,
          style: AppTextStyle.numberSmall,
          textAlign: TextAlign.center,
        ),
        Text(
          label,
          style: AppTextStyle.labelSmall.textTertiary,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildProgressBar() {
    return Container(
      height: 8,
      margin: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingLG),
      decoration: BoxDecoration(
        color: AppColorsStyle.containerBackground,
        borderRadius: BorderRadius.circular(4),
      ),
      child: LinearProgressIndicator(
        value: widget.state.progress,
        backgroundColor: Colors.transparent,
        valueColor: const AlwaysStoppedAnimation<Color>(AppColorsStyle.primary),
      ),
    );
  }

  Widget _buildTypingArea() {
    final sentence = widget.state.currentSentence;
    if (sentence == null) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppDimensions.paddingLG),
      child: SingleChildScrollView(
        controller: _scrollController,
        child: _buildHighlightedText(sentence.content),
      ),
    );
  }

  Widget _buildHighlightedText(String text) {
    final userInput = widget.state.userInput;
    final spans = <TextSpan>[];

    for (int i = 0; i < text.length; i++) {
      final char = text[i];
      Color? backgroundColor;
      Color? textColor;

      if (i < userInput.length) {
        // 이미 입력된 부분
        if (userInput[i] == char) {
          // 정확한 입력
          backgroundColor = AppColorsStyle.typingCorrect.withOpacity(0.3);
          textColor = AppColorsStyle.typingCorrect;
        } else {
          // 틀린 입력
          backgroundColor = AppColorsStyle.typingIncorrect.withOpacity(0.3);
          textColor = AppColorsStyle.typingIncorrect;
        }
      } else if (i == userInput.length) {
        // 현재 입력해야 할 위치
        backgroundColor = AppColorsStyle.typingCurrent.withOpacity(0.5);
        textColor = AppColorsStyle.typingCurrent;
      } else {
        // 아직 입력하지 않은 부분
        textColor = AppColorsStyle.typingPending;
      }

      spans.add(
        TextSpan(
          text: char,
          style: AppTextStyle.typingText.copyWith(
            color: textColor,
            backgroundColor: backgroundColor,
            fontSize: 18,
            height: 1.8,
          ),
        ),
      );
    }

    return RichText(
      text: TextSpan(children: spans),
      textAlign: TextAlign.left,
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingLG),
      color: AppColorsStyle.cardBackground,
      child: Column(
        children: [
          TextField(
            controller: _textController,
            focusNode: _focusNode,
            onChanged: (value) {
              widget.onAction(ParagraphPracticeAction.updateInput(value));
            },
            decoration: InputDecoration(
              hintText: '여기에 위 문장을 입력하세요...',
              filled: true,
              fillColor: AppColorsStyle.containerBackground,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
                borderSide: const BorderSide(
                  color: AppColorsStyle.primary,
                  width: 2,
                ),
              ),
            ),
            style: AppTextStyle.typingText.copyWith(fontSize: 16),
            maxLines: 3,
            autofocus: true,
            textInputAction: TextInputAction.done,
          ),
          const SizedBox(height: AppDimensions.spacing12),
          Text(
            '입력된 글자: ${widget.state.userInput.length} / ${widget.state.totalSentenceLength}',
            style: AppTextStyle.labelMedium.textSecondary,
          ),
        ],
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
            _buildFinalStats(),
            const SizedBox(height: AppDimensions.spacing24),
            _buildCompletedActions(),
          ],
        ),
      ),
    );
  }

  Widget _buildFinalStats() {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingLG),
      decoration: BoxDecoration(
        color: AppColorsStyle.containerBackground,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
      ),
      child: Column(
        children: [
          const Text('최종 결과', style: AppTextStyle.heading4),
          const SizedBox(height: AppDimensions.spacing16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildFinalStatItem('WPM', widget.state.wpm.toStringAsFixed(1)),
              _buildFinalStatItem(
                '정확도',
                '${widget.state.accuracy.toStringAsFixed(1)}%',
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.spacing12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildFinalStatItem(
                '시간',
                _formatTime(widget.state.elapsedSeconds),
              ),
              _buildFinalStatItem('레벨', widget.state.typingLevel),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFinalStatItem(String label, String value) {
    return Column(
      children: [
        Text(value, style: AppTextStyle.numberMedium),
        Text(label, style: AppTextStyle.labelMedium.textSecondary),
      ],
    );
  }

  Widget _buildCompletedActions() {
    return Wrap(
      spacing: AppDimensions.spacing12,
      runSpacing: AppDimensions.spacing8,
      children: [
        ElevatedButton(
          onPressed: () => widget.onAction(
            const ParagraphPracticeAction.practiceAnotherSentence(),
          ),
          child: const Text('다른 문장 연습'),
        ),
        OutlinedButton(
          onPressed: () =>
              widget.onAction(const ParagraphPracticeAction.createChallenge()),
          child: const Text('도전장 만들기'),
        ),
        TextButton(
          onPressed: () =>
              widget.onAction(const ParagraphPracticeAction.navigateToHome()),
          child: const Text('홈으로'),
        ),
      ],
    );
  }

  String _formatTime(double seconds) {
    final minutes = (seconds / 60).floor();
    final remainingSeconds = (seconds % 60).floor();
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }
}
