class UIRenderer {
    float scale = 600;
    boolean showPolygonView = false;
    boolean showRotatedCopies = false;
    
    StaticDataReader staticDataReader;
    
    UIRenderer() {
    }
    
    void setStaticDataReader(StaticDataReader reader) {
        this.staticDataReader = reader;
    }
    
    // Main rendering function
    void renderAnalysis(AnalysisEngine engine) {
        pushMatrix();
        translate(width/2, height/2);
        
        if (showPolygonView) {
            renderPolygonView(engine);
        } else {
            renderStandardView(engine);
        }
        
        popMatrix();
        
        // Draw UI info
        drawUI();
    }
    
    // Polygon view
    void renderPolygonView(AnalysisEngine engine) {
        // Draw concentric circle guides
        drawRadiusGuides();
        
        if (staticDataReader == null) {
            fill(255, 100, 100);
            textAlign(CENTER);
            text("Static data not loaded", 0, 0);
            return;
        }

        drawRotatedPolygons(0); 

        if (showRotatedCopies) {
            // Draw rotated copies at 72 degrees
            drawRotatedPolygons(72); 
            drawRotatedPolygons(144);
            drawRotatedPolygons(216);
            drawRotatedPolygons(288);
        } 
        
        // Draw nodes (on top of polygons)
        drawNodesOverlay(engine);
    }
    
    void drawRotatedPolygons(float angleDegrees) {
        ArrayList<Polygon> rotatedPolygons = staticDataReader.getRotatedPolygons(angleDegrees);
        
        for (Polygon poly : rotatedPolygons) {
            fill(poly.getFillColor());

            stroke(255, 255, 255, 100); // Lighter border
            strokeWeight(1);
            
            // Draw polygon
            ArrayList<Node> vertices = poly.getVertices();
            if (vertices.size() >= 3) {
                beginShape();
                for (Node vertex : vertices) {
                    PVector pos = vertex.getPosition();
                    vertex(pos.x * scale, pos.y * scale);
                }
                endShape(CLOSE);
            }
        }
    }
    
    void drawNodesOverlay(AnalysisEngine engine) {
        // Draw all nodes as overlay layer
        noStroke();
        for (Node node : engine.getNodes()) {
            PVector pos = node.getPosition();
            
            // Smaller nodes
            if (node.getType().equals("intersection")) {
                fill(255, 255, 255, 200);
                ellipse(pos.x * scale, pos.y * scale, 6, 6);
            } else {
                fill(255, 255, 100, 200);
                ellipse(pos.x * scale, pos.y * scale, 8, 8);
            }
        }
    }
    
    void drawPolygonLabels(ArrayList<Polygon> polygons) {
        fill(255);
        stroke(0);
        strokeWeight(1);
        textAlign(CENTER);
        textSize(12);
        
        for (Polygon poly : polygons) {
            PVector center = poly.getCenter();
            text("P" + poly.getId(), center.x * scale, center.y * scale);
        }
        noStroke();
    }
    
    // Standard graph view (unchanged)
    void renderStandardView(AnalysisEngine engine) {
        // Draw radius guide circles for reference
        drawRadiusGuides();

        // Draw edges
        stroke(220, 220, 220, 150);
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
            } else if (node.getType().equals("Inner")) {
                fill(100, 255, 100, 200);
            } else {
                fill(255, 255, 100, 200);
            }
            
            // Node size
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
    }
    
    // Draw radius guide circles
    void drawRadiusGuides() {
        stroke(80, 80, 80, 120);
        strokeWeight(1);
        noFill();
        
        // Draw concentric circles for radius reference
        float[] actualRadii = {0.06, 0.15, 0.30, 0.39, 0.41, 0.48};
        for (float r : actualRadii) {
            ellipse(0, 0, r * scale * 2, r * scale * 2);
        }

        noFill();
    }
    
    // Toggle polygon view
    void togglePolygonView() {
        showPolygonView = !showPolygonView;
        println("Polygon view: " + (showPolygonView ? "ON" : "OFF"));
    }
    
    // Toggle rotated copies
    void toggleRotatedCopies() {
        showRotatedCopies = !showRotatedCopies;
        println("Rotated copies: " + (showRotatedCopies ? "ON" : "OFF"));
    }
    
    // Draw UI information
    void drawUI() {
        // Status info
        fill(0, 0, 0, 180);
        rect(10, height - 200, 300, 190);
        
        fill(255);
        textAlign(LEFT);
        textSize(12);
        text("Controls:", 20, height - 180);
        text("P - Toggle polygon view", 20, height - 160);
        text("R - Toggle rotated copies", 20, height - 140);
        text("O - Output polygon polar data", 20, height - 120);
        text("+ / - Zoom in/out", 20, height - 100);
        text("0 - Reset zoom", 20, height - 80);
        text("S - Screenshot", 20, height - 60);
        text("D - Debug segments", 20, height - 40);
        text("ESC - Exit", 20, height - 20);
        
        // Show current scale
        fill(255, 255, 0);
        text("Zoom: " + nf(scale/100.0, 1, 1) + "x", width - 100, height - 20);
        
        // Show current view mode
        fill(100, 255, 100);
        if (showPolygonView) {
            String viewMode = "Polygon View" + (showRotatedCopies ? " + Rotated" : "");
            text("View: " + viewMode, width - 200, height - 40);
        } else {
            text("View: Standard", width - 100, height - 40);
        }
    }
    
    // Adjust scale
    void adjustScale(float factor) {
        scale *= factor;
        scale = constrain(scale, 400, 800);
    }
}