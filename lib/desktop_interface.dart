import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class DesktopInterface extends StatelessWidget {
  const DesktopInterface({
    super.key,
    required this.channel,
    required this.sendButtonPress,
    required this.leaveRoom,
  });
  final WebSocketChannel channel;
  final Function sendButtonPress;
  final Function leaveRoom;

  @override
  Widget build(BuildContext context) {
    return RawKeyboardListener(
      autofocus: true,
      focusNode: FocusNode(),
      onKey: (event) {
        sendButtonPress(event.character);
      },
      child: Scaffold(
        //exit button
        floatingActionButton: FloatingActionButton(
          child: const Icon(Icons.exit_to_app),
          onPressed: () {
            leaveRoom();
          },
        ),
        body: const Text("Desktop Interface"),
      ),
    );
  }
}
