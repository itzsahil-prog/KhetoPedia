import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../core/localization/localization.dart';
import '../../../shared/widgets/widgets.dart';
import '../domain/crop_scan.dart';

/// Screen displaying crop scan analysis results.
class ScanResultScreen extends StatelessWidget {
  const ScanResultScreen({super.key, required this.scan});

  final CropScan scan;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(l.scanTitle),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Image
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: AspectRatio(
              aspectRatio: 1,
              child: CachedNetworkImage(
                imageUrl: scan.imageUrl,
                fit: BoxFit.cover,
                placeholder: (_, __) => Container(
                  color: cs.surfaceContainerHighest,
                  child: const Center(child: CircularProgressIndicator()),
                ),
                errorWidget: (_, __, ___) => Container(
                  color: cs.surfaceContainerHighest,
                  child: const Icon(Icons.error_outline, size: 48),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Crop detection
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.grass_outlined, color: cs.primary),
                    const SizedBox(width: 12),
                    Text(l.scanCropDetected, style: tt.titleMedium),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  scan.cropType.toUpperCase(),
                  style: tt.headlineSmall?.copyWith(
                    color: cs.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text('${l.scanConfidence}: ', style: tt.bodyMedium),
                    Text(
                      '${(scan.confidence * 100).toStringAsFixed(1)}%',
                      style: tt.bodyMedium?.copyWith(
                        color: cs.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Disease detection
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      scan.isHealthy ? Icons.check_circle_outline : Icons.warning_outlined,
                      color: scan.isHealthy ? Colors.green : Colors.orange,
                    ),
                    const SizedBox(width: 12),
                    Text(l.scanDiseaseDetected, style: tt.titleMedium),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  scan.disease ?? l.scanHealthy,
                  style: tt.headlineSmall?.copyWith(
                    color: scan.isHealthy ? Colors.green : Colors.orange,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (scan.diseaseConfidence != null) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text('${l.scanConfidence}: ', style: tt.bodyMedium),
                      Text(
                        '${(scan.diseaseConfidence! * 100).toStringAsFixed(1)}%',
                        style: tt.bodyMedium?.copyWith(
                          color: scan.isHealthy ? Colors.green : Colors.orange,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),

          // Recommendations
          if (scan.recommendations != null && scan.recommendations!.isNotEmpty) ...[
            const SizedBox(height: 16),
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.lightbulb_outline, color: cs.primary),
                      const SizedBox(width: 12),
                      Text(l.scanRecommendations, style: tt.titleMedium),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ...scan.recommendations!.map((rec) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.check, size: 20, color: cs.primary),
                        const SizedBox(width: 8),
                        Expanded(child: Text(rec, style: tt.bodyMedium)),
                      ],
                    ),
                  )),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
