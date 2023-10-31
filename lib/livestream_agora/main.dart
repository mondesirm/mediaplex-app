//import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:mediaplex/livestream_agora/signaling.dart';
import 'package:mediaplex/utils/theme.dart';
import 'package:mediaplex/auth/service/user_service.dart';
import 'package:mediaplex/auth/models/user_model.dart';

class StreamPage extends StatefulWidget {
  const StreamPage({super.key});

  @override
  _StreamPageState createState() => _StreamPageState();
}

class _StreamPageState extends State<StreamPage>
    with SingleTickerProviderStateMixin {
  late TabController _tab;
  int _tabIndex = 0;
  Signaling signaling = Signaling();
  RTCVideoRenderer _localRenderer = RTCVideoRenderer();
  RTCVideoRenderer _remoteRenderer = RTCVideoRenderer();
  String? streamId;
  TextEditingController textEditingController = TextEditingController(text: '');
  final UserService _userService = UserService();
  late Future<Profile> _profile;
  late Profile _data;

  @override
  void initState() {
    _localRenderer.initialize();
    _remoteRenderer.initialize();

    signaling.onAddRemoteStream = ((stream) {
      _remoteRenderer.srcObject = stream;
      setState(() {});
    });

    super.initState();
    WidgetsFlutterBinding.ensureInitialized();
    _profile = _userService.fetchProfile(context);
    _tab = TabController(length: 2, vsync: this);
    _tab.addListener(() => setState(() => _tabIndex = _tab.index));
  }

  @override
  void dispose() {
    _tab.dispose();
    _localRenderer.dispose();
    _remoteRenderer.dispose();
    super.dispose();
  }

  Future<Profile> getProfile() async {
    // Get id of the current user
    var profile = await _profile;
    return profile;
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: MyTheme.appBar(context,
            screen: 'LibraryScreen',
            bottom: TabBar(controller: _tab, tabs: const [
              Tab(
                  text: 'Start stream',
                  icon: Icon(Icons.reset_tv, color: MyTheme.secondary)),
              Tab(
                  text: 'Join stream',
                  icon: Icon(Icons.featured_video, color: MyTheme.secondary))
            ]),
            actions: [
              if (_tabIndex == 0)
                IconButton(
                    splashRadius: 25,
                    tooltip: 'Open camera & microphone',
                    onPressed: () {
                      signaling.openUserMedia(_localRenderer, _remoteRenderer);
                    },
                    icon: const Icon(Icons.video_camera_front_rounded,
                        color: Colors.red)),
            ],
            child: Expanded(
                child: Text('My streaming page',
                    overflow: TextOverflow.ellipsis,
                    style: MyTheme.appText()))),
        body: TabBarView(controller: _tab, children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: MyTheme.boxDecoration(),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: MyTheme.boxDecoration(),
                      child: FutureBuilder<Profile>(
                          future: _profile,
                          builder: (context, snapshot) {
                            if (snapshot.hasError)
                              return Center(
                                  child: Text(
                                      'Something went wrong...\nPlease try again later.',
                                      textAlign: TextAlign.center,
                                      style: MyTheme.appText(size: 20)));

                            if (snapshot.hasData) {
                              _data = snapshot.data!;
                              return Column(
                                children: [
                                  Text('Steam of: ${_data.username}',
                                      style: MyTheme.appText(size: 20)),
                                ],
                              );
                            } else {
                              return Center(child: CircularProgressIndicator());
                            }
                          }),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                            child: RTCVideoView(_localRenderer, mirror: true)),
                        //Expanded(child: RTCVideoView(_remoteRenderer)),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: MyTheme.boxDecoration(),
                      child: FutureBuilder<Profile>(
                          future: _profile,
                          builder: (context, snapshot) {
                            if (snapshot.hasError)
                              return Center(
                                  child: Text(
                                      'Something went wrong...\nPlease try again later.',
                                      textAlign: TextAlign.center,
                                      style: MyTheme.appText(size: 20)));

                            if (snapshot.hasData) {
                              _data = snapshot.data!;
                              return Column(
                                children: [
                                  ElevatedButton(
                                    onPressed: () async {
                                      streamId = await signaling.createStream(
                                          _remoteRenderer, _data);
                                      textEditingController.text = streamId!;
                                      setState(() {});
                                    },
                                    child: Text("Create stream"),
                                  ),
                                  SizedBox(
                                    width: 8,
                                  ),
                                ],
                              );
                            } else {
                              return Center(child: CircularProgressIndicator());
                            }
                          }),
                    ),
                    SizedBox(
                      width: 8,
                    ),
                    ElevatedButton(
                      onPressed: () {
                        signaling.hangUp(streamId!, _localRenderer);
                      },
                      child: Text("Stop stream"),
                    )
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("Stream ID: "),
                      Flexible(
                        child: TextFormField(
                          controller: textEditingController,
                        ),
                      )
                    ],
                  ),
                ),
                SizedBox(height: 8)
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: MyTheme.boxDecoration(),
            child: Column(
              children: [
                SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        // Add streamId
                        signaling.joinStream(
                          textEditingController.text.trim(),
                          _remoteRenderer,
                        );
                      },
                      child: Text("Join stream"),
                    ),
                    SizedBox(
                      width: 8,
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        /* Expanded(
                            child: RTCVideoView(_localRenderer, mirror: true)),*/
                        Expanded(child: RTCVideoView(_remoteRenderer)),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("Join the following Stream: "),
                      Flexible(
                        child: TextFormField(
                          controller: textEditingController,
                        ),
                      )
                    ],
                  ),
                ),
                SizedBox(height: 8)
              ],
            ),
          )
        ]),
      );
}
