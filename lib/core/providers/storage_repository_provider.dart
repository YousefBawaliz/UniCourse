import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:uni_course/core/failure.dart';
import 'package:uni_course/core/providers/firebase_providers.dart';
import 'package:uni_course/core/type_defs.dart';

final storageRepositoryProvider = Provider((ref) {
  return StorageRepository(firebaseStorage: ref.watch(storageProvider));
});

class StorageRepository {
  final FirebaseStorage _firebaseStorage;

  StorageRepository({required FirebaseStorage firebaseStorage})
      : _firebaseStorage = firebaseStorage;

  //FutureEither<String> because we're gonna need to store the url of the image as a url
  FutureEither<String> storeFile(
      {required String path, required String id, required File? file}) async {
    try {
      //the path of where the file is gonna be stored
      final ref = _firebaseStorage.ref().child(path).child(id);

      //Upload a [File] from the filesystem
      UploadTask uploadTask = ref.putFile(file!);

      //with this snapshot we get access to the download url
      final snapshot = await uploadTask;

      return right(await snapshot.ref.getDownloadURL());
      //
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }
}
