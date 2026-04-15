import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:parent_school_app/core/constants/app_colors.dart';
import 'package:parent_school_app/core/localization/l10n_extension.dart';

import '../../../core/routing/route_names.dart';
import '../../../data/models/gallery_model.dart';
import '../../providers/gallery_provider.dart';

class GalleryScreen extends ConsumerStatefulWidget {
  const GalleryScreen({super.key});

  @override
  ConsumerState<GalleryScreen> createState() => _GalleryScreenState();
}

class _GalleryScreenState extends ConsumerState<GalleryScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(galleryAlbumsProvider.notifier).loadAlbums();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final state = ref.watch(galleryAlbumsProvider);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.galleryTitle), centerTitle: true),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : state.error != null
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.error_outline, size: 48, color: theme.colorScheme.error),
                      const SizedBox(height: 12),
                      Text(l10n.galleryLoadFailed, style: theme.textTheme.bodyLarge),
                      const SizedBox(height: 12),
                      FilledButton.icon(
                        onPressed: () => ref.read(galleryAlbumsProvider.notifier).loadAlbums(),
                        icon: const Icon(Icons.refresh, size: 18),
                        label: Text(l10n.refreshAction),
                      ),
                    ],
                  ),
                )
              : state.albums.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.photo_library_outlined, size: 56, color: AppColors.slate400),
                          const SizedBox(height: 12),
                          Text(l10n.galleryEmpty,
                              style: theme.textTheme.bodyLarge?.copyWith(color: AppColors.slate500)),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: () async => ref.read(galleryAlbumsProvider.notifier).loadAlbums(),
                      child: GridView.builder(
                        padding: const EdgeInsets.all(16),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 0.85,
                        ),
                        itemCount: state.albums.length,
                        itemBuilder: (context, index) => _AlbumCard(
                          album: state.albums[index],
                          isDark: isDark,
                        ),
                      ),
                    ),
    );
  }
}

class _AlbumCard extends StatelessWidget {
  final GalleryAlbumModel album;
  final bool isDark;

  const _AlbumCard({required this.album, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;

    return GestureDetector(
      onTap: () => context.push(RouteNames.galleryAlbum, extra: album),
      child: Container(
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: theme.colorScheme.outline.withValues(alpha: 0.06)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.15 : 0.04),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cover
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                child: album.coverUrl != null
                    ? Image.network(
                        album.coverUrl!,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _PlaceholderCover(),
                      )
                    : _PlaceholderCover(),
              ),
            ),
            // Info
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    album.title,
                    style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${album.photosCount} ${l10n.galleryPhotos}',
                    style: theme.textTheme.bodySmall?.copyWith(color: AppColors.slate400),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PlaceholderCover extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.slate100,
      child: const Center(
        child: Icon(Icons.photo_library_rounded, size: 32, color: AppColors.slate300),
      ),
    );
  }
}
