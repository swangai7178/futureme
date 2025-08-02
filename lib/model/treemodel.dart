class TreeNodeData {
  final String id;
  final String title;
  final String description;
  List<TreeNodeData> children;

  TreeNodeData({
    required this.id,
    required this.title,
    required this.description,
    this.children = const [],
  });

  TreeNodeData copyWith({List<TreeNodeData>? children}) {
    return TreeNodeData(
      id: id,
      title: title,
      description: description,
      children: children ?? this.children,
    );
  }
}
