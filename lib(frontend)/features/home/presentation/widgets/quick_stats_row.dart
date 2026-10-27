import 'package:flutter/material.dart';

import '../../../../core/localization/localization.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../domain/quick_stat.dart';

/// Horizontally-scrolling row of KPI tiles.
///
/// All labels and values come from [QuickStat] objects returned by the API.
/// No value is invented by the client.
class QuickStatsRow extends StatelessWidget {
  const QuickStatsRow({super.key, required this.stats});

  final List<QuickStat> stats;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);

    if (stats.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: EmptyState(
          icon:    Icons.bar_chart_outlined,
          message: l.dashboardStatsEmpty,
        ),
      );
    }

    return SizedBox(
      height: 96,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: stats.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (ctx, i) => _StatTile(stat: stats[i]),
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({required this.stat});
  final QuickStat stat;

  // Trend icon — only shown when the server sends a trend value.
  Widget? _trendIcon(ColorScheme cs) {
    return switch (stat.trend) {
      'up'     => Icon(Icons.trending_up_rounded,    size: 14, color: cs.primary),
      'down'   => Icon(Icons.trending_down_rounded,  size: 14, color: cs.error),
      'stable' => Icon(Icons.trending_flat_rounded,  size: 14, color: cs.onSurfaceVariant),
      _        => null,
    };
  }

  @override
  Widget build(BuildContext context) {
    final cs      = Theme.of(context).colorScheme;
    final tt      = Theme.of(context).textTheme;
    final trendIc = _trendIcon(cs);

    return Semantics(
      label: '${stat.label}: ${stat.value}${stat.unit != null ? ' ${stat.unit}' : ''}',
      child: Container(
        width: 130,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color:        cs.surface,
          borderRadius: BorderRadius.circular(12),
          border:       Border.all(color: cs.outline),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment:  MainAxisAlignment.spaceBetween,
          children: [
            Text(
              stat.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: tt.labelSmall?.copyWith(color: cs.onSurfaceVariant),
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Text(
                    stat.value,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: tt.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color:      cs.onSurface,
                    ),
                  ),
                ),
                if (stat.unit != null)
                  Text(
                    ' ${stat.unit}',
                    style: tt.labelSmall?.copyWith(color: cs.onSurfaceVariant),
                  ),
                if (trendIc != null) ...[
                  const SizedBox(width: 4),
                  trendIc,
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
