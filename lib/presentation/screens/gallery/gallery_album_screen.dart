import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:parent_school_app/core/constants/app_colors.dart';
import 'package:parent_school_app/core/localization/l10n_extension.dart';

import '../../../data/models/gallery_model.dart';
import '../../providers/gallery_provider.dart';

class GalleryAlbumScreen extends ConsumerStatefulWidget {
  final GalleryAlbumModel album;

  const GalleryAlbumScreen({super.key, required this.album});

  @override
  ConsumerState<GalleryAlbumScreen> createState() => _GalleryAlbumScreenState();
}

class _GalleryAlbumScreenState extends ConsumerState<GalleryAlbumScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(galleryPhotosProvider.notifier).loadPhotos(widget.album.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final state = ref.watch(galleryPhotosProvider);

    return Scaffold(
      appBar: AppBar(title: Text(widget.album.title), centerTitle: true),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : state.error != null
              ? Center(child: Text(l10n.galleryLoadFailed))
              : state.photos.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.photo_outlined, size: 56, color: AppColors.slate400),
                          const SizedBox(height: 12),
                          Text(l10n.galleryNoPhotos,
                              style: theme.textTheme.bodyLarge?.copyWith(color: AppColors.slate500)),
                        ],
                      ),
                    )
                  : GridView.builder(
                      padding: const EdgeInsets.all(8),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 4,
                        mainAxisSpacing: 4,
                      ),
                      itemCount: state.photos.length,
                      itemBuilder: (context, index) {
                        final photo = state.photos[index];
                        return GestureDetector(
                          onTap: () => _showFullScreen(context, state.photos, index),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              photo.filePath,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                color: AppColors.slate200,
                                child: const Icon(Icons.broken_image_rounded,
                                    color: AppColors.slate400),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
    );
  }

  void _showFullScreen(BuildContext context, List<GalleryPhotoModel> photos, int initialIndex) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => _FullScreenGallery(photos: photos, initialIndex: initialIndex),
    ));
  }
}

class _FullScreenGallery extends StatelessWidget {
  final List<GalleryPhotoModel> photos;
  final int initialIndex;

  const _FullScreenGallery({required this.photos, required this.initialIndex});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: PageView.builder(
        controller: PageController(initialPage: initialIndex),
        itemCount: photos.length,
        itemBuilder: (context, index) {
          final photo = photos[index];
          return InteractiveViewer(
            child: Center(
              child: Image.network(
                photo.filePath,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => const Icon(
                  Icons.broken_image_rounded,
                  size: 48,
                  color: Colors.white54,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
