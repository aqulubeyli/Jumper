import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame_tiled/flame_tiled.dart';

class CollisionBlock extends PositionComponent with HasGameReference {
  CollisionBlock(TiledObject obj)
    : super(
        position: Vector2(obj.x, obj.y),
        size: Vector2(obj.width, obj.height),
        anchor: Anchor.topLeft,
      ) {
    // Добавляем хитбокс. Flame сам разберется, что это объект коллизии.
    add(RectangleHitbox());
    debugMode = true;
  }
}
