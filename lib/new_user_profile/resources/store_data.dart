import 'dart:io';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';

final FirebaseStorage _storage = FirebaseStorage.instance;
final FirebaseFirestore _firestore = FirebaseFirestore.instance;

class StoreData {
  Future<String> uploadImageToStorage(String childName, Uint8List file) async {
    Reference ref = _storage.ref().child(childName);
    UploadTask uploadTask = ref.putData(file);
    TaskSnapshot snapshot = await uploadTask;
    String downloadURL = await snapshot.ref.getDownloadURL();
    return downloadURL;
  }

  Future<String> uploadVideoToStorage(String videoURL) async {
    Reference ref = _storage.ref().child('videos/${DateTime.now()}.mp4');
    await ref.putFile(File(videoURL));
    String downloadURL = await ref.getDownloadURL();
    return downloadURL;
  }

  Future<String> saveData(
      {required String fullName,
      required String gender,
      required String dob,
      required Uint8List image,
      required String video}) async {
    String resp = 'Some error occurred while saving';
    try {
      if (fullName.isNotEmpty || gender.isNotEmpty || dob.isNotEmpty) {
        String imageURL = await uploadImageToStorage('profileImage', image);

        await _firestore.collection('users').add({
          'name': fullName,
          'gender': gender,
          'dob': dob,
          'profile_image': imageURL,
          'profile_video': video,
          'timestamp': FieldValue.serverTimestamp(),
        });
        resp = 'success';
      }
    } catch (err) {
      resp = err.toString();
    }
    return resp;
  }
}
