import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/localization/localization.dart';
import '../../shared/widgets/widgets.dart';
import 'ai/presentation/ai_chat_screen.dart';

/// AI Agricultural Assistant feature screen.
class AIScreen extends ConsumerWidget {
  const AIScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);

    return const AIChatScreen();
  }
}
