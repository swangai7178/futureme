import 'package:flutter/material.dart';


void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Decision Tree',
      home: Scaffold(
        appBar: AppBar(title: Text('Life Choices Tree')),
        body: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Container(
            height: 1000,
            width: 2000,
            padding: const EdgeInsets.all(20),
            child: TreeGraph(),
          ),
        ),
      ),
    );
  }
}
class NodeData {
  final String title;
  final String description;
  final List<NodeData> children;
  bool expanded;

  NodeData({
    required this.title,
    required this.description,
    this.children = const [],
    this.expanded = false,
  });
}

class TreeGraph extends StatefulWidget {
  @override
  _TreeGraphState createState() => _TreeGraphState();
}

class _TreeGraphState extends State<TreeGraph> {
  final Map<NodeData, Offset> _nodePositions = {};

  final NodeData _root = NodeData(
    title: "Graduate High School",
    description: "You finish school",
    children: [
      NodeData(
        title: "Go to University",
        description: "You pursue higher education",
        children: [
          NodeData(
            title: "Graduate University",
            description: "You get a degree",
            children: [
              NodeData(
                title: "Get a Job",
                description: "You start your career",
              ),
              NodeData(
                title: "Start a Business",
                description: "You become an entrepreneur",
              ),
            ],
          ),
        ],
      ),
      NodeData(
        title: "Start Working",
        description: "You earn money early",
        children: [
          NodeData(
            title: "Grow Career",
            description: "You gain experience",
          ),
          NodeData(
            title: "Change Fields",
            description: "You explore new opportunities",
          ),
        ],
      ),
    ],
  );

  @override
  Widget build(BuildContext context) {
    List<Widget> widgets = [];
    _nodePositions.clear();

    double startX = 20;
    double startY = 100;
    double horizontalSpacing = 260;
    double verticalSpacing = 120;

    void buildNodes(NodeData node, double x, double y) {
      final key = GlobalKey();
      widgets.add(Positioned(
        left: x,
        top: y,
        child: LifeChoiceCard(
          key: key,
          title: node.title,
          description: node.description,
          onTap: () => setState(() {
            node.expanded = !node.expanded;
          }),
        ),
      ));
      _nodePositions[node] = Offset(x, y);

      if (node.expanded) {
        for (int i = 0; i < node.children.length; i++) {
          var child = node.children[i];
          double childX = x + horizontalSpacing;
          double childY = y + (i * verticalSpacing);
          buildNodes(child, childX, childY);
        }
      }
    }

    buildNodes(_root, startX, startY);

    return Stack(
      children: [
        // Line painter below everything else
        Positioned.fill(
          child: CustomPaint(
            painter: TreeLinePainter(_nodePositions, _root),
          ),
        ),
        ...widgets, // Cards on top of lines
      ],
    );
  }
}

class TreeLinePainter extends CustomPainter {
  final Map<NodeData, Offset> nodePositions;
  final NodeData root;

  TreeLinePainter(this.nodePositions, this.root);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey
      ..strokeWidth = 2;

    void drawLines(NodeData node) {
      final parentOffset = nodePositions[node];
      if (parentOffset == null) return;

      if (node.expanded) {
        for (var child in node.children) {
          final childOffset = nodePositions[child];
          if (childOffset != null) {
            final start = Offset(
              parentOffset.dx + 120, // right side of card
              parentOffset.dy + 30,  // center vertically
            );
            final end = Offset(
              childOffset.dx,
              childOffset.dy + 30,
            );
            canvas.drawLine(start, end, paint);
            drawLines(child);
          }
        }
      }
    }

    drawLines(root);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}


class LinePainter extends CustomPainter {
  final Map<Branch, Offset> positions;

  LinePainter(this.positions);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey.shade800
      ..strokeWidth = 2;

    for (var entry in positions.entries) {
      final parent = entry.key;
      final parentOffset = entry.value;

      for (var child in parent.children) {
        final childOffset = positions[child];
        if (childOffset != null) {
          canvas.drawLine(parentOffset, childOffset, paint);
        }
      }
    }
  }

  @override
  bool shouldRepaint(LinePainter oldDelegate) => true;
}
