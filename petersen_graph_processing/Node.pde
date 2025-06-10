/**
 * Node class for Petersen Graph
 */
class Node {
  int chainId;
  float x, y;
  float r, g, b;
  float radius;
  
  Node(int chainId, float x, float y, float r, float g, float b, float radius) {
    this.chainId = chainId;
    this.x = x;
    this.y = y;
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