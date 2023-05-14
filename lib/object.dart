import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_sketcher/sketcher.dart';

typedef Point = ({double x, double y, double z});
typedef Object = ({
  Point position,
  Point velocity,
  double mass,
  double radius,
});
typedef Objects = List<Object>;

Point addPoints(Point a, Point b) {
  return (x: a.x + b.x, y: a.y + b.y, z: a.z + b.z);
}

Point scalePoint(Point p, double scale) {
  return (x: p.x * scale, y: p.y * scale, z: p.z * scale);
}

Animator<Objects> gravity(double g) {
  Objects animator(Objects objects) {
    Objects updatedObjects = List.from(objects);
    for (int i = 0; i < objects.length; i++) {
      for (int j = i + 1; j < objects.length; j++) {
        // print('object $i, $j');
        final objI = updatedObjects[i];
        final objJ = updatedObjects[j];

        Point direction =
            addPoints(objJ.position, scalePoint(objI.position, -1));

        double dist = sqrt(direction.x * direction.x +
            direction.y * direction.y +
            direction.z * direction.z);

        double force = g * objI.mass * objJ.mass / (dist * dist);

        updatedObjects[i] = (
          position: objI.position,
          mass: objI.mass,
          radius: objI.radius,
          velocity: addPoints(objI.velocity, scalePoint(direction, force)),
        );
        updatedObjects[j] = (
          position: objJ.position,
          mass: objJ.mass,
          radius: objJ.radius,
          velocity: addPoints(objJ.velocity, scalePoint(direction, -1 * force)),
        );
      }
    }

    return updatedObjects;
  }

  return animator;
}

Animator<Objects> velocityStep() {
  return (objects) {
    var updatedObjects = <Object>[];
    for (var obj in objects) {
      var updated = (
        position: addPoints(obj.position, obj.velocity),
        mass: obj.mass,
        radius: obj.radius,
        velocity: obj.velocity,
      );
      updatedObjects.add(updated);
    }
    return updatedObjects;
  };
}

Animator<S> reduceAnimators<S>(List<Animator<S>> animators) {
  return (state) {
    for (var animator in animators) {
      state = animator(state);
    }
    return state;
  };
}

// Gets bounding box of objects
Rect getBoundingBox(Objects objects) {
  double minX = double.infinity;
  double maxX = double.negativeInfinity;
  double minY = double.infinity;
  double maxY = double.negativeInfinity;

  for (var obj in objects) {
    if (obj.position.x - obj.radius < minX) {
      minX = obj.position.x - obj.radius;
    }
    if (obj.position.x + obj.radius > maxX) {
      maxX = obj.position.x + obj.radius;
    }
    if (obj.position.y - obj.radius < minY) {
      minY = obj.position.y - obj.radius;
    }
    if (obj.position.y + obj.radius > maxY) {
      maxY = obj.position.y + obj.radius;
    }
  }

  return Rect.fromLTRB(minX, minY, maxX, maxY);
}

// Zoom canvas to fit the rectangle
void zoomToFit(Canvas canvas, Size size, Rect rect) {
  double canvasWidth = size.width;
  double canvasHeight = size.height;

  double rectWidth = rect.right - rect.left;
  double rectHeight = rect.bottom - rect.top;

  double scale = min(canvasWidth / rectWidth, canvasHeight / rectHeight);

  // Calculate the translation required to center the rectangle on the canvas
  double translateX = (canvasWidth - rectWidth * scale) / 2;
  double translateY = (canvasHeight - rectHeight * scale) / 2;

  // Apply the transformations in the following order:
  // 1. Translate to center
  // 2. Translate by the negation of the rectangle's top-left corner
  // 3. Scale the canvas
  canvas.translate(translateX, translateY);
  canvas.translate(-rect.left * scale, -rect.top * scale);
  canvas.scale(scale, scale);
}
