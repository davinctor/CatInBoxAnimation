import 'package:flutter/material.dart';
import 'dart:math' as math;

class Cat extends StatelessWidget {
  final CatImageState _catImageState;

  Cat(this._catImageState);

  Widget buildImage(imageName) {
    return Image.asset('assets/images/$imageName.png');
  }

  @override
  Widget build(BuildContext context) {
    switch (_catImageState) {
      case CatImageState.rightAngry: {
        return buildImage('cat_side_angry');
      }
      case CatImageState.leftAngry: {
        return Transform(
          child: buildImage('cat_side_angry'),
          transform: Matrix4.rotationY(math.pi),
          alignment: Alignment.center,
        );
      }
      case CatImageState.faceHappy: {
        return buildImage('cat_face_happy');
      }
      case CatImageState.faceAngry:
      default: {
        return buildImage('cat_face_angry');
      }
    }
  }
}

enum CatImageState {
  leftAngry,
  rightAngry,
  faceAngry,
  faceHappy,
}