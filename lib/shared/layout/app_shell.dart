import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/localization/localization.dart';
import 'responsive_layout.dart';

/// Navigation destination descriptor — keeps router and shell in sync.
class _NavDest {
  const _NavDest({
    required this.path,
    required this.icon,
    required this.selectedIcon,
    required this.label,
  });
  final String   path;
  final IconData icon;
  final IconData selectedIcon;
  final String Function(AppLocalizations) label;
}

const List<_NavDest> _destinations = [
  _NavDest(
    path:         '/home',
    icon:         Icons.home_outlined,
    selectedIcon: Icons.home_rounded,
    label:        (l) => l.tabHome,
  ),
  _NavDest(
    path:         '/scan',
    icon:         Icons.center_focus_weak_rounded,
    selectedIcon: Icons.center_focus_strong_rounded,
    label:        (l) => l.tabScan,
  ),
  _NavDest(
    path:         '/fields',
    icon:         Icons.landscape_outlined,
    selectedIcon: Icons.landscape_rounded,
    label:        (l) => l.tabFields,
  ),
  _NavDest(
    path:         '/soil',
    icon:         Icons.science_outlined,
    selectedIcon: Icons.science_rounded,
    label:        (l) => l.tabSoil,
  ),
  _NavDest(
    path:         '/ai',
    icon:         Icons.psychology_outlined,
    selectedIcon: Icons.psychology_rounded,
    label:        (l) => l.tabAI,
  ),
];

/// Top-level scaffold that wraps every primary-navigation screen.
///
/// - Compact screens  → [NavigationBar] (bottom)
/// - Expanded screens → [NavigationRail] (left side)
///
/// Receives the current child from GoRouter's [StatefulShellRoute].
class AppShell extends StatelessWidget {
  const AppShell({
    super.key,
    required this.navigationShell,
  });

  final StatefulNavigationShell navigationShell;

  void _onDestinationSelected(int index) {
    navigationShell.goBranch(
      index,
      // Tap already-selected tab → go to branch initial location.
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l      = AppLocalizations.of(context);
    final layout = ResponsiveLayout.of(context);
    final currentIndex = navigationShell.currentIndex;

    final navDestinations = _destinations
        .map((d) => NavigationDestination(
              icon:             Icon(d.icon),
              selectedIcon:     Icon(d.selectedIcon),
              label:            d.label(l),
              tooltip:          d.label(l),
            ))
        .toList();

    if (layout.isExpanded) {
      // ── Tablet / desktop: NavigationRail ──────────────────────────────
      return Scaffold(
        body: Row(
          children: [
            NavigationRail(
              selectedIndex:     currentIndex,
              onDestinationSelected: _onDestinationSelected,
              labelType:         NavigationRailLabelType.all,
              destinations: _destinations
                  .map((d) => NavigationRailDestination(
                        icon:         Icon(d.icon),
                        selectedIcon: Icon(d.selectedIcon),
                        label:        Text(d.label(l)),
                      ))
                  .toList(),
            ),
            const VerticalDivider(width: 1, thickness: 1),
            Expanded(child: navigationShell),
          ],
        ),
      );
    }

    // ── Phone: NavigationBar (bottom) ────────────────────────────────────
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex:          currentIndex,
        onDestinationSelected:  _onDestinationSelected,
        destinations:           navDestinations,
        animationDuration:      const Duration(milliseconds: 200),
      ),
    );
  }
}
