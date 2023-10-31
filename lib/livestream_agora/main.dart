//import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:mediaplex/livestream_agora/signaling.dart';
import 'package:mediaplex/utils/theme.dart';
import 'package:mediaplex/auth/service/user_service.dart';
import 'package:mediaplex/auth/models/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
  FirebaseFirestore db = FirebaseFirestore.instance;
  String? streamId = null;
  String? streamIdJoin = null;
  TextEditingController textEditingController = TextEditingController(text: '');
  TextEditingController textEditingController2 =
      TextEditingController(text: '');
  final UserService _userService = UserService();
  late Future<Profile> _profile;
  late Profile _data;
  late Future<List<Profile>> _users;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _formKey2 = GlobalKey<FormState>();

  @override
  void initState() {
    _localRenderer.initialize();
    _remoteRenderer.initialize();

    signaling.onAddRemoteStream = ((stream) {
      _remoteRenderer.srcObject = stream;
      setState(() {});
    });

    // Add event listener to peerConnection
    signaling.peerConnection?.onConnectionState = (state) {
      print("signaling.peerConnection?.onConnectionState");
      print(state);
      if (state == RTCPeerConnectionState.RTCPeerConnectionStateDisconnected) {
        // The peer connection has disconnected
        // You can add your custom logic here
        print("Peer Connection Disconnected 2");

        // Close the peer connection
        signaling.peerConnection?.close();
        FirebaseFirestore db = FirebaseFirestore.instance;
        print(streamId);
        DocumentReference streamRef = db.collection('streams').doc('$streamId');
        streamRef.delete();
      }
    };
    //if sig

    super.initState();
    WidgetsFlutterBinding.ensureInitialized();
    _profile = _userService.fetchProfile(context);
    _tab = TabController(length: 3, vsync: this);
    _tab.addListener(() => setState(() => _tabIndex = _tab.index));
    _users = _userService.fetchUsers(context);
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
                  text: 'Join stream with id',
                  icon: Icon(Icons.featured_video, color: MyTheme.secondary)),
              Tab(
                  text: 'List stream',
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
                                  Text('Stream of ${_data.username}',
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
                      // padding: const EdgeInsets.all(10),
                      //decoration: MyTheme.boxDecoration(),
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
                                  streamId != null
                                      ? Container()
                                      : Container(
                                          height: 50,
                                          decoration: MyTheme.boxDecoration(
                                              radius: 30,
                                              colors: [
                                                MyTheme.logoDark,
                                                MyTheme.logoLight
                                                    .withOpacity(0.7)
                                              ]),
                                          child: ElevatedButton(
                                              style: MyTheme.buttonStyle(
                                                  bgColor: Colors.transparent,
                                                  borderColor:
                                                      Colors.transparent),
                                              onPressed: () async {
                                                streamId = await signaling
                                                    .createStream(
                                                        _remoteRenderer, _data);
                                                textEditingController.text =
                                                    streamId!;
                                                setState(() {});
                                              },
                                              child: Text('Create stream',
                                                  style: MyTheme.appText()))),
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
                    streamId != null
                        ? Container(
                            height: 50,
                            decoration: MyTheme.boxDecoration(
                                radius: 30,
                                colors: [
                                  MyTheme.logoDark,
                                  MyTheme.logoLight.withOpacity(0.7)
                                ]),
                            child: ElevatedButton(
                                style: MyTheme.buttonStyle(
                                    bgColor: Colors.transparent,
                                    borderColor: Colors.transparent),
                                onPressed: () async {
                                  signaling.hangUp(streamId!, _localRenderer);
                                  streamId = null;
                                  _localRenderer = RTCVideoRenderer();
                                  textEditingController.text = '';
                                  setState(() {});
                                  initState();
                                  /* signaling.openUserMedia(
                                      _localRenderer, _remoteRenderer);*/
                                },
                                child: Text('Stop stream',
                                    style: MyTheme.appText())))
                        : Container(),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Join the stream with ID:',
                          style: MyTheme.appText(weight: FontWeight.w500)),
                      const SizedBox(height: 40),
                      SizedBox(
                        width: MediaQuery.sizeOf(context).width * .7,
                        child: Form(
                          key: _formKey,
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          child: Column(children: [
                            TextFormField(
                                autofocus: true,
                                controller: textEditingController,
                                textInputAction: TextInputAction.next,
                                onFieldSubmitted: (value) =>
                                    TextInputAction.next,
                                style:
                                    MyTheme.appText(weight: FontWeight.normal),
                                decoration: MyTheme.inputDecoration(
                                    fontSize: 15,
                                    hint: 'Stream Id',
                                    prefixIcon: Icons.person),
                                enabled: false,
                                validator: (value) {
                                  if (value == null || value.isEmpty)
                                    return 'Stream ID is required.';
                                  if (value.length < 10)
                                    return 'Stream ID should be at least 10 characters long.';
                                  return null;
                                }),
                          ]),
                        ),
                      )
                    ],
                  ),
                ),
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
                    Container(
                        height: 50,
                        decoration: MyTheme.boxDecoration(radius: 30, colors: [
                          MyTheme.logoDark,
                          MyTheme.logoLight.withOpacity(0.7)
                        ]),
                        child: ElevatedButton(
                            style: MyTheme.buttonStyle(
                                bgColor: Colors.transparent,
                                borderColor: Colors.transparent),
                            onPressed: () async {
                              signaling.joinStream(
                                textEditingController2.text.trim(),
                                _remoteRenderer,
                              );
                              signaling.peerConnection?.onConnectionState =
                                  (state) {
                                print(
                                    "signaling.peerConnection?.onConnectionState");
                                print(state);
                                if (state ==
                                    RTCPeerConnectionState
                                        .RTCPeerConnectionStateDisconnected) {
                                  // The peer connection has disconnected
                                  // You can add your custom logic here
                                  print("Peer Connection Disconnected 3");

                                  // Close the peer connection
                                  signaling.peerConnection?.close();
                                  FirebaseFirestore db =
                                      FirebaseFirestore.instance;
                                  print(streamId);
                                  DocumentReference streamRef =
                                      db.collection('streams').doc('$streamId');
                                  streamRef.delete();
                                }
                              };
                            },
                            child:
                                Text('Join stream', style: MyTheme.appText()))),
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
                        Expanded(
                            child: RTCVideoView(_remoteRenderer, mirror: true)),
                      ],
                    ),
                  ),
                ),
                /*FutureBuilder<List<Profile>>(
                    future: _users,
                    builder: (context, snapshot) {
                      if (snapshot.hasError)
                        return Center(
                            child: Text(
                                'Something went wrong...\nPlease try again later.',
                                textAlign: TextAlign.center,
                                style: MyTheme.appText(size: 20)));

                      if (snapshot.hasData) {
                        final user = snapshot.data!;
                        //return list view of users
                        return ListView.builder(
                            itemCount: user.length,
                            itemBuilder: (context, index) {
                              return Text("test");
                            });
                      } else {
                        return Center(child: CircularProgressIndicator());
                      }
                    }),*/
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Join the stream with ID:',
                          style: MyTheme.appText(weight: FontWeight.w500)),
                      const SizedBox(height: 40),
                      SizedBox(
                        width: MediaQuery.sizeOf(context).width * .7,
                        child: Form(
                          key: _formKey2,
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          child: Column(children: [
                            TextFormField(
                                autofocus: true,
                                controller: textEditingController2,
                                textInputAction: TextInputAction.next,
                                onFieldSubmitted: (value) =>
                                    TextInputAction.next,
                                style:
                                    MyTheme.appText(weight: FontWeight.normal),
                                decoration: MyTheme.inputDecoration(
                                    fontSize: 15,
                                    hint: 'Stream Id',
                                    prefixIcon: Icons.person),
                                validator: (value) {
                                  if (value == null || value.isEmpty)
                                    return 'Stream ID is required.';
                                  if (value.length < 10)
                                    return 'Stream ID should be at least 10 characters long.';
                                  return null;
                                }),
                          ]),
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
            child: StreamBuilder<QuerySnapshot>(
              stream: db.collection('streams').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator(); // Display a loading indicator
                }
                if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                }
                if (!snapshot.hasData) {
                  return Text('No data available'); // Handle empty data
                }

                final streamDocs = snapshot.data!.docs;

                return ListView.builder(
                  itemCount: streamDocs.length,
                  itemBuilder: (context, index) {
                    // print(streamData);
                    final streamData = streamDocs[index].data();

                    //if profile is not null then print the profile
                    //
                    if (streamData is Map<String, dynamic>) {
                      var profile = streamData["profile"];
                      var username = profile["username"];

                      return Card(
                        elevation: 3, // Pour ajouter une ombre à la carte
                        margin: EdgeInsets.all(8), // Marge autour de la carte
                        child: ListTile(
                          title: Text('Streamer : $username'),
                          onTap: () {
                            streamIdJoin = streamDocs[index].id.toString();
                            _tab.index = 1;
                            textEditingController2.text =
                                streamIdJoin.toString();
                          },
                          leading: Icon(
                              Icons.video_library), // Icône à gauche du titre
                          subtitle: Text("More information here"), // Sous-titre
                          // Vous pouvez personnaliser davantage en ajoutant plus d'informations ici
                        ),
                      );
                    }
                    return ListTile(
                      title: Text("No stream available"),
                    );
                  },
                );
              },
            ),
          ),
        ]),
      );
}
