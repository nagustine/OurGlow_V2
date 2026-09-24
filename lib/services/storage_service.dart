import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';

class StorageService {
  static const bool useMock = true;

  final FirebaseStorage _storage = FirebaseStorage.instance;

  final Map<String, String> _mockUrls = {};

  Future<String?> uploadDiaryPhoto({
    required String uid,
    required String entryId,
    required Uint8List bytes,
    required String fileName,
  }) async {
    if (useMock) {
      final fakeUrl = 'mock://photo/$uid/$entryId/$fileName';
      _mockUrls[fakeUrl] = fakeUrl;
      return fakeUrl;
    }

    final ref = _storage
        .ref()
        .child('diary_photos')
        .child(uid)
        .child(entryId)
        .child(fileName);

    final metadata = SettableMetadata(contentType: 'image/jpeg');
    final task = await ref.putData(bytes, metadata);
    return await task.ref.getDownloadURL();
  }

  Future<void> deletePhoto(String url) async {
    if (useMock) {
      _mockUrls.remove(url);
      return;
    }
    try {
      final ref = _storage.refFromURL(url);
      await ref.delete();
    } catch (_) {}
  }
}