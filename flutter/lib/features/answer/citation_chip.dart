import 'package:flutter/material.dart';

import '../../app/theme/app_theme.dart';
import '../../app/theme/tokens.dart';
import '../../core/logic/citations.dart';
import '../../core/models/answers.dart';

/// 正文里的引用芯片：色板底色 9%、描边 28%、等宽编号，Tooltip 显示文献信息。
class CitationChip extends StatelessWidget {
  const CitationChip({
    super.key,
    required this.ref_,
    required this.text,
    required this.paper,
    this.onTap,
  });

  final CitationRef ref_;
  final String text;
  final AnswerPaper? paper;
  final void Function(CitationRef ref)? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = citationColor(
      ref_.n,
      dark: theme.brightness == Brightness.dark,
    );
    final label = text.replaceAll('[', '').replaceAll(']', '');

    final chip = Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
      decoration: BoxDecoration(
        color: color.withValues(alpha: PicoSeekTokens.tintFillAlpha),
        borderRadius: BorderRadius.circular(PicoSeekTokens.radiusSm),
        border: Border.all(
          color: color.withValues(alpha: PicoSeekTokens.tintBorderAlpha),
        ),
      ),
      child: Text(
        label,
        style: theme.textTheme.labelSmall
            ?.merge(monoStyle)
            .copyWith(color: color, fontWeight: FontWeight.w600),
      ),
    );

    final tooltip = _tooltip(theme);
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap == null ? null : () => onTap!(ref_),
        child: tooltip == null
            ? chip
            : Tooltip(richMessage: tooltip, child: chip),
      ),
    );
  }

  InlineSpan? _tooltip(ThemeData theme) {
    final source = paper;
    if (source == null) return null;
    final lines = <String>[
      source.title,
      [
        source.journal,
        source.year,
      ].where((part) => part.isNotEmpty).join(' · '),
      source.rankLabel,
    ].where((line) => line.trim().isNotEmpty).toList();
    if (lines.isEmpty) return null;
    return TextSpan(
      text: lines.join('\n'),
      style: theme.textTheme.bodySmall?.copyWith(
        color: theme.colorScheme.onInverseSurface,
      ),
    );
  }
}
