import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../app/answers_version.dart';
import '../../core/api/endpoints.dart';
import '../../core/models/answers.dart';
import '../../core/models/page.dart';
import '../../core/session/session_controller.dart';

part 'history_controller.g.dart';

@riverpod
class HistoryController extends _$HistoryController {
  static const limit = 20;

  AnswerStatus? status;
  String query = '';
  int offset = 0;
  Timer? _debounce;
  Timer? _poll;
  int _generation = 0;
  bool _refreshing = false;

  @override
  Future<Page<AnswerSummary>> build() async {
    final client = ref.watch(apiClientProvider);
    ref.watch(answersVersionProvider);
    final generation = ++_generation;
    _refreshing = false;
    ref.onDispose(() {
      _generation++;
      _debounce?.cancel();
      _poll?.cancel();
      _poll = null;
    });
    final page = await client.answers(
      status: status,
      q: query.trim(),
      limit: limit,
      offset: offset,
    );
    if (ref.mounted && generation == _generation) _updatePolling(page);
    return page;
  }

  void setStatus(AnswerStatus? value) {
    if (status == value) return;
    status = value;
    offset = 0;
    ref.invalidateSelf();
  }

  void setQuery(String value) {
    query = value;
    offset = 0;
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      _debounce = null;
      ref.invalidateSelf();
    });
  }

  void setOffset(int value) {
    if (offset == value) return;
    offset = value < 0 ? 0 : value;
    ref.invalidateSelf();
  }

  Future<void> reload() async {
    if (_refreshing || state.isLoading || (_debounce?.isActive ?? false)) return;
    _refreshing = true;
    final generation = _generation;
    final previous = state.value;
    try {
      final page = await ref.read(apiClientProvider).answers(
        status: status,
        q: query.trim(),
        limit: limit,
        offset: offset,
      );
      if (!ref.mounted || generation != _generation) return;
      state = AsyncData(page);
      _updatePolling(page);
    } catch (error, stackTrace) {
      if (!ref.mounted || generation != _generation) return;
      if (previous == null) state = AsyncError(error, stackTrace);
    } finally {
      if (ref.mounted && generation == _generation) _refreshing = false;
    }
  }

  void _updatePolling(Page<AnswerSummary> page) {
    if (page.items.any((item) => item.status.isActive)) {
      _poll ??= Timer.periodic(const Duration(seconds: 5), (_) {
        unawaited(reload());
      });
    } else {
      _poll?.cancel();
      _poll = null;
    }
  }
}
