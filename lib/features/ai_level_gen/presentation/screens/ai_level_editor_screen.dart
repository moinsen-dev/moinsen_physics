import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flame/game.dart';
import 'package:flame_forge2d/flame_forge2d.dart' hide Transform;
import '../../domain/entities/ai_level_generator.dart';
import '../../../levels/domain/entities/level.dart';
import '../widgets/sketch_canvas.dart';
import '../widgets/ai_chat_interface.dart';
import '../widgets/level_preview.dart';

/// Revolutionary AI-powered level editor with natural language
class AILevelEditorScreen extends StatefulWidget {
  const AILevelEditorScreen({super.key});

  @override
  State<AILevelEditorScreen> createState() => _AILevelEditorScreenState();
}

class _AILevelEditorScreenState extends State<AILevelEditorScreen>
    with TickerProviderStateMixin {
  final AILevelGenerator _aiGenerator = AILevelGenerator();
  final TextEditingController _promptController = TextEditingController();
  final List<SketchElement> _sketchElements = [];
  
  Level? _generatedLevel;
  bool _isGenerating = false;
  String _selectedWorld = "Newton's Laboratory";
  int _selectedDifficulty = 5;
  
  // Animation controllers
  late AnimationController _panelController;
  late AnimationController _glowController;
  late Animation<double> _panelSlide;
  late Animation<double> _glowAnimation;
  
  // Editor modes
  EditorMode _currentMode = EditorMode.chat;
  
  @override
  void initState() {
    super.initState();
    
    _panelController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _glowController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
    
    _panelSlide = Tween<double>(
      begin: -300,
      end: 0,
    ).animate(CurvedAnimation(
      parent: _panelController,
      curve: Curves.easeOutCubic,
    ));
    
    _glowAnimation = Tween<double>(
      begin: 0.5,
      end: 1.0,
    ).animate(_glowController);
    
    _panelController.forward();
  }
  
  @override
  void dispose() {
    _promptController.dispose();
    _panelController.dispose();
    _glowController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Background with quantum effect
          _buildQuantumBackground(),
          
          // Main content area
          Row(
            children: [
              // Left panel - AI chat and controls
              AnimatedBuilder(
                animation: _panelSlide,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(_panelSlide.value, 0),
                    child: _buildLeftPanel(),
                  );
                },
              ),
              
              // Center - Level preview/editor
              Expanded(
                child: _buildCenterArea(),
              ),
              
              // Right panel - Properties and tools
              _buildRightPanel(),
            ],
          ),
          
          // Top toolbar
          _buildTopToolbar(),
          
          // AI thinking indicator
          if (_isGenerating) _buildAIThinkingOverlay(),
        ],
      ),
    );
  }
  
  Widget _buildQuantumBackground() {
    return AnimatedBuilder(
      animation: _glowAnimation,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: Alignment.center,
              radius: 2,
              colors: [
                Colors.purple.withValues(alpha: 0.1 * _glowAnimation.value),
                Colors.black,
              ],
            ),
          ),
        );
      },
    );
  }
  
  Widget _buildLeftPanel() {
    return Container(
      width: 350,
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.9),
        border: Border(
          right: BorderSide(
            color: Colors.cyan.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
      ),
      child: Column(
        children: [
          // Mode selector
          _buildModeSelector(),
          
          // Content based on mode
          Expanded(
            child: _currentMode == EditorMode.chat
                ? _buildChatInterface()
                : _buildSketchInterface(),
          ),
          
          // Generate button
          _buildGenerateButton(),
        ],
      ),
    );
  }
  
  Widget _buildModeSelector() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          _buildModeButton(
            'CHAT',
            EditorMode.chat,
            Icons.chat_bubble_outline,
          ),
          const SizedBox(width: 8),
          _buildModeButton(
            'SKETCH',
            EditorMode.sketch,
            Icons.brush,
          ),
          const SizedBox(width: 8),
          _buildModeButton(
            'HYBRID',
            EditorMode.hybrid,
            Icons.merge_type,
          ),
        ],
      ),
    );
  }
  
  Widget _buildModeButton(String label, EditorMode mode, IconData icon) {
    final isSelected = _currentMode == mode;
    
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => setState(() => _currentMode = mode),
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: isSelected
                  ? Colors.cyan.withValues(alpha: 0.2)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isSelected
                    ? Colors.cyan
                    : Colors.cyan.withValues(alpha: 0.3),
              ),
            ),
            child: Column(
              children: [
                Icon(
                  icon,
                  color: isSelected ? Colors.cyan : Colors.white60,
                ),
                const SizedBox(height: 4),
                Text(
                  label,
                  style: TextStyle(
                    color: isSelected ? Colors.cyan : Colors.white60,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildChatInterface() {
    return AIChatInterface(
      controller: _promptController,
      onSuggestionSelected: (suggestion) {
        _promptController.text = suggestion;
      },
      suggestions: const [
        'Create a level with portals and time crystals',
        'Design a puzzle that uses magnetic forces',
        'Make a challenging zero-gravity maze',
        'Build a level where players must use momentum',
        'Create a Rube Goldberg machine puzzle',
      ],
    );
  }
  
  Widget _buildSketchInterface() {
    return SketchCanvas(
      onSketchUpdate: (elements) {
        setState(() {
          _sketchElements.clear();
          _sketchElements.addAll(elements);
        });
      },
    );
  }
  
  Widget _buildGenerateButton() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: ElevatedButton(
        onPressed: _isGenerating ? null : _generateLevel,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.cyan,
          foregroundColor: Colors.black,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 8,
          shadowColor: Colors.cyan.withValues(alpha: 0.5),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _isGenerating ? Icons.hourglass_empty : Icons.auto_awesome,
              size: 24,
            ),
            const SizedBox(width: 12),
            Text(
              _isGenerating ? 'GENERATING...' : 'GENERATE LEVEL',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildCenterArea() {
    return Container(
      margin: const EdgeInsets.only(top: 80),
      child: _generatedLevel != null
          ? LevelPreview(
              level: _generatedLevel!,
              onEdit: (element) {
                // Handle element editing
                _showElementEditor(element);
              },
            )
          : _buildEmptyState(),
    );
  }
  
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.auto_awesome,
            size: 80,
            color: Colors.cyan.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 24),
          Text(
            'AI LEVEL GENERATOR',
            style: TextStyle(
              color: Colors.cyan,
              fontSize: 32,
              fontWeight: FontWeight.bold,
              letterSpacing: 4,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Describe your dream level or sketch it out',
            style: TextStyle(
              color: Colors.white60,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'The AI will create it for you!',
            style: TextStyle(
              color: Colors.white60,
              fontSize: 18,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildRightPanel() {
    return Container(
      width: 300,
      margin: const EdgeInsets.only(top: 80),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.9),
        border: Border(
          left: BorderSide(
            color: Colors.cyan.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
      ),
      child: Column(
        children: [
          // World selector
          _buildWorldSelector(),
          
          // Difficulty slider
          _buildDifficultySlider(),
          
          // AI parameters
          _buildAIParameters(),
          
          // Level properties (if generated)
          if (_generatedLevel != null) _buildLevelProperties(),
        ],
      ),
    );
  }
  
  Widget _buildWorldSelector() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'WORLD THEME',
            style: TextStyle(
              color: Colors.cyan,
              fontSize: 14,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: Colors.cyan.withValues(alpha: 0.3),
              ),
            ),
            child: DropdownButton<String>(
              value: _selectedWorld,
              isExpanded: true,
              dropdownColor: Colors.grey[900],
              style: const TextStyle(color: Colors.white),
              underline: Container(),
              items: const [
                "Newton's Laboratory",
                'Zero-G Space Station',
                'Quantum Realm',
                'Time Distortion Zone',
                'Magnetic Metropolis',
                'The Singularity',
              ].map((world) {
                return DropdownMenuItem(
                  value: world,
                  child: Text(world),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedWorld = value!;
                });
              },
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildDifficultySlider() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'DIFFICULTY',
                style: TextStyle(
                  color: Colors.cyan,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),
              Text(
                '$_selectedDifficulty/10',
                style: TextStyle(
                  color: Colors.cyan,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SliderTheme(
            data: SliderThemeData(
              activeTrackColor: Colors.cyan,
              inactiveTrackColor: Colors.cyan.withValues(alpha: 0.3),
              thumbColor: Colors.cyan,
              overlayColor: Colors.cyan.withValues(alpha: 0.3),
              trackHeight: 4,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
            ),
            child: Slider(
              value: _selectedDifficulty.toDouble(),
              min: 1,
              max: 10,
              divisions: 9,
              onChanged: (value) {
                setState(() {
                  _selectedDifficulty = value.round();
                });
              },
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildAIParameters() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'AI CREATIVITY',
            style: TextStyle(
              color: Colors.purple,
              fontSize: 14,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 16),
          _buildParameterToggle('Quantum Mechanics', true),
          _buildParameterToggle('Time Manipulation', true),
          _buildParameterToggle('Portal Networks', false),
          _buildParameterToggle('Magnetic Fields', true),
          _buildParameterToggle('Zero Gravity Zones', false),
        ],
      ),
    );
  }
  
  Widget _buildParameterToggle(String label, bool defaultValue) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(color: Colors.white70),
          ),
          Switch(
            value: defaultValue,
            onChanged: (value) {
              // Handle parameter change
            },
            activeColor: Colors.purple,
          ),
        ],
      ),
    );
  }
  
  Widget _buildLevelProperties() {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'LEVEL PROPERTIES',
              style: TextStyle(
                color: Colors.yellow,
                fontSize: 14,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 16),
            _buildProperty('Objects', '${_generatedLevel!.objects.length}'),
            _buildProperty('Goals', '${_generatedLevel!.victoryConditions.length}'),
            _buildProperty('Time Limit', '${_generatedLevel!.starThresholds?.threeStars.timeLimit ?? 'N/A'}s'),
            _buildProperty('Physics', _generatedLevel!.physicsConfig.enableQuantumEffects ? 'Quantum' : 'Classic'),
          ],
        ),
      ),
    );
  }
  
  Widget _buildProperty(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(color: Colors.white60),
          ),
          Text(
            value,
            style: const TextStyle(
              color: Colors.yellow,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildTopToolbar() {
    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.9),
        border: Border(
          bottom: BorderSide(
            color: Colors.cyan.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          // Back button
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          
          // Title
          const SizedBox(width: 16),
          ShaderMask(
            shaderCallback: (bounds) {
              return const LinearGradient(
                colors: [Colors.cyan, Colors.purple],
              ).createShader(bounds);
            },
            child: const Text(
              'AI LEVEL CREATOR',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                letterSpacing: 3,
                color: Colors.white,
              ),
            ),
          ),
          
          const Spacer(),
          
          // Action buttons
          _buildToolbarButton(Icons.play_arrow, 'Test', _testLevel),
          _buildToolbarButton(Icons.save, 'Save', _saveLevel),
          _buildToolbarButton(Icons.share, 'Share', _shareLevel),
          _buildToolbarButton(Icons.cloud_upload, 'Publish', _publishLevel),
          
          const SizedBox(width: 16),
        ],
      ),
    );
  }
  
  Widget _buildToolbarButton(IconData icon, String label, VoidCallback onPressed) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: TextButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, color: Colors.cyan),
        label: Text(
          label,
          style: const TextStyle(
            color: Colors.cyan,
            fontWeight: FontWeight.bold,
          ),
        ),
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: BorderSide(
              color: Colors.cyan.withValues(alpha: 0.3),
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildAIThinkingOverlay() {
    return Container(
      color: Colors.black.withValues(alpha: 0.8),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // AI brain animation
            Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    Colors.purple.withValues(alpha: 0.8),
                    Colors.cyan.withValues(alpha: 0.4),
                    Colors.transparent,
                  ],
                ),
              ),
              child: const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  strokeWidth: 3,
                ),
              ),
            ),
            const SizedBox(height: 32),
            Text(
              'AI IS CREATING YOUR LEVEL',
              style: TextStyle(
                color: Colors.cyan,
                fontSize: 20,
                fontWeight: FontWeight.bold,
                letterSpacing: 3,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              _getRandomThinkingMessage(),
              style: TextStyle(
                color: Colors.white60,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Future<void> _generateLevel() async {
    setState(() {
      _isGenerating = true;
    });
    
    try {
      // Simulate AI processing time
      await Future.delayed(const Duration(seconds: 2));
      
      final worldId = [
        "Newton's Laboratory",
        'Zero-G Space Station',
        'Quantum Realm',
        'Time Distortion Zone',
        'Magnetic Metropolis',
        'The Singularity',
      ].indexOf(_selectedWorld) + 1;
      
      Level generatedLevel;
      
      if (_currentMode == EditorMode.chat) {
        generatedLevel = await _aiGenerator.generateLevel(
          prompt: _promptController.text,
          worldId: worldId,
          difficulty: _selectedDifficulty,
        );
      } else if (_currentMode == EditorMode.sketch) {
        generatedLevel = await _aiGenerator.generateFromSketch(
          sketch: _sketchElements,
          description: 'User sketch',
          worldId: worldId,
        );
      } else {
        // Hybrid mode
        generatedLevel = await _aiGenerator.generateFromSketch(
          sketch: _sketchElements,
          description: _promptController.text,
          worldId: worldId,
        );
      }
      
      setState(() {
        _generatedLevel = generatedLevel;
      });
      
      // Show success animation
      _showSuccessAnimation();
      
    } catch (e) {
      _showError('Failed to generate level: $e');
    } finally {
      setState(() {
        _isGenerating = false;
      });
    }
  }
  
  void _showElementEditor(dynamic element) {
    // Show element editing dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text(
          'Edit Element',
          style: TextStyle(color: Colors.cyan),
        ),
        content: Container(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Element properties editor
              Text(
                'Element editing coming soon!',
                style: TextStyle(color: Colors.white60),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              // Apply changes
              Navigator.pop(context);
            },
            child: const Text('Apply'),
          ),
        ],
      ),
    );
  }
  
  void _testLevel() {
    if (_generatedLevel != null) {
      // Navigate to level test screen
      HapticFeedback.mediumImpact();
    }
  }
  
  void _saveLevel() {
    if (_generatedLevel != null) {
      // Save level to local storage
      HapticFeedback.mediumImpact();
      _showSnackBar('Level saved!');
    }
  }
  
  void _shareLevel() {
    if (_generatedLevel != null) {
      // Share level
      HapticFeedback.mediumImpact();
    }
  }
  
  void _publishLevel() {
    if (_generatedLevel != null) {
      // Publish to community
      HapticFeedback.heavyImpact();
      _showPublishDialog();
    }
  }
  
  void _showPublishDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text(
          'Publish Level',
          style: TextStyle(color: Colors.cyan),
        ),
        content: const Text(
          'Share your creation with the Gravity Lab community?',
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _showSnackBar('Level published to community!');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.cyan,
              foregroundColor: Colors.black,
            ),
            child: const Text('Publish'),
          ),
        ],
      ),
    );
  }
  
  void _showSuccessAnimation() {
    // Show success feedback
    HapticFeedback.heavyImpact();
  }
  
  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }
  
  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.cyan,
      ),
    );
  }
  
  String _getRandomThinkingMessage() {
    final messages = [
      'Calculating quantum probabilities...',
      'Optimizing physics parameters...',
      'Designing creative challenges...',
      'Balancing difficulty curve...',
      'Adding particle effects...',
      'Testing solution paths...',
    ];
    return messages[DateTime.now().second % messages.length];
  }
}

enum EditorMode {
  chat,
  sketch,
  hybrid,
}