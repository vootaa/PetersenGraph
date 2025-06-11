class UIRenderer {
    float scale = 100;
    boolean showSymmetryAnalysis = false;
    
    UIRenderer() {
    }
    
    // Main rendering function
    void renderAnalysis(AnalysisEngine engine) {
        pushMatrix();
        translate(width/2, height/2);
        
        if (showSymmetryAnalysis) {
            renderSymmetryAnalysis(engine);
        } else {
            renderStandardView(engine);
        }
        
        popMatrix();
        
        // Draw UI info
        drawUI();
    }
    
    // Standard graph view
    void renderStandardView(AnalysisEngine engine) {
        // Draw edges
        stroke(100, 150);
        strokeWeight(1);
        for (Edge edge : engine.getEdges()) {
            if (edge.isValid()) {
                PVector start = edge.getStartNode().getPosition();
                PVector end = edge.getEndNode().getPosition();
                line(start.x * scale, start.y * scale, end.x * scale, end.y * scale);
            }
        }
        
        // Draw nodes
        noStroke();
        for (Node node : engine.getNodes()) {
            PVector pos = node.getPosition();
            
            // Color by type
            if (node.getType().equals("intersection")) {
                fill(0, 255, 255, 200);
            } else if (node.getType().equals("Middle")) {
                fill(255, 100, 100, 200);
            } else {
                fill(255, 255, 100, 200);
            }
            
            ellipse(pos.x * scale, pos.y * scale, 8, 8);
            
            // Draw node ID
            fill(255);
            textAlign(CENTER);
            text(node.getId(), pos.x * scale, pos.y * scale - 12);
        }
    }
    
    // Symmetry analysis view - shows only 1/5 of the structure
    void renderSymmetryAnalysis(AnalysisEngine engine) {
        // Only show nodes in first symmetry group (0-72 degrees)
        ArrayList<Node> firstGroupNodes = getSymmetryGroupNodes(engine, 0);
        ArrayList<Edge> firstGroupEdges = getSymmetryGroupEdges(engine, firstGroupNodes);
        
        // Draw reference lines for 72-degree sectors
        drawSymmetryGuides();
        
        // Draw edges in first group
        stroke(255, 150, 0, 200);
        strokeWeight(2);
        for (Edge edge : firstGroupEdges) {
            if (edge.isValid()) {
                PVector start = edge.getStartNode().getPosition();
                PVector end = edge.getEndNode().getPosition();
                line(start.x * scale, start.y * scale, end.x * scale, end.y * scale);
            }
        }
        
        // Draw nodes in first group
        noStroke();
        for (Node node : firstGroupNodes) {
            PVector pos = node.getPosition();
            
            // Highlight by radius
            float radius = node.getRadius();
            if (radius < 0.5) {
                fill(255, 0, 0, 200); // Inner nodes
            } else if (radius < 1.0) {
                fill(0, 255, 0, 200); // Middle nodes
            } else {
                fill(0, 0, 255, 200); // Outer nodes
            }
            
            ellipse(pos.x * scale, pos.y * scale, 12, 12);
            
            // Draw node info
            fill(255);
            textAlign(CENTER);
            text(node.getId(), pos.x * scale, pos.y * scale - 15);
        }
        
        // Draw analysis info
        drawSymmetryInfo(firstGroupNodes, firstGroupEdges);
    }
    
    // Get nodes in a specific symmetry group
    ArrayList<Node> getSymmetryGroupNodes(AnalysisEngine engine, int group) {
        ArrayList<Node> groupNodes = new ArrayList<Node>();
        float startAngle = group * 72.0;
        float endAngle = (group + 1) * 72.0;
        
        for (Node node : engine.getNodes()) {
            float angle = node.getNormalizedAngleDegrees();
            if (angle >= startAngle && angle < endAngle) {
                groupNodes.add(node);
            }
        }
        
        return groupNodes;
    }
    
    // Get edges that connect nodes within a symmetry group
    ArrayList<Edge> getSymmetryGroupEdges(AnalysisEngine engine, ArrayList<Node> groupNodes) {
        ArrayList<Edge> groupEdges = new ArrayList<Edge>();
        
        for (Edge edge : engine.getEdges()) {
            if (edge.isValid()) {
                boolean startInGroup = groupNodes.contains(edge.getStartNode());
                boolean endInGroup = groupNodes.contains(edge.getEndNode());
                
                // Include edge if both nodes are in the group
                if (startInGroup && endInGroup) {
                    groupEdges.add(edge);
                }
            }
        }
        
        return groupEdges;
    }
    
    // Draw symmetry guide lines
    void drawSymmetryGuides() {
        stroke(80, 80, 80);
        strokeWeight(1);
        
        for (int i = 0; i < 5; i++) {
            float angle = radians(i * 72);
            float x = cos(angle) * scale * 2;
            float y = sin(angle) * scale * 2;
            line(0, 0, x, y);
        }
        
        // Draw concentric circles for radius reference
        noFill();
        stroke(60, 60, 60);
        for (int r = 1; r <= 3; r++) {
            ellipse(0, 0, r * scale, r * scale);
        }
    }
    
    // Draw symmetry analysis info
    void drawSymmetryInfo(ArrayList<Node> nodes, ArrayList<Edge> edges) {
        pushMatrix();
        translate(-width/2 + 20, -height/2 + 20);
        
        fill(0, 0, 0, 150);
        rect(0, 0, 250, 120);
        
        fill(255);
        textAlign(LEFT);
        text("Symmetry Group Analysis (1/5 Structure)", 10, 20);
        text("Nodes: " + nodes.size(), 10, 40);
        text("Edges: " + edges.size(), 10, 60);
        text("Press V to toggle view", 10, 80);
        text("Press P for polar analysis", 10, 100);
        
        popMatrix();
    }
    
    // Draw UI information
    void drawUI() {
        // Status info
        fill(0, 0, 0, 150);
        rect(10, height - 80, 200, 70);
        
        fill(255);
        textAlign(LEFT);
        text("Controls:", 20, height - 60);
        text("P - Polar Analysis", 20, height - 45);
        text("E - Edge Analysis", 20, height - 30);
        text("V - Toggle View", 20, height - 15);
    }
    
    // Toggle symmetry analysis view
    void toggleSymmetryView() {
        showSymmetryAnalysis = !showSymmetryAnalysis;
        println("View toggled: " + (showSymmetryAnalysis ? "Symmetry Analysis" : "Standard View"));
    }
    
    // Adjust scale
    void adjustScale(float factor) {
        scale *= factor;
        scale = constrain(scale, 20, 300);
    }
}