import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../core/api/endpoints.dart';
import '../../core/models/page.dart';
import '../../core/models/papers.dart';
import '../../core/session/session_controller.dart';

part 'library_controller.g.dart';

@riverpod
class LibraryController extends _$LibraryController {
  String query = '';
  int offset = 0;
  static const limit = 20;
  Timer? _debounce;

  @override
  Future<Page<PaperMeta>> build() {
    final client = ref.watch(apiClientProvider);
    ref.onDispose(() => _debounce?.cancel());
    return client.papers(q: query.trim(), limit: limit, offset: offset);
  }

  void setQuery(String value) {
    query = value;
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      offset = 0;
      reload();
    });
  }

  void setOffset(int value) {
    _debounce?.cancel();
    offset = value < 0 ? 0 : value ~/ limit * limit;
    reload();
  }

  void reload() => ref.invalidateSelf();
}

@riverpod
Future<String> paperFulltext(Ref ref, String key) =>
    ref.watch(apiClientProvider).paperFulltext(key);

@riverpod
Future<List<Fact>> paperFacts(Ref ref, String key) =>
    ref.watch(apiClientProvider).paperFacts(key);

@riverpod
Future<PaperMeta> paperMeta(Ref ref, String key) =>
    ref.watch(apiClientProvider).paper(key);
