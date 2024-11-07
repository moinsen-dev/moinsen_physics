import 'package:flutter/material.dart';

import '../_index.dart';

class NewtonCradlePlainDart extends StatefulWidget {
  final SimulationControls controls;
  final Function(double velocity)? onCollision;

  const NewtonCradlePlainDart({
    super.key,
    required this.controls,
    this.onCollision,
  });

  @override
  State<NewtonCradlePlainDart> createState() => _NewtonCradlePlainDartState();
}

class _NewtonCradlePlainDartState extends State<NewtonCradlePlainDart>
    with SingleTickerProviderStateMixin {
  late NewtonCradleController controller;
  late SimulationControls controls;
  bool showControls = false; // Start with controls collapsed

  @override
  void initState() {
    super.initState();
    controls = widget.controls;
    controller = NewtonCradleController(
      vsync: this,
      onUpdate: () => setState(() {}),
      controls: controls,
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.updateBalls(context);
    });
  }

  @override
  void didUpdateWidget(NewtonCradlePlainDart oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controls != oldWidget.controls) {
      setState(() {
        controls = widget.controls;
        controller.controls = widget.controls;
        controller.updateBalls(context);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return GestureDetector(
                behavior: HitTestBehavior.opaque,
                onPanStart: (details) {
                  controller.handlePanStart(details,
                      Size(constraints.maxWidth, constraints.maxHeight));
                },
                onPanUpdate: controller.handlePanUpdate,
                onPanEnd: controller.handlePanEnd,
                child: CustomPaint(
                  size: Size(constraints.maxWidth, constraints.maxHeight),
                  painter: NewtonCradlePainter(
                    balls: controller.balls,
                    ballRadius: controls.ballRadius,
                    ballColor: controls.ballColor,
                    ballWeight: controls.ballWeightGrams,
                    useRubberBands: controls.useRubberBands,
                  ),
                ),
              );
            },
          ),
        ),
        NewtonCradleControlsWidget(
          controls: controls,
          onControlsChanged: _onControlsChanged,
          showControls: showControls,
          onToggleControls: _toggleControls,
          onReset: () {
            controller.updateBalls(context);
          },
        ),
      ],
    );
  }

  void _toggleControls() {
    setState(() {
      showControls = !showControls;
    });
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
}
