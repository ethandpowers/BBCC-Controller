import 'dart:convert';
import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:game_controller/desktop_interface.dart';
import 'package:game_controller/join_room.dart';
import 'package:game_controller/mobile_interface.dart';
import 'package:multi_window/multi_window.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

Future<void> main(List<String> args) async {
  MultiWindow.init(args);
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

  WebSocketChannel? _channel;

  String roomId = "";
  double previousX = 0;
  double previousY = 0;

  void sendInput(String input) {
    _channel?.sink.add('{"type": "dispatch", "params": $input}');
  }

  void sendButtonPress(String button) {
    sendInput(jsonEncode(
      {"type": "buttonPress", "button": button},
    ));
  }

  void sendButtonRelease(String button) {
    sendInput(jsonEncode(
      {"type": "buttonRelease", "button": button},
    ));
  }

  void sendJoyStickInput(double x, double y) {
    if ((previousX - x).abs() > 0.1 || (previousY - y).abs() > 0.1) {
      sendInput(jsonEncode(
        {
          "type": "joystick",
          "params": {"x": x, "y": y}
        },
      ));
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
    _channel?.sink.add(jsonEncode({"type": "leave", "params": {}}));
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
    _channel?.stream.listen(
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
    if (!Platform.isMacOS) {
      return buildBody();
    }
    return PlatformMenuBar(menus: <MenuItem>[
      PlatformMenu(
        label: 'Flutter API Sample',
        menus: <MenuItem>[
          PlatformMenuItemGroup(
            members: <MenuItem>[
              PlatformMenuItem(
                label: 'New Instance',
                onSelected: () {
                  MultiWindow.create('game_controller');
                },
              ),
            ],
          ),
          if (PlatformProvidedMenuItem.hasMenu(
              PlatformProvidedMenuItemType.quit))
            const PlatformProvidedMenuItem(
                type: PlatformProvidedMenuItemType.quit),
        ],
      ),
    ], child: buildBody());
  }

  Widget buildBody() {
    //display controls when connected to room
    if (_channel == null) return Container();
    if (roomId.length == 5) {
      if (Platform.isMacOS || Platform.isWindows || Platform.isLinux) {
        return DesktopInterface(
          channel: _channel!,
          sendButtonPress: sendButtonPress,
          sendButtonRelease: sendButtonRelease,
          leaveRoom: leaveRoom,
        );
      } else {
        return MobileInterface(
          channel: _channel!,
          sendButtonPress: sendButtonPress,
          sendJoystickInput: sendJoyStickInput,
          sendZeroJoystickInput: sendZeroJoyStickInput,
          leaveRoom: leaveRoom,
        );
      }
    } else {
      //join room form
      return JoinRoom(channel: _channel!);
    }
  }
}
