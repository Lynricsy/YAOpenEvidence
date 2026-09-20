import 'package:flutter/material.dart';

import '../../app/theme/tokens.dart';
import '../../shared/widgets/brand_logo.dart';
import '../../shared/widgets/surface.dart';

/// 提问页示例问题（文案与 Web 端一致）。
const askExamples = <String>[
  'SGLT2抑制剂对HFpEF患者有什么获益？',
  '替尔泊肽与司美格鲁肽在肥胖患者减重和心血管结局上的比较',
  '他汀类药物一级预防在老年人中的获益与风险',
];

/// 提问页 Hero：品牌标识 + 衬线大标题 + 副标题。
class AskHero extends StatelessWidget {
  const AskHero({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final wide = MediaQuery.sizeOf(context).width >= PicoSeekTokens.compactMaxWidth;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const BrandLogo(size: 40, semanticLabel: 'PicoSeek'),
        const SizedBox(height: PicoSeekTokens.space3),
        Text(
          '请提出您的临床或科研问题',
          style:
              (wide
                      ? theme.textTheme.displaySmall
                      : theme.textTheme.headlineMedium)
                  ?.copyWith(height: 1.2),
        ),
        const SizedBox(height: PicoSeekTokens.space2),
        Text(
          '从 PubMed / Europe PMC 检索并逐篇核实，生成可回溯到原文段落的循证综述。',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

/// 示例问题芯片组。
class AskExamples extends StatelessWidget {
  const AskExamples({super.key, required this.onExample});

  final void Function(String question) onExample;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '试试这些问题',
          style: theme.textTheme.labelMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: PicoSeekTokens.space2),
        for (final example in askExamples)
          Padding(
            padding: const EdgeInsets.only(bottom: PicoSeekTokens.space2 + 2),
            child: PicoSeekCard(
              onTap: () => onExample(example),
              child: Row(
                children: [
                  Expanded(
                    child: Text(example, style: theme.textTheme.bodyMedium),
                  ),
                  Icon(
                    Icons.north_east,
                    size: 14,
                    color: theme.colorScheme.outline,
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
