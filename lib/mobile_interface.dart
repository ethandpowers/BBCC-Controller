import 'package:flutter/material.dart';
import 'package:flutter_joystick/flutter_joystick.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class MobileInterface extends StatelessWidget {
  const MobileInterface({
    super.key,
    required this.channel,
    required this.sendButtonPress,
    required this.sendJoystickInput,
    required this.sendZeroJoystickInput,
    required this.leaveRoom,
  });
  final WebSocketChannel channel;
  final Function sendButtonPress;
  final Function sendJoystickInput;
  final Function sendZeroJoystickInput;
  final Function leaveRoom;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //exit button
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.exit_to_app),
        onPressed: () {
          leaveRoom();
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      body: Row(
        children: [
          //left joystick
          SizedBox(
            width: MediaQuery.of(context).size.width / 2,
            child: JoystickArea(
              initialJoystickAlignment: Alignment.center,
              period: const Duration(milliseconds: 1),
              base: Image.asset('assets/images/joystick_background.png'),
              stick: Image.asset('assets/images/joystick_knob.png'),
              listener: (details) {
                sendJoystickInput(details.x, details.y);
              },
              onStickDragEnd: () {
                sendZeroJoystickInput();
              },
            ),
          ),
          SizedBox(
            width: MediaQuery.of(context).size.width / 2,
            // two buttons on top of each other, uaing the full height of the screen
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: SizedBox(
                    // height: MediaQuery.of(context).size.height / 2,
                    width: MediaQuery.of(context).size.width / 2,
                    child: Listener(
                      onPointerDown: (event) {
                        sendButtonPress("A");
                      },
                      child: TextButton(
                        style: const ButtonStyle(enableFeedback: false),
                        onPressed: () {},
                        child: const Text(
                          "A",
                          style: TextStyle(
                            fontSize: 50,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: SizedBox(
                    // height: MediaQuery.of(context).size.height / 2,
                    width: MediaQuery.of(context).size.width / 2,
                    child: Listener(
                      onPointerDown: (event) {
                        sendButtonPress("B");
                      },
                      child: TextButton(
                        onPressed: () {},
                        style: const ButtonStyle(enableFeedback: false),
                        child: const Text(
                          "B",
                          style: TextStyle(
                            fontSize: 50,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
