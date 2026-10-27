import 'package:flutter/material.dart';
import '../../shared/widgets/widgets.dart';
import '../../core/localization/localization.dart';

/// AI Agri-Assistant feature — shell placeholder.
class AIScreen extends StatelessWidget {
  const AIScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Scaffold(
      body: EmptyState(
        icon: Icons.psychology_outlined,
        title: l.tabAI,
        message: 'AI assistant coming soon.',
      ),
    );
  }
}
