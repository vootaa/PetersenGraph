class Node {
    int id;
    PVector position;
    PVector polarCoordinate; // x = radius, y = angle in radians
    String type;
    // Constructor from coordinates
    Node(int id, float x, float y, String type) {
        this.id = id;
        this.position = new PVector(x, y);
        this.type = type;
        calculatePolarCoordinate();
    }

    // Constructor from PVector
    Node(int id, PVector pos, String type) {
        this.id = id;
        this.position = pos.copy();
        this.type = type;
        calculatePolarCoordinate();
    }
    
    // Constructor from JSONObject
    try {
        this.id = nodeObj.getInt("node_id");  
        
        // 根据JSON格式，坐标可能在 "cartesian" 对象中
        if (nodeObj.hasKey("cartesian")) {
            JSONObject cartesian = nodeObj.getJSONObject("cartesian");
            this.position = new PVector(
                cartesian.getFloat("x"), 
                cartesian.getFloat("y")
            );
        } else {
            this.position = new PVector(
                nodeObj.getFloat("x"), 
                nodeObj.getFloat("y")
            );
        }
        
        this.type = nodeObj.hasKey("layer") ? nodeObj.getString("layer") : "default";
        calculatePolarCoordinate();
    } catch (Exception e) {
        println("警告: 创建节点时发生错误 - " + e.getMessage());
        this.id = -1;
        this.position = new PVector(0, 0);
        this.type = "error";
        calculatePolarCoordinate();
    }
    
    // Calculate polar coordinates from Cartesian
    void calculatePolarCoordinate() {
        this.polarCoordinate = new PVector(
            sqrt(position.x * position.x + position.y * position.y), // radius
            atan2(position.y, position.x)                              // angle in radians
        );
    }
    
    // Getters
    int getId() { 
        return id; 
    }
    
    PVector getPosition() { 
        return position.copy(); 
    }
    
    PVector getPolarCoordinate() { 
        return polarCoordinate.copy(); 
    }
    
    String getType() { 
        return type; 
    }
    
    // Polar coordinate helper methods
    float getRadius() { 
        return polarCoordinate.x; 
    }
    
    float getAngle() { 
        return polarCoordinate.y; 
    }
    
    float getAngleDegrees() { 
        return degrees(polarCoordinate.y); 
    }
    
    // Normalized angle (0-360 degrees)
    float getNormalizedAngleDegrees() {
        float angleDeg = getAngleDegrees();
        while (angleDeg < 0) angleDeg += 360;
        while (angleDeg >= 360) angleDeg -= 360;
        return angleDeg;
    }
    
    // Update position and recalculate polar coordinates
    void setPosition(float x, float y) {
        this.position.set(x, y);
        calculatePolarCoordinate();
    }
    
    void setPosition(PVector pos) {
        this.position = pos.copy();
        calculatePolarCoordinate();
    }
    
    // String representation for debugging
    String toString() {
        return "Node[ID:" + id + " Pos:(" + nf(position.x, 1, 2) + "," + 
               nf(position.y, 1, 2) + ") Polar:(r=" + nf(getRadius(), 1, 2) + 
               " θ=" + nf(getAngleDegrees(), 1, 1) + "°) Type:" + type + "]";
    }
}