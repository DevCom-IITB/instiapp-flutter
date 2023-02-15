import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import 'dart:math';

class PopUpBox extends StatefulWidget {
  @override
  State<PopUpBox> createState() => _PopUpBoxState();
}

class _PopUpBoxState extends State<PopUpBox> {
  late ConfettiController _controllerBottomLeft;
  late ConfettiController _controllerBottomRight;

  @override
  void initState() {
    super.initState();

    _controllerBottomLeft =
        ConfettiController(duration: const Duration(milliseconds: 100));
    _controllerBottomRight =
        ConfettiController(duration: const Duration(milliseconds: 100));
    _controllerBottomLeft.play();
    _controllerBottomRight.play();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Center(
          child: Material(
            color: Colors.transparent,
            child: Container(
              height: MediaQuery.of(context).size.width,
              margin: EdgeInsets.symmetric(horizontal: 10),
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(22),
                gradient: LinearGradient(
                  colors: [
                    Colors.orange,
                    Colors.blueGrey,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Join the celebration as",
                        style: TextStyle(fontFamily: "Quicksand")),
                    Text("INSTIAPP TURNS 5",
                        style: TextStyle(fontFamily: "Quickens")),
                    CachedNetworkImage(
                        width: 0.33 * MediaQuery.of(context).size.width,
                        imageUrl:
                            "https://thumbs.dreamstime.com/b/christmas-star-background-6396494.jpg"),
                    Text(
                        "Lets wish happy birthday to an app that never stopped being so incredibly awesome",
                        style: TextStyle(fontFamily: "Quicksand")),
                    IconButton(onPressed: () {}, icon: const Icon(Icons.share))
                  ]),
            ),
          ),
        ),
        Align(
          alignment: Alignment.topLeft,
          child: ConfettiWidget(
            confettiController: _controllerBottomLeft,
            blastDirection: pi / 6,
            emissionFrequency: 0.01,
            numberOfParticles: 100,
            maxBlastForce: 30,
            minBlastForce: 20,
            gravity: 0.3,
            maximumSize: const Size(50, 10),
          ),
        ),
        Align(
          alignment: Alignment.topRight,
          child: ConfettiWidget(
            confettiController: _controllerBottomRight,
            blastDirection: (pi - pi / 6),
            emissionFrequency: 0.01,
            numberOfParticles: 50,
            maxBlastForce: 30,
            minBlastForce: 20,
            gravity: 0.3,
            maximumSize: const Size(50, 10),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _controllerBottomLeft.dispose();
    _controllerBottomRight.dispose();
    super.dispose();
  }
}
