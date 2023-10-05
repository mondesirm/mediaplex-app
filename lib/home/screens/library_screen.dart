import 'dart:io';
import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as path;
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

import 'package:mediaplex/utils/theme.dart';
import 'package:mediaplex/player/gallery.dart';
import 'package:mediaplex/home/models/fav_model.dart';
import 'package:mediaplex/home/widgets/fav_card.dart';
import 'package:mediaplex/home/service/home_service.dart';
import 'package:mediaplex/player/models/media_model.dart';

enum UploadSource { camera, gallery }

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> with SingleTickerProviderStateMixin {
  int _tabIndex = 0;
  bool _reverse = true;
  List<Fav> _models = [];
  late TabController _tab;
  List<Media> _images = [];
  List<dynamic> _history = [];
  late Future<List<Fav>> _favorites;
  final ImagePicker _picker = ImagePicker();
  final HomeService _service = HomeService();
  final FirebaseStorage _storage = FirebaseStorage.instance;

  void init() {
    WidgetsFlutterBinding.ensureInitialized();
    SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]);
    _favorites = _service.fetchFavs(context);
    _tab = TabController(length: 3, vsync: this);
    _tab.addListener(() => setState(() => _tabIndex = _tab.index));
  }

  @override
  void initState() { super.initState(); init(); }

  @override
  void dispose() { _tab.dispose(); super.dispose(); }

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
    XFile? image;

    try {
      image = await _picker.pickImage(source: src == UploadSource.camera ? ImageSource.camera : ImageSource.gallery, maxWidth: 1920);

      File file = File(image!.path);
      String name = path.basename(image.path);

      print('File path: ${file.path} (image path: ${image.path}))');
      print('File exists: ${file.existsSync()}');
      print('Uploading $name with size ${file.lengthSync()} bytes, from ${src == UploadSource.camera ? 'camera' : 'gallery'}');

      try {
        // Upload selected image with some custom meta data
        /* UploadTask uploadTask = */ await _storage.ref(name).putFile(file, SettableMetadata(customMetadata: {
          'owner': 'a random user',
          'description': 'No description.'
        }));

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

  // Retrieve uploaded images
  Future<List<Media>> _loadImages() async {
    List<Media> files = [];

    ListResult res = await _storage.ref().list();
    List<Reference> items = res.items;

    await Future.forEach<Reference>(items, (file) async {
      String url = await file.getDownloadURL();
      FullMetadata meta = await file.getMetadata();

      files.add(Media.fromJson({
        'url': url,
        'path': file.fullPath,
        'size': meta.size ?? 0,
        'type': meta.contentType ?? 'unknown',
        'createdAt': meta.timeCreated ?? DateTime.now(),
        'owner': meta.customMetadata?['owner'] ?? 'a random user',
        'description': meta.customMetadata?['description'] ?? 'No description.'
      }));
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
    appBar: MyTheme.appBar(
      context,
      screen: 'LibraryScreen',
      bottom: TabBar(
        controller: _tab,
        tabs: const [
          Tab(text: 'History',  icon: Icon(Icons.history, color: MyTheme.secondary)),
          Tab(text: 'Favorites', icon: Icon(Icons.favorite, color: MyTheme.secondary)),
          Tab(text: 'My Media', icon: Icon(Icons.star, color: MyTheme.secondary))
        ]
      ),
      actions: [
        if (_tabIndex == 0 && _history.isNotEmpty) IconButton(
          splashRadius: 25,
          tooltip: 'Clear History',
          onPressed: _clearHistory,
          icon: const Icon(Icons.clear_all, color: Colors.red)
        ),
        if (_tabIndex == 1) IconButton(
          splashRadius: 25,
          onPressed: () => setState(() => _reverse = !_reverse),
          tooltip: _reverse ? 'Sort Older First' : 'Sort Newer First',
          icon: Icon(_reverse ? Icons.keyboard_double_arrow_down : Icons.keyboard_double_arrow_up, color: MyTheme.logoLight)
        ),
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
          icon: const Icon(Icons.perm_media, color: MyTheme.logoLight)
          // onPressed: () => MyTheme.showSnackBar(context, text: 'Coming soon!')
        )
      ],
      child: Expanded(child: Text('My Library', overflow: TextOverflow.ellipsis, style: MyTheme.appText()))
    ),
    body: TabBarView(
      controller: _tab,
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: MyTheme.boxDecoration(),
          child: FutureBuilder<SharedPreferences>(
            future: SharedPreferences.getInstance(),
            builder: (context, snapshot) {
              if (snapshot.hasError) return Center(child: Text('Something went wrong...\nPlease try again later.', textAlign: TextAlign.center, style: MyTheme.appText(size: 20)));

              if (snapshot.hasData) { _history = jsonDecode(snapshot.data!.getString('history') ?? '[]'); }
              else { return Center(child: MyTheme.loadingAnimation()); }

              return _history.isEmpty
                ? Center(child: Text('No history found', style: MyTheme.appText(size: 25, weight: FontWeight.bold)))
                : Column(children: [
                  Text('Your last played items (max 9)', style: MyTheme.appText(size: 20, weight: FontWeight.w400)),
                  Align(
                    alignment: Alignment.topLeft,
                    child: AnimationLimiter(child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: _history.length,
                      physics: const BouncingScrollPhysics(),
                      itemBuilder: (context, index) => AnimationConfiguration.staggeredList(
                        position: index,
                        duration: const Duration(seconds: 1),
                        child: SlideAnimation(
                          horizontalOffset: 80,
                          child: FadeInAnimation(child: FavCard(
                            index: index + 1,
                            model: Fav.fromJson(_history[index]),
                            onDelete: () => _removeHistoryItem(Fav.fromJson(_history[index]))
                          ))
                        )
                      )
                    ))
                  )
                ]);
            }
          )
        ),
        Container(
          padding: const EdgeInsets.all(10),
          decoration: MyTheme.boxDecoration(),
          child: FutureBuilder<List<Fav>>(
            future: _favorites,
            builder: (context, snapshot) {
              if (snapshot.hasError) return Center(child: Text('Something went wrong...\nPlease try again later.', textAlign: TextAlign.center, style: MyTheme.appText(size: 20)));

              if (snapshot.hasData) {
                _models = snapshot.data!;

                return _models.isEmpty
                  ? Center(child: Text('No favorites found', style: MyTheme.appText(size: 25, weight: FontWeight.bold)))
                  : Column(children: [
                    Text('Your ${_models.length} favorite${_models.length == 1 ? '' : 's'}', style: MyTheme.appText(size: 20, weight: FontWeight.w400)),
                    Align(
                      alignment: Alignment.topLeft,
                      child: AnimationLimiter(child: ListView.builder(
                        shrinkWrap: true,
                        reverse: _reverse,
                        itemCount: _models.length,
                        physics: const BouncingScrollPhysics(),
                        itemBuilder: (context, index) => AnimationConfiguration.staggeredList(
                          position: index,
                          duration: const Duration(seconds: 1),
                          child: SlideAnimation(
                            horizontalOffset: 80,
                            child: FadeInAnimation(child: FavCard(
                              index: index + 1,
                              model: _models[index],
                              onDelete: () => MyTheme.showAlertDialog(context, title: 'Remove Favorite', text: 'Do you want to remove ${_models[index].name} from your favorites?', onConfirm: () {
                                _service.deleteFav(context, model: _models[index]).then((value) {
                                  MyTheme.showSnackBar(context, text: value);
                                  setState(() { _models.remove(_models[index]); });
                                }).catchError((error) {
                                  MyTheme.showError(context, text: error.toString());
                                });
                              })
                            ))
                          )
                        )
                      ))
                    )
                  ]);
              } else { return Center(child: MyTheme.loadingAnimation()); }
            }
          )
        ),
        Container(
          padding: const EdgeInsets.all(10),
          decoration: MyTheme.boxDecoration(),
          child: FutureBuilder<List<Media>>(
            future: _loadImages(),
            builder: (context, snapshot) {
              if (snapshot.hasError) return Center(child: Text('Something went wrong...\nPlease try again later.', textAlign: TextAlign.center, style: MyTheme.appText(size: 20)));

              if (snapshot.hasData) {
                _images = snapshot.data!;

                return _images.isEmpty
                  ? Center(child: Text('No images found', style: MyTheme.appText(size: 25, weight: FontWeight.bold)))
                  : Column(children: [
                    Text('Your ${_images.length} image${_images.length == 1 ? '' : 's'}', style: MyTheme.appText(size: 20, weight: FontWeight.w400)),
                    Align(
                      alignment: Alignment.topLeft,
                      child: AnimationLimiter(child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: _images.length,
                        physics: const BouncingScrollPhysics(),
                        itemBuilder: (context, index) => AnimationConfiguration.staggeredList(
                          position: index,
                          duration: const Duration(seconds: 1),
                          child: SlideAnimation(
                            horizontalOffset: 80,
                            child: FadeInAnimation(child: Card(
                              color: MyTheme.surface,
                              margin: const EdgeInsets.symmetric(vertical: 10),
                              child: ListTile(
                                dense: false,
                                textColor: Colors.white,
                                title: Text(_images[index].path!),
                                leading: Image.network(_images[index].url!),
                                onTap: () => MyTheme.showImageDialog(context, image: _images[index]),
                                subtitle: Text('${_images[index].createdAt} • ${_images[index].description}'),
                                onLongPress: () => MyTheme.push(context, widget: Gallery(index: index, images: _images)),
                                trailing: IconButton(
                                  splashRadius: 25,
                                  tooltip: 'Delete',
                                  onPressed: () => _delete(_images[index].path!),
                                  icon: const Icon(Icons.delete, color: Colors.red)
                                )
                              )
                            ))
                          )
                        )
                      ))
                    )
                  ]);
              } else { return Center(child: MyTheme.loadingAnimation()); }
            }
          )
        )
      ]
    )
  );
}