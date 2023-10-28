import 'package:flutter/material.dart';


import 'package:agora_rtc_engine/rtc_local_view.dart' as RtcLocalView;
import 'package:agora_rtc_engine/rtc_remote_view.dart' as RtcRemoteView;
import 'package:agora_rtc_engine/agora_rtc_engine.dart';

import 'package:flutter_dotenv/flutter_dotenv.dart';

class UserPage extends StatefulWidget {
  final String channelName;
  final String userName;
  final int uid;  

  const UserPage({
    Key? key,
    required this.channelName,
    required this.userName,
    required this.uid,
  }) : super(key: key);

  @override
  State<UserPage> createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  List<int> _users = [];
  late RtcEngine _engine;
  AgoraRtmClient _client;
  AgoraRtmChannel? _channel;

  @override
  void initState() {
    super.initState();
    // initialize agora sdk
    initializeAgora();
  }

  Future<void> initializeAgora() async {
    _engine = await RtcEngine.createWithConfig(RtcEngineConfig(
      dotenv.env['AGORA_APP_ID']!,
    ));
    _client = await AgoraRtmClient.createInstance(dotenv.env['AGORA_APP_ID']!);

    await _engine.enableVideo();
    await _engine.setChannelProfile(ChannelProfile.LiveBroadcasting);
    await _engine.setClientRole(ClientRole.Broadcaster);

    _engine.setEventHandler(
      RtcEngineEventHandler(
        joinChannelSuccess: (String channel, int uid, int elapsed) {
          print('joinChannelSuccess ${channel} ${uid} ${elapsed}');
          setState(() {
            _users.add(uid);
          });
        },
      ),
    );

    _client?.onMessageReceived = (AgoraRtmMessage message, String peerId) {
      print("Peer msg: " + peerId + ", msg: " + message.text);
    };

    _client?.onConnectionStateChanged = (int state, int reason) {
      print('Connection state changed: ' + state.toString() + ', reason: ' + reason.toString());
      if (state == 5) {
        _channel?.leave();
        _client?.logout();
        _client?.destroy();
        print('Logout.');
      }
    };

    _channel?.onMenberJoined = (AgoraRtmMember member) {
      print('Member joined: ' + member.userId + ', channel: ' + member.channelId);
    };

    _channel?.onMenberLeft = (AgoraRtmMember member) {
      print('Member left: ' + member.userId + ', channel: ' + member.channelId);
    };

    _channel?.onMessageReceived = (AgoraRtmMessage message, AgoraRtmMember member) {
      print('Channel msg: ' + member.userId + ', msg: ' + message.text);
    };

    await _client.login(null, widget.uid.toString());
    _channel = await _client.createChannel(widget.channelName);
    await _channel?.join();
    await _engine.joinChannel(null, widget.channelName, null, widget.uid);
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: Text("User Page")));
  }
}
