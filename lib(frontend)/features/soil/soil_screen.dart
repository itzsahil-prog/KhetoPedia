import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/localization/localization.dart';
import '../../shared/widgets/widgets.dart';
import 'soil/presentation/soil_test_form_screen.dart';
import 'soil/presentation/soil_history_screen.dart';

/// Soil analysis feature screen.
class SoilScreen extends ConsumerWidget {
  const SoilScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l.soilTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            tooltip: l.soilHistory,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SoilHistoryScreen()),
              );
            },
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.science_outlined,
                size: 120,
                color: Theme.of(context).colorScheme.primary.withAlpha(128),
              ),
              const SizedBox(height: 32),
              Text(
                l.soilTitle,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 16),
              Text(
                'Submit soil test results to track soil health and toxicity levels',
                style: Theme.of(context).textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),
              AppButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const SoilTestFormScreen()),
                  );
                },
                label: l.soilNewTest,
                icon: Icons.add,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
