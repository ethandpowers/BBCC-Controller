import 'dart:convert';
import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:game_controller/desktop_interface.dart';
import 'package:game_controller/join_room.dart';
import 'package:game_controller/mobile_interface.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // set to landscape orientation
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);

  // set to fullscreen
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);

  runApp(const App());
}

class App extends StatelessWidget {
  const App({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Home(),
    );
  }
}

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  HomeState createState() => HomeState();
}

class HomeState extends State<Home> {
  static const sERVERuRI = 'ws://142.93.200.13:443';

  WebSocketChannel _channel = WebSocketChannel.connect(Uri.parse(sERVERuRI));

  String roomId = "";
  double previousX = 0;
  double previousY = 0;

  void sendInput(String input) {
    _channel.sink.add(jsonEncode({"type": "dispatch", "params": input}));
  }

  void sendButtonPress(String button) {
    sendInput('{"button":"$button"}');
  }

  void sendJoyStickInput(double x, double y) {
    if ((previousX - x).abs() > 0.1 || (previousY - y).abs() > 0.1) {
      sendInput(jsonEncode({"x": x, "y": y}));
      previousX = x;
      previousY = y;
    }
  }

  void sendZeroJoyStickInput() {
    sendInput(jsonEncode({"x": 0.0, "y": 0.0}));
    previousX = 0;
    previousY = 0;
  }

  void leaveRoom() {
    _channel.sink.add(jsonEncode({"type": "leave", "params": {}}));
    setState(() {
      roomId = "";
    });
  }

  @override
  void initState() {
    reconnect();
    super.initState();
  }

  void reconnect() {
    setState(() {
      _channel = WebSocketChannel.connect(Uri.parse(sERVERuRI));
    });
    // Websocket listener
    _channel.stream.listen(
      (event) {
        var obj = jsonDecode(event);
        switch (obj["message"]) {
          case "joined":
            setState(() {
              roomId = obj["params"]["group"];
            });
            break;
        }
      },
      onDone: reconnect,
    );
  }

  @override
  Widget build(BuildContext context) {
    //display controls when connected to room
    if (roomId.length == 5) {
      if (Platform.isMacOS || Platform.isWindows || Platform.isLinux) {
        return DesktopInterface(
          channel: _channel,
          sendButtonPress: sendButtonPress,
          leaveRoom: leaveRoom,
        );
      } else {
        return MobileInterface(
          channel: _channel,
          sendButtonPress: sendButtonPress,
          sendJoystickInput: sendJoyStickInput,
          sendZeroJoystickInput: sendZeroJoyStickInput,
          leaveRoom: leaveRoom,
        );
      }
    } else {
      //join room form
      return JoinRoom(channel: _channel);
    }
  }
}
