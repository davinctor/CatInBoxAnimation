import 'package:flutter/material.dart';
import 'dart:math';
import 'package:quiver/async.dart';

import '../widgets/cat.dart';

class Home extends StatefulWidget {
  @override
  State<Home> createState() => HomeState();
}

const TURN_TO_SIDE_TIMES = 2;

class HomeState extends State<Home> with TickerProviderStateMixin {
  Animation<double> _catAnimation;
  AnimationController _catAnimationController;
  Animation<double> _flapAnimation;
  AnimationController _flapAnimationController;
  CountdownTimer _turnHeadToSideTimer;

  CatImageState _catImageState = CatImageState.faceAngry;

  Color boxColor = Colors.brown[400];

  @override
  void initState() {
    prepareAnimation();
    _flapAnimationController.forward();
    super.initState();
  }

  @override
  void dispose() {
    _catAnimationController.dispose();
    _flapAnimationController.dispose();
    _turnHeadToSideTimer.cancel();
    super.dispose();
  }

  void onLongCatPressed() {
    final catAnimationStatus = _catAnimation.status;
    if (catAnimationStatus == AnimationStatus.dismissed) {
      _flapAnimationController.stop();
      _catAnimationController.forward();
    }
  }

  void prepareAnimation() {
    _catAnimationController = AnimationController(
      duration: Duration(milliseconds: 350),
      vsync: this,
    );
    _catAnimationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        startTurnHeadToSideTimer();
      } else if (status == AnimationStatus.dismissed) {
        _flapAnimationController.forward();
        changeCatHeadState(CatImageState.faceAngry);
      }
    });
    _catAnimation = Tween(
      begin: -50.0,
      end: -160.0,
    ).animate(CurvedAnimation(
      curve: Curves.easeIn,
      parent: _catAnimationController,
    ));
    _flapAnimationController = AnimationController(
      duration: Duration(milliseconds: 400),
      vsync: this,
    );
    _flapAnimation = Tween(
      begin: pi * 0.55,
      end: pi * 0.6,
    ).animate(CurvedAnimation(
      curve: Curves.easeInOut,
      parent: _flapAnimationController,
    ));
    _flapAnimation.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _flapAnimationController.reverse();
      } else if (status == AnimationStatus.dismissed) {
        _flapAnimationController.forward();
      }
    });
  }

  void startTurnHeadToSideTimer() {
    _turnHeadToSideTimer = CountdownTimer(
        Duration(seconds: TURN_TO_SIDE_TIMES * 2 + 1), // each side plus face
        Duration(seconds: 1));
    _turnHeadToSideTimer.listen(
      (event) {
        changeCatHeadState(event.elapsed.inSeconds % 2 == 0
            ? CatImageState.rightAngry
            : CatImageState.leftAngry);
      },
      onDone: () {
        changeCatHeadState(CatImageState.faceAngry);
        runWithDelay(1000, () {
          changeCatHeadState(CatImageState.faceHappy);
          runWithDelay(700, () {
            _catAnimationController.reverse();
          });
        });
      },
    );
  }

  void runWithDelay(int milliseconds, Function callback) {
    Future.delayed(
      Duration(milliseconds: milliseconds),
      callback,
    );
  }

  void changeCatHeadState(CatImageState state) {
    setState(() => _catImageState = state);
  }

  Widget buildBox() {
    return Container(
      width: 200.0,
      height: 200.0,
      color: boxColor,
    );
  }

  Widget buildLeftFlap() {
    return Positioned(
      child: AnimatedBuilder(
        animation: _flapAnimation,
        builder: (context, child) {
          return Transform.rotate(
            child: child,
            angle: _flapAnimation.value,
            alignment: Alignment.topLeft,
          );
        },
        child: Container(
          width: 125.0,
          height: 10.0,
          color: boxColor,
        ),
      ),
      top: 5.0,
      left: 10.0,
    );
  }

  Widget buildRightFlap() {
    return Positioned(
      top: 5.0,
      right: 10.0,
      child: AnimatedBuilder(
        animation: _flapAnimation,
        builder: (context, child) {
          return Transform.rotate(
            child: child,
            angle: -_flapAnimation.value,
            alignment: Alignment.topRight,
          );
        },
        child: Container(
          width: 125.0,
          height: 10.0,
          color: boxColor,
        ),
      ),
    );
  }

  Widget buildCatAnimation() {
    return AnimatedBuilder(
      animation: _catAnimation,
      builder: (context, child) {
        return Positioned(
          child: child,
          top: _catAnimation.value,
          right: 0.0,
          left: 0.0,
        );
      },
      child: Cat(_catImageState),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Center(
          child: Stack(
        overflow: Overflow.visible,
        children: <Widget>[
          buildCatAnimation(),
          buildBox(),
          buildLeftFlap(),
          buildRightFlap(),
        ],
      )),
      onLongPress: onLongCatPressed,
    );
  }
}
