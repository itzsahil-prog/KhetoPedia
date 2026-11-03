import 'package:flutter/material.dart';

import '../../../core/localization/localization.dart';
import '../../../shared/widgets/widgets.dart';

/// Soil test history screen.
class SoilHistoryScreen extends StatelessWidget {
  const SoilHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l.soilHistory),
      ),
      body: EmptyState(
        icon: Icons.history,
        title: l.soilHistory,
        message: l.soilHistoryEmpty,
      ),
    );
  }
}
