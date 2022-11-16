import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class JoinRoom extends StatefulWidget {
  const JoinRoom({super.key, required this.channel});
  final WebSocketChannel channel;

  @override
  JoinRoomState createState() => JoinRoomState();
}

class JoinRoomState extends State<JoinRoom> {
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              "Join Room",
              style: TextStyle(fontSize: 30),
            ),
            SizedBox(
              width: MediaQuery.of(context).size.width / 3,
              child: TextField(
                controller: _controller,
                decoration: const InputDecoration(
                  hintText: "Room ID",
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                //verify valid form value
                if (_controller.text.length == 5) {
                  widget.channel.sink.add(jsonEncode({
                    "type": "join",
                    "params": {"code": _controller.text.toUpperCase()}
                  }));
                }
              },
              child: const Text("Join"),
            ),
          ],
        ),
      ),
    );
  }
}
