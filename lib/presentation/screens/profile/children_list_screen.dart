import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/user_provider.dart';

class ChildrenListScreen extends ConsumerWidget {
  const ChildrenListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userState = ref.watch(userProvider);
    final children = userState.children;

    return Scaffold(
      appBar: AppBar(title: const Text('Farzandlarim')),
      body: children.isEmpty
          ? const Center(child: Text('Farzandlar topilmadi'))
          : ListView.builder(
              itemCount: children.length,
              padding: const EdgeInsets.all(16),
              itemBuilder: (context, index) {
                final child = children[index];
                final isSelected = userState.selectedChild?.id == child.id;

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  elevation: isSelected ? 4 : 1,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: isSelected
                        ? BorderSide(color: Theme.of(context).primaryColor, width: 2)
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
                    title: Text(child.fullName, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('${child.className} - Sinf'),
                    trailing: isSelected
                        ? Icon(Icons.check_circle, color: Theme.of(context).primaryColor)
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
