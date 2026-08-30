import 'package:flutter/material.dart';

import '../feature.dart';
import '../history/history_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final sections = <Widget>[
      ListTile(
        leading: CircleAvatar(
          backgroundColor: theme.colorScheme.primaryContainer,
          foregroundColor: theme.colorScheme.onPrimaryContainer,
          child: const Icon(Icons.insights_outlined),
        ),
        title: const Text('きろく'),
        subtitle: const Text('スコアの履歴と推移'),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (context) => const HistoryScreen(),
            ),
          );
        },
      ),
      const Divider(height: 1),
    ];

    for (final category in FeatureCategory.values) {
      final items =
          features.where((f) => f.category == category).toList();
      if (items.isEmpty) continue;
      sections.add(Padding(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 4),
        child: Text(
          category.label,
          style: theme.textTheme.labelLarge
              ?.copyWith(color: theme.colorScheme.primary),
        ),
      ));
      for (final feature in items) {
        sections.add(_FeatureTile(feature: feature));
      }
    }

    return Scaffold(
      appBar: AppBar(title: const Text('sense')),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: sections,
      ),
    );
  }
}

class _FeatureTile extends StatelessWidget {
  const _FeatureTile({required this.feature});

  final Feature feature;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: theme.colorScheme.secondaryContainer,
        foregroundColor: theme.colorScheme.onSecondaryContainer,
        child: Icon(feature.icon),
      ),
      title: Text(feature.title),
      subtitle: Text(feature.subtitle),
      trailing: feature.isImplemented
          ? const Icon(Icons.chevron_right)
          : Text('準備中', style: theme.textTheme.labelSmall),
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (context) => feature.buildScreen(context),
          ),
        );
      },
    );
  }
}
