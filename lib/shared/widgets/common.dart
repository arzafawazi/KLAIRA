import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../data/models/enums.dart';

/// Kartu dasar: latar putih, radius 16, garis tipis. (Figma: card)
class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(AppSpacing.lg),
    this.color = AppColors.surface,
    this.borderColor = AppColors.ink100,
    this.radius = AppRadius.lg,
    this.onTap,
    this.elevated = false,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color color;
  final Color? borderColor;
  final double radius;
  final VoidCallback? onTap;
  final bool elevated;

  @override
  Widget build(BuildContext context) {
    final r = BorderRadius.circular(radius);
    return Material(
      color: color,
      borderRadius: r,
      elevation: 0,
      child: Ink(
        decoration: BoxDecoration(
          borderRadius: r,
          border: borderColor == null ? null : Border.all(color: borderColor!),
          boxShadow: elevated
              ? [BoxShadow(color: AppColors.ink900.withValues(alpha: 0.06), blurRadius: 12, offset: const Offset(0, 4))]
              : null,
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: r,
          child: Padding(padding: padding, child: child),
        ),
      ),
    );
  }
}

/// Label kategori hasil (Aman / Waspada / Overclaim) — selalu ikon + teks + warna.
class StatusBadge extends StatelessWidget {
  const StatusBadge({super.key, required this.category, this.large = false});

  final OverclaimCategory category;
  final bool large;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Container(
      padding: EdgeInsets.fromLTRB(large ? 10 : 8, 4, large ? 12 : 10, 4),
      decoration: BoxDecoration(color: category.background, borderRadius: AppRadius.fullAll),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(category.icon, size: large ? 16 : 14, color: category.color),
        const SizedBox(width: 4),
        Text(category.label,
            style: (large ? t.labelMedium : t.bodySmall)?.copyWith(color: category.color, fontWeight: FontWeight.w600)),
      ]),
    );
  }
}

/// Pil kecil berwarna (kategori, tingkat, kata pemicu).
class Pill extends StatelessWidget {
  const Pill({
    super.key,
    required this.label,
    this.color = AppColors.primary700,
    this.background = AppColors.primary50,
    this.icon,
    this.outlined = false,
  });

  final String label;
  final Color color;
  final Color background;
  final IconData? icon;
  final bool outlined;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: outlined ? AppColors.surface : background,
        borderRadius: AppRadius.fullAll,
        border: outlined ? Border.all(color: AppColors.ink200) : null,
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        if (icon != null) ...[Icon(icon, size: 14, color: color), const SizedBox(width: 6)],
        Flexible(
          child: Text(label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: color, fontWeight: FontWeight.w600)),
        ),
      ]),
    );
  }
}

/// Kotak ikon persegi membulat (Figma: icon tile).
class IconTile extends StatelessWidget {
  const IconTile({
    super.key,
    required this.icon,
    this.color = AppColors.primary600,
    this.background = AppColors.primary50,
    this.size = 40,
    this.iconSize,
  });

  final IconData icon;
  final Color color;
  final Color background;
  final double size;
  final double? iconSize;

  @override
  Widget build(BuildContext context) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(color: background, borderRadius: AppRadius.mdAll),
        child: Icon(icon, color: color, size: iconSize ?? size * 0.5),
      );
}

/// Tombol ikon bulat dengan garis tepi (Figma: Back / Action button).
class CircleIconButton extends StatelessWidget {
  const CircleIconButton(
      {super.key, required this.icon, required this.onPressed, required this.tooltip, this.size = 44});

  final IconData icon;
  final VoidCallback? onPressed;
  final String tooltip;
  final double size;

  @override
  Widget build(BuildContext context) => Tooltip(
        message: tooltip,
        child: Material(
          color: AppColors.surface,
          shape: const CircleBorder(side: BorderSide(color: AppColors.ink200)),
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: onPressed,
            child: SizedBox.square(dimension: size, child: Icon(icon, size: 20, color: AppColors.ink900)),
          ),
        ),
      );
}

/// Judul section dengan subjudul & aksi opsional.
class SectionHeader extends StatelessWidget {
  const SectionHeader({super.key, required this.title, this.subtitle, this.icon, this.actionLabel, this.onAction});

  final String title;
  final String? subtitle;
  final IconData? icon;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
      Expanded(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            if (icon != null) ...[Icon(icon, size: 18, color: AppColors.primary600), const SizedBox(width: 8)],
            Flexible(child: Text(title, style: t.titleMedium)),
          ]),
          if (subtitle != null) ...[const SizedBox(height: 2), Text(subtitle!, style: t.bodySmall)],
        ]),
      ),
      if (actionLabel != null)
        TextButton(
          onPressed: onAction,
          style:
              TextButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 8), minimumSize: const Size(44, 36)),
          child: Text(actionLabel!, style: t.titleSmall?.copyWith(color: AppColors.primary600)),
        ),
    ]);
  }
}

/// Banner informasi (ikon + teks).
class InfoBanner extends StatelessWidget {
  const InfoBanner({
    super.key,
    required this.text,
    this.icon = Icons.info_outline,
    this.color = AppColors.primary700,
    this.background = AppColors.primary50,
  });

  final String text;
  final IconData icon;
  final Color color;
  final Color background;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(color: background, borderRadius: AppRadius.mdAll),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 10),
          Expanded(child: Text(text, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: color))),
        ]),
      );
}

/// Bar kemajuan berwarna (derajat keanggotaan / kekuatan aturan).
class LevelBar extends StatelessWidget {
  const LevelBar({super.key, required this.value, required this.color, this.height = 6});

  final double value;
  final Color color;
  final double height;

  @override
  Widget build(BuildContext context) => ClipRRect(
        borderRadius: AppRadius.fullAll,
        child: LinearProgressIndicator(
          value: value.clamp(0.0, 1.0),
          minHeight: height,
          color: color,
          backgroundColor: AppColors.ink100,
        ),
      );
}

/// Area tombol bawah yang menempel (Figma: Bottom bar).
class BottomActionBar extends StatelessWidget {
  const BottomActionBar({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) => DecoratedBox(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          border: Border(top: BorderSide(color: AppColors.ink100)),
        ),
        child: SafeArea(
          top: false,
          minimum: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.md, AppSpacing.lg, AppSpacing.md),
          child: child,
        ),
      );
}

/// Tampilan kosong yang ramah.
class EmptyState extends StatelessWidget {
  const EmptyState({super.key, required this.icon, required this.title, required this.message, this.action});

  final IconData icon;
  final String title;
  final String message;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 48),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        IconTile(icon: icon, size: 64),
        const SizedBox(height: 16),
        Text(title, style: t.titleMedium, textAlign: TextAlign.center),
        const SizedBox(height: 6),
        Text(message, style: t.bodyMedium?.copyWith(color: AppColors.ink500), textAlign: TextAlign.center),
        if (action != null) ...[const SizedBox(height: 20), action!],
      ]),
    );
  }
}

/// Avatar inisial pengguna berbasis [CircleAvatar] (Beranda & Profil).
class UserAvatar extends StatelessWidget {
  const UserAvatar({super.key, required this.initials, this.radius = 22});

  final String initials;
  final double radius;

  @override
  Widget build(BuildContext context) => Semantics(
        label: 'Avatar $initials',
        child: CircleAvatar(
          radius: radius,
          backgroundColor: AppColors.primary100,
          child: Text(
            initials,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColors.primary700,
                  fontSize: radius * 0.62,
                ),
          ),
        ),
      );
}

/// Teks sapaan dua gaya ("Halo, **Nama**") memakai [RichText].
class GreetingText extends StatelessWidget {
  const GreetingText({super.key, required this.name});

  final String name;

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.titleLarge;
    return RichText(
      textScaler: MediaQuery.textScalerOf(context),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      text: TextSpan(style: style?.copyWith(fontWeight: FontWeight.w500), children: [
        const TextSpan(text: 'Halo, '),
        TextSpan(text: name, style: style?.copyWith(color: AppColors.primary700)),
        const WidgetSpan(
          alignment: PlaceholderAlignment.middle,
          child: Padding(
            padding: EdgeInsets.only(left: 6),
            child: Icon(Icons.waving_hand_rounded, size: 20, color: AppColors.accent500),
          ),
        ),
      ]),
    );
  }
}
