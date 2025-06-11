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
    Node(JSONObject nodeObj) {
        try {
            this.id = nodeObj.getInt("node_id");
            
            // Based on JSON format, coordinates are in "polar" object as strings
            if (nodeObj.hasKey("polar")) {
                JSONObject polar = nodeObj.getJSONObject("polar");
                
                // Parse float from string
                float radius = Float.parseFloat(polar.getString("radius"));
                float angleRad = Float.parseFloat(polar.getString("angle_radians"));
                
                // Convert from polar to Cartesian coordinates
                float x = radius * cos(angleRad);
                float y = radius * sin(angleRad);
                
                this.position = new PVector(x, y);
                this.polarCoordinate = new PVector(radius, angleRad);
                
            } else if (nodeObj.hasKey("x") && nodeObj.hasKey("y")) {
                // Fallback: create directly from x,y coordinates (if they exist)
                this.position = new PVector(
                    nodeObj.getFloat("x"), 
                    nodeObj.getFloat("y")
                );
                calculatePolarCoordinate();
            } else {
                throw new RuntimeException("No valid coordinate data found");
            }
            
            this.type = nodeObj.hasKey("layer") ? nodeObj.getString("layer") : "default";
            
        } catch (Exception e) {
            println("Warning: Error creating node - " + e.getMessage());
            println("Node data: " + nodeObj.toString());
            this.id = -1;
            this.position = new PVector(0, 0);
            this.type = "error";
            calculatePolarCoordinate();
        }
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
