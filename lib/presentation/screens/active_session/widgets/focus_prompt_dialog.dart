import 'package:flutter/material.dart';
import 'package:srl_app/common_widgets/spacing.dart';
import 'package:srl_app/core/utils/build_context_extensions.dart';
import 'package:srl_app/domain/models/focus_check.dart';

class FocusPromptDialog extends StatelessWidget {
  const FocusPromptDialog({
    required this.onFocusLevelSelected,
    super.key,
  });

  final void Function(FocusLevel) onFocusLevelSelected;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      icon: const Icon(Icons.question_mark_rounded, size: 48),
      title: const Text(
        'Bist du noch fokussiert?',
        textAlign: TextAlign.center,
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Nimm dir einen Moment, um deinen Fokus zu überprüfen.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14),
          ),
          const VerticalSpace(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(
                child: _FocusOption(
                  emoji: '🎯',
                  label: 'Gut',
                  onTap: () {
                    Navigator.of(context).pop();
                    onFocusLevelSelected(FocusLevel.good);
                  },
                ),
              ),
              Expanded(
                child: _FocusOption(
                  emoji: '😐',
                  label: 'Geht so',
                  onTap: () {
                    Navigator.of(context).pop();
                    onFocusLevelSelected(FocusLevel.okay);
                  },
                ),
              ),
              Expanded(
                child: _FocusOption(
                  emoji: '😴',
                  label: 'Abgelenkt',
                  onTap: () {
                    Navigator.of(context).pop();
                    onFocusLevelSelected(FocusLevel.distracted);
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FocusOption extends StatelessWidget {
  const _FocusOption({
    required this.emoji,
    required this.label,
    required this.onTap,
  });

  final String emoji;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 2),
      decoration: BoxDecoration(
        color: context.colorScheme.secondary.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 32)),
              const VerticalSpace(size: SpaceSize.xsmall),
              Text(label, style: const TextStyle(fontSize: 12)),
            ],
          ),
        ),
      ),
    );
  }
}
