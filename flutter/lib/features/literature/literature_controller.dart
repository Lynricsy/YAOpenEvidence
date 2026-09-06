import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../core/api/endpoints.dart';
import '../../core/logic/ask_filters.dart';
import '../../core/models/literature.dart';
import '../../core/session/session_controller.dart';

part 'literature_controller.freezed.dart';
part 'literature_controller.g.dart';

@freezed
abstract class LiteratureFilters with _$LiteratureFilters {
  const LiteratureFilters._();

  const factory LiteratureFilters({
    @Default(YearMode.any) YearMode yearMode,
    @Default(3) int years,
    int? yearFrom,
    int? yearTo,
    @Default(<String>[]) List<String> publicationTypes,
    @Default(<int>[]) List<int> quartiles,
    @Default(<String>[]) List<String> journals,
    @Default(false) bool openAccessOnly,
  }) = _LiteratureFilters;

  String? get rangeError {
    if (yearMode != YearMode.range) return null;
    if (yearTo != null && yearFrom == null) return '请先选择起始年';
    if (yearFrom != null && yearTo != null && yearTo! < yearFrom!) {
      return '结束年不得早于起始年';
    }
    return null;
  }
}

@riverpod
class LiteratureController extends _$LiteratureController {
  String query = '';
  LiteratureSource source = LiteratureSource.auto;
  int limit = 10;
  LiteratureFilters filters = const LiteratureFilters();
  int _request = 0;

  @override
  AsyncValue<LiteratureSearchResult?> build() => const AsyncData(null);

  void setSource(LiteratureSource value) => source = value;
  void setLimit(int value) {
    if (const [10, 20, 30].contains(value)) limit = value;
  }
  void setFilters(LiteratureFilters value) => filters = value;

  Future<void> search() async {
    final q = query.trim();
    if (q.isEmpty || filters.rangeError != null) return;
    final request = ++_request;
    final payload = LiteratureQuery(
      q: q,
      source: source,
      limit: limit,
      years: filters.yearMode == YearMode.recent ? filters.years : null,
      yearFrom: filters.yearMode == YearMode.range ? filters.yearFrom : null,
      yearTo: filters.yearMode == YearMode.range ? filters.yearTo : null,
      publicationTypes: filters.publicationTypes,
      quartiles: filters.quartiles,
      journals: filters.journals,
      openAccessOnly: source == LiteratureSource.s2 && filters.openAccessOnly,
    );
    final client = ref.read(apiClientProvider);
    state = const AsyncLoading();
    final result = await AsyncValue.guard<LiteratureSearchResult?>(
      () => client.literatureSearch(payload),
    );
    if (ref.mounted && request == _request) state = result;
  }
}
