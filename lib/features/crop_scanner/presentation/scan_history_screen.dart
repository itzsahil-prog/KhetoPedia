import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../../../core/localization/localization.dart';
import '../../../shared/widgets/widgets.dart';
import '../application/crop_scanner_provider.dart';
import 'scan_result_screen.dart';

/// Crop scan history list screen.
class ScanHistoryScreen extends ConsumerWidget {
  const ScanHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final historyAsync = ref.watch(cropScanHistoryProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l.scanHistory),
      ),
      body: historyAsync.when(
        loading: () => const LoadingView(),
        error: (err, _) => ErrorView(
          message: l.errorGeneric,
          onRetry: () => ref.invalidate(cropScanHistoryProvider),
        ),
        data: (scans) {
          if (scans.isEmpty) {
            return EmptyState(
              icon: Icons.history,
              title: l.scanHistory,
              message: l.scanHistoryEmpty,
            );
          }

          return RefreshIndicator(
            onRefresh: () => ref.refresh(cropScanHistoryProvider.future),
            child: ListView.separated(
              padding: const EdgeInsets.all(20),
              itemCount: scans.length,
              separatorBuilder: (_, __) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                final scan = scans[index];
                return AppCard(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ScanResultScreen(scan: scan),
                      ),
                    );
                  },
                  child: Row(
                    children: [
                      // Thumbnail
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: SizedBox(
                          width: 80,
                          height: 80,
                          child: CachedNetworkImage(
                            imageUrl: scan.imageUrl,
                            fit: BoxFit.cover,
                            placeholder: (_, __) => Container(
                              color: Theme.of(context).colorScheme.surfaceContainerHighest,
                            ),
                            errorWidget: (_, __, ___) => Container(
                              color: Theme.of(context).colorScheme.surfaceContainerHighest,
                              child: const Icon(Icons.image_not_supported),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Details
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              scan.cropType.toUpperCase(),
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              scan.disease ?? l.scanHealthy,
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: scan.isHealthy ? Colors.green : Colors.orange,
                              ),
                            ),
                            if (scan.createdAt != null) ...[
                              const SizedBox(height: 4),
                              Text(
                                timeago.format(scan.createdAt!),
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      const Icon(Icons.chevron_right),
                    ],
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
