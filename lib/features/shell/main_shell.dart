import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/router/app_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/responsive.dart';
import '../../shared/widgets/klaira_logo.dart';

/// Kerangka 4 tab utama + tombol Cek (Figma: `Bottom Nav`).
///
/// **Adaptif:**
/// - Layar *compact* (HP potret) → bottom navigation dengan tombol Cek di tengah.
/// - Layar *medium* (HP lanskap / tablet kecil) → [NavigationRail] ringkas.
/// - Layar *expanded* (tablet lanskap) → [NavigationRail] dengan label lengkap.
class MainShell extends StatelessWidget {
  const MainShell({super.key, required this.shell});

  final StatefulNavigationShell shell;

  static const _tabs = [
    (icon: Icons.home_outlined, active: Icons.home_rounded, label: 'Beranda'),
    (icon: Icons.history_rounded, active: Icons.history_rounded, label: 'Riwayat'),
    (icon: Icons.menu_book_outlined, active: Icons.menu_book_rounded, label: 'Edukasi'),
    (icon: Icons.person_outline_rounded, active: Icons.person_rounded, label: 'Profil'),
  ];

  void _onTap(int i) => shell.goBranch(i, initialLocation: i == shell.currentIndex);

  @override
  Widget build(BuildContext context) {
    final size = context.windowSize;
    if (size.isCompact) return _compact(context);
    return _rail(context, extended: size.isExpanded);
  }

  // ------------------------------------------------------------------ compact
  Widget _compact(BuildContext context) => Scaffold(
        body: shell,
        bottomNavigationBar: DecoratedBox(
          decoration: const BoxDecoration(
            color: AppColors.surface,
            border: Border(top: BorderSide(color: AppColors.ink100)),
          ),
          child: SafeArea(
            top: false,
            child: SizedBox(
              height: 72,
              child: Row(children: [
                _NavItem(tab: _tabs[0], selected: shell.currentIndex == 0, onTap: () => _onTap(0)),
                _NavItem(tab: _tabs[1], selected: shell.currentIndex == 1, onTap: () => _onTap(1)),
                const Expanded(child: Center(child: _CheckButton())),
                _NavItem(tab: _tabs[2], selected: shell.currentIndex == 2, onTap: () => _onTap(2)),
                _NavItem(tab: _tabs[3], selected: shell.currentIndex == 3, onTap: () => _onTap(3)),
              ]),
            ),
          ),
        ),
      );

  // ---------------------------------------------------------- medium/expanded
  Widget _rail(BuildContext context, {required bool extended}) {
    final t = Theme.of(context).textTheme;
    return Scaffold(
      body: Row(children: [
        SafeArea(
          right: false,
          child: NavigationRail(
            extended: extended,
            minExtendedWidth: 220,
            backgroundColor: AppColors.surface,
            indicatorColor: AppColors.primary50,
            selectedIndex: shell.currentIndex,
            onDestinationSelected: _onTap,
            labelType: extended ? NavigationRailLabelType.none : NavigationRailLabelType.all,
            selectedIconTheme: const IconThemeData(color: AppColors.primary600),
            unselectedIconTheme: const IconThemeData(color: AppColors.ink500),
            selectedLabelTextStyle: t.bodySmall?.copyWith(color: AppColors.primary600, fontWeight: FontWeight.w700),
            unselectedLabelTextStyle: t.bodySmall,
            leading: Padding(
              padding: const EdgeInsets.only(top: 8, bottom: 16),
              child: Column(children: [
                if (extended)
                  Row(mainAxisSize: MainAxisSize.min, children: [
                    const KlairaLogo(size: 32),
                    const SizedBox(width: 10),
                    Text('Klaira', style: t.titleMedium?.copyWith(color: AppColors.primary700)),
                  ])
                else
                  const KlairaLogo(size: 36),
                const SizedBox(height: 20),
                extended
                    ? FilledButton.icon(
                        key: const Key('rail-check'),
                        onPressed: () => context.push(AppRoutes.check),
                        icon: const Icon(Icons.document_scanner_outlined, size: 20),
                        label: const Text('Cek Iklan'),
                      )
                    : const _CheckButton(),
              ]),
            ),
            destinations: [
              for (final tab in _tabs)
                NavigationRailDestination(
                  icon: Icon(tab.icon),
                  selectedIcon: Icon(tab.active),
                  label: Text(tab.label),
                ),
            ],
          ),
        ),
        const VerticalDivider(width: 1),
        Expanded(child: shell),
      ]),
    );
  }
}

class _CheckButton extends StatelessWidget {
  const _CheckButton();

  @override
  Widget build(BuildContext context) => Tooltip(
        message: 'Cek iklan',
        child: Material(
          color: AppColors.primary600,
          shape: const CircleBorder(),
          elevation: 6,
          shadowColor: AppColors.primary700.withValues(alpha: 0.4),
          child: InkWell(
            key: const Key('nav-check'),
            customBorder: const CircleBorder(),
            onTap: () => context.push(AppRoutes.check),
            child: const SizedBox.square(
              dimension: 56,
              child: Icon(Icons.document_scanner_outlined, color: AppColors.surface, size: 26),
            ),
          ),
        ),
      );
}

class _NavItem extends StatelessWidget {
  const _NavItem({required this.tab, required this.selected, required this.onTap});

  final ({IconData icon, IconData active, String label}) tab;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected ? AppColors.primary600 : AppColors.ink500;
    return Expanded(
      child: Semantics(
        selected: selected,
        button: true,
        label: tab.label,
        child: InkResponse(
          onTap: onTap,
          radius: 36,
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(selected ? tab.active : tab.icon, color: color, size: 24),
            const SizedBox(height: 4),
            Text(
              tab.label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: color,
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                  ),
            ),
          ]),
        ),
      ),
    );
  }
}
