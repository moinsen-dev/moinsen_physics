import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import '../../domain/entities/ai_level_generator.dart';

/// Sketch canvas for drawing level ideas
class SketchCanvas extends StatefulWidget {
  final Function(List<SketchElement>) onSketchUpdate;
  
  const SketchCanvas({
    super.key,
    required this.onSketchUpdate,
  });

  @override
  State<SketchCanvas> createState() => _SketchCanvasState();
}

class _SketchCanvasState extends State<SketchCanvas> {
  final List<SketchElement> _elements = [];
  final List<Offset> _currentPath = [];
  
  DrawingTool _selectedTool = DrawingTool.object;
  String _selectedObjectType = 'ball';
  Color _selectedColor = Colors.green;
  bool _isDrawing = false;
  
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Toolbar
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.5),
            border: Border(
              bottom: BorderSide(
                color: Colors.cyan.withValues(alpha: 0.3),
              ),
            ),
          ),
          child: Column(
            children: [
              // Tool selector
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildToolButton(
                    icon: Icons.circle,
                    tool: DrawingTool.object,
                    tooltip: 'Place Object',
                  ),
                  _buildToolButton(
                    icon: Icons.gesture,
                    tool: DrawingTool.path,
                    tooltip: 'Draw Path',
                  ),
                  _buildToolButton(
                    icon: Icons.text_fields,
                    tool: DrawingTool.annotation,
                    tooltip: 'Add Text',
                  ),
                  _buildToolButton(
                    icon: Icons.clear,
                    tool: DrawingTool.eraser,
                    tooltip: 'Eraser',
                  ),
                ],
              ),
              
              const SizedBox(height: 8),
              
              // Object type selector (when object tool is selected)
              if (_selectedTool == DrawingTool.object)
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildObjectTypeChip('ball', Colors.green),
                      _buildObjectTypeChip('cube', Colors.blue),
                      _buildObjectTypeChip('magnet', Colors.red),
                      _buildObjectTypeChip('portal', Colors.purple),
                      _buildObjectTypeChip('energy', Colors.yellow),
                      _buildObjectTypeChip('goal', Colors.orange),
                    ],
                  ),
                ),
            ],
          ),
        ),
        
        // Canvas
        Expanded(
          child: GestureDetector(
            onPanStart: _onPanStart,
            onPanUpdate: _onPanUpdate,
            onPanEnd: _onPanEnd,
            onTapDown: _onTapDown,
            child: Container(
              width: double.infinity,
              color: Colors.grey[900],
              child: CustomPaint(
                painter: SketchPainter(
                  elements: _elements,
                  currentPath: _currentPath,
                  selectedColor: _selectedColor,
                ),
              ),
            ),
          ),
        ),
        
        // Action buttons
        Container(
          padding: const EdgeInsets.all(8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              TextButton.icon(
                onPressed: _clearCanvas,
                icon: const Icon(Icons.clear_all, color: Colors.red),
                label: const Text('Clear', style: TextStyle(color: Colors.red)),
              ),
              TextButton.icon(
                onPressed: _undo,
                icon: const Icon(Icons.undo, color: Colors.cyan),
                label: const Text('Undo', style: TextStyle(color: Colors.cyan)),
              ),
              TextButton.icon(
                onPressed: _exportSketch,
                icon: const Icon(Icons.check, color: Colors.green),
                label: const Text('Done', style: TextStyle(color: Colors.green)),
              ),
            ],
          ),
        ),
      ],
    );
  }
  
  Widget _buildToolButton({
    required IconData icon,
    required DrawingTool tool,
    required String tooltip,
  }) {
    final isSelected = _selectedTool == tool;
    
    return Tooltip(
      message: tooltip,
      child: IconButton(
        onPressed: () {
          HapticFeedback.lightImpact();
          setState(() {
            _selectedTool = tool;
          });
        },
        icon: Icon(icon),
        color: isSelected ? Colors.cyan : Colors.white60,
        style: IconButton.styleFrom(
          backgroundColor: isSelected
              ? Colors.cyan.withValues(alpha: 0.2)
              : Colors.transparent,
          side: BorderSide(
            color: isSelected
                ? Colors.cyan
                : Colors.cyan.withValues(alpha: 0.3),
          ),
        ),
      ),
    );
  }
  
  Widget _buildObjectTypeChip(String type, Color color) {
    final isSelected = _selectedObjectType == type;
    
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(type.toUpperCase()),
        selected: isSelected,
        selectedColor: color.withValues(alpha: 0.3),
        backgroundColor: Colors.transparent,
        side: BorderSide(
          color: isSelected ? color : color.withValues(alpha: 0.3),
        ),
        labelStyle: TextStyle(
          color: isSelected ? color : Colors.white60,
          fontSize: 12,
        ),
        onSelected: (selected) {
          if (selected) {
            setState(() {
              _selectedObjectType = type;
              _selectedColor = color;
            });
          }
        },
      ),
    );
  }
  
  void _onPanStart(DragStartDetails details) {
    if (_selectedTool == DrawingTool.path) {
      setState(() {
        _isDrawing = true;
        _currentPath.clear();
        _currentPath.add(details.localPosition);
      });
    }
  }
  
  void _onPanUpdate(DragUpdateDetails details) {
    if (_isDrawing && _selectedTool == DrawingTool.path) {
      setState(() {
        _currentPath.add(details.localPosition);
      });
    }
  }
  
  void _onPanEnd(DragEndDetails details) {
    if (_isDrawing && _selectedTool == DrawingTool.path) {
      setState(() {
        _isDrawing = false;
        if (_currentPath.length > 1) {
          _elements.add(SketchElement(
            type: 'path',
            points: _currentPath.map((offset) => Vector2(offset.dx, offset.dy)).toList(),
            properties: {
              'color': _selectedColor.toARGB32(),
              'curved': true,
            },
          ));
          _currentPath.clear();
          widget.onSketchUpdate(_elements);
        }
      });
    }
  }
  
  void _onTapDown(TapDownDetails details) {
    HapticFeedback.lightImpact();
    
    if (_selectedTool == DrawingTool.object) {
      setState(() {
        _elements.add(SketchElement(
          type: 'object',
          points: [Vector2(details.localPosition.dx, details.localPosition.dy)],
          properties: {
            'type': _selectedObjectType,
            'color': _selectedColor.toARGB32(),
          },
        ));
        widget.onSketchUpdate(_elements);
      });
    } else if (_selectedTool == DrawingTool.annotation) {
      _showTextInput(details.localPosition);
    } else if (_selectedTool == DrawingTool.eraser) {
      _eraseAt(details.localPosition);
    }
  }
  
  void _showTextInput(Offset position) {
    showDialog(
      context: context,
      builder: (context) {
        String text = '';
        return AlertDialog(
          backgroundColor: Colors.grey[900],
          title: const Text('Add Annotation', style: TextStyle(color: Colors.cyan)),
          content: TextField(
            autofocus: true,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              hintText: 'Enter text...',
              hintStyle: TextStyle(color: Colors.white30),
            ),
            onChanged: (value) => text = value,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (text.isNotEmpty) {
                  setState(() {
                    _elements.add(SketchElement(
                      type: 'annotation',
                      points: [Vector2(position.dx, position.dy)],
                      text: text,
                    ));
                    widget.onSketchUpdate(_elements);
                  });
                }
                Navigator.pop(context);
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }
  
  void _eraseAt(Offset position) {
    setState(() {
      _elements.removeWhere((element) {
        if (element.points.isEmpty) return false;
        
        final elementPos = element.points.first;
        final distance = (Offset(elementPos.x, elementPos.y) - position).distance;
        
        return distance < 30; // Erase radius
      });
      widget.onSketchUpdate(_elements);
    });
  }
  
  void _clearCanvas() {
    HapticFeedback.mediumImpact();
    setState(() {
      _elements.clear();
      _currentPath.clear();
      widget.onSketchUpdate(_elements);
    });
  }
  
  void _undo() {
    HapticFeedback.lightImpact();
    if (_elements.isNotEmpty) {
      setState(() {
        _elements.removeLast();
        widget.onSketchUpdate(_elements);
      });
    }
  }
  
  void _exportSketch() {
    HapticFeedback.heavyImpact();
    widget.onSketchUpdate(_elements);
  }
}

/// Drawing tools
enum DrawingTool {
  object,
  path,
  annotation,
  eraser,
}

/// Custom painter for the sketch
class SketchPainter extends CustomPainter {
  final List<SketchElement> elements;
  final List<Offset> currentPath;
  final Color selectedColor;
  
  SketchPainter({
    required this.elements,
    required this.currentPath,
    required this.selectedColor,
  });
  
  @override
  void paint(Canvas canvas, Size size) {
    // Draw grid
    _drawGrid(canvas, size);
    
    // Draw elements
    for (final element in elements) {
      if (element.type == 'object') {
        _drawObject(canvas, element);
      } else if (element.type == 'path') {
        _drawPath(canvas, element);
      } else if (element.type == 'annotation') {
        _drawAnnotation(canvas, element);
      }
    }
    
    // Draw current path
    if (currentPath.isNotEmpty) {
      final paint = Paint()
        ..color = selectedColor
        ..strokeWidth = 3
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;
      
      final path = Path();
      path.moveTo(currentPath.first.dx, currentPath.first.dy);
      
      for (int i = 1; i < currentPath.length; i++) {
        path.lineTo(currentPath[i].dx, currentPath[i].dy);
      }
      
      canvas.drawPath(path, paint);
    }
  }
  
  void _drawGrid(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white10
      ..strokeWidth = 0.5;
    
    // Vertical lines
    for (double x = 0; x <= size.width; x += 50) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    
    // Horizontal lines
    for (double y = 0; y <= size.height; y += 50) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }
  
  void _drawObject(Canvas canvas, SketchElement element) {
    if (element.points.isEmpty) return;
    
    final position = element.points.first;
    final type = element.properties['type'] ?? 'ball';
    final color = Color(element.properties['color'] ?? Colors.green.toARGB32());
    
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    
    final strokePaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    
    switch (type) {
      case 'ball':
        canvas.drawCircle(Offset(position.x, position.y), 20, Paint()..color = color.withValues(alpha: 0.3));
        canvas.drawCircle(Offset(position.x, position.y), 20, strokePaint);
        break;
        
      case 'cube':
        final rect = Rect.fromCenter(
          center: Offset(position.x, position.y),
          width: 40,
          height: 40,
        );
        canvas.drawRect(rect, Paint()..color = color.withValues(alpha: 0.3));
        canvas.drawRect(rect, strokePaint);
        break;
        
      case 'goal':
        // Draw target circles
        for (int i = 3; i > 0; i--) {
          final goalPaint = Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2
            ..color = color.withValues(alpha: 0.3 + i * 0.2);
          canvas.drawCircle(
            Offset(position.x, position.y),
            i * 10.0,
            goalPaint,
          );
        }
        break;
        
      default:
        // Generic object
        canvas.drawCircle(Offset(position.x, position.y), 20, Paint()..color = color.withValues(alpha: 0.3));
        canvas.drawCircle(Offset(position.x, position.y), 20, strokePaint);
    }
    
    // Draw type label
    final textPainter = TextPainter(
      text: TextSpan(
        text: type.toUpperCase(),
        style: TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(position.x - textPainter.width / 2, position.y - textPainter.height / 2),
    );
  }
  
  void _drawPath(Canvas canvas, SketchElement element) {
    if (element.points.length < 2) return;
    
    final color = Color(element.properties['color'] ?? Colors.cyan.toARGB32());
    final paint = Paint()
      ..color = color
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    
    final path = Path();
    path.moveTo(element.points.first.x, element.points.first.y);
    
    if (element.properties['curved'] == true) {
      // Draw smooth curve
      for (int i = 1; i < element.points.length - 1; i++) {
        final p0 = element.points[i];
        final p1 = element.points[i + 1];
        final midPoint = Offset((p0.x + p1.x) / 2, (p0.y + p1.y) / 2);
        path.quadraticBezierTo(p0.x, p0.y, midPoint.dx, midPoint.dy);
      }
      if (element.points.length > 1) {
        final last = element.points.last;
        path.lineTo(last.x, last.y);
      }
    } else {
      // Draw straight lines
      for (int i = 1; i < element.points.length; i++) {
        path.lineTo(element.points[i].x, element.points[i].y);
      }
    }
    
    canvas.drawPath(path, paint);
    
    // Draw arrow at end
    if (element.points.length >= 2) {
      final last = element.points.last;
      final secondLast = element.points[element.points.length - 2];
      final direction = (last - secondLast).normalized();
      
      final arrowLength = 15.0;
      final arrowAngle = 0.5;
      
      final arrow1 = last - direction * arrowLength;
      final arrow2 = arrow1 + Vector2(
        -direction.y * arrowAngle - direction.x * arrowAngle,
        direction.x * arrowAngle - direction.y * arrowAngle,
      ) * arrowLength * 0.5;
      final arrow3 = arrow1 + Vector2(
        direction.y * arrowAngle - direction.x * arrowAngle,
        -direction.x * arrowAngle - direction.y * arrowAngle,
      ) * arrowLength * 0.5;
      
      canvas.drawLine(Offset(last.x, last.y), Offset(arrow2.x, arrow2.y), paint);
      canvas.drawLine(Offset(last.x, last.y), Offset(arrow3.x, arrow3.y), paint);
    }
  }
  
  void _drawAnnotation(Canvas canvas, SketchElement element) {
    if (element.points.isEmpty || element.text == null) return;
    
    final position = element.points.first;
    
    // Draw text background
    final bgPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.7)
      ..style = PaintingStyle.fill;
    
    final textPainter = TextPainter(
      text: TextSpan(
        text: element.text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 14,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    
    final bgRect = Rect.fromLTWH(
      position.x - 5,
      position.y - 5,
      textPainter.width + 10,
      textPainter.height + 10,
    );
    
    canvas.drawRRect(
      RRect.fromRectAndRadius(bgRect, const Radius.circular(4)),
      bgPaint,
    );
    
    textPainter.paint(canvas, Offset(position.x, position.y));
  }
  
  @override
  bool shouldRepaint(SketchPainter oldDelegate) {
    return true;
  }
}