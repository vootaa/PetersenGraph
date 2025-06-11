class Polygon {
    int id;
    ArrayList<Node> vertices;
    color fillColor;
    color strokeColor;
    
    Polygon(int id, ArrayList<Node> vertices) {
        this.id = id;
        this.vertices = new ArrayList<Node>(vertices);
        this.strokeColor = color(255, 255, 255, 200); // 统一白色边界
        this.fillColor = color(150, 150, 150, 100);   // 默认灰色填充
    }
    
    void setColor(color fillColor) {
        this.fillColor = fillColor;
    }
    
    void setStrokeColor(color strokeColor) {
        this.strokeColor = strokeColor;
    }
    
    void draw(float scale) {
        if (vertices.size() < 3) return;
        
        // 绘制填充
        fill(fillColor);
        stroke(strokeColor);
        strokeWeight(2);
        
        beginShape();
        for (Node vertex : vertices) {
            PVector pos = vertex.getPosition();
            vertex(pos.x * scale, pos.y * scale);
        }
        endShape(CLOSE);
    }
    
    void drawOutline(float scale) {
        if (vertices.size() < 3) return;
        
        // 只绘制轮廓
        noFill();
        stroke(strokeColor);
        strokeWeight(2);
        
        beginShape();
        for (Node vertex : vertices) {
            PVector pos = vertex.getPosition();
            vertex(pos.x * scale, pos.y * scale);
        }
        endShape(CLOSE);
    }
    
    // Getters
    int getId() { return id; }
    ArrayList<Node> getVertices() { return new ArrayList<Node>(vertices); }
    color getFillColor() { return fillColor; }
    color getStrokeColor() { return strokeColor; }
    
    // 获取多边形中心点
    PVector getCenter() {
        float centerX = 0, centerY = 0;
        for (Node vertex : vertices) {
            PVector pos = vertex.getPosition();
            centerX += pos.x;
            centerY += pos.y;
        }
        centerX /= vertices.size();
        centerY /= vertices.size();
        return new PVector(centerX, centerY);
    }
    
    // 检查点是否在多边形内（用于交互）
    boolean containsPoint(PVector point) {
        // 简单的射线投射算法
        int intersections = 0;
        int n = vertices.size();
        
        for (int i = 0; i < n; i++) {
            PVector v1 = vertices.get(i).getPosition();
            PVector v2 = vertices.get((i + 1) % n).getPosition();
            
            if (((v1.y <= point.y) && (point.y < v2.y)) || 
                ((v2.y <= point.y) && (point.y < v1.y))) {
                
                float intersectionX = v1.x + (point.y - v1.y) * (v2.x - v1.x) / (v2.y - v1.y);
                if (point.x < intersectionX) {
                    intersections++;
                }
            }
        }
        
        return (intersections % 2) == 1;
    }
}