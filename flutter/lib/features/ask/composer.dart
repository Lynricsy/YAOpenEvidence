import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../app/theme/tokens.dart';
import '../../core/models/answers.dart';
import 'engine_picker.dart';

/// 提问（新建一轮）还是追问（续接智能体会话）。
enum ComposerMode { ask, followUp }

/// 提问输入框。物理键盘 Enter 提交、Shift+Enter 换行；移动端换行键正常换行。
class Composer extends StatefulWidget {
  const Composer({
    super.key,
    required this.controller,
    required this.onSubmit,
    this.submitting = false,
    this.autofocus = false,
    this.hintText,
    this.dock = false,
    this.trailing = const [],
    required this.engine,
    required this.onEngineChanged,
    this.mode = ComposerMode.ask,
  });

  final TextEditingController controller;
  final void Function(String question) onSubmit;
  final bool submitting;
  final bool autofocus;

  /// 未给时按 [mode] 取默认占位。
  final String? hintText;

  /// Dock 形态：答案页底部浮层（更紧凑、带阴影分隔）。
  final bool dock;
  final List<Widget> trailing;
  final AnswerEngine engine;
  final ValueChanged<AnswerEngine> onEngineChanged;
  final ComposerMode mode;

  @override
  State<Composer> createState() => _ComposerState();
}

class _ComposerState extends State<Composer> {
  static const maxLength = 2000;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onChanged);
    super.dispose();
  }

  void _onChanged() => setState(() {});

  bool get _canSubmit =>
      !widget.submitting && widget.controller.text.trim().isNotEmpty;

  String get _hint =>
      widget.hintText ??
      switch (widget.mode) {
        ComposerMode.ask => '请输入临床或科研问题…',
        ComposerMode.followUp => '追问这个话题…',
      };

  void _submit() {
    if (!_canSubmit) return;
    widget.onSubmit(widget.controller.text.trim());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final length = widget.controller.text.characters.length;

    return Container(
      padding: const EdgeInsets.all(YaoeTokens.space3),
      decoration: BoxDecoration(
        color: context.yaoe.card,
        borderRadius: BorderRadius.circular(YaoeTokens.radiusXl),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: CallbackShortcuts(
                  bindings: {
                    const SingleActivator(LogicalKeyboardKey.enter): _submit,
                    const SingleActivator(
                      LogicalKeyboardKey.numpadEnter,
                    ): _submit,
                  },
                  child: TextField(
                    controller: widget.controller,
                    autofocus: widget.autofocus,
                    minLines: widget.dock ? 1 : 3,
                    maxLines: widget.dock ? 4 : 8,
                    maxLength: maxLength,
                    maxLengthEnforcement: MaxLengthEnforcement.enforced,
                    keyboardType: TextInputType.multiline,
                    textInputAction: TextInputAction.newline,
                    style: theme.textTheme.bodyLarge,
                    decoration: InputDecoration(
                      hintText: _hint,
                      counterText: '',
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      filled: false,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: YaoeTokens.space2),
              ...widget.trailing,
              const SizedBox(width: YaoeTokens.space1),
              FilledButton(
                onPressed: _canSubmit ? _submit : null,
                style: FilledButton.styleFrom(
                  minimumSize: const Size(44, 40),
                  padding: const EdgeInsets.symmetric(
                    horizontal: YaoeTokens.space3,
                  ),
                ),
                child: widget.submitting
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.arrow_upward, size: 18),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(top: YaoeTokens.space1),
            child: Row(
              children: [
                EnginePicker(
                  value: widget.engine,
                  onChanged: widget.onEngineChanged,
                  locked: widget.mode == ComposerMode.followUp,
                ),
                const SizedBox(width: YaoeTokens.space2),
                Expanded(
                  child: Text(
                    'Enter 提交 · Shift+Enter 换行 · $length/$maxLength',
                    textAlign: TextAlign.end,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
