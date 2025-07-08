// lib/typing/presentation/sentence_selection/sentence_selection_screen.dart
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../../shared/styles/app_colors_style.dart';
import '../../../shared/styles/app_text_style.dart';
import '../../../shared/styles/app_dimensions.dart';
import '../../domain/model/sentence.dart';
import '../../domain/enum/typing_enums.dart';

class SentenceSelectionScreen extends StatefulWidget {
  final AsyncValue<List<Sentence>> sentences;
  final PracticeMode mode;
  final Language language;
  final Function(Sentence sentence) onSentenceSelected;
  final VoidCallback onRandomSelect;
  final Function(String language) onLanguageChanged;

  const SentenceSelectionScreen({
    super.key,
    required this.sentences,
    required this.mode,
    required this.language,
    required this.onSentenceSelected,
    required this.onRandomSelect,
    required this.onLanguageChanged,
  });

  @override
  State<SentenceSelectionScreen> createState() =>
      _SentenceSelectionScreenState();
}

class _SentenceSelectionScreenState extends State<SentenceSelectionScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );
    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(parent: _slideController, curve: Curves.elasticOut),
        );

    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFF8FAFC), Color(0xFFE0F2FE)],
          ),
        ),
        child: widget.sentences.when(
          data: (sentences) => _buildContent(sentences),
          loading: () => _buildLoading(),
          error: (error, stackTrace) => _buildError(error.toString()),
        ),
      ),
    );
  }

  Widget _buildLoading() {
    return const Center(
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(AppColorsStyle.primary),
      ),
    );
  }

  Widget _buildError(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColorsStyle.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColorsStyle.error.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.error_outline_rounded,
                  size: 48,
                  color: AppColorsStyle.error,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                '문장을 불러올 수 없습니다',
                style: AppTextStyle.heading4,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                error,
                style: AppTextStyle.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColorsStyle.error,
                    foregroundColor: AppColorsStyle.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text('뒤로 가기'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent(List<Sentence> sentences) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: CustomScrollView(
          slivers: [
            _buildSliverAppBar(),
            SliverToBoxAdapter(child: _buildHeader(sentences.length)),
            SliverToBoxAdapter(child: _buildRandomButton()),
            SliverToBoxAdapter(child: _buildSectionTitle()),
            _buildSentenceList(sentences),
          ],
        ),
      ),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 80,
      floating: false,
      pinned: true,
      elevation: 0,
      backgroundColor: Colors.transparent,
      leading: IconButton(
        icon: const Icon(
          Icons.arrow_back_ios_rounded,
          color: AppColorsStyle.textPrimary,
        ),
        onPressed: () => Navigator.of(context).pop(),
      ),
      title: Text(
        '문장 선택하기',
        style: AppTextStyle.heading3.copyWith(
          color: AppColorsStyle.textPrimary,
        ),
      ),
      centerTitle: true,
    );
  }

  Widget _buildHeader(int totalCount) {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColorsStyle.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: widget.mode.isWord
                  ? AppColorsStyle.primary
                  : const Color(0xFF3B82F6),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              widget.mode.icon,
              color: AppColorsStyle.white,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.mode.displayName, style: AppTextStyle.heading3),
                const SizedBox(height: 4),
                Text(
                  '연습할 문장을 선택해주세요',
                  style: AppTextStyle.bodyMedium.copyWith(
                    color: AppColorsStyle.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColorsStyle.containerBackground,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '총 $totalCount개의 문장 • ${widget.language.displayName}',
                    style: AppTextStyle.labelMedium.copyWith(
                      color: AppColorsStyle.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRandomButton() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: Material(
        elevation: 6,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF8B5CF6), Color(0xFFEC4899)],
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: widget.onRandomSelect,
            child: Container(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColorsStyle.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.shuffle_rounded,
                          color: AppColorsStyle.white,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        '랜덤 문장으로 시작',
                        style: AppTextStyle.heading4.copyWith(
                          color: AppColorsStyle.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '무작위로 선택된 문장으로 바로 연습해보세요',
                    style: AppTextStyle.bodyMedium.copyWith(
                      color: AppColorsStyle.white.withOpacity(0.8),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle() {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 32, 20, 16),
      child: Text(
        '문장 목록',
        style: AppTextStyle.heading4.copyWith(
          color: AppColorsStyle.textPrimary,
        ),
      ),
    );
  }

  Widget _buildSentenceList(List<Sentence> sentences) {
    if (sentences.isEmpty) {
      return SliverToBoxAdapter(
        child: Container(
          margin: const EdgeInsets.all(20),
          padding: const EdgeInsets.all(40),
          decoration: BoxDecoration(
            color: AppColorsStyle.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  color: AppColorsStyle.containerBackground,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.search_off_rounded,
                  size: 48,
                  color: AppColorsStyle.textTertiary,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                '문장이 없습니다',
                style: AppTextStyle.bodyLarge.copyWith(
                  color: AppColorsStyle.textSecondary,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate((context, index) {
        final sentence = sentences[index];
        return _buildSentenceCard(sentence, index);
      }, childCount: sentences.length),
    );
  }

  Widget _buildSentenceCard(Sentence sentence, int index) {
    final difficulty = DifficultyLevel.fromLevel(sentence.difficulty);

    return Container(
      margin: EdgeInsets.fromLTRB(
        20,
        index == 0 ? 0 : 8,
        20,
        index == widget.sentences.value!.length - 1 ? 20 : 8,
      ),
      child: Material(
        elevation: 2,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            color: AppColorsStyle.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColorsStyle.containerBackground,
              width: 1,
            ),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () => widget.onSentenceSelected(sentence),
            child: Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 난이도 및 카테고리 배지
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: difficulty.color,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          difficulty.label,
                          style: AppTextStyle.labelSmall.copyWith(
                            color: AppColorsStyle.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColorsStyle.containerBackground,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          sentence.category,
                          style: AppTextStyle.labelSmall.copyWith(
                            color: AppColorsStyle.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // 문장 내용
                  Text(
                    sentence.content,
                    style: AppTextStyle.bodyLarge.copyWith(
                      color: AppColorsStyle.textPrimary,
                      height: 1.5,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 16),

                  // 통계 정보
                  Row(
                    children: [
                      _buildStatChip(
                        Icons.text_fields_rounded,
                        '${sentence.content.length}글자',
                      ),
                      const SizedBox(width: 12),
                      _buildStatChip(
                        Icons.space_bar_rounded,
                        '${sentence.wordCount}단어',
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColorsStyle.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.play_arrow_rounded,
                          size: 20,
                          color: AppColorsStyle.primary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatChip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColorsStyle.containerBackground,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColorsStyle.textTertiary),
          const SizedBox(width: 4),
          Text(
            text,
            style: AppTextStyle.labelSmall.copyWith(
              color: AppColorsStyle.textTertiary,
            ),
          ),
        ],
      ),
    );
  }
}
