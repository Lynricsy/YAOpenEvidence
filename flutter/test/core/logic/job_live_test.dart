import 'package:flutter_test/flutter_test.dart';
import 'package:yaopenevidence/core/api/sse.dart';
import 'package:yaopenevidence/core/logic/job_live.dart';
import 'package:yaopenevidence/core/models/tool_call.dart';

SseEvent event(String name, String json) => SseEvent(event: name, data: json);

void main() {
  test('search 完成后写入摘要，succeeded 不清空既有状态', () {
    var live = JobLive.empty
        .applying(
          event(
            'progress',
            '{"stage":"read","current":2,"total":5,"title":"某篇"}',
          ),
        )
        .applying(
          event('stage', '''
{"stage":"search","status":"finished","detail":{"candidates":30,"kept":8,
"dropped":{"year":10,"quartile":7,"unranked":3,"journal":2},
"papers":[{"n":1,"pmid":"1","title":"T","year":"2024","journal":"J","rank_label":"Q1","pmcid":"PMC1"}]}}'''),
        );
    live = live.applying(event('succeeded', '{"answer_id":"a1"}'));

    expect(live.stages[StageKey.search]?.status, StageStatus.finished);
    expect(live.search?.candidates, 30);
    expect(live.search?.kept, 8);
    expect(live.search?.dropped['year'], 10);
    expect(live.search?.papers.first.pmid, '1');
    expect(live.search?.papers.first.rankLabel, 'Q1');
    expect(live.progress?.stage, StageKey.read);
    expect(live.progress?.current, 2);
    expect(live.terminal, const Succeeded(answerId: 'a1'));
  });

  test('终态可被后续事件覆盖，不做短路', () {
    var live = JobLive.empty.applying(
      event('failed', '{"code":"no_papers","message":"没有文献"}'),
    );
    expect(live.terminal, const Failed(code: 'no_papers', message: '没有文献'));
    live = live.applying(event('cancelled', '{}'));
    expect(live.terminal, const Cancelled());
  });

  test('失败事件字段缺失时回落默认值', () {
    final live = JobLive.empty.applying(event('failed', '{}'));
    expect(live.terminal, const Failed(code: 'internal_error', message: ''));
  });

  test('日志上限 200 条，超出丢弃最早的', () {
    var live = JobLive.empty;
    for (var index = 1; index <= 205; index++) {
      live = live.applying(
        event('log', '{"level":"info","message":"$index"}'),
      );
    }
    expect(live.logs, hasLength(200));
    expect(live.logs.first.message, '6');
    expect(live.logs.last.message, '205');
  });

  test('非法与未知事件保持原状', () {
    final base = JobLive.empty.applying(
      event('stage', '{"stage":"queries","status":"started"}'),
    );
    expect(
      base.applying(event('stage', '{"stage":"unknown","status":"started"}')),
      base,
    );
    expect(
      base.applying(event('stage', '{"stage":"read","status":"paused"}')),
      base,
    );
    expect(
      base.applying(event('progress', '{"stage":"nope","current":1}')),
      base,
    );
    expect(base.applying(event('log', '{"level":"info"}')), base);
    expect(base.applying(event('whatever', '{}')), base);
    expect(base.applying(event('stage', 'not json')), base);
  });

  test('警告日志保留级别', () {
    final live = JobLive.empty.applying(
      event('log', '{"level":"warning","message":"慢"}'),
    );
    expect(live.logs.single.level, LogLevel.warning);
  });

  test('阶段摘要文案', () {
    expect(
      stageSummary(StageKey.search, const {
        'candidates': 30,
        'kept': 8,
        'dropped': {'year': 10, 'quartile': 7, 'unranked': 3, 'journal': 2},
      }),
      '候选 30 → 保留 8（年份 -10 / 分区 -7 / 未收录 -3 / 期刊 -2）',
    );
    expect(
      stageSummary(StageKey.read, const {'relevant': 4, 'total': 6}),
      '相关 4/6',
    );
    expect(stageSummary(StageKey.queries, const {'queries': 3}), '检索式 3');
    expect(
      stageSummary(StageKey.fulltext, const {'n_fulltext': 2, 'papers': 5}),
      '全文 2 · 文献 5',
    );
    expect(stageSummary(StageKey.synthesize, const {'note': '忽略非数字'}), '');
  });

  test('agent 阶段进入 running，工具调用按 call_id 就地替换', () {
    var live = JobLive.empty.applying(
      event('stage', '{"stage":"agent","status":"started","detail":{}}'),
    );
    expect(live.stages[StageKey.agent]?.status, StageStatus.running);
    // agent 不属于标准流水线，否则会在阶段步骤条里多出一格。
    expect(StageKey.askPipeline, isNot(contains(StageKey.agent)));

    live = live.applying(
      event(
        'tool',
        '{"call_id":"c1","server":"semantic_scholar","tool":"read_pdf",'
        '"status":"started","args":{"path":"x.pdf"}}',
      ),
    );
    expect(live.tools.single.status, ToolCallStatus.started);
    expect(live.tools.single.durationMs, isNull);

    live = live.applying(
      event(
        'tool',
        '{"call_id":"c1","server":"semantic_scholar","tool":"read_pdf",'
        '"status":"completed","args":{"path":"x.pdf"},"duration_ms":820}',
      ),
    );
    expect(live.tools, hasLength(1));
    expect(live.tools.single.status, ToolCallStatus.completed);
    expect(live.tools.single.durationMs, 820);

    live = live.applying(
      event('tool', '{"call_id":"c2","server":"shell","tool":"exec"}'),
    );
    expect(live.tools.map((c) => c.callId), ['c1', 'c2']);
  });

  test('缺 call_id 的工具帧被丢弃', () {
    final live = JobLive.empty.applying(
      event('tool', '{"server":"shell","tool":"exec","status":"started"}'),
    );
    expect(live.tools, isEmpty);
  });
}
