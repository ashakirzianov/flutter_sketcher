import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_sketcher/color.dart';
import 'package:flutter_sketcher/object.dart';
import 'package:flutter_sketcher/sketcher.dart';

class RythmWeb extends StatelessWidget {
  const RythmWeb({super.key});

  @override
  Widget build(BuildContext context) {
    var n = 13;
    var state = <Object>[];
    var stepx = 30;
    var stepy = 40;
    var random = Random();
    for (var i = 0; i < n; i++) {
      for (var j = 0; j < n; j++) {
        if ((i + j) % 2 == 0) {
          continue;
        }
        var x = j * stepx.toDouble(); // - (n - 1) * stepx / 2;
        var y = i * stepy.toDouble(); //- (n - 1) * stepy / 2;
        var mass = random.nextDouble() * 2 + 1;
        Object object = (
          position: (x: x, y: y, z: 0),
          velocity: (x: 0, y: 0, z: 0),
          mass: mass,
          radius: 20 * random.nextDouble() * mass,
        );
        state.add(object);
      }
    }
    var box = getBoundingBox(state);
    return SceneWidget<Objects>(
      state: state,
      animator: reduceAnimators([
        gravity(0.02),
        velocityStep(),
      ]),
      layers: [
        Layer(
          background: (canvas, size, state, frame) {
            canvas.drawRect(
              Rect.fromLTWH(0, 0, size.width, size.height),
              Paint()..color = Colors.black,
            );
          },
          render: (canvas, size, state, frame) {
            final double alpha = 1 / (frame / 100 + 1);
            var colors = hslaRange(
              start: HSLColor.fromAHSL(alpha, 40, .80, .50),
              end: HSLColor.fromAHSL(alpha, 80, .80, .50),
              count: 15,
            );
            canvas.save();
            zoomToFit(canvas, size, box);
            for (var idx = 0; idx < state.length; idx++) {
              var object = state[idx];
              var color = modItem(colors, idx);
              canvas.drawCircle(
                Offset(object.position.x, object.position.y),
                object.radius / log(frame / 10 + 1),
                Paint()
                  ..strokeWidth = .1
                  ..color = color
                  ..style = PaintingStyle.stroke,
              );
            }
            canvas.restore();
          },
        ),
      ],
    );
  }
}
