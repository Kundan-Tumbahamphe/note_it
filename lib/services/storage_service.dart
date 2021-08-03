import 'dart:io';
import 'package:meta/meta.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:noteit/configs/configs.dart';
import 'package:uuid/uuid.dart';
import 'package:path_provider/path_provider.dart' as pathProvider;
import 'package:flutter_image_compress/flutter_image_compress.dart';

class StorageService {
  final FirebaseStorage _storageService = FirebaseStorage.instance;

  Future<File> _compressImage(
      {@required String imageId, @required File image}) async {
    Directory tempDir = await pathProvider.getTemporaryDirectory();
    String path = tempDir.path;
    File compressedImageFile = await FlutterImageCompress.compressAndGetFile(
      image.absolute.path,
      '$path/image_$imageId.jpg',
      quality: 40,
    );
    return compressedImageFile;
  }

  Future<String> _uploadImage(
      {@required String path, @required File compressImage}) async {
    StorageUploadTask uploadTask =
        _storageService.ref().child(path).putFile(compressImage);
    StorageTaskSnapshot storageSnap = await uploadTask.onComplete;
    String downloadUrl = await storageSnap.ref.getDownloadURL();
    return downloadUrl;
  }

  Future<String> uploadNoteImageAndGetDownloadUrl(File imageFile) async {
    String imageId = Uuid().v4();

    File compressedImage =
        await _compressImage(imageId: imageId, image: imageFile);

    String downloadUrl = await _uploadImage(
        path: Paths.noteImages(imageId), compressImage: compressedImage);
    return downloadUrl;
  }

  Future<void> deleteImage(String imageUrl) async {
    final StorageReference storageReference =
        await _storageService.getReferenceFromUrl(imageUrl);
    await storageReference.delete();
  }
}
