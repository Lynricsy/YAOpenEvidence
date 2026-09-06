import 'package:flutter/material.dart';

import '../../app/theme/tokens.dart';
import 'nav_items.dart';

/// 窄屏「更多」表单：查文献 / 用户（管理员）/ 账号。
Future<void> showMoreSheet(
  BuildContext context, {
  required bool isAdmin,
  required void Function(int branch) onSelect,
}) async {
  final selected = await showModalBottomSheet<int>(
    context: context,
    useSafeArea: true,
    builder: (context) {
      final items = moreItems
          .where((item) => !item.adminOnly || isAdmin)
          .toList();
      return SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: YaoeTokens.space2),
            for (final item in items)
              ListTile(
                leading: Icon(item.icon, size: 20),
                title: Text(item.label),
                onTap: () => Navigator.of(context).pop(item.branch),
              ),
            const SizedBox(height: YaoeTokens.space2),
          ],
        ),
      );
    },
  );
  if (selected != null) onSelect(selected);
}
