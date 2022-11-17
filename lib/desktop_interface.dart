import 'dart:async';
import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class DesktopInterface extends StatefulWidget {
  const DesktopInterface({
    super.key,
    required this.channel,
    required this.sendButtonPress,
    required this.sendButtonRelease,
    required this.leaveRoom,
  });
  final WebSocketChannel channel;
  final Function sendButtonPress;
  final Function sendButtonRelease;
  final Function leaveRoom;

  @override
  DesktopInterfaceState createState() => DesktopInterfaceState();
}

class DesktopInterfaceState extends State<DesktopInterface> {
  // list of keys pressed
  List<String> keysPressed = [];
  // List<KeyOption> keysPressed = [];

  // @override
  // void initState() {
  //   super.initState();

  //   const tenMs = Duration(milliseconds: 10);
  //   Timer.periodic(
  //       tenMs,
  //       (Timer t) => {
  //             keysPressed
  //                 .where((element) => !element.notified)
  //                 .forEach((element) {
  //               widget.sendButtonPress(element.key);
  //               element.notified = true;
  //             })
  //           });
  // }

  @override
  Widget build(BuildContext context) {
    return KeyboardListener(
      autofocus: true,
      focusNode: FocusNode(),
      onKeyEvent: (event) {
        // if (event.runtimeType == KeyUpEvent) {
        //   widget.sendButtonRelease(event.logicalKey.keyLabel);
        //   keysPressed.removeWhere(
        //       (element) => element.key == event.logicalKey.keyLabel);
        //   // re-notify for each key pressed after any key is released
        //   keysPressed.every((element) => element.notified = false);
        // } else {
        //   // if key is not already pressed
        //   if (!keysPressed
        //       .any((element) => element.key == event.logicalKey.keyLabel)) {
        //     keysPressed.add(
        //         KeyOption(key: event.logicalKey.keyLabel, notified: false));
        //   }
        // }

        if (event.runtimeType == KeyUpEvent) {
          keysPressed.remove(event.logicalKey.keyLabel);
          widget.sendButtonRelease(event.logicalKey.keyLabel);
        } else {
          // if key is not already pressed
          if (!keysPressed.contains(event.logicalKey.keyLabel)) {
            keysPressed.add(event.logicalKey.keyLabel);
            widget.sendButtonPress(event.logicalKey.keyLabel);
          }
        }
      },
      child: Scaffold(
        //exit button
        floatingActionButton: FloatingActionButton(
          child: const Icon(Icons.exit_to_app),
          onPressed: () {
            widget.leaveRoom();
          },
        ),
        body: const Center(child: Text("Desktop Interface")),
      ),
    );
  }
}

class KeyOption {
  KeyOption({required this.key, required this.notified});

  String key;
  bool notified;
}
