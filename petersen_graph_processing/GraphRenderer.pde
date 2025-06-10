class GraphRenderer {
  PetersenGraph graph;

  GraphRenderer(PetersenGraph graph) {
    this.graph = graph;
  }

  void render() {
    graph.display();
  }
}