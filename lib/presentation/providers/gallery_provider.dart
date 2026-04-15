import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/remote/gallery_api.dart';
import '../../data/models/gallery_model.dart';
import 'auth_provider.dart';

final galleryApiProvider = Provider<GalleryApi>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  return GalleryApi(dioClient);
});

// ─── Albums ───

class GalleryAlbumsState {
  final bool isLoading;
  final String? error;
  final List<GalleryAlbumModel> albums;

  const GalleryAlbumsState({this.isLoading = false, this.error, this.albums = const []});
}

class GalleryAlbumsNotifier extends StateNotifier<GalleryAlbumsState> {
  final GalleryApi _api;

  GalleryAlbumsNotifier(this._api) : super(const GalleryAlbumsState());

  Future<void> loadAlbums() async {
    state = const GalleryAlbumsState(isLoading: true);
    try {
      final albums = await _api.getAlbums();
      state = GalleryAlbumsState(albums: albums);
    } catch (e) {
      state = GalleryAlbumsState(error: e.toString());
    }
  }
}

final galleryAlbumsProvider =
    StateNotifierProvider.autoDispose<GalleryAlbumsNotifier, GalleryAlbumsState>(
  (ref) {
    final api = ref.watch(galleryApiProvider);
    return GalleryAlbumsNotifier(api);
  },
);

// ─── Photos ───

class GalleryPhotosState {
  final bool isLoading;
  final String? error;
  final List<GalleryPhotoModel> photos;

  const GalleryPhotosState({this.isLoading = false, this.error, this.photos = const []});
}

class GalleryPhotosNotifier extends StateNotifier<GalleryPhotosState> {
  final GalleryApi _api;

  GalleryPhotosNotifier(this._api) : super(const GalleryPhotosState());

  Future<void> loadPhotos(int albumId) async {
    state = const GalleryPhotosState(isLoading: true);
    try {
      final photos = await _api.getPhotos(albumId);
      state = GalleryPhotosState(photos: photos);
    } catch (e) {
      state = GalleryPhotosState(error: e.toString());
    }
  }
}

final galleryPhotosProvider =
    StateNotifierProvider.autoDispose<GalleryPhotosNotifier, GalleryPhotosState>(
  (ref) {
    final api = ref.watch(galleryApiProvider);
    return GalleryPhotosNotifier(api);
  },
);
