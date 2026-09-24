import 'package:flutter/material.dart';

import '../widgets/common.dart';
import 'impurities_screen.dart';
import 'peak_search_screen.dart';
import 'settings_screen.dart';
import 'solvents_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      body: IndexedStack(
        index: _index,
        children: const [
          SolventsScreen(),
          ImpuritiesScreen(),
          PeakSearchScreen(),
          SettingsScreen(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.science_outlined),
            selectedIcon: const Icon(Icons.science),
            label: l10n.tabSolvents,
          ),
          NavigationDestination(
            icon: const Icon(Icons.list_alt_outlined),
            selectedIcon: const Icon(Icons.list_alt),
            label: l10n.tabImpurities,
          ),
          NavigationDestination(
            icon: const Icon(Icons.manage_search_outlined),
            selectedIcon: const Icon(Icons.manage_search),
            label: l10n.tabPeakSearch,
          ),
          NavigationDestination(
            icon: const Icon(Icons.settings_outlined),
            selectedIcon: const Icon(Icons.settings),
            label: l10n.tabSettings,
          ),
        ],
      ),
    );
  }
}
