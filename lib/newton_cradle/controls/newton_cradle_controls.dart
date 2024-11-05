import 'package:flutter/material.dart';

import '_index.dart';

class NewtonCradleControlsWidget extends StatelessWidget {
  final SimulationControls controls;
  final ValueChanged<SimulationControls> onControlsChanged;
  final bool showControls;
  final VoidCallback onToggleControls;
  final VoidCallback onReset;

  const NewtonCradleControlsWidget({
    super.key,
    required this.controls,
    required this.onControlsChanged,
    required this.showControls,
    required this.onToggleControls,
    required this.onReset,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Container(
        color: Colors.grey[200],
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Controls'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(
                      controls.isSoundEnabled
                          ? Icons.volume_up
                          : Icons.volume_off,
                      color: controls.isSoundEnabled ? null : Colors.grey,
                    ),
                    tooltip:
                        controls.isSoundEnabled ? 'Mute sound' : 'Unmute sound',
                    onPressed: () {
                      onControlsChanged(controls.copyWith(
                          isSoundEnabled: !controls.isSoundEnabled));
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.restore),
                    tooltip: 'Reset to defaults',
                    onPressed: onReset,
                  ),
                  IconButton(
                    icon: Icon(
                      showControls ? Icons.expand_less : Icons.expand_more,
                    ),
                    onPressed: onToggleControls,
                  ),
                ],
              ),
            ),
            if (showControls) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  children: [
                    const Text('Version'),
                    const SizedBox(width: 16),
                    SegmentedButton<CradleVersion>(
                      segments: const [
                        ButtonSegment(
                          value: CradleVersion.classic,
                          label: Text('Classic'),
                        ),
                        ButtonSegment(
                          value: CradleVersion.physics,
                          label: Text('Physics'),
                        ),
                      ],
                      selected: {controls.version},
                      onSelectionChanged: (Set<CradleVersion> selection) {
                        onControlsChanged(
                          controls.copyWith(version: selection.first),
                        );
                      },
                    ),
                  ],
                ),
              ),
              _buildSlider(
                label: 'Number of Balls',
                value: controls.numberOfBalls.toDouble(),
                min: 2,
                max: 10,
                divisions: 8,
                onChanged: (value) {
                  onControlsChanged(
                      controls.copyWith(numberOfBalls: value.round()));
                },
              ),
              _buildSlider(
                label: 'Ball Size',
                value: controls.ballRadius,
                min: 10,
                max: 30,
                onChanged: (value) {
                  onControlsChanged(controls.copyWith(ballRadius: value));
                },
              ),
              _buildSlider(
                label: 'Rope Length',
                value: controls.ropeLength,
                min: 100,
                max: 400,
                onChanged: (value) {
                  onControlsChanged(controls.copyWith(ropeLength: value));
                },
              ),
              _buildColorPicker(),
              _buildSlider(
                label: 'Weight (g)',
                value: controls.ballWeightGrams,
                min: 50,
                max: 1000,
                divisions: 95,
                onChanged: (value) {
                  onControlsChanged(controls.copyWith(ballWeightGrams: value));
                },
                valueDisplay: '${controls.ballWeightGrams.round()}g',
              ),
              if (controls.isSoundEnabled) ...[
                _buildSlider(
                  label: 'Volume',
                  value: controls.soundVolume,
                  min: 0.0,
                  max: 1.0,
                  divisions: 20,
                  onChanged: (value) {
                    onControlsChanged(controls.copyWith(soundVolume: value));
                  },
                  valueDisplay: '${(controls.soundVolume * 100).round()}%',
                ),
              ],
              const SizedBox(height: 16),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildColorPicker() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        children: [
          const Text('Ball Color'),
          const SizedBox(width: 16),
          Wrap(
            spacing: 8,
            children: [
              Colors.grey,
              Colors.blue,
              Colors.red,
              Colors.green,
              Colors.purple,
            ].map((color) => _buildColorButton(color)).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildColorButton(Color color) {
    return GestureDetector(
      onTap: () {
        onControlsChanged(controls.copyWith(ballColor: color));
      },
      child: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(
            color:
                controls.ballColor == color ? Colors.black : Colors.transparent,
            width: 2,
          ),
        ),
      ),
    );
  }

  Widget _buildSlider({
    required String label,
    required double value,
    required double min,
    required double max,
    required ValueChanged<double> onChanged,
    int? divisions,
    String? valueDisplay,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(label),
          ),
          Expanded(
            child: Slider(
              value: value,
              min: min,
              max: max,
              divisions: divisions,
              label: valueDisplay ?? value.round().toString(),
              onChanged: onChanged,
            ),
          ),
          SizedBox(
            width: 70,
            child: Text(
              valueDisplay ?? value.round().toString(),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}
