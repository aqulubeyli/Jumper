import 'dart:async';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame_tiled/flame_tiled.dart';

class CollisionWall extends PositionComponent {
  CollisionWall(TiledObject obj)
    : super(
        position: Vector2(obj.x, obj.y),
        size: Vector2(obj.width, obj.height),
      ) {
    add(RectangleHitbox());
  }
}
