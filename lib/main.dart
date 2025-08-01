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

class Branch {
  final String choice;
  final String outcome;
  List<Branch> children = [];
  bool expanded = false;

  Branch({required this.choice, required this.outcome});
}

class TreeGraph extends StatefulWidget {
  const TreeGraph({super.key});

  @override
  _TreeGraphState createState() => _TreeGraphState();
}

class _TreeGraphState extends State<TreeGraph> {
  final Map<Branch, Offset> nodePositions = {};
  final double xGap = 200;
  final double yGap = 100;

  late Branch root;

  @override
  void initState() {
    super.initState();

    // Root scenario
    root = Branch(choice: "Graduate High School", outcome: "You finish school");

    // First level choices
    var job = Branch(choice: "Get a job", outcome: "Earn money early");
    var college = Branch(choice: "Go to college", outcome: "Build skills");

    // Second level
    var promotion = Branch(choice: "Work hard", outcome: "Get promoted");
    var travel = Branch(choice: "Travel", outcome: "See the world");
    var studyMore = Branch(choice: "Masters Degree", outcome: "Higher expertise");

    root.children.addAll([job, college]);
    job.children.addAll([promotion, travel]);
    college.children.add(studyMore);
  }

  @override
  Widget build(BuildContext context) {
    nodePositions.clear();

    return Stack(
      children: [
        ..._buildTree(root, 0, 0),
        CustomPaint(
          size: Size.infinite,
          painter: LinePainter(nodePositions),
        ),
      ],
    );
  }

  List<Widget> _buildTree(Branch node, double x, double y) {
    List<Widget> widgets = [];

    nodePositions[node] = Offset(x + 100, y + 30); // For line drawing

    widgets.add(Positioned(
      left: x,
      top: y,
      child: GestureDetector(
        onTap: () {
          setState(() {
            node.expanded = !node.expanded;
          });
        },
        child: Container(
          width: 180,
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.blueAccent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Text(node.choice, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              SizedBox(height: 4),
              Text(node.outcome, style: TextStyle(color: Colors.white70, fontSize: 12)),
            ],
          ),
        ),
      ),
    ));

    if (node.expanded) {
      for (int i = 0; i < node.children.length; i++) {
        final child = node.children[i];
        final childX = x + xGap;
        final childY = y + i * yGap + 50;

        widgets.addAll(_buildTree(child, childX, childY));
      }
    }

    return widgets;
  }
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
