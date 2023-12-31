import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:video_player/video_player.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

import 'package:mediaplex/utils/theme.dart';
import 'package:mediaplex/player/gallery.dart';
import 'package:mediaplex/home/models/fav_model.dart';
import 'package:mediaplex/home/widgets/fav_card.dart';
import 'package:mediaplex/auth/models/user_model.dart';
import 'package:mediaplex/home/service/home_service.dart';
import 'package:mediaplex/auth/service/user_service.dart';
import 'package:mediaplex/player/models/media_model.dart';
import 'package:mediaplex/player/player.dart';

enum UploadSource { camera, gallery, video }

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen>
    with SingleTickerProviderStateMixin {
  int _tabIndex = 0;
  bool _reverse = true;
  List<Fav> _models = [];
  List<Media> _files = [];
  late TabController _tab;
  List<dynamic> _history = [];
  late Future<Profile> _profile;
  late Future<List<Fav>> _favorites;
  final ImagePicker _picker = ImagePicker();
  final HomeService _service = HomeService();
  final UserService _userService = UserService();
  final FirebaseStorage _storage = FirebaseStorage.instance;
  VideoPlayerController? _videoController;
  FilePicker? _filePicker;

  void init() {
    WidgetsFlutterBinding.ensureInitialized();
    SystemChrome.setPreferredOrientations(
        [DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]);
    _favorites = _service.fetchFavs(context);
    _profile = _userService.fetchProfile(context);
    _tab = TabController(length: 4, vsync: this);
    _tab.addListener(() => setState(() => _tabIndex = _tab.index));
  }

  @override
  void initState() {
    super.initState();
    init();
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  void _clearHistory() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() => _history = []);
    preferences.setString('history', '[]');
  }

  void _removeHistoryItem(dynamic model) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() => _history.removeWhere((_) => _['url'] == model.url));
    preferences.setString('history', jsonEncode(_history));
  }

  // Launch camera or gallery then upload image to Firebase Storage
  Future<void> _upload(UploadSource src) async {
    // Get id of the current user
    var profile = await _profile;
    int id = profile.id!;

    XFile? image;

    try {
      image = await _picker.pickImage(
          source: src == UploadSource.camera
              ? ImageSource.camera
              : ImageSource.gallery,
          maxWidth: 1920);

      // File file = File(image!.path);
      // String name = path.basename(image.path);

      var bytes = await image!.readAsBytes();

      // print('File path: ${file.path} (image path: ${image.path}))');
      // print('File exists: ${file.existsSync()}');
      // print('Uploading $name with size ${file.lengthSync()} bytes, from ${src == UploadSource.camera ? 'camera' : 'gallery'}');

      try {
        Reference reference =
            FirebaseStorage.instance.ref().child('$id/${image.name}');

        UploadTask uploadTask = reference.putData(bytes);
        await uploadTask.whenComplete(
            () => MyTheme.showSnackBar(context, text: 'Upload complete!'));

        // Upload selected image with some custom meta data
        // /* UploadTask uploadTask = */ await _storage.ref('$id/$name').putFile(file, SettableMetadata(customMetadata: {
        //   'owner': profile.username!,
        //   'description': 'No description.'
        // }));

        // Listen for state changes, errors, and completion of the upload.
        // uploadTask.snapshotEvents.listen((TaskSnapshot taskSnapshot) {
        //   switch (taskSnapshot.state) {
        //     case TaskState.running:
        //       double progress = 100 * (taskSnapshot.bytesTransferred / taskSnapshot.totalBytes);
        //       print('Upload is $progress% complete.');
        //       break;
        //     case TaskState.paused:
        //       print('Upload is paused.');
        //       break;
        //     case TaskState.canceled:
        //       print('Upload was canceled');
        //       break;
        //     case TaskState.error:
        //       // Handle unsuccessful uploads
        //       break;
        //     case TaskState.success:
        //       // Handle successful uploads on complete
        //       break;
        //   }
        // });

        // Refresh the UI
        setState(() {});
      } on FirebaseException catch (err) {
        if (kDebugMode) print(err);
      }
    } catch (err) {
      if (kDebugMode) print(err);
    }
  }

  // Launch camera or gallery then upload image to Firebase Storage
  Future<void> _uploadVideo(UploadSource src) async {
    final result = await FilePicker.platform
        .pickFiles(type: FileType.video, allowMultiple: false);

    if (result != null) {
      // Get id of the current user
      var profile = await _profile;
      int id = profile.id!;
      Uint8List? fileBytes = result.files.single.bytes;

      try {
        Reference reference = FirebaseStorage.instance
            .ref()
            .child('$id/${result.files.single.name}');

        UploadTask uploadTask = reference.putData(fileBytes!);
        await uploadTask.whenComplete(
            () => MyTheme.showSnackBar(context, text: 'Upload complete!'));
        // Refresh the UI
        setState(() {});
      } on FirebaseException catch (err) {
        if (kDebugMode) print(err);
      }
    }
  }

  // Retrieve uploaded images
  Future<List<Media>> _loadImages() async {
    // Get id of the current user
    var profile = await _profile;
    int id = profile.id!;

    List<Media> files = [];

    ListResult res = await _storage.ref(id.toString()).list();
    List<Reference> items = res.items;

    await Future.forEach<Reference>(items, (file) async {
      String url = await file.getDownloadURL();
      FullMetadata meta = await file.getMetadata();

      //if name finish by mp4, it's a video

      if (!file.name.endsWith('mp4')) {
        files.add(Media.fromJson({
          'url': url,
          'path': file.fullPath,
          'size': meta.size ?? 0,
          'type': meta.contentType ?? 'unknown',
          'createdAt': meta.timeCreated ?? DateTime.now(),
          'owner': meta.customMetadata?['owner'] ?? 'a random user',
          'description':
              meta.customMetadata?['description'] ?? 'No description.'
        }));
      }
    });

    return files;
  }

  // Retrieve uploaded videos
  Future<List<Media>> _loadVideos() async {
    // Get id of the current user
    var profile = await _profile;
    int id = profile.id!;

    List<Media> files = [];

    ListResult res = await _storage.ref(id.toString()).list();
    List<Reference> items = res.items;

    await Future.forEach<Reference>(items, (file) async {
      String url = await file.getDownloadURL();
      FullMetadata meta = await file.getMetadata();

      if (file.name.endsWith('mp4')) {
        files.add(Media.fromJson({
          'url': url,
          'path': file.fullPath,
          'size': meta.size ?? 0,
          'type': meta.contentType ?? 'unknown',
          'createdAt': meta.timeCreated ?? DateTime.now(),
          'owner': meta.customMetadata?['owner'] ?? 'a random user',
          'description':
              meta.customMetadata?['description'] ?? 'No description.'
        }));
      }
    });

    return files;
  }

  // Delete the selected image
  Future<void> _delete(String ref) async {
    await _storage.ref(ref).delete();
    // Rebuild the UI
    setState(() {});
  }

  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: MyTheme.appBar(context,
          screen: 'LibraryScreen',
          bottom: TabBar(controller: _tab, tabs: const [
            Tab(
                text: 'History',
                icon: Icon(Icons.history, color: MyTheme.secondary)),
            Tab(
                text: 'Favorites',
                icon: Icon(Icons.favorite, color: MyTheme.secondary)),
            Tab(
                text: 'Images',
                icon: Icon(Icons.perm_media, color: MyTheme.secondary)),
            Tab(
                text: 'Videos',
                icon: Icon(Icons.featured_video, color: MyTheme.secondary))
          ]),
          actions: [
            if (_tabIndex == 0 && _history.isNotEmpty)
              IconButton(
                  splashRadius: 25,
                  tooltip: 'Clear History',
                  onPressed: _clearHistory,
                  icon: const Icon(Icons.clear_all, color: Colors.red)),
            if (_tabIndex == 1)
              IconButton(
                  splashRadius: 25,
                  onPressed: () => setState(() => _reverse = !_reverse),
                  tooltip: _reverse ? 'Sort Older First' : 'Sort Newer First',
                  icon: Icon(
                      _reverse
                          ? Icons.keyboard_double_arrow_down
                          : Icons.keyboard_double_arrow_up,
                      color: MyTheme.logoLight)),
            IconButton(
                splashRadius: 25,
                tooltip: 'Upload (Camera)',
                onPressed: () => _upload(UploadSource.camera),
                icon: const Icon(Icons.photo_camera, color: MyTheme.logoLight)
                // onPressed: () => MyTheme.showSnackBar(context, text: 'Coming soon!')
                ),
            IconButton(
                splashRadius: 25,
                tooltip: 'Upload (Gallery)',
                onPressed: () => _upload(UploadSource.gallery),
                icon: const Icon(Icons.drive_folder_upload,
                    color: MyTheme.logoLight)
                // onPressed: () => MyTheme.showSnackBar(context, text: 'Coming soon!')
                ),
            IconButton(
                splashRadius: 25,
                tooltip: 'Upload (Video)',
                onPressed: () => _uploadVideo(UploadSource.video),
                icon: const Icon(Icons.featured_video, color: MyTheme.logoLight)
                // onPressed: () => MyTheme.showSnackBar(context, text: 'Coming soon!')
                )
          ],
          child: Expanded(
              child: Text('My Library',
                  overflow: TextOverflow.ellipsis, style: MyTheme.appText()))),
      body: TabBarView(controller: _tab, children: [
        Container(
            padding: const EdgeInsets.all(10),
            decoration: MyTheme.boxDecoration(),
            child: FutureBuilder<SharedPreferences>(
                future: SharedPreferences.getInstance(),
                builder: (context, snapshot) {
                  if (snapshot.hasError)
                    return Center(
                        child: Text(
                            'Something went wrong...\nPlease try again later.',
                            textAlign: TextAlign.center,
                            style: MyTheme.appText(size: 20)));

                  if (snapshot.hasData) {
                    _history =
                        jsonDecode(snapshot.data!.getString('history') ?? '[]');
                  } else {
                    return Center(child: MyTheme.loadingAnimation());
                  }

                  return _history.isEmpty
                      ? Center(
                          child: Text('No history found',
                              style: MyTheme.appText(
                                  size: 25, weight: FontWeight.bold)))
                      : Column(children: [
                          Text('${_history.length} items (max 9)',
                              style: MyTheme.appText(
                                  size: 20, weight: FontWeight.w400)),
                          Align(
                              alignment: Alignment.topLeft,
                              child: AnimationLimiter(
                                  child: ListView.builder(
                                      shrinkWrap: true,
                                      itemCount: _history.length,
                                      physics: const BouncingScrollPhysics(),
                                      itemBuilder: (context, index) =>
                                          AnimationConfiguration.staggeredList(
                                              position: index,
                                              duration:
                                                  const Duration(seconds: 1),
                                              child: SlideAnimation(
                                                  horizontalOffset: 80,
                                                  child: FadeInAnimation(
                                                      child: FavCard(
                                                          index: index + 1,
                                                          model: Fav.fromJson(
                                                              _history[index]),
                                                          onDelete: () =>
                                                              _removeHistoryItem(
                                                                  Fav.fromJson(
                                                                      _history[index])))))))))
                        ]);
                })),
        Container(
            padding: const EdgeInsets.all(10),
            decoration: MyTheme.boxDecoration(),
            child: FutureBuilder<List<Fav>>(
                future: _favorites,
                builder: (context, snapshot) {
                  if (snapshot.hasError)
                    return Center(
                        child: Text(
                            'Something went wrong...\nPlease try again later.',
                            textAlign: TextAlign.center,
                            style: MyTheme.appText(size: 20)));

                  if (snapshot.hasData) {
                    _models = snapshot.data!;

                    return _models.isEmpty
                        ? Center(
                            child: Text('No favorites found',
                                style: MyTheme.appText(
                                    size: 25, weight: FontWeight.bold)))
                        : Column(children: [
                            Text(
                                '${_models.length} item${_models.length == 1 ? '' : 's'}',
                                style: MyTheme.appText(
                                    size: 20, weight: FontWeight.w400)),
                            Align(
                                alignment: Alignment.topLeft,
                                child: AnimationLimiter(
                                    child: ListView.builder(
                                        shrinkWrap: true,
                                        reverse: _reverse,
                                        itemCount: _models.length,
                                        physics: const BouncingScrollPhysics(),
                                        itemBuilder: (context, index) =>
                                            AnimationConfiguration
                                                .staggeredList(
                                                    position: index,
                                                    duration: const Duration(
                                                        seconds: 1),
                                                    child: SlideAnimation(
                                                        horizontalOffset: 80,
                                                        child: FadeInAnimation(
                                                            child: FavCard(
                                                                index:
                                                                    index + 1,
                                                                model: _models[
                                                                    index],
                                                                onDelete: () =>
                                                                    MyTheme.showAlertDialog(
                                                                        context,
                                                                        title:
                                                                            'Remove Favorite',
                                                                        text:
                                                                            'Do you want to remove ${_models[index].name} from your favorites?',
                                                                        onConfirm:
                                                                            () {
                                                                      _service
                                                                          .deleteFav(
                                                                              context,
                                                                              model: _models[
                                                                                  index])
                                                                          .then(
                                                                              (value) {
                                                                        MyTheme.showSnackBar(
                                                                            context,
                                                                            text:
                                                                                value);
                                                                        setState(
                                                                            () {
                                                                          _models
                                                                              .remove(_models[index]);
                                                                        });
                                                                      }).catchError(
                                                                              (error) {
                                                                        MyTheme.showError(
                                                                            context,
                                                                            text:
                                                                                error.toString());
                                                                      });
                                                                    }))))))))
                          ]);
                  } else {
                    return Center(child: MyTheme.loadingAnimation());
                  }
                })),
        Container(
            padding: const EdgeInsets.all(10),
            decoration: MyTheme.boxDecoration(),
            child: FutureBuilder<List<Media>>(
                future: _loadImages(),
                builder: (context, snapshot) {
                  if (snapshot.hasError)
                    return Center(
                        child: Text(
                            'Something went wrong...\nPlease try again later.',
                            textAlign: TextAlign.center,
                            style: MyTheme.appText(size: 20)));

                  if (snapshot.hasData) {
                    _files = snapshot.data!;

                    return _files.isEmpty
                        ? Center(
                            child: Text('No media found',
                                style: MyTheme.appText(
                                    size: 25, weight: FontWeight.bold)))
                        : Column(children: [
                            Text(
                                '${_files.length} item${_files.length == 1 ? '' : 's'}',
                                style: MyTheme.appText(
                                    size: 20, weight: FontWeight.w400)),
                            Align(
                                alignment: Alignment.topLeft,
                                child: AnimationLimiter(
                                    child: ListView.builder(
                                        shrinkWrap: true,
                                        itemCount: _files.length,
                                        physics: const BouncingScrollPhysics(),
                                        itemBuilder: (context, index) =>
                                            AnimationConfiguration
                                                .staggeredList(
                                                    position: index,
                                                    duration: const Duration(
                                                        seconds: 1),
                                                    child: SlideAnimation(
                                                        horizontalOffset: 80,
                                                        child: FadeInAnimation(
                                                            child: Tooltip(
                                                          message:
                                                              'Long press to enter Gallery Mode',
                                                          child: Card(
                                                              color: MyTheme
                                                                  .surface,
                                                              margin: const EdgeInsets
                                                                  .symmetric(
                                                                  vertical: 10),
                                                              child: ListTile(
                                                                  dense: false,
                                                                  textColor:
                                                                      Colors
                                                                          .white,
                                                                  title: Text(
                                                                      _files[index]
                                                                          .path!),
                                                                  leading: Image.network(
                                                                      _files[index]
                                                                          .url!),
                                                                  onTap: () =>
                                                                      MyTheme.showImageDialog(
                                                                          context,
                                                                          image: _files[index]),
                                                                  subtitle: Text('${_files[index].createdAt} • ${_files[index].description}'),
                                                                  onLongPress: () => MyTheme.push(context, name: 'gallery', widget: Gallery(index: index, items: _files)),
                                                                  trailing: IconButton(splashRadius: 25, tooltip: 'Delete', onPressed: () => _delete(_files[index].path!), icon: const Icon(Icons.delete, color: Colors.red)))),
                                                        )))))))
                          ]);
                  } else {
                    return Center(child: MyTheme.loadingAnimation());
                  }
                })),
        Container(
            padding: const EdgeInsets.all(10),
            decoration: MyTheme.boxDecoration(),
            child: FutureBuilder<List<Media>>(
                future: _loadVideos(),
                builder: (context, snapshot) {
                  if (snapshot.hasError)
                    return Center(
                        child: Text(
                            'Something went wrong...\nPlease try again later.',
                            textAlign: TextAlign.center,
                            style: MyTheme.appText(size: 20)));

                  if (snapshot.hasData) {
                    _files = snapshot.data!;

                    return _files.isEmpty
                        ? Center(
                            child: Text('No videos found',
                                style: MyTheme.appText(
                                    size: 25, weight: FontWeight.bold)))
                        : Column(children: [
                            Text(
                                '${_files.length} item${_files.length == 1 ? '' : 's'}',
                                style: MyTheme.appText(
                                    size: 20, weight: FontWeight.w400)),
                            Align(
                                alignment: Alignment.topLeft,
                                child: AnimationLimiter(
                                    child: ListView.builder(
                                        shrinkWrap: true,
                                        itemCount: _files.length,
                                        physics: const BouncingScrollPhysics(),
                                        itemBuilder: (context, index) =>
                                            AnimationConfiguration
                                                .staggeredList(
                                                    position: index,
                                                    duration: const Duration(
                                                        seconds: 1),
                                                    child: SlideAnimation(
                                                        horizontalOffset: 80,
                                                        child: FadeInAnimation(
                                                            child: Tooltip(
                                                          message:
                                                              'Long press to enter Gallery Mode',
                                                          child: Card(
                                                              color: MyTheme
                                                                  .surface,
                                                              margin: const EdgeInsets
                                                                  .symmetric(
                                                                  vertical: 10),
                                                              child: ListTile(
                                                                  dense: false,
                                                                  textColor:
                                                                      Colors
                                                                          .white,
                                                                  title: Text(
                                                                      _files[index]
                                                                          .path!),
                                                                 /* leading: Image.network(
                                                                      _files[index]
                                                                          .url!),*/
                                                                          // MyTheme.push(context, name: 'player', widget: Player(model: _files[index]));
                                                                  onTap: () =>
                                                                      MyTheme.showVideoPlayerDialog(
                                                                          context,
                                                                          video: _files[index]),
                                                                          
                                                                  subtitle: Text('${_files[index].createdAt} • ${_files[index].description}'),
                                                                  trailing: IconButton(splashRadius: 25, tooltip: 'Delete', onPressed: () => _delete(_files[index].path!), icon: const Icon(Icons.delete, color: Colors.red)))),
                                                        )))))))
                          ]);
                  } else {
                    return Center(child: MyTheme.loadingAnimation());
                  }
                }))
      ]));
}
