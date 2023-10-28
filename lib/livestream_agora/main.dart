//import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:mediaplex/livestream_agora/signaling.dart';
import 'package:mediaplex/utils/theme.dart';

class StreamPage extends StatefulWidget {
  const StreamPage({super.key});

  @override
  _StreamPageState createState() => _StreamPageState();
}

class _StreamPageState extends State<StreamPage> with SingleTickerProviderStateMixin  {
  late TabController _tab;
  int _tabIndex = 0;
  Signaling signaling = Signaling();
  RTCVideoRenderer _localRenderer = RTCVideoRenderer();
  RTCVideoRenderer _remoteRenderer = RTCVideoRenderer();
  String? streamId;
  TextEditingController textEditingController = TextEditingController(text: '');

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

    _tab = TabController(length: 4, vsync: this);
    _tab.addListener(() => setState(() => _tabIndex = _tab.index));
  }

  @override
  void dispose() {
    _tab.dispose();
    _localRenderer.dispose();
    _remoteRenderer.dispose();
    super.dispose();
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
            actions: [],
            child: Expanded(
                child: Text('My streaming page',
                    overflow: TextOverflow.ellipsis,
                    style: MyTheme.appText()))),
        body: Column(
          children: [
            SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {
                    signaling.openUserMedia(_localRenderer, _remoteRenderer);
                  },
                  child: Text("Open camera & microphone"),
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
                    Expanded(child: RTCVideoView(_localRenderer, mirror: true)),
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
      );
}
