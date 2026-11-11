import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_info.dart';
import '../../core/router/app_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../data/models/enums.dart';
import '../../shared/widgets/common.dart';
import '../../state/app_state.dart';
import '../../core/utils/responsive.dart';

/// 14 Profil — statistik, kontribusi SDG 12, preferensi, dan informasi.
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final s = context.watch<AppState>();
    final avoided = s.countOf(OverclaimCategory.overclaim);

    return Scaffold(
      body: SafeArea(
        child: ResponsiveCenter(
            child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          children: [
            Text('Profil', style: t.headlineSmall),
            const SizedBox(height: 16),
            AppCard(
              padding: const EdgeInsets.all(20),
              child: Column(children: [
                Row(children: [
                  UserAvatar(initials: s.initials, radius: 28),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(s.userName, style: t.titleMedium),
                      Text('Pengguna Klaira', style: t.bodySmall),
                    ]),
                  ),
                  IconButton(
                    tooltip: 'Ubah nama',
                    icon: const Icon(Icons.edit_outlined, color: AppColors.ink500),
                    onPressed: () => _editName(context, s),
                  ),
                ]),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(color: AppColors.background, borderRadius: AppRadius.mdAll),
                  child: Row(children: [
                    _Stat(value: s.totalChecked, label: 'Iklan dicek'),
                    _Stat(value: avoided, label: 'Overclaim'),
                    _Stat(value: s.savedCount, label: 'Disimpan'),
                  ]),
                ),
              ]),
            ),
            const SizedBox(height: 16),
            AppCard(
              color: AppColors.accent100,
              borderColor: null,
              child: Row(children: [
                const IconTile(
                    icon: Icons.eco_outlined, color: AppColors.surface, background: AppColors.accent500, size: 44),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('Kontribusimu untuk SDG 12', style: t.titleSmall?.copyWith(color: AppColors.accent600)),
                    const SizedBox(height: 2),
                    Text(
                      avoided == 0
                          ? 'Mulai cek iklan untuk menghindari pembelian karena klaim berlebihan.'
                          : 'Kamu sudah mengenali $avoided iklan dengan klaim berlebihan sebelum membeli.',
                      style: t.bodyMedium,
                    ),
                  ]),
                ),
              ]),
            ),
            const SizedBox(height: AppSpacing.section),
            _Group(title: 'Preferensi', rows: [
              _Row(icon: Icons.language_rounded, label: 'Bahasa', value: 'Indonesia', onTap: () {}),
              _Row(
                icon: Icons.notifications_none_rounded,
                label: 'Notifikasi edukasi',
                trailing: Switch(value: s.eduNotification, onChanged: s.setEduNotification),
              ),
              _Row(
                icon: Icons.slideshow_outlined,
                label: 'Tampilkan pengenalan lagi',
                onTap: () async {
                  await s.resetOnboarding();
                  if (context.mounted) context.go(AppRoutes.onboarding);
                },
              ),
            ]),
            const SizedBox(height: AppSpacing.section),
            _Group(title: 'Tentang', rows: [
              _Row(
                  icon: Icons.auto_awesome_outlined,
                  label: 'Tentang Model Neurofuzzy',
                  onTap: () => _info(context, _modelInfo)),
              _Row(
                  icon: Icons.help_outline_rounded,
                  label: 'Panduan Penggunaan',
                  onTap: () => _info(context, _guideInfo)),
              _Row(
                  icon: Icons.verified_user_outlined,
                  label: 'Kebijakan Privasi',
                  onTap: () => _info(context, _privacyInfo)),
              _Row(
                icon: Icons.info_outline_rounded,
                label: 'Tentang Klaira',
                value: 'v${AppInfo.version}',
                onTap: () => showAboutDialog(
                  context: context,
                  applicationName: AppInfo.name,
                  applicationVersion: AppInfo.version,
                  applicationIcon: ClipRRect(
                    borderRadius: AppRadius.mdAll,
                    child: Image.asset('assets/images/logo.png', width: 48, height: 48),
                  ),
                  children: [
                    Text(AppInfo.projectTitle, style: t.bodyMedium),
                    const SizedBox(height: 12),
                    Text(AppInfo.team.join('\n'), style: t.bodySmall),
                    const SizedBox(height: 8),
                    Text(AppInfo.institution, style: t.bodySmall),
                  ],
                ),
              ),
            ]),
            const SizedBox(height: AppSpacing.section),
            // Identitas aplikasi (Image.asset dari assets/images/logo.png).
            Row(children: [
              ClipRRect(
                borderRadius: AppRadius.mdAll,
                child: Image.asset('assets/images/logo.png', width: 40, height: 40, semanticLabel: 'Logo Klaira'),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('${AppInfo.name} v${AppInfo.version}', style: t.titleSmall),
                  Text('Proyek Mobile Front End · Mendukung SDG 12', style: t.bodySmall),
                ]),
              ),
            ]),
            const SizedBox(height: AppSpacing.lg),
            Material(
              color: AppColors.dangerBg,
              borderRadius: AppRadius.lgAll,
              child: InkWell(
                borderRadius: AppRadius.lgAll,
                onTap: () => _confirmReset(context, s),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    const Icon(Icons.delete_outline_rounded, color: AppColors.danger, size: 20),
                    const SizedBox(width: 8),
                    Text('Hapus Semua Riwayat', style: t.titleSmall?.copyWith(color: AppColors.danger)),
                  ]),
                ),
              ),
            ),
          ],
        )),
      ),
    );
  }

  static const _modelInfo = (
    'Tentang Model Neurofuzzy',
    'Klaira dirancang untuk menampilkan hasil model Adaptive Neuro-Fuzzy Inference System (ANFIS). '
        'Model membaca enam fitur tekstual — kata absolut, klaim medis, klaim waktu, klaim otoritas, superlatif, '
        'dan bahasa emosional — lalu menghitung derajat keanggotaan RENDAH, SEDANG, dan TINGGI. '
        'Aturan JIKA–MAKA yang aktif digabung menjadi skor overclaim 0–100.\n\n'
        'Pada prototipe ini, proses analisis disimulasikan secara lokal dengan aturan yang meniru model, '
        'sehingga hasil hanya untuk demonstrasi antarmuka.',
  );
  static const _guideInfo = (
    'Panduan Penggunaan',
    '1. Tekan tombol Cek di tengah navigasi bawah.\n'
        '2. Tempel deskripsi produk, atau pilih Tempel Link lalu Ambil Deskripsi.\n'
        '3. Tekan Analisis Klaim dan tunggu prosesnya.\n'
        '4. Baca skor, frasa yang ditandai, fitur, dan aturan fuzzy.\n'
        '5. Ketuk fitur atau frasa untuk melihat penjelasan lengkap.\n'
        '6. Simpan hasil penting; semua hasil tersimpan di Riwayat.',
  );
  static const _privacyInfo = (
    'Kebijakan Privasi',
    'Seluruh riwayat dan preferensi disimpan hanya di perangkat ini. '
        'Prototipe Klaira tidak mengirim teks iklan, riwayat, atau data pribadi ke server mana pun. '
        'Kamu dapat menghapus semua riwayat kapan saja melalui menu Profil.',
  );

  static void _info(BuildContext context, (String, String) info) {
    final t = Theme.of(context).textTheme;
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
          child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(info.$1, style: t.titleLarge),
            const SizedBox(height: 12),
            Text(info.$2, style: t.bodyMedium),
          ]),
        ),
      ),
    );
  }

  static Future<void> _editName(BuildContext context, AppState s) async {
    final c = TextEditingController(text: s.userName);
    final name = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Ubah nama'),
        content: TextField(
          controller: c,
          autofocus: true,
          textCapitalization: TextCapitalization.words,
          decoration: const InputDecoration(hintText: 'Nama kamu'),
          onSubmitted: (v) => Navigator.pop(ctx, v),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
          TextButton(onPressed: () => Navigator.pop(ctx, c.text), child: const Text('Simpan')),
        ],
      ),
    );
    c.dispose();
    if (name != null) await s.setUserName(name);
  }

  static Future<void> _confirmReset(BuildContext context, AppState s) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus semua riwayat?'),
        content: const Text('Semua hasil analisis di perangkat ini akan dihapus.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Batal')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Hapus', style: TextStyle(color: AppColors.danger)),
          ),
        ],
      ),
    );
    if (ok == true) await s.clearHistory();
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.value, required this.label});
  final int value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Expanded(
      child: Column(children: [
        Text('$value', style: t.titleMedium),
        Text(label, style: t.bodySmall),
      ]),
    );
  }
}

class _Group extends StatelessWidget {
  const _Group({required this.title, required this.rows});
  final String title;
  final List<_Row> rows;

  @override
  Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title.toUpperCase(), style: Theme.of(context).textTheme.labelSmall),
        const SizedBox(height: 8),
        AppCard(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(children: [
            for (var i = 0; i < rows.length; i++) ...[
              rows[i],
              if (i < rows.length - 1) const Divider(),
            ],
          ]),
        ),
      ]);
}

class _Row extends StatelessWidget {
  const _Row({required this.icon, required this.label, this.value, this.trailing, this.onTap});
  final IconData icon;
  final String label;
  final String? value;
  final Widget? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return InkWell(
      onTap: onTap,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 52),
        child: Row(children: [
          Icon(icon, size: 20, color: AppColors.ink700),
          const SizedBox(width: 12),
          Expanded(child: Text(label, style: t.labelMedium)),
          if (value != null) Text(value!, style: t.bodyMedium?.copyWith(color: AppColors.ink500)),
          if (trailing != null)
            trailing!
          else ...[
            const SizedBox(width: 4),
            const Icon(Icons.chevron_right_rounded, color: AppColors.ink300, size: 20),
          ],
        ]),
      ),
    );
  }
}
