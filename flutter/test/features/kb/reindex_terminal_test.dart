import 'package:flutter_test/flutter_test.dart';
import 'package:picoseek/core/logic/job_live.dart';
import 'package:picoseek/core/models/answers.dart';
import 'package:picoseek/core/models/jobs.dart';
import 'package:picoseek/features/kb/kb_controller.dart';

Job _job(JobStatus status, {Map<String, dynamic>? result, JobError? error}) =>
    Job(
      id: 'j1',
      kind: JobKind.kbReindex,
      status: status,
      result: result,
      error: error,
      createdAt: DateTime.utc(2026, 9, 8),
    );

void main() {
  // SSE 断流时只剩 REST 兜底：这里映射错了，进度条会永远转下去或提前消失。
  test('活动中的任务没有终态', () {
    expect(jobTerminal(_job(JobStatus.queued)), isNull);
    expect(jobTerminal(_job(JobStatus.running)), isNull);
  });

  test('成功的任务带出条目与论文数', () {
    final terminal = jobTerminal(
      _job(JobStatus.succeeded, result: {'items': 12, 'papers': 3}),
    );
    expect(terminal, const Succeeded(items: 12, papers: 3));
  });

  test('失败的任务保留失败码与消息', () {
    final terminal = jobTerminal(
      _job(
        JobStatus.failed,
        error: const JobError(code: 'llm_unavailable', message: '502'),
      ),
    );
    expect(terminal, const Failed(code: 'llm_unavailable', message: '502'));
  });

  test('缺失 error 字段的失败仍收敛为 internal_error', () {
    expect(
      jobTerminal(_job(JobStatus.failed)),
      const Failed(code: 'internal_error', message: ''),
    );
  });

  test('取消的任务是 Cancelled', () {
    expect(jobTerminal(_job(JobStatus.cancelled)), const Cancelled());
  });

  test('终态文案：失败带上服务端消息，成功与取消固定文案', () {
    expect(reindexTerminalMessage(const Succeeded()), '索引重建完成');
    expect(reindexTerminalMessage(const Cancelled()), '索引重建已取消');
    expect(
      reindexTerminalMessage(const Failed(code: 'timeout', message: '')),
      '任务超时',
    );
    expect(
      reindexTerminalMessage(
        const Failed(code: 'timeout', message: 'exceeded 1800s'),
      ),
      '任务超时：exceeded 1800s',
    );
  });
}
