import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../core/api/query_encoding.dart';

/// PubMed 详情页。
Uri? pubmedUrl(String? pmid) {
  final value = pmid?.trim() ?? '';
  if (value.isEmpty) return null;
  return Uri.parse(
    'https://pubmed.ncbi.nlm.nih.gov/${encodePathComponent(value)}/',
  );
}

/// DOI 解析地址：按 `/` 分段分别编码，保留 DOI 自身的层级结构。
Uri? doiUrl(String? doi) {
  final value = doi?.trim() ?? '';
  if (value.isEmpty) return null;
  final encoded = value.split('/').map(encodeQueryComponent).join('/');
  return Uri.parse('https://doi.org/$encoded');
}

/// PMC 全文页。
Uri? pmcUrl(String? pmcid) {
  final value = pmcid?.trim() ?? '';
  if (value.isEmpty) return null;
  return Uri.parse(
    'https://www.ncbi.nlm.nih.gov/pmc/articles/${encodePathComponent(value)}/',
  );
}

/// 开放获取 PDF（后端原样给出的地址）。
Uri? pdfUrl(String? url) {
  final value = url?.trim() ?? '';
  if (value.isEmpty) return null;
  return Uri.tryParse(value);
}

/// 用系统浏览器打开外链；失败时给出 SnackBar 提示。
Future<void> openExternal(BuildContext context, Uri? url) async {
  if (url == null) return;
  final messenger = ScaffoldMessenger.maybeOf(context);
  final ok = await launchUrl(url, mode: LaunchMode.externalApplication);
  if (!ok) {
    messenger?.showSnackBar(SnackBar(content: Text('无法打开链接：$url')));
  }
}

/// 一行外链按钮：PubMed / DOI / PDF。
class ExternalLinkRow extends StatelessWidget {
  const ExternalLinkRow({
    super.key,
    this.pmid,
    this.doi,
    this.pmcid,
    this.pdf,
  });

  final String? pmid;
  final String? doi;
  final String? pmcid;
  final String? pdf;

  @override
  Widget build(BuildContext context) {
    final links = <(String, Uri?)>[
      ('PubMed', pubmedUrl(pmid)),
      ('DOI', doiUrl(doi)),
      ('PMC', pmcUrl(pmcid)),
      ('PDF', pdfUrl(pdf)),
    ].where((entry) => entry.$2 != null).toList();
    if (links.isEmpty) return const SizedBox.shrink();

    return Wrap(
      spacing: 8,
      runSpacing: 4,
      children: [
        for (final (label, url) in links)
          TextButton.icon(
            onPressed: () => openExternal(context, url),
            icon: const Icon(Icons.open_in_new, size: 14),
            label: Text(label),
            style: TextButton.styleFrom(
              visualDensity: VisualDensity.compact,
              padding: const EdgeInsets.symmetric(horizontal: 8),
            ),
          ),
      ],
    );
  }
}
