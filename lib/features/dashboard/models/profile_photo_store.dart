import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../core/cloud/cloud_store.dart';
import '../../../core/storage/local_database.dart';

/// Foto profil setiap pengguna, dikenali lewat nama lengkapnya seperti data
/// proyek. Foto disimpan di database lokal dan, bila tersinkron, di koleksi
/// `profile_photos` sehingga terlihat oleh pengguna lain.
class ProfilePhotoStore extends ChangeNotifier with CloudSync {
  ProfilePhotoStore({this.database});

  static const collection = 'profile_photos';

  final LocalDatabase? database;
  final Map<String, Uint8List?> _photos = {};

  /// ID dokumen foto dari nama pengguna.
  static String idFor(String name) =>
      name.trim().toLowerCase().replaceAll(RegExp('[^a-z0-9]+'), '-');

  /// Foto profil [name], atau `null` bila belum ada.
  Uint8List? photoFor(String name) {
    final id = idFor(name);
    if (_photos.containsKey(id)) return _photos[id];
    final stored = database?.readBytes(_key(id));
    _photos[id] = stored;
    return stored;
  }

  void setPhoto(String name, Uint8List photo) {
    final id = idFor(name);
    _photos[id] = photo;
    notifyListeners();
    unawaited(database?.writeBytes(_key(id), photo));
    upload(collection, id, {
      'id': id,
      'owner': name.trim(),
      'data': base64Encode(photo),
    });
  }

  void removePhoto(String name) {
    final id = idFor(name);
    _photos[id] = null;
    notifyListeners();
    unawaited(database?.delete(_key(id)));
    removeRemote(collection, id);
  }

  /// Mendengarkan foto profil semua pengguna. Foto dikompres kecil sehingga
  /// seluruh koleksi tetap ringan diunduh.
  void startSync(CloudStore cloud) {
    beginSync(cloud);
    listenRemote(collection, (documents) {
      final remote = <String, Uint8List>{};
      for (final document in documents) {
        final id = document['id'];
        final data = document['data'];
        if (id is! String || data is! String) continue;
        try {
          remote[id] = base64Decode(data);
        } on FormatException {
          continue;
        }
      }
      // Foto yang dihapus di perangkat lain ikut hilang di sini.
      for (final id in _photos.keys.toList()) {
        if (!remote.containsKey(id) && _photos[id] != null) {
          _photos[id] = null;
          unawaited(database?.delete(_key(id)));
        }
      }
      remote.forEach((id, photo) {
        _photos[id] = photo;
        unawaited(database?.writeBytes(_key(id), photo));
      });
      notifyListeners();
    });
  }

  static String _key(String id) => 'profile_photo:$id';
}

/// Menyediakan [ProfilePhotoStore] bagi semua avatar di bawahnya, dan
/// membangun ulang avatar ketika ada foto yang berubah.
class ProfilePhotoScope extends InheritedNotifier<ProfilePhotoStore> {
  const ProfilePhotoScope({
    required ProfilePhotoStore store,
    required super.child,
    super.key,
  }) : super(notifier: store);

  static ProfilePhotoStore? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<ProfilePhotoScope>()?.notifier;
}

/// Halaman baru yang tetap dapat menampilkan foto profil. Rute baru berada di
/// luar [ProfilePhotoScope] milik dashboard, jadi penyimpanannya diteruskan.
MaterialPageRoute<T> pageRouteWithPhotos<T>(
  BuildContext context,
  WidgetBuilder builder,
) {
  final photos = ProfilePhotoScope.maybeOf(context);
  return MaterialPageRoute<T>(
    builder: (context) => photos == null
        ? builder(context)
        : ProfilePhotoScope(
            store: photos,
            child: Builder(builder: builder),
          ),
  );
}
