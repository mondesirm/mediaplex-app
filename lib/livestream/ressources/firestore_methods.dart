import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mediaplex/livestream/models/livestream_model.dart';
import 'package:mediaplex/livestream/ressources/storage_methods.dart';
import 'package:mediaplex/livestream//utils/utils.dart';
import 'package:uuid/uuid.dart';
import 'package:mediaplex/auth/service/user_service.dart';

class FirestoreMethods {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final StorageMethods _storageMethods = StorageMethods();
  final UserService _userService = UserService();
  late Future<Profile> _profile;
  

  Future<String> startLiveStream(
      BuildContext context, String title, Uint8List? image) async {
        _profile = _userService.fetchProfile(context);
    
    String channelId = '';
    try {
      if (title.isNotEmpty && image != null) {
        if (!((await _firestore
                .collection('livestream')
                .doc('${user.user.uid}${user.user.username}')
                .get())
            .exists)) {
          String thumbnailUrl = await _storageMethods.uploadImageToStorage(
            'livestream-thumbnails',
            image,
            user.user.uid,
          );
          channelId = '${user.user.uid}${user.user.username}';

          LiveStream liveStream = LiveStream(
            title: title,
            image: thumbnailUrl,
            uid: user.user.uid,
            username: user.user.username,
            viewers: 0,
            channelId: channelId,
            startedAt: DateTime.now(),
          );

          _firestore
              .collection('livestream')
              .doc(channelId)
              .set(liveStream.toMap());
        } else {
          showSnackBar(
              context, 'Two Livestreams cannot start at the same time.');
        }
      } else {
        showSnackBar(context, 'Please enter all the fields');
      }
    } on FirebaseException catch (e) {
      showSnackBar(context, e.message!);
    }
    return channelId;
  }

}