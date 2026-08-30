import 'package:flutter/material.dart';

import '../feature.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('sense')),
      body: ListView.separated(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: features.length,
        separatorBuilder: (_, _) => const Divider(height: 1, indent: 72),
        itemBuilder: (context, index) {
          final feature = features[index];
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
        },
      ),
    );
  }
}
