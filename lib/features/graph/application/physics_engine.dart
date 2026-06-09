import 'dart:math';
import 'package:flutter/material.dart';
import '../domain/entities/node.dart';
import '../domain/entities/edge.dart';

class PhysicsEngine {
  final List<Node> nodes;
  final List<Edge> edges;

  final Map<String, Offset> positions = {};
  final Map<String, Offset> velocities = {};

  // Physics tuning parameters
  final double maxVelocity = 50.0;
  final double repulsionConstant = 2500.0;
  final double springLength = 80.0;
  final double springStiffness = 0.05;
  final double gravityConstant = 0.02;
  final double damping = 0.85;

  final Size canvasSize;
  final Offset center;

  PhysicsEngine({
    required this.nodes,
    required this.edges,
    required this.canvasSize,
  }) : center = Offset(canvasSize.width / 2, canvasSize.height / 2) {
    _initializePositions();
  }

  void _initializePositions() {
    final random = Random(42); // Deterministic initialization
    for (final node in nodes) {
      // Spawn nodes clustered near the center
      positions[node.id] = Offset(
        center.dx + (random.nextDouble() - 0.5) * 500,
        center.dy + (random.nextDouble() - 0.5) * 500,
      );
      velocities[node.id] = Offset.zero;
    }
  }

  void tick() {
    final Map<String, Offset> forces = {
      for (var node in nodes) node.id: Offset.zero,
    };

    // 1. Repulsion (O(N^2) simplified logic for 1000 nodes)
    // Note: Phase 7 will replace this with Barnes-Hut QuadTree for 50k+ nodes
    for (int i = 0; i < nodes.length; i++) {
      for (int j = i + 1; j < nodes.length; j++) {
        final idA = nodes[i].id;
        final idB = nodes[j].id;

        final posA = positions[idA]!;
        final posB = positions[idB]!;

        final delta = posA - posB;
        final distanceSq = delta.distanceSquared;

        if (distanceSq > 0 && distanceSq < 40000) {
          // Limit repulsion radius for performance
          final forceMag = repulsionConstant / distanceSq;
          final force = (delta / sqrt(distanceSq)) * forceMag;

          forces[idA] = forces[idA]! + force;
          forces[idB] = forces[idB]! - force;
        }
      }
    }

    // 2. Spring Attraction (Edges)
    for (final edge in edges) {
      final posA = positions[edge.sourceId];
      final posB = positions[edge.targetId];

      if (posA != null && posB != null) {
        final delta = posB - posA;
        final distance = delta.distance;

        if (distance > 0) {
          final displacement = distance - springLength;
          final forceMag = displacement * springStiffness * edge.weight;
          final force = (delta / distance) * forceMag;

          forces[edge.sourceId] = forces[edge.sourceId]! + force;
          forces[edge.targetId] = forces[edge.targetId]! - force;
        }
      }
    }

    // 3. Center Gravity & Integration
    for (final node in nodes) {
      final id = node.id;
      final currentPos = positions[id]!;

      // Gravity pulling toward the center of the canvas
      final gravityDelta = center - currentPos;
      final gravityForce = gravityDelta * gravityConstant;

      var currentForce = forces[id]! + gravityForce;
      var newVelocity = (velocities[id]! + currentForce) * damping;

      // Clamp velocity to prevent physics explosions
      if (newVelocity.distance > maxVelocity) {
        newVelocity = (newVelocity / newVelocity.distance) * maxVelocity;
      }

      velocities[id] = newVelocity;
      positions[id] = currentPos + newVelocity;
    }
  }
}
