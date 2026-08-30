import 'package:flutter/material.dart';

import '../feature.dart';

class PlaceholderScreen extends StatelessWidget {
  const PlaceholderScreen({super.key, required this.feature});

  final Feature feature;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(feature.title)),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(feature.icon, size: 56, color: theme.colorScheme.outline),
            const SizedBox(height: 16),
            Text('準備中', style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(
              'Issue #${feature.issueNumber} で検討中',
              style: theme.textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}
