import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'newton_cradle_game.dart';
import '../controls/simulation_controls.dart';

class NewtonCradleForge2D extends StatefulWidget {
  final SimulationControls controls;
  final Function(double velocity)? onCollision;

  const NewtonCradleForge2D({
    super.key,
    required this.controls,
    this.onCollision,
  });

  @override
  State<NewtonCradleForge2D> createState() => _NewtonCradleForge2DState();
}

class _NewtonCradleForge2DState extends State<NewtonCradleForge2D> {
  late NewtonCradleGame game;

  @override
  void initState() {
    super.initState();
    game = NewtonCradleGame(
      controls: widget.controls,
      onCollision: widget.onCollision,
    );
  }

  @override
  Widget build(BuildContext context) {
    return GameWidget(
      game: game,
      loadingBuilder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
      errorBuilder: (context, error) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 48),
            const SizedBox(height: 16),
            Text('Error: $error'),
          ],
        ),
      ),
      backgroundBuilder: (context) => Container(
        color: Colors.white,
      ),
    );
  }

  @override
  void didUpdateWidget(NewtonCradleForge2D oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controls != widget.controls) {
      game.updateControls(widget.controls);
    }
  }
}
