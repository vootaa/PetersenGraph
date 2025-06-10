/**
 * Intersection class for Petersen Graph edge crossings
 */
class Intersection {
  int intersectionId;
  float x, y;
  int edge1Id, edge2Id;
  Edge edge1, edge2;
  float r, g, b;
  float radius;
  
  Intersection(int intersectionId, float x, float y, int edge1Id, int edge2Id, Edge edge1, Edge edge2, float r, float g, float b, float radius) {
    this.intersectionId = intersectionId;
    this.x = x;
    this.y = y;
    this.edge1Id = edge1Id;
    this.edge2Id = edge2Id;
    this.edge1 = edge1;
    this.edge2 = edge2;
    this.r = r;
    this.g = g;
    this.b = b;
    this.radius = radius;
  }
  
  void display() {
    pushStyle();
    fill(r * 255, g * 255, b * 255);
    noStroke();
    ellipse(x, y, radius * 2, radius * 2);
    popStyle();
  }
}