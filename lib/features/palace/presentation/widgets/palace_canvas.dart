import 'package:flutter/material.dart';
import '../../domain/entities/palace.dart';

class PalaceCanvas extends StatefulWidget {
  final Room room;
  final Function(PlacedNode) onNodeMoved;

  const PalaceCanvas({
    super.key,
    required this.room,
    required this.onNodeMoved,
  });

  @override
  State<PalaceCanvas> createState() => _PalaceCanvasState();
}

class _PalaceCanvasState extends State<PalaceCanvas> {
  final TransformationController _transformationController =
      TransformationController();

  @override
  void dispose() {
    _transformationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return InteractiveViewer(
      transformationController: _transformationController,
      boundaryMargin: const EdgeInsets.all(double.infinity),
      minScale: 0.1,
      maxScale: 5.0,
      child: Container(
        width: widget.room.width,
        height: widget.room.height,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          border: Border.all(color: Colors.white24, width: 2),
        ),
        child: Stack(
          children: widget.room.placedNodes.map((placedNode) {
            return Positioned(
              left: placedNode.dx,
              top: placedNode.dy,
              child: Draggable<PlacedNode>(
                data: placedNode,
                feedback: Material(
                  color: Colors.transparent,
                  child: _buildNodeWidget(placedNode, isDragging: true),
                ),
                childWhenDragging: Opacity(
                  opacity: 0.3,
                  child: _buildNodeWidget(placedNode),
                ),
                onDragEnd: (details) {
                  // Calculate local position relative to the canvas
                  final renderBox = context.findRenderObject() as RenderBox;
                  final localPosition = renderBox.globalToLocal(details.offset);

                  final updatedNode = placedNode.copyWith(
                    dx: localPosition.dx,
                    dy: localPosition.dy,
                  );
                  widget.onNodeMoved(updatedNode);
                },
                child: _buildNodeWidget(placedNode),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildNodeWidget(PlacedNode node, {bool isDragging = false}) {
    return Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        color: isDragging ? Colors.deepPurpleAccent : Colors.deepPurple,
        shape: BoxShape.circle,
        boxShadow: [
          if (isDragging)
            BoxShadow(
              color: Colors.black.withOpacity(0.5),
              blurRadius: 10,
              spreadRadius: 2,
            )
        ],
      ),
      child: Center(
        child: Icon(
          Icons.memory,
          color: Colors.white,
          size: isDragging ? 32 : 24,
        ),
      ),
    );
  }
}
