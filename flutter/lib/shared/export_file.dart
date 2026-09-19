import 'dart:io';
import 'dart:typed_data';

import 'package:file_selector/file_selector.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart' hide XFile;

/// 把服务端导出的 PDF 交给系统处理，返回落盘路径；用户取消另存为时返回 null。
///
/// Android 没有面向用户的通用「另存为」，由系统分享面板决定去向（存到文件、发给
/// 其他应用皆可）；桌面端反过来，分享面板不存在，直接开另存为对话框。
Future<String?> saveOrSharePdf({
  required Uint8List bytes,
  required String filename,
}) async {
  if (Platform.isAndroid) {
    // 分享面板只接受文件 URI，先落到应用私有临时目录再交出去。
    final file = File('${(await getTemporaryDirectory()).path}/$filename');
    await file.writeAsBytes(bytes, flush: true);
    // share_plus 自 11 起只保留这一套实例 API，旧的 Share.shareXFiles 已移除。
    await SharePlus.instance.share(
      ShareParams(files: [XFile(file.path, mimeType: 'application/pdf')]),
    );
    return file.path;
  }

  final location = await getSaveLocation(
    suggestedName: filename,
    acceptedTypeGroups: const [
      XTypeGroup(label: 'PDF', extensions: ['pdf']),
    ],
  );
  if (location == null) return null;
  await File(location.path).writeAsBytes(bytes, flush: true);
  return location.path;
}
