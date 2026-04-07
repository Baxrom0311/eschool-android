import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/localization/app_localizations.dart';
import '../../providers/user_provider.dart';

class ChildrenListScreen extends ConsumerWidget {
  const ChildrenListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final userState = ref.watch(userProvider);
    final children = userState.children;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(title: Text(l10n.myChildrenTitle)),
      body: children.isEmpty
          ? Center(
              child: Text(
                l10n.noChildrenFound,
                style: TextStyle(color: colorScheme.onSurfaceVariant),
              ),
            )
          : ListView.builder(
              itemCount: children.length,
              padding: const EdgeInsets.all(16),
              itemBuilder: (context, index) {
                final child = children[index];
                final isSelected = userState.selectedChild?.id == child.id;

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  color: theme.cardColor,
                  elevation: isSelected ? 4 : 1,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: isSelected
                        ? BorderSide(color: colorScheme.primary, width: 2)
                        : BorderSide.none,
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(12),
                    leading: CircleAvatar(
                      backgroundImage: child.avatarUrl != null
                          ? NetworkImage(child.avatarUrl!)
                          : null,
                      child: child.avatarUrl == null
                          ? Text(child.fullName[0].toUpperCase())
                          : null,
                    ),
                    title: Text(
                      child.fullName,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    subtitle: Text(
                      l10n.childClassText(child.className),
                      style: TextStyle(color: colorScheme.onSurfaceVariant),
                    ),
                    trailing: isSelected
                        ? Icon(Icons.check_circle, color: colorScheme.primary)
                        : null,
                    onTap: () {
                      ref.read(userProvider.notifier).selectChild(child);
                      context.pop();
                    },
                  ),
                );
              },
            ),
    );
  }
}
