import 'dart:math';

import 'package:flutter/material.dart';

import '../_index.dart';

class NewtonCradleWidget extends StatefulWidget {
  const NewtonCradleWidget({super.key});

  @override
  NewtonCradleWidgetState createState() => NewtonCradleWidgetState();
}

class NewtonCradleWidgetState extends State<NewtonCradleWidget>
    with SingleTickerProviderStateMixin {
  late NewtonCradleController controller;
  bool showControls = false;
  SimulationControls controls = SimulationControls.defaultControls;

  @override
  void initState() {
    super.initState();
    controller = NewtonCradleController(
      vsync: this,
      onUpdate: () {
        setState(() {});
      },
      controls: controls,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.updateBalls(context);
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    controller.updateBalls(context);
  }

  void _onPanStart(DragStartDetails details) {
    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final localPosition = renderBox.globalToLocal(details.globalPosition);

    for (var ball in controller.balls) {
      final distance = (localPosition - ball.position).distance;
      if (distance <= controls.ballRadius * 2) {
        setState(() {
          ball.isDragging = true;
          ball.dragOffset = localPosition - ball.position;
          ball.angularVelocity = 0;
        });
        break;
      }
    }
  }

  void _onPanUpdate(DragUpdateDetails details) {
    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final localPosition = renderBox.globalToLocal(details.globalPosition);

    for (var ball in controller.balls) {
      if (ball.isDragging) {
        setState(() {
          Offset targetPosition = localPosition - ball.dragOffset;
          double dx = targetPosition.dx - ball.origin.dx;
          double dy = targetPosition.dy - ball.origin.dy;
          double newAngle = atan2(dx, dy);
          const double maxAngle = pi / 3;
          newAngle = newAngle.clamp(-maxAngle, maxAngle);
          ball.setAngle(newAngle);

          double deltaX = details.delta.dx;
          double deltaTime = 0.016;
          ball.angularVelocity = (deltaX / ball.length) / deltaTime * 0.1;
        });
        break;
      }
    }
  }

  void _onPanEnd(DragEndDetails details) {
    for (var ball in controller.balls) {
      if (ball.isDragging) {
        setState(() {
          ball.isDragging = false;
          double velocityScale = 0.3;
          double pixelsPerSecond = details.velocity.pixelsPerSecond.dx;
          ball.angularVelocity =
              (pixelsPerSecond * velocityScale) / (200 * ball.length);
          if (ball.angularVelocity.abs() < 0.1) {
            ball.angularVelocity = 0.0;
          }
        });
        break;
      }
    }
  }

  void _onControlsChanged(SimulationControls newControls) {
    setState(() {
      controls = newControls;
      controller.controls = newControls;
      controller.updateBalls(context);
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.red.withOpacity(0.1),
      child: Column(
        children: [
          Expanded(
            child: controls.version == CradleVersion.classic
                ? GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTapDown: (details) {},
                    onPanStart: _onPanStart,
                    onPanUpdate: _onPanUpdate,
                    onPanEnd: _onPanEnd,
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        return Container(
                          width: constraints.maxWidth,
                          height: constraints.maxHeight,
                          color: Colors.transparent,
                          child: CustomPaint(
                            size: Size(
                                constraints.maxWidth, constraints.maxHeight),
                            painter: NewtonCradlePainter(
                              balls: controller.balls,
                              ballRadius: controls.ballRadius,
                              ballColor: controls.ballColor,
                              ballWeight: controls.ballWeightGrams,
                            ),
                          ),
                        );
                      },
                    ),
                  )
                : NewtonCradleForge2D(
                    controls: controls,
                    onCollision: (velocity) {},
                  ),
          ),
          NewtonCradleControlsWidget(
            controls: controls,
            onControlsChanged: _onControlsChanged,
            showControls: showControls,
            onToggleControls: () =>
                setState(() => showControls = !showControls),
            onReset: () => setState(() {
              controls = SimulationControls.defaultControls;
              controller.controls = controls;
              controller.updateBalls(context);
            }),
          ),
        ],
      ),
    );
  }
}
