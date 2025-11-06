import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:task_2/collisions_class/collision_ground.dart';
import 'package:task_2/collisions_class/collision_platforma.dart';
import 'package:task_2/collisions_class/collision_wall.dart';

class Player extends PositionComponent with CollisionCallbacks {
  // Joystick to control the player
  final JoystickComponent joystick;
  Vector2 velocity = Vector2.zero();

  // Physics constants
  final double _gravity = 980;
  final double _moveSpeed = 200;
  final double _jumpForce = 500;

  bool isOnGround = false;

  Player({Vector2? position, required this.joystick})
    : super(position: position ?? Vector2.zero(), size: Vector2.all(64)) {
    // A simple square to represent the player
    add(RectangleComponent(size: size, paint: Paint()..color = Colors.blue));
    add(RectangleHitbox());
  }

  double moveTowards(double current, double target, double maxDelta) {
    if ((target - current).abs() <= maxDelta) return target;
    return current + (target > current ? maxDelta : -maxDelta);
  }

  @override
  void update(double dt) {
    super.update(dt);

    // ---- 1) Smooth Horizontal Movement (Acceleration) ----
    double targetXSpeed = joystick.relativeDelta.x * _moveSpeed;
    velocity.x = moveTowards(
      velocity.x,
      targetXSpeed,
      800 * dt,
    ); // <— 800 = acceleration strength

    // ---- 2) Better Gravity (fall faster) ----
    if (velocity.y < 0) {
      // going up
      velocity.y += _gravity * 0.6 * dt; // gentle gravity going up
    } else {
      // falling
      velocity.y += _gravity * 1.3 * dt; // stronger fall
    }

    // ---- 3) Variable Jump Height ----
    if (!isOnGround && joystick.relativeDelta.y > -0.2 && velocity.y < 0) {
      velocity.y *= 0.6; // stop rising early
    }

    // ---- Apply movement ----
    position += velocity * dt;

    // ---- Jump (press up) ----
    if (isOnGround && joystick.relativeDelta.y < -0.5) {
      jump();
    }
  }

  void jump() {
    if (isOnGround) {
      velocity.y = -_jumpForce;
      isOnGround = false;
    }
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollision(intersectionPoints, other);

    // ✅ Ground collision
    if (other is CollisionGround) {
      // Player bottom touches the ground top
      final playerBottom = position.y + size.y;
      final groundTop = other.position.y;

      if (velocity.y > 0 && playerBottom > groundTop) {
        // Snap to ground
        position.y = groundTop - size.y;
        velocity.y = 0;
        isOnGround = true;
      }
    }

    // ✅ Wall collision
    if (other is CollisionWall) {
      if (velocity.x > 0) {
        position.x = other.position.x - size.x;
      } else if (velocity.x < 0) {
        position.x = other.position.x + other.size.x;
      }
      velocity.x = 0;
    }

    // ✅ Ground collision
    if (other is CollisionPlatforma) {
      // Player bottom touches the ground top
      final playerBottom = position.y + size.y;
      final platformTop = other.position.y;

      // Only land if falling downward and hitting the top of platform
      if (velocity.y > 0 &&
          playerBottom > platformTop &&
          position.y + size.y < platformTop + other.size.y / 2) {
        position.y = platformTop - size.y;
        velocity.y = 0;
        isOnGround = true;
      }
    }
  }

  @override
  void onCollisionEnd(PositionComponent other) {
    super.onCollisionEnd(other);
    if (other is CollisionGround) {
      isOnGround = false;
    }
  }
}
