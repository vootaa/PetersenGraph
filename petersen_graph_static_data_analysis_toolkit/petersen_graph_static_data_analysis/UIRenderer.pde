class UIRenderer {
    float scale = 600;
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
        strokeWeight(2);  // Increase line thickness
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
            } else if (node.getType().equals("Inner")) {
                fill(100, 255, 100, 200);
            } else {
                fill(255, 255, 100, 200);
            }
            
            // Increase node size
            float nodeSize = 12;
            if (node.getType().equals("intersection")) {
                nodeSize = 8;  // Intersection points slightly smaller
            }
            
            ellipse(pos.x * scale, pos.y * scale, nodeSize, nodeSize);
            
            // Draw node ID with better visibility
            fill(255);
            stroke(0);
            strokeWeight(1);
            textAlign(CENTER);
            textSize(10);
            text(node.getId(), pos.x * scale, pos.y * scale - 16);
            noStroke();
        }
        
        // Draw radius guide circles for reference
        drawRadiusGuides();
    }
    
    // Draw radius guide circles
    void drawRadiusGuides() {
        stroke(60, 60, 60, 100);
        strokeWeight(1);
        noFill();
        
        // Draw concentric circles for different radius levels
        for (float r = 0.1; r <= 0.5; r += 0.1) {
            ellipse(0, 0, r * scale * 2, r * scale * 2);
        }
    }
    
    // Symmetry analysis view - shows only 1/5 of the structure
    void renderSymmetryAnalysis(AnalysisEngine engine) {
        // Only show nodes in first symmetry group (0-72 degrees)
        ArrayList<Node> firstGroupNodes = getSymmetryGroupNodes(engine, 0);
        ArrayList<Edge> firstGroupEdges = getSymmetryGroupEdges(engine, firstGroupNodes);
        
        // Draw reference lines for 72-degree sectors
        drawSymmetryGuides();
        
        // Draw all edges in light gray first
        stroke(50, 50, 50, 100);
        strokeWeight(1);
        for (Edge edge : engine.getEdges()) {
            if (edge.isValid()) {
                PVector start = edge.getStartNode().getPosition();
                PVector end = edge.getEndNode().getPosition();
                line(start.x * scale, start.y * scale, end.x * scale, end.y * scale);
            }
        }
        
        // Draw edges in first group highlighted
        stroke(255, 150, 0, 255);
        strokeWeight(3);
        for (Edge edge : firstGroupEdges) {
            if (edge.isValid()) {
                PVector start = edge.getStartNode().getPosition();
                PVector end = edge.getEndNode().getPosition();
                line(start.x * scale, start.y * scale, end.x * scale, end.y * scale);
            }
        }
        
        // Draw all nodes in light gray first
        noStroke();
        for (Node node : engine.getNodes()) {
            PVector pos = node.getPosition();
            fill(100, 100, 100, 100);
            ellipse(pos.x * scale, pos.y * scale, 6, 6);
        }
        
        // Draw nodes in first group highlighted
        noStroke();
        for (Node node : firstGroupNodes) {
            PVector pos = node.getPosition();
            
            // Highlight by radius
            float radius = node.getRadius();
            if (radius < 0.2) {
                fill(255, 100, 100, 255); // Inner nodes - red
            } else if (radius < 0.4) {
                fill(100, 255, 100, 255); // Middle nodes - green
            } else {
                fill(100, 100, 255, 255); // Outer nodes - blue
            }
            
            ellipse(pos.x * scale, pos.y * scale, 15, 15);
            
            // Draw node info
            fill(255);
            stroke(0);
            strokeWeight(1);
            textAlign(CENTER);
            textSize(10);
            text(node.getId(), pos.x * scale, pos.y * scale - 20);
            noStroke();
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
        stroke(120, 120, 120, 150);
        strokeWeight(2);
        
        for (int i = 0; i < 5; i++) {
            float angle = radians(i * 72);
            float x = cos(angle) * scale * 0.6;
            float y = sin(angle) * scale * 0.6;
            line(0, 0, x, y);
        }
        
        // Draw concentric circles for radius reference
        noFill();
        stroke(80, 80, 80, 100);
        strokeWeight(1);
        for (float r = 0.1; r <= 0.5; r += 0.1) {
            ellipse(0, 0, r * scale * 2, r * scale * 2);
        }
        
        // Highlight the 72-degree sector
        fill(255, 255, 0, 30);
        noStroke();
        arc(0, 0, scale * 1.2, scale * 1.2, 0, radians(72));
    }
    
    // Draw symmetry analysis info
    void drawSymmetryInfo(ArrayList<Node> nodes, ArrayList<Edge> edges) {
        pushMatrix();
        translate(-width/2 + 20, -height/2 + 20);
        
        fill(0, 0, 0, 180);
        rect(0, 0, 280, 140);
        
        fill(255);
        textAlign(LEFT);
        textSize(12);
        text("Symmetry Group Analysis (1/5 Structure)", 10, 20);
        text("Nodes: " + nodes.size(), 10, 40);
        text("Edges: " + edges.size(), 10, 60);
        text("Press V to toggle view", 10, 80);
        text("Press P for polar analysis", 10, 100);
        text("+/- to zoom", 10, 120);
        
        popMatrix();
    }
    
    // Draw UI information
    void drawUI() {
        // Status info
        fill(0, 0, 0, 180);
        rect(10, height - 140, 220, 130);
        
        fill(255);
        textAlign(LEFT);
        textSize(12);
        text("Controls:", 20, height - 120);
        text("P - Polar analysis", 20, height - 100);
        text("G - Polygon component analysis", 20, height - 80);
        text("V - Toggle view", 20, height - 60);
        text("+ / - Zoom in/out", 20, height - 40);
        text("0 - Reset zoom", 20, height - 20);
        
        // Show current scale
        fill(255, 255, 0);
        text("Zoom: " + nf(scale/100.0, 1, 1) + "x", width - 100, height - 20);
        
        // Show current view mode
        fill(100, 255, 100);
        text("View: " + (showSymmetryAnalysis ? "Symmetry" : "Standard"), width - 100, height - 40);
    }
    
    // Toggle symmetry analysis view
    void toggleSymmetryView() {
        showSymmetryAnalysis = !showSymmetryAnalysis;
        println("View toggled: " + (showSymmetryAnalysis ? "Symmetry Analysis" : "Standard View"));
    }
    
    // Adjust scale
    void adjustScale(float factor) {
        scale *= factor;
        scale = constrain(scale, 400, 800);  // Expand zoom range
        //println("Scale adjusted to: " + nf(scale/100.0, 1, 1) + "x");
    }
}