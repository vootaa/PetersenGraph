class Edge {
    int id;
    Node startNode;
    Node endNode;
    int type; // Edge type for categorization
    
    // Constructor with Node objects
    Edge(int id, Node start, Node end, int type) {
        this.id = id;
        this.startNode = start;
        this.endNode = end;
        this.type = type;
    }
    
    // Getters
    int getId() { 
        return id; 
    }
    
    Node getStartNode() { 
        return startNode; 
    }
    
    Node getEndNode() { 
        return endNode; 
    }
    
    int getType() { 
        return type; 
    }
    
    // Validation
    boolean isValid() {
        return startNode != null && endNode != null;
    }
    
    // Helper methods
    float getLength() {
        if (!isValid()) return 0;
        return PVector.dist(startNode.getPosition(), endNode.getPosition());
    }
    
    PVector getDirection() {
        if (!isValid()) return new PVector(0, 0);
        PVector dir = PVector.sub(endNode.getPosition(), startNode.getPosition());
        dir.normalize();
        return dir;
    }
    
    PVector getMidpoint() {
        if (!isValid()) return new PVector(0, 0);
        return PVector.lerp(startNode.getPosition(), endNode.getPosition(), 0.5);
    }
    
    // Check if this edge connects two specific nodes
    boolean connects(int nodeId1, int nodeId2) {
        if (!isValid()) return false;
        return (startNode.getId() == nodeId1 && endNode.getId() == nodeId2) ||
               (startNode.getId() == nodeId2 && endNode.getId() == nodeId1);
    }
    
    // Check if this edge contains a specific node
    boolean containsNode(int nodeId) {
        if (!isValid()) return false;
        return startNode.getId() == nodeId || endNode.getId() == nodeId;
    }
    
    // Get the other node (given one node of the edge)
    Node getOtherNode(Node node) {
        if (!isValid() || node == null) return null;
        if (startNode.getId() == node.getId()) {
            return endNode;
        } else if (endNode.getId() == node.getId()) {
            return startNode;
        }
        return null;
    }
    
    // String representation for debugging
    String toString() {
        if (!isValid()) {
            return "Edge[ID:" + id + " INVALID]";
        }
        return "Edge[ID:" + id + " " + startNode.getId() + "->" + 
               endNode.getId() + " Type:" + type + " Length:" + 
               nf(getLength(), 1, 2) + "]";
    }
}