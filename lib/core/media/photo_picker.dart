import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';

enum PhotoSource { camera, gallery }

/// Mengambil foto dari kamera atau galeri perangkat.
/// [instance] dapat diganti dengan versi palsu pada pengujian.
abstract class PhotoPicker {
  static PhotoPicker instance = ImagePickerPhotoPicker();

  /// Ukuran maksimal foto setelah dikompres.
  static const maxBytes = 2 * 1024 * 1024;

  /// Mengembalikan isi foto, atau `null` bila pengguna membatalkan.
  Future<Uint8List?> pick(PhotoSource source);
}

/// Implementasi dengan paket image_picker: kamera dan galeri di Android,
/// pemilih berkas di browser.
class ImagePickerPhotoPicker implements PhotoPicker {
  final _picker = ImagePicker();

  @override
  Future<Uint8List?> pick(PhotoSource source) async {
    final file = await _picker.pickImage(
      source: switch (source) {
        PhotoSource.camera => ImageSource.camera,
        PhotoSource.gallery => ImageSource.gallery,
      },
      // Foto diperkecil dan dikompres agar database lokal tetap ringan.
      maxWidth: 1280,
      maxHeight: 1280,
      imageQuality: 75,
    );
    return file?.readAsBytes();
  }
}
