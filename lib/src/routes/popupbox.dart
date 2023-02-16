import 'dart:io';

import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:math';

import 'package:share/share.dart';

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
              width: MediaQuery.of(context).size.width,
              margin: EdgeInsets.symmetric(horizontal: 10),
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(22),
                gradient: LinearGradient(
                  colors: [
                    Color(0xff8bb7fe),
                    Color.fromARGB(255, 158, 195, 255),
                    Color(0xffe1eaff),
                    Color(0xffeaf0ff),
                    Color(0xffffffff),
                    Color(0xfff4f2fe),
                    Color(0xffeaf0ff),
                    Color(0xffded7ff),
                    Color(0xffded7ff),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(0, 40, 0, 40),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Stack(
                        children: <Widget>[
                          Text("Join the celebration as",
                              style: TextStyle(
                                  fontSize: 16,
                                  foreground: Paint()
                                    ..style = PaintingStyle.stroke
                                    ..strokeWidth = 1
                                    ..color = Color(0xff1960d2),
                                  fontFamily: "Quicksand")),
                          Text("Join the celebration as",
                              style: TextStyle(
                                  fontSize: 16,
                                  color: Color(0xff348ded),
                                  fontFamily: "Quicksand")),
                        ],
                      ),
                      Text(
                        "INSTIAPP TURNS 5",
                        style: TextStyle(
                          color: Color(0xff3a77ee),
                          fontFamily: "Quickens",
                          fontSize: 34,
                        ),
                      ),
                      Image.asset(
                        "assets/login/lotus.png",
                        width: 0.33 * MediaQuery.of(context).size.width,
                      ),
                      Stack(
                        children: [
                          Text("Lets wish happy birthday to an",
                              style: TextStyle(
                                  foreground: Paint()
                                    ..style = PaintingStyle.stroke
                                    ..strokeWidth = 1
                                    ..color = Color(0xff1960d2),
                                  fontSize: 17,
                                  fontFamily: "Quicksand")),
                          Text("Lets wish happy birthday to an",
                              style: TextStyle(
                                  color: Color(0xff348ded),
                                  fontSize: 17,
                                  fontFamily: "Quicksand")),
                        ],
                      ),
                      Stack(
                        children: [
                          Text("app that never stopped being so",
                              style: TextStyle(
                                  fontSize: 17,
                                  foreground: Paint()
                                    ..style = PaintingStyle.stroke
                                    ..strokeWidth = 1
                                    ..color = Color(0xff1960d2),
                                  fontFamily: "Quicksand")),
                          Stack(
                            children: [
                              Text("app that never stopped being so",
                                  style: TextStyle(
                                      fontSize: 17,
                                      foreground: Paint()
                                        ..style = PaintingStyle.stroke
                                        ..strokeWidth = 1
                                        ..color = Color(0xff1960d2),
                                      fontFamily: "Quicksand")),
                              Text("app that never stopped being so",
                                  style: TextStyle(
                                      fontSize: 17,
                                      color: Color(0xff348ded),
                                      fontFamily: "Quicksand")),
                            ],
                          ),
                        ],
                      ),
                      Stack(
                        children: [
                          Text("incredibly awesome",
                              style: TextStyle(
                                  fontSize: 17,
                                  foreground: Paint()
                                    ..style = PaintingStyle.stroke
                                    ..strokeWidth = 1
                                    ..color = Color(0xff1960d2),
                                  fontFamily: "Quicksand")),
                          Text("incredibly awesome",
                              style: TextStyle(
                                  fontSize: 17,
                                  color: Color(0xff348ded),
                                  fontFamily: "Quicksand")),
                        ],
                      ),
                      IconButton(
                          onPressed: () async {
                            Directory _path =
                                await getApplicationDocumentsDirectory();
                            String _localPath = _path.path +
                                Platform.pathSeparator +
                                'Download';
                            final path =
                                '${_localPath + Platform.pathSeparator}instastory.jpg';
                            await Share.shareFiles([path],
                                mimeTypes: ["image/png"]);
                          },
                          icon: const Icon(Icons.share))
                    ]),
              ),
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
