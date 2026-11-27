import 'package:flutter/material.dart';

import '../theme.dart';

/// Các mảnh dựng nên màn Cài đặt. Tách ra để màn hình chỉ còn phần nội dung.
class SettingsGroup extends StatelessWidget {
  const SettingsGroup({super.key, required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(4, 0, 4, 7),
            child: Text(
              title.toUpperCase(),
              style: TextStyle(
                fontSize: 10.5,
                letterSpacing: 1.2,
                fontWeight: FontWeight.w600,
                color: c.inkFaint,
              ),
            ),
          ),
          DecoratedBox(
            decoration: c.cardBox(radius: Radii.card),
            child: Column(
              children: [
                for (var i = 0; i < children.length; i++) ...[
                  if (i > 0) Divider(height: 1, color: c.line),
                  children[i],
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class SettingsRow extends StatelessWidget {
  const SettingsRow({
    super.key,
    required this.label,
    this.sublabel,
    this.value,
    this.accent,
    this.onTap,
  });

  final String label;
  final String? sublabel, value;
  final Color? accent;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        child: Row(
          children: [
            Expanded(
              child: _Label(label: label, sublabel: sublabel, color: accent),
            ),
            if (value != null)
              Text(value!, style: TextStyle(fontSize: 14, color: c.inkFaint)),
          ],
        ),
      ),
    );
  }
}

class SettingsSwitch extends StatelessWidget {
  const SettingsSwitch({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
    this.sublabel,
  });

  final String label;
  final String? sublabel;
  final bool value;

  /// `null` thì công tắc mờ đi — dùng khi máy không hỗ trợ tính năng đó.
  final ValueChanged<bool>? onChanged;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: onChanged == null ? 0.5 : 1,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 8, 10, 8),
        child: Row(
          children: [
            Expanded(
              child: _Label(label: label, sublabel: sublabel),
            ),
            Switch.adaptive(value: value, onChanged: onChanged),
          ],
        ),
      ),
    );
  }
}

class SettingsSlider extends StatelessWidget {
  const SettingsSlider({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
    this.onChangeEnd,
    this.min = 0.2,
    this.max = 0.9,
    this.format,
  });

  final String label;
  final double value;
  final double min, max;

  /// Cách hiện con số bên phải. Không truyền thì hiện dạng bội tốc độ.
  final String Function(double)? format;
  final ValueChanged<double> onChanged;
  final ValueChanged<double>? onChangeEnd;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: _Label(label: label)),
              Text(
                format?.call(value) ?? '${(value * 2).toStringAsFixed(1)}×',
                style: TextStyle(fontSize: 14, color: c.inkFaint),
              ),
            ],
          ),
          Slider(
            value: value.clamp(min, max),
            min: min,
            max: max,
            onChanged: onChanged,
            // Nghe thử ngay khi thả tay — chỉnh tốc độ mà không nghe được thì
            // chỉnh mò.
            onChangeEnd: onChangeEnd,
          ),
        ],
      ),
    );
  }
}

class _Label extends StatelessWidget {
  const _Label({required this.label, this.sublabel, this.color});

  final String label;
  final String? sublabel;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label, style: TextStyle(fontSize: 15, color: color ?? c.ink)),
        if (sublabel != null)
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Text(
              sublabel!,
              style: TextStyle(fontSize: 12, height: 1.3, color: c.inkFaint),
            ),
          ),
      ],
    );
  }
}
