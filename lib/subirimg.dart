import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

final FirebaseStorage storage = FirebaseStorage.instance;
Future<bool> uploadImage(File image, String email) async {
  print(image.path);

  final String nameFile = image.path.split("/").last;

  final Reference ref = storage.ref().child("Imagenes").child(email);

  final UploadTask uploadTask = ref.putFile(image);

  final TaskSnapshot snapshot = await uploadTask.whenComplete(() => true);

  print(snapshot);

  final String url = await snapshot.ref.getDownloadURL();

  print(url);

  if (snapshot.state == TaskState.success) {
    return true;
  } else {
    return false;
  }
}
