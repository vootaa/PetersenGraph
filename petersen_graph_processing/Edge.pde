/**
 * Edge class for Petersen Graph
 */
class Edge {
  int edgeId;
  Node from, to;
  int type;
  float r, g, b;
  float thickness;
  
  Edge(int edgeId,Node from, Node to, int type, float r, float g, float b, float thickness) {
    this.edgeId = edgeId;
    this.from = from;
    this.to = to;
    this.type = type;
    this.r = r;
    this.g = g;
    this.b = b;
    this.thickness = thickness;
  }
  
  void display() {
    pushStyle();
    stroke(r * 255, g * 255, b * 255);
    strokeWeight(thickness);
    line(from.x, from.y, to.x, to.y);
    popStyle();
  }
}