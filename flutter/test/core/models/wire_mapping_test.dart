import 'package:flutter_test/flutter_test.dart';
import 'package:yaopenevidence/core/models/answers.dart';
import 'package:yaopenevidence/core/models/jobs.dart';
import 'package:yaopenevidence/core/models/literature.dart';
import 'package:yaopenevidence/core/models/meta.dart';
import 'package:yaopenevidence/core/models/page.dart';
import 'package:yaopenevidence/core/models/problem.dart';

void main() {
  test('snake_case + 默认值 + 未知来源回落', () {
    final answer = Answer.fromJson({
      'id': 'a1',
      'job_id': 'j1',
      'status': 'ready',
      'question': 'q',
      'filters_label': 'lbl',
      'created_at': '2026-09-06T14:20:57Z',
      'papers': [
        {'n': 1, 'source': 'brand_new', 'n_citations_verified': 2},
      ],
    });
    expect(answer.jobId, 'j1');
    expect(answer.status, AnswerStatus.ready);
    expect(answer.createdAt.toUtc().year, 2026);
    expect(answer.papers.single.source, PaperSource.abstract);
    expect(answer.papers.single.nCitationsVerified, 2);
    expect(answer.options, isEmpty);
    expect(answer.queries, isEmpty);
  });

  test('AnswerCreate 省略 null 字段', () {
    final json = const AnswerCreate(
      question: 'q',
      papers: 8,
      years: 3,
    ).toJson();
    expect(json.containsKey('year_from'), isFalse);
    expect(json.containsKey('keep_unranked'), isFalse);
    expect(json['use_kb'], isTrue);
    expect(json['max_chars'], 28000);
  });

  test('JobKind kb_reindex 与 Page 泛型', () {
    final job = Job.fromJson({
      'id': 'j',
      'kind': 'kb_reindex',
      'status': 'running',
      'created_at': '2026-09-06T14:20:57Z',
    });
    expect(job.kind, JobKind.kbReindex);
    final page = Page<AnswerSummary>.fromJson({
      'items': [
        {
          'id': 'a',
          'status': 'queued',
          'created_at': '2026-09-06T14:20:57Z',
        },
      ],
      'total': 1,
      'limit': 20,
      'offset': 0,
    }, (o) => AnswerSummary.fromJson(o! as Map<String, Object?>));
    expect(page.items.single.status, AnswerStatus.queued);
  });

  test('Problem.loc 混合类型与 LiteratureRecord.fulltextIdent', () {
    final problem = Problem.fromJson({
      'status': 422,
      'code': 'validation_error',
      'errors': [
        {'loc': ['body', 0, 'question'], 'msg': 'bad', 'type': 'x'},
      ],
    });
    expect(problem.errors!.single.loc, ['body', '0', 'question']);
    final record = LiteratureRecord.fromJson({
      'source': 's2',
      'id': 'x',
      'pmid': ' 123 ',
      's2_id': 'abc',
      'cited_by': 5,
    });
    expect(record.fulltextIdent, '123');
    expect(record.s2Id, 'abc');
    expect(record.citedBy, 5);
  });

  test('paper_ingest 与分区表 / 机构状态的 snake_case 映射', () {
    expect(
      Job.fromJson({
        'id': 'j',
        'kind': 'paper_ingest',
        'status': 'queued',
        'created_at': '2026-09-06T14:20:57Z',
      }).kind,
      JobKind.paperIngest,
    );

    final tables = RankTables.fromJson({
      'tables': [
        {'file': 'scimagojr_2024.csv', 'year': 2024, 'journals': 30199,
          'source': 'scimago'},
      ],
      'issns': 50618,
      'titles': 30056,
      'loaded_at': '2026-09-08T10:00:00Z',
    });
    expect(tables.tables.single.journals, 30199);
    expect(tables.tables.single.year, 2024);
    expect(tables.loadedAt!.toUtc().hour, 10);

    // 空表意味着 Q1–Q4 不生效，默认值不能把它伪装成「有表」
    expect(RankTables.fromJson(const {}).tables, isEmpty);

    final paywall = PaywallStatus.fromJson({
      'configured': true,
      'saved_at': '2026-09-08T10:00:00Z',
      'final_url': 'https://www.sciencedirect.com/',
      'has_session_storage': false,
      'has_context_meta': true,
      'playwright_available': true,
    });
    expect(paywall.finalUrl, 'https://www.sciencedirect.com/');
    expect(paywall.hasSessionStorage, isFalse);
    expect(paywall.hasContextMeta, isTrue);
    expect(paywall.playwrightAvailable, isTrue);
  });
}
