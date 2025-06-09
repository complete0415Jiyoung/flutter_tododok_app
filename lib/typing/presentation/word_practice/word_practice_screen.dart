// lib/typing/presentation/word_practice/word_practice_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
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
    with TickerProviderStateMixin, WidgetsBindingObserver {
  final TextEditingController _textController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _focusNode.requestFocus();

    // 포커스 유지를 위한 리스너 추가
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void didUpdateWidget(WordPracticeScreen oldWidget) {
    super.didUpdateWidget(oldWidget);

    // 입력이 초기화되었을 때 텍스트 컨트롤러도 초기화
    if (widget.state.userInput.isEmpty && _textController.text.isNotEmpty) {
      _textController.clear();
    }

    // 게임이 실행 중일 때 포커스 유지
    if (widget.state.isGameRunning && !_focusNode.hasFocus) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _focusNode.requestFocus();
      });
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    // 앱이 다시 활성화될 때 포커스 복원
    if (state == AppLifecycleState.resumed && widget.state.isGameRunning) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _focusNode.requestFocus();
      });
    }
  }

  void _onFocusChange() {
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
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _focusNode.removeListener(_onFocusChange);
    _textController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E), // 어두운 게임 배경
      appBar: _buildAppBar(),
      body: SafeArea(child: _buildBody()),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: const Color(0xFF16213E),
      foregroundColor: Colors.white,
      title: const Text('단어 잡기 게임'),
      actions: [
        _buildLanguageToggle(),
        if (widget.state.canPause)
          IconButton(
            icon: const Icon(Icons.pause),
            onPressed: () =>
                widget.onAction(const WordPracticeAction.pauseGame()),
          ),
      ],
    );
  }

  Widget _buildLanguageToggle() {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.language),
      onSelected: (language) {
        widget.onAction(WordPracticeAction.changeLanguage(language));
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
      loading: () =>
          const Center(child: CircularProgressIndicator(color: Colors.white)),
      error: (error, stackTrace) => _buildErrorView(error.toString()),
      data: (sentences) {
        if (widget.state.isGameOver) {
          return _buildGameOverView();
        } else if (!widget.state.isGameRunning && !widget.state.canStart) {
          return _buildPausedView();
        } else if (widget.state.canStart) {
          return _buildStartView();
        } else {
          return _buildGameView();
        }
      },
    );
  }

  Widget _buildErrorView(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          Text(
            '단어를 불러올 수 없습니다',
            style: AppTextStyle.heading4.withColor(Colors.white),
          ),
          const SizedBox(height: 8),
          Text(
            error,
            style: AppTextStyle.bodyMedium.withColor(Colors.grey),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => widget.onAction(
              WordPracticeAction.initialize(widget.state.language),
            ),
            child: const Text('다시 시도'),
          ),
        ],
      ),
    );
  }

  Widget _buildStartView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withOpacity(0.3)),
            ),
            child: Column(
              children: [
                const Icon(Icons.keyboard, size: 80, color: Colors.white),
                const SizedBox(height: 24),
                Text(
                  '단어 잡기 게임',
                  style: AppTextStyle.heading2.withColor(Colors.white),
                ),
                const SizedBox(height: 16),
                Text(
                  '하늘에서 떨어지는 단어를\n빠르게 입력해서 잡아보세요!',
                  style: AppTextStyle.bodyLarge.withColor(Colors.grey[300]!),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                _buildGameRules(),
                const SizedBox(height: 32),
                SizedBox(
                  width: 200,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () =>
                        widget.onAction(const WordPracticeAction.startGame()),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColorsStyle.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                    child: const Text('게임 시작', style: AppTextStyle.buttonLarge),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGameRules() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('게임 규칙', style: AppTextStyle.labelLarge.withColor(Colors.white)),
          const SizedBox(height: 8),
          _buildRuleItem('• 떨어지는 단어를 정확히 입력하세요'),
          _buildRuleItem('• 단어가 바닥에 닿으면 생명이 감소합니다'),
          _buildRuleItem('• 생명이 0이 되면 게임이 끝납니다'),
          _buildRuleItem('• 레벨이 올라갈수록 속도가 빨라집니다'),
        ],
      ),
    );
  }

  Widget _buildRuleItem(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Text(
        text,
        style: AppTextStyle.bodySmall.withColor(Colors.grey[300]!),
      ),
    );
  }

  Widget _buildGameView() {
    return Column(
      children: [
        _buildGameStats(),
        Expanded(
          child: Stack(children: [_buildGameArea(), ..._buildFallingWords()]),
        ),
        _buildInputArea(),
      ],
    );
  }

  Widget _buildGameStats() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.black.withOpacity(0.5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem('점수', widget.state.score.toString(), Icons.stars),
          _buildStatItem(
            '레벨',
            widget.state.level.toString(),
            Icons.trending_up,
          ),
          _buildStatItem('생명', widget.state.lives.toString(), Icons.favorite),
          _buildStatItem(
            'CPM',
            widget.state.cpm.toStringAsFixed(0), // 소수점 없이 표시
            Icons.speed,
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return SizedBox(
      width: 70, // 고정 폭 설정
      child: Column(
        children: [
          Icon(icon, color: Colors.white, size: 20),
          const SizedBox(height: 4),
          SizedBox(
            height: 20, // 고정 높이 설정
            child: Text(
              value,
              style: AppTextStyle.numberSmall.withColor(Colors.white),
              textAlign: TextAlign.center, // 중앙 정렬
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Text(
            label,
            style: AppTextStyle.labelSmall.withColor(Colors.grey[300]!),
            textAlign: TextAlign.center, // 중앙 정렬
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildGameArea() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF1A1A2E), Color(0xFF16213E), Color(0xFF0F3460)],
        ),
      ),
    );
  }

  List<Widget> _buildFallingWords() {
    return widget.state.fallingWords.map((word) {
      return Positioned(
        left: word.x * MediaQuery.of(context).size.width - 40,
        top: word.y * (MediaQuery.of(context).size.height - 200),
        child: _buildFallingWordWidget(word),
      );
    }).toList();
  }

  Widget _buildFallingWordWidget(FallingWord word) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 100),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: word.isMatched
            ? AppColorsStyle.primary.withOpacity(0.8)
            : Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(20),
        border: word.isMatched
            ? Border.all(color: AppColorsStyle.primary, width: 2)
            : null,
        boxShadow: [
          BoxShadow(
            color: word.isMatched
                ? AppColorsStyle.primary.withOpacity(0.5)
                : Colors.black.withOpacity(0.3),
            blurRadius: word.isMatched ? 8 : 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        word.text,
        style: AppTextStyle.typingText.copyWith(
          color: word.isMatched ? Colors.white : Colors.black,
          fontSize: 16,
          fontWeight: word.isMatched ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }

  Widget _buildInputArea() {
    return GestureDetector(
      // 입력 영역을 탭하면 포커스 유지
      onTap: () {
        if (!_focusNode.hasFocus) {
          _focusNode.requestFocus();
        }
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        color: Colors.black.withOpacity(0.7),
        child: Column(
          children: [
            Text(
              '입력된 글자: ${widget.state.userInput}',
              style: AppTextStyle.bodyMedium.withColor(Colors.white),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _textController,
              focusNode: _focusNode,
              onChanged: (value) {
                widget.onAction(WordPracticeAction.updateInput(value));
              },
              onSubmitted: (value) {
                widget.onAction(const WordPracticeAction.submitInput());
                // 제출 후 즉시 포커스 복원
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (mounted && widget.state.isGameRunning) {
                    _focusNode.requestFocus();
                  }
                });
              },
              decoration: InputDecoration(
                hintText: '떨어지는 단어를 입력하세요...',
                hintStyle: TextStyle(color: Colors.grey[400]),
                filled: true,
                fillColor: Colors.white.withOpacity(0.1),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: AppColorsStyle.primary,
                    width: 2,
                  ),
                ),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.send, color: Colors.white),
                  onPressed: () {
                    widget.onAction(const WordPracticeAction.submitInput());
                    // 버튼 클릭 후에도 포커스 복원
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (mounted && widget.state.isGameRunning) {
                        _focusNode.requestFocus();
                      }
                    });
                  },
                ),
              ),
              style: AppTextStyle.typingText.withColor(Colors.white),
              autofocus: true,
              // 키보드가 숨겨지지 않도록 설정
              textInputAction: TextInputAction.done,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPausedView() {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.8),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.pause_circle, size: 64, color: Colors.white),
            const SizedBox(height: 16),
            Text(
              '게임 일시정지',
              style: AppTextStyle.heading3.withColor(Colors.white),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                ElevatedButton(
                  onPressed: () =>
                      widget.onAction(const WordPracticeAction.resumeGame()),
                  child: const Text('계속하기'),
                ),
                const SizedBox(width: 16),
                OutlinedButton(
                  onPressed: () =>
                      widget.onAction(const WordPracticeAction.restartGame()),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Colors.white),
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

  Widget _buildGameOverView() {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(32),
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.9),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.red.withOpacity(0.5)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.gamepad, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'GAME OVER',
              style: AppTextStyle.heading2.withColor(Colors.red),
            ),
            const SizedBox(height: 24),
            _buildFinalGameStats(),
            const SizedBox(height: 24),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                ElevatedButton(
                  onPressed: () =>
                      widget.onAction(const WordPracticeAction.restartGame()),
                  child: const Text('다시 도전'),
                ),
                const SizedBox(width: 16),
                OutlinedButton(
                  onPressed: () => widget.onAction(
                    const WordPracticeAction.navigateToHome(),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Colors.white),
                  ),
                  child: const Text('홈으로'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFinalGameStats() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text('최종 결과', style: AppTextStyle.heading4.withColor(Colors.white)),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildFinalStatItem('점수', widget.state.score.toString()),
              _buildFinalStatItem('레벨', widget.state.level.toString()),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildFinalStatItem(
                '맞춘 단어',
                widget.state.correctWordsCount.toString(),
              ),
              _buildFinalStatItem(
                '정확도',
                '${widget.state.accuracy.toStringAsFixed(1)}%',
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              // 최종 결과에서도 CPM으로 표시
              _buildFinalStatItem(
                '평균 CPM',
                widget.state.cpm.toStringAsFixed(0),
              ),
              _buildFinalStatItem(
                '플레이 시간',
                '${widget.state.elapsedSeconds.toStringAsFixed(1)}초',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFinalStatItem(String label, String value) {
    return SizedBox(
      width: 100, // 최종 결과는 조금 더 넓게
      child: Column(
        children: [
          SizedBox(
            height: 25, // 고정 높이 설정
            child: Text(
              value,
              style: AppTextStyle.numberMedium.withColor(Colors.white),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Text(
            label,
            style: AppTextStyle.labelSmall.withColor(Colors.grey[300]!),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
