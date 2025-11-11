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
  bool onLeftWall = false;
  bool onRightWall = false;
  //
  bool jumpButtonHeld = false;

  // Adding coyote time variables
  final double coyoteTime = 0.15; // 150 ms of coyote time
  double coyoteTimer = 0.0;

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

    // --- Update Coyote Time ---
    if (isOnGround) {
      coyoteTimer = coyoteTime;
    } else {
      coyoteTimer = (coyoteTimer - dt).clamp(0, coyoteTime);
    }

    // --- HORIZONTAL MOVEMENT (SMOOTH MARIO ACCELERATION) ---
    double input = joystick.relativeDelta.x; // -1 to 1
    double accel = 1200;
    double friction = isOnGround ? 1000 : 300;

    if (input.abs() > 0.1) {
      velocity.x += input * accel * dt;
    } else {
      // Apply friction only when no input
      velocity.x = moveTowards(velocity.x, 0, friction * dt);
    }

    // Cap speed
    velocity.x = velocity.x.clamp(-_moveSpeed, _moveSpeed);

    // --- JUMP INPUT (ONE PRESS) ---
    bool jumpPressed = joystick.relativeDelta.y < -0.5 && !jumpButtonHeld;
    jumpButtonHeld = joystick.relativeDelta.y < -0.5;

    if (jumpPressed && (isOnGround || coyoteTimer > 0)) {
      jump();
    }

    // --- VARIABLE JUMP HEIGHT ---
    if (!isOnGround && !jumpButtonHeld && velocity.y < 0) {
      velocity.y += _gravity * 1.5 * dt; // damp upward movement
    }

    // --- GRAVITY ---
    velocity.y += _gravity * dt;

    // --- APPLY MOVEMENT ---
    position += velocity * dt;
  }

  void jump() {
    velocity.y = -_jumpForce;
    isOnGround = false;
    coyoteTimer = 0; // consume coyote time
    print("Jump executed");
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
        onRightWall = true;
        onLeftWall = false;

        print("Collided with wall on the right");
      } else if (velocity.x < 0) {
        position.x = other.position.x + other.size.x;
        onLeftWall = true;
        onRightWall = false;

        print("Collided with wall on the left");
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
