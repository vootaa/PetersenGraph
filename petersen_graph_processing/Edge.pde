class Edge {
  Node nodeA;
  Node nodeB;
  color edgeColor;
  float lineWidth;

  Edge(Node a, Node b, color c, float w) {
    nodeA = a;
    nodeB = b;
    edgeColor = c;
    lineWidth = w;
  }

  void display(float scale) {
    stroke(edgeColor);
    strokeWeight(lineWidth * scale);
    line(nodeA.x * scale + width/2, nodeA.y * scale + height/2, 
         nodeB.x * scale + width/2, nodeB.y * scale + height/2);
  }
}