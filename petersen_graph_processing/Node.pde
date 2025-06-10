class Node {
  float x, y;
  color nodeColor;
  float radius;
  int chainId;

  Node(float x, float y, color nodeColor, float radius, int chainId) {
    this.x = x;
    this.y = y;
    this.nodeColor = nodeColor;
    this.radius = radius;
    this.chainId = chainId;
  }

  void display(float scale) {
    fill(nodeColor);
    noStroke();
    ellipse(x * scale + width/2, y * scale + height/2, radius * scale * 2, radius * scale * 2);
  }
}