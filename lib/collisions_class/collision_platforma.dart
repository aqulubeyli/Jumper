import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame_tiled/flame_tiled.dart';

class CollisionPlatforma extends PositionComponent {
  CollisionPlatforma(TiledObject obj)
    : super(
        position: Vector2(obj.x, obj.y),
        size: Vector2(obj.width, obj.height),
      ) {
    add(RectangleHitbox());
  }
}
