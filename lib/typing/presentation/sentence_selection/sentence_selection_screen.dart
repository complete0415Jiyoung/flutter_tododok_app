// lib/typing/presentation/sentence_selection/sentence_selection_screen.dart
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../../shared/styles/app_colors_style.dart';
import '../../../shared/styles/app_text_style.dart';
import '../../../shared/styles/app_dimensions.dart';
import '../../domain/model/sentence.dart';

class SentenceSelectionScreen extends StatefulWidget {
  final AsyncValue<List<Sentence>> sentences;
  final String mode; // 'word' or 'paragraph'
  final String language;
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

  int selectedDifficulty = 0;
  String selectedCategory = '전체';

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
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColorsStyle.primary.withOpacity(0.05),
              AppColorsStyle.primaryLight.withOpacity(0.1),
              AppColorsStyle.surface,
            ],
          ),
        ),
        child: SafeArea(
          child: widget.sentences.when(
            loading: () => _buildLoadingView(),
            error: (error, stack) => _buildErrorView(error.toString()),
            data: (sentences) => _buildContent(sentences),
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColorsStyle.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: AppColorsStyle.primary.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              children: [
                const SizedBox(
                  width: 50,
                  height: 50,
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AppColorsStyle.primary,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text('문장을 불러오는 중...', style: AppTextStyle.bodyLarge.primary),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorView(String error) {
    return Center(
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Container(
          margin: const EdgeInsets.all(24),
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: AppColorsStyle.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: AppColorsStyle.error.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, 10),
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
                style: AppTextStyle.bodyMedium.textTertiary,
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
    final filteredSentences = _filterSentences(sentences);
    final categories = _getCategories(sentences);

    return CustomScrollView(
      slivers: [
        _buildSliverAppBar(),
        SliverToBoxAdapter(child: _buildHeader(sentences.length)),
        SliverToBoxAdapter(child: _buildFilters(categories)),
        SliverToBoxAdapter(child: _buildRandomButton()),
        _buildSentenceList(filteredSentences),
      ],
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 120,
      floating: false,
      pinned: true,
      elevation: 0,
      backgroundColor: Colors.transparent,
      foregroundColor: AppColorsStyle.textPrimary,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColorsStyle.primary, AppColorsStyle.primaryLight],
            ),
          ),
        ),
      ),
      leading: Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColorsStyle.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_rounded,
            color: AppColorsStyle.white,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      actions: [
        Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColorsStyle.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: PopupMenuButton<String>(
            icon: const Icon(
              Icons.language_rounded,
              color: AppColorsStyle.white,
            ),
            onSelected: widget.onLanguageChanged,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'ko',
                child: Row(
                  children: [
                    if (widget.language == 'ko')
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: AppColorsStyle.primary,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.check,
                          size: 16,
                          color: AppColorsStyle.white,
                        ),
                      )
                    else
                      const SizedBox(width: 24),
                    const SizedBox(width: 12),
                    const Text('한글'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'en',
                child: Row(
                  children: [
                    if (widget.language == 'en')
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: AppColorsStyle.primary,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.check,
                          size: 16,
                          color: AppColorsStyle.white,
                        ),
                      )
                    else
                      const SizedBox(width: 24),
                    const SizedBox(width: 12),
                    const Text('English'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(int totalCount) {
    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Container(
          margin: const EdgeInsets.all(20),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColorsStyle.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: AppColorsStyle.primary.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          AppColorsStyle.primary,
                          AppColorsStyle.primaryLight,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(
                      widget.mode == 'word'
                          ? Icons.sports_esports_rounded
                          : Icons.article_rounded,
                      color: AppColorsStyle.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.mode == 'word' ? '단어 연습' : '장문 연습',
                          style: AppTextStyle.heading3,
                        ),
                        Text(
                          '연습할 문장을 선택해주세요',
                          style: AppTextStyle.bodyMedium.textSecondary,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: AppColorsStyle.containerBackground,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '총 $totalCount개의 문장 • ${widget.language == 'ko' ? '한글' : 'English'}',
                  style: AppTextStyle.labelMedium.primary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilters(List<String> categories) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('필터', style: AppTextStyle.heading4),
          const SizedBox(height: 16),

          // 난이도 필터
          Text('난이도', style: AppTextStyle.labelLarge.textSecondary),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildModernFilterChip('전체', 0, true),
                const SizedBox(width: 12),
                ...List.generate(5, (index) {
                  final difficulty = index + 1;
                  return Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: _buildModernFilterChip(
                      'Lv.$difficulty',
                      difficulty,
                      true,
                    ),
                  );
                }),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // 카테고리 필터
          Text('카테고리', style: AppTextStyle.labelLarge.textSecondary),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: categories.map((category) {
                return Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: _buildModernFilterChip(category, category, false),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildModernFilterChip(
    String label,
    dynamic value,
    bool isDifficulty,
  ) {
    final isSelected = isDifficulty
        ? selectedDifficulty == value
        : selectedCategory == value;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            setState(() {
              if (isDifficulty) {
                selectedDifficulty = value;
              } else {
                selectedCategory = value;
              }
            });
          },
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              gradient: isSelected
                  ? const LinearGradient(
                      colors: [
                        AppColorsStyle.primary,
                        AppColorsStyle.primaryLight,
                      ],
                    )
                  : null,
              color: isSelected ? null : AppColorsStyle.containerBackground,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isSelected
                    ? Colors.transparent
                    : AppColorsStyle.border.withOpacity(0.3),
                width: 1,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: AppColorsStyle.primary.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : null,
            ),
            child: Text(
              label,
              style: AppTextStyle.labelMedium.copyWith(
                color: isSelected
                    ? AppColorsStyle.white
                    : AppColorsStyle.textSecondary,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRandomButton() {
    return Container(
      margin: const EdgeInsets.all(20),
      child: Material(
        elevation: 4,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColorsStyle.secondary,
                AppColorsStyle.secondary.withOpacity(0.8),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: InkWell(
            onTap: widget.onRandomSelect,
            borderRadius: BorderRadius.circular(20),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 18),
              child: Row(
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
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    '랜덤으로 시작하기',
                    style: AppTextStyle.buttonLarge.withColor(
                      AppColorsStyle.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
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
            borderRadius: BorderRadius.circular(24),
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
                '조건에 맞는 문장이 없습니다',
                style: AppTextStyle.bodyLarge.textSecondary,
              ),
            ],
          ),
        ),
      );
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate((context, index) {
        final sentence = sentences[index];
        return _buildModernSentenceCard(sentence, index);
      }, childCount: sentences.length),
    );
  }

  Widget _buildModernSentenceCard(Sentence sentence, int index) {
    return Container(
      margin: EdgeInsets.fromLTRB(20, index == 0 ? 0 : 8, 20, 16),
      child: Material(
        elevation: 2,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: () => widget.onSentenceSelected(sentence),
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColorsStyle.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: AppColorsStyle.border.withOpacity(0.1),
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 헤더
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: _getDifficultyColor(sentence.difficulty),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'Level ${sentence.difficulty}',
                        style: AppTextStyle.labelSmall.withColor(
                          AppColorsStyle.white,
                        ),
                      ),
                    ),
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
                        sentence.category,
                        style: AppTextStyle.labelSmall.textSecondary,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // 문장 내용
                Text(
                  sentence.content,
                  style: AppTextStyle.bodyLarge.copyWith(height: 1.5),
                  maxLines: widget.mode == 'word' ? 2 : 3,
                  overflow: TextOverflow.ellipsis,
                ),

                const SizedBox(height: 16),

                // 통계 & 화살표
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
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 16,
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
    );
  }

  Widget _buildStatChip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColorsStyle.containerBackground,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColorsStyle.textTertiary),
          const SizedBox(width: 4),
          Text(text, style: AppTextStyle.labelSmall.textTertiary),
        ],
      ),
    );
  }

  List<Sentence> _filterSentences(List<Sentence> sentences) {
    return sentences.where((sentence) {
      if (selectedDifficulty != 0 &&
          sentence.difficulty != selectedDifficulty) {
        return false;
      }
      if (selectedCategory != '전체' && sentence.category != selectedCategory) {
        return false;
      }
      return true;
    }).toList();
  }

  List<String> _getCategories(List<Sentence> sentences) {
    final categories = sentences.map((s) => s.category).toSet().toList();
    categories.sort();
    return ['전체', ...categories];
  }

  Color _getDifficultyColor(int difficulty) {
    switch (difficulty) {
      case 1:
        return const Color(0xFF4CAF50); // Green
      case 2:
        return const Color(0xFF2196F3); // Blue
      case 3:
        return const Color(0xFFFF9800); // Orange
      case 4:
        return const Color(0xFFE91E63); // Pink
      case 5:
        return const Color(0xFF9C27B0); // Purple
      default:
        return AppColorsStyle.textTertiary;
    }
  }
}
