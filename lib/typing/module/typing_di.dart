// lib/typing/module/typing_di.dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../data/data_source/typing_data_source.dart';
import '../data/data_source/mock_typing_data_source_impl.dart';
import '../data/repository_impl/typing_repository_impl.dart';
import '../domain/repository/typing_repository.dart';
import '../domain/usecase/get_sentences_use_case.dart';
import '../domain/usecase/get_random_sentence_use_case.dart';
import '../domain/usecase/save_typing_result_use_case.dart';
import '../domain/usecase/get_user_typing_results_use_case.dart';
import '../domain/usecase/get_best_records_use_case.dart';

part 'typing_di.g.dart';

/// DataSource Provider (Mock 데이터 사용, 상태 유지 필요)
@Riverpod(keepAlive: true)
TypingDataSource typingDataSource(TypingDataSourceRef ref) =>
    MockTypingDataSourceImpl();

/// Repository Provider
@riverpod
TypingRepository typingRepository(TypingRepositoryRef ref) =>
    TypingRepositoryImpl(dataSource: ref.watch(typingDataSourceProvider));

/// UseCase Providers
@riverpod
GetSentencesUseCase getSentencesUseCase(GetSentencesUseCaseRef ref) =>
    GetSentencesUseCase(repository: ref.watch(typingRepositoryProvider));

@riverpod
GetRandomSentenceUseCase getRandomSentenceUseCase(
  GetRandomSentenceUseCaseRef ref,
) => GetRandomSentenceUseCase(repository: ref.watch(typingRepositoryProvider));

@riverpod
SaveTypingResultUseCase saveTypingResultUseCase(
  SaveTypingResultUseCaseRef ref,
) => SaveTypingResultUseCase(repository: ref.watch(typingRepositoryProvider));

@riverpod
GetUserTypingResultsUseCase getUserTypingResultsUseCase(
  GetUserTypingResultsUseCaseRef ref,
) => GetUserTypingResultsUseCase(
  repository: ref.watch(typingRepositoryProvider),
);

@riverpod
GetBestRecordsUseCase getBestRecordsUseCase(GetBestRecordsUseCaseRef ref) =>
    GetBestRecordsUseCase(repository: ref.watch(typingRepositoryProvider));
