class StaticDataReader {
    ArrayList<Polygon> polygons;
    ArrayList<Node> nodes;
    ArrayList<Node> intersections;

    ArrayList<Polygon> hardcodedPolygons;
    
    StaticDataReader() {
        polygons = new ArrayList<Polygon>();
        nodes = new ArrayList<Node>();
        intersections = new ArrayList<Node>();

        hardcodedPolygons = new ArrayList<Polygon>();
        createHardcodedPolygons();
    }
    
    // Get nodes from AnalysisEngine
    void linkWithAnalysisEngine(AnalysisEngine engine) {
        HashMap<String, Node> nodeMap = new HashMap<String, Node>();
        
        // Build node mapping table
        for (Node node : engine.getNodes()) {
            String key;
            if (node.getType().equals("intersection")) {
                key = "I" + node.getId();
            } else {
                key = "N" + node.getId();
            }
            nodeMap.put(key, node);
        }
        
        // Create polygons using real coordinates
        createPolygon1(nodeMap);
        createPolygon2(nodeMap);
        createPolygon3(nodeMap);
        createPolygon4(nodeMap);
        createPolygon5(nodeMap);
        createPolygon6(nodeMap);
        
        println("Linked " + polygons.size() + " polygons with real coordinates");
    }

    void createHardcodedPolygons() {
        // P1= {(0.060,36),(0.060,324),(0.150,0)}
        createHardcodedPolygon(1, new float[][]{{0.060,36},{0.060,324},{0.150,0}});
        
        // P2= {(0.060,36),(0.150,0),(0.300,0),(0.390,6),(0.390,66),(0.300,72),(0.150,72)}
        createHardcodedPolygon(2, new float[][]{{0.060,36},{0.150,0},{0.300,0},{0.390,6},{0.390,66},{0.300,72},{0.150,72}});
        
        // P3= {(0.300,0),(0.390,354),(0.416,0),(0.390,6)}
        createHardcodedPolygon(3, new float[][]{{0.300,0},{0.390,354},{0.416,0},{0.390,6}});
        
        // P4= {(0.390,6),(0.416,0),(0.480,10)}
        createHardcodedPolygon(4, new float[][]{{0.390,6},{0.416,0},{0.480,10}});
        
        // P5= {(0.390,6),(0.480,10),(0.480,62),(0.390,66)}
        createHardcodedPolygon(5, new float[][]{{0.390,6},{0.480,10},{0.480,62},{0.390,66}});
        
        // P6= {(0.390,66),(0.480,62),(0.416,72)}
        createHardcodedPolygon(6, new float[][]{{0.390,66},{0.480,62},{0.416,72}});
    }

    void createHardcodedPolygon(int id, float[][] polarCoords) {
        ArrayList<Node> vertices = new ArrayList<Node>();
        
        for (int i = 0; i < polarCoords.length; i++) {
            float radius = polarCoords[i][0];
            float angleDegrees = polarCoords[i][1];
            
            // Convert polar coordinates to Cartesian coordinates
            float angleRad = radians(angleDegrees);
            float x = radius * cos(angleRad);
            float y = radius * sin(angleRad);
            
            Node vertex = new Node(2000 + id * 10 + i, new PVector(x, y), "hardcoded");
            vertices.add(vertex);
        }
        
        if (vertices.size() >= 3) {
            Polygon poly = new Polygon(id, vertices);
            poly.setColor(color(0, 0, 0, 255)); // Black fill
            hardcodedPolygons.add(poly);
        }
    }

    // Get hardcoded polygons
    ArrayList<Polygon> getHardcodedPolygons() {
        return new ArrayList<Polygon>(hardcodedPolygons);
    }

    // Create rotated copies of hardcoded polygons
    ArrayList<Polygon> getRotatedHardcodedPolygons(float angleDegrees) {
        ArrayList<Polygon> rotatedPolygons = new ArrayList<Polygon>();
        
        for (Polygon originalPoly : hardcodedPolygons) {
            ArrayList<Node> rotatedVertices = new ArrayList<Node>();
            
            for (Node vertex : originalPoly.getVertices()) {
                Node rotatedNode = createRotatedNode(vertex, angleDegrees);
                rotatedVertices.add(rotatedNode);
            }
            
            Polygon rotatedPoly = new Polygon(originalPoly.getId(), rotatedVertices);
            rotatedPoly.setColor(color(0, 0, 0, 255)); // Black fill, no transparency
            rotatedPolygons.add(rotatedPoly);
        }
        
        return rotatedPolygons;
    }
    
    void createPolygon1(HashMap<String, Node> nodeMap) {
        // {I1010, I1011, N6}
        ArrayList<Node> vertices = new ArrayList<Node>();
        addVertex(vertices, "I1010", nodeMap);
        addVertex(vertices, "I1011", nodeMap);
        addVertex(vertices, "N6", nodeMap);
        
        if (vertices.size() == 3) {
            Polygon poly = new Polygon(1, vertices);
            poly.setColor(color(20, 20, 20, 255)); // Dark gray fill
            polygons.add(poly);
        }
    }
    
    void createPolygon2(HashMap<String, Node> nodeMap) {
        // {I1010, N6, N1, I1001, I1002, N2, N7}
        ArrayList<Node> vertices = new ArrayList<Node>();
        addVertex(vertices, "I1010", nodeMap);
        addVertex(vertices, "N6", nodeMap);
        addVertex(vertices, "N1", nodeMap);
        addVertex(vertices, "I1001", nodeMap);
        addVertex(vertices, "I1002", nodeMap);
        addVertex(vertices, "N2", nodeMap);
        addVertex(vertices, "N7", nodeMap);
        
        if (vertices.size() == 7) {
            Polygon poly = new Polygon(2, vertices);
            poly.setColor(color(20, 20, 20, 255)); // Dark gray fill
            polygons.add(poly);
        }
    }
    
    void createPolygon3(HashMap<String, Node> nodeMap) {
        // {N1, I1006, I1016, I1001}
        ArrayList<Node> vertices = new ArrayList<Node>();
        addVertex(vertices, "N1", nodeMap);
        addVertex(vertices, "I1006", nodeMap);
        addVertex(vertices, "I1016", nodeMap);
        addVertex(vertices, "I1001", nodeMap);
        
        if (vertices.size() == 4) {
            Polygon poly = new Polygon(3, vertices);
            poly.setColor(color(20, 20, 20, 255)); // Dark gray fill
            polygons.add(poly);
        }
    }
    
    void createPolygon4(HashMap<String, Node> nodeMap) {
        // {I1001, I1016, N11}
        ArrayList<Node> vertices = new ArrayList<Node>();
        addVertex(vertices, "I1001", nodeMap);
        addVertex(vertices, "I1016", nodeMap);
        addVertex(vertices, "N11", nodeMap);
        
        if (vertices.size() == 3) {
            Polygon poly = new Polygon(4, vertices);
            poly.setColor(color(20, 20, 20, 255)); // Dark gray fill
            polygons.add(poly);
        }
    }
    
    void createPolygon5(HashMap<String, Node> nodeMap) {
        // {I1001, N11, N12, I1002}
        ArrayList<Node> vertices = new ArrayList<Node>();
        addVertex(vertices, "I1001", nodeMap);
        addVertex(vertices, "N11", nodeMap);
        addVertex(vertices, "N12", nodeMap);
        addVertex(vertices, "I1002", nodeMap);
        
        if (vertices.size() == 4) {
            Polygon poly = new Polygon(5, vertices);
            poly.setColor(color(20, 20, 20, 255)); // Dark gray fill
            polygons.add(poly);
        }
    }
    
    void createPolygon6(HashMap<String, Node> nodeMap) {
        // {I1002, N12, I1017}
        ArrayList<Node> vertices = new ArrayList<Node>();
        addVertex(vertices, "I1002", nodeMap);
        addVertex(vertices, "N12", nodeMap);
        addVertex(vertices, "I1017", nodeMap);
        
        if (vertices.size() == 3) {
            Polygon poly = new Polygon(6, vertices);
            poly.setColor(color(20, 20, 20, 255)); // Dark gray fill
            polygons.add(poly);
        }
    }
    
    void addVertex(ArrayList<Node> vertices, String nodeId, HashMap<String, Node> nodeMap) {
        Node node = nodeMap.get(nodeId);
        if (node != null) {
            vertices.add(node);
        } else {
            println("Warning: Node " + nodeId + " not found in analysis data");
        }
    }
    
    ArrayList<Polygon> getPolygons() {
        return new ArrayList<Polygon>(polygons);
    }
    
    // Create rotated polygon collection
    ArrayList<Polygon> getRotatedPolygons(float angleDegrees) {
        ArrayList<Polygon> rotatedPolygons = new ArrayList<Polygon>();
        
        for (Polygon originalPoly : polygons) {
            ArrayList<Node> rotatedVertices = new ArrayList<Node>();
            
            for (Node vertex : originalPoly.getVertices()) {
                Node rotatedNode = createRotatedNode(vertex, angleDegrees);
                rotatedVertices.add(rotatedNode);
            }
            
            Polygon rotatedPoly = new Polygon(originalPoly.getId(), rotatedVertices);
            rotatedPoly.setColor(originalPoly.getFillColor());
            rotatedPolygons.add(rotatedPoly);
        }
        
        return rotatedPolygons;
    }
    
    Node createRotatedNode(Node originalNode, float angleDegrees) {
        PVector pos = originalNode.getPosition();
        
        // Rotate coordinates
        float angleRad = radians(angleDegrees);
        float newX = pos.x * cos(angleRad) - pos.y * sin(angleRad);
        float newY = pos.x * sin(angleRad) + pos.y * cos(angleRad);
        
        // Create new node (keep original ID and type)
        Node rotatedNode = new Node(originalNode.getId(), new PVector(newX, newY), originalNode.getType());
        return rotatedNode;
    }

    void printPolygonPolarData() {
        println("\n=== Polygon Polar Coordinate Data ===");
        
        for (Polygon poly : polygons) {
            ArrayList<Node> vertices = poly.getVertices();
            
            print("P" + poly.getId() + ": {");
            
            for (int i = 0; i < vertices.size(); i++) {
                Node vertex = vertices.get(i);
                PVector pos = vertex.getPosition();
                
                // Calculate polar coordinates
                float radius = sqrt(pos.x * pos.x + pos.y * pos.y);
                float angleDegrees = degrees(atan2(pos.y, pos.x));
                
                // Ensure angle is positive
                if (angleDegrees < 0) {
                    angleDegrees += 360;
                }
                
                print("(" + nf(radius, 1, 3) + "," + nf(angleDegrees, 1, 1) + ")");
                
                if (i < vertices.size() - 1) {
                    print(",");
                }
            }
            
            println("}");
        }
        
        println("=== End Polygon Polar Data ===\n");
    }

    // Output detailed polar coordinate data including node ID information
    void printDetailedPolygonPolarData() {
        println("\n=== Detailed Polygon Polar Coordinate Data ===");
        
        for (Polygon poly : polygons) {
            ArrayList<Node> vertices = poly.getVertices();
            
            println("Polygon " + poly.getId() + ":");
            print("  Vertices: {");
            
            for (int i = 0; i < vertices.size(); i++) {
                Node vertex = vertices.get(i);
                PVector pos = vertex.getPosition();
                
                // Calculate polar coordinates
                float radius = sqrt(pos.x * pos.x + pos.y * pos.y);
                float angleDegrees = degrees(atan2(pos.y, pos.x));
                
                // Ensure angle is positive
                if (angleDegrees < 0) {
                    angleDegrees += 360;
                }
                
                // Get node identifier
                String nodeLabel;
                if (vertex.getType().equals("intersection")) {
                    nodeLabel = "I" + vertex.getId();
                } else {
                    nodeLabel = "N" + vertex.getId();
                }
                
                print("(" + nf(radius, 1, 3) + "," + nf(angleDegrees, 1, 1) + ")");
                
                if (i < vertices.size() - 1) {
                    print(",");
                }
            }
            
            println("}");
            
            // Output detailed information for each vertex
            println("  Vertex Details:");
            for (int i = 0; i < vertices.size(); i++) {
                Node vertex = vertices.get(i);
                PVector pos = vertex.getPosition();
                
                float radius = sqrt(pos.x * pos.x + pos.y * pos.y);
                float angleDegrees = degrees(atan2(pos.y, pos.x));
                if (angleDegrees < 0) angleDegrees += 360;
                
                String nodeLabel = vertex.getType().equals("intersection") ? "I" + vertex.getId() : "N" + vertex.getId();
                
                println("    " + nodeLabel + ": r=" + nf(radius, 1, 3) + ", θ=" + nf(angleDegrees, 1, 1) + "°");
            }
            
            println();
        }
        
        println("=== End Detailed Polar Data ===\n");
    }

    // Output concise format for copy-paste
    void printCopyablePolygonData() {
        println("\n=== Copyable Polygon Data ===");
        
        for (Polygon poly : polygons) {
            ArrayList<Node> vertices = poly.getVertices();
            
            print("P" + poly.getId() + " = {");
            
            for (int i = 0; i < vertices.size(); i++) {
                Node vertex = vertices.get(i);
                PVector pos = vertex.getPosition();
                
                float radius = sqrt(pos.x * pos.x + pos.y * pos.y);
                float angleDegrees = degrees(atan2(pos.y, pos.x));
                if (angleDegrees < 0) angleDegrees += 360;
                
                print("(" + nf(radius, 1, 3) + "," + nf(angleDegrees, 1, 1) + ")");
                
                if (i < vertices.size() - 1) {
                    print(", ");
                }
            }
            
            println("};");
        }
        
        println("=== End Copyable Data ===\n");
    }
}