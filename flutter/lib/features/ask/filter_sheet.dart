import 'package:flutter/material.dart';

import '../../shared/widgets/adaptive_sheet.dart';
import 'filter_panel.dart';

/// 打开筛选面板。
Future<void> showFilterSheet(BuildContext context) => showAdaptiveSheet<void>(
  context,
  title: '检索筛选',
  child: const FilterPanel(),
);
