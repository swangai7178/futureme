class TreeNodeData {
  final String id;
  final String title;
  final String description;
  final List<TreeNodeData> children;

  TreeNodeData({
    required this.id,
    required this.title,
    required this.description,
    this.children = const [],
  });
}
