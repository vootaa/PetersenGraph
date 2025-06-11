class Polygon {
    int id;
    ArrayList<Node> vertices;
    color fillColor;
    color strokeColor;
    
    Polygon(int id, ArrayList<Node> vertices) {
        this.id = id;
        this.vertices = new ArrayList<Node>(vertices);
        this.strokeColor = color(255, 255, 255, 200); // Uniform white border
        this.fillColor = color(150, 150, 150, 100);   // Default gray fill
    }
    
    void setColor(color fillColor) {
        this.fillColor = fillColor;
    }
    
    void setStrokeColor(color strokeColor) {
        this.strokeColor = strokeColor;
    }
        
    // Getters
    int getId() { return id; }
    ArrayList<Node> getVertices() { return new ArrayList<Node>(vertices); }
    color getFillColor() { return fillColor; }
    color getStrokeColor() { return strokeColor; }
    
    // Get polygon center point
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
    
    // Check if point is inside polygon (for interaction)
    boolean containsPoint(PVector point) {
        // Simple ray casting algorithm
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