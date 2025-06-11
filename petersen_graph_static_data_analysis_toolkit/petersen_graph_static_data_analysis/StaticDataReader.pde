class StaticDataReader {
    ArrayList<Polygon> polygons;
    ArrayList<Node> nodes;
    ArrayList<Node> intersections;
    
    StaticDataReader() {
        polygons = new ArrayList<Polygon>();
        nodes = new ArrayList<Node>();
        intersections = new ArrayList<Node>();
    }
    
    // 从AnalysisEngine获取节点
    void linkWithAnalysisEngine(AnalysisEngine engine) {
        HashMap<String, Node> nodeMap = new HashMap<String, Node>();
        
        // 构建节点映射表
        for (Node node : engine.getNodes()) {
            String key;
            if (node.getType().equals("intersection")) {
                key = "I" + node.getId();
            } else {
                key = "N" + node.getId();
            }
            nodeMap.put(key, node);
        }
        
        // 创建多边形，使用真实坐标
        createPolygon1(nodeMap);
        createPolygon2(nodeMap);
        createPolygon3(nodeMap);
        createPolygon4(nodeMap);
        createPolygon5(nodeMap);
        createPolygon6(nodeMap);
        
        println("Linked " + polygons.size() + " polygons with real coordinates");
    }
    
    void createPolygon1(HashMap<String, Node> nodeMap) {
        // {I1010, I1011, N6}
        ArrayList<Node> vertices = new ArrayList<Node>();
        addVertex(vertices, "I1010", nodeMap);
        addVertex(vertices, "I1011", nodeMap);
        addVertex(vertices, "N6", nodeMap);
        
        if (vertices.size() == 3) {
            Polygon poly = new Polygon(1, vertices);
            poly.setColor(color(255, 100, 100, 150)); // 红色填充
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
            poly.setColor(color(100, 255, 100, 150)); // 绿色填充
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
            poly.setColor(color(100, 100, 255, 150)); // 蓝色填充
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
            poly.setColor(color(255, 255, 100, 150)); // 黄色填充
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
            poly.setColor(color(255, 100, 255, 150)); // 洋红色填充
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
            poly.setColor(color(100, 255, 255, 150)); // 青色填充
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
    
    // 创建旋转后的多边形集合
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
        
        // 旋转坐标
        float angleRad = radians(angleDegrees);
        float newX = pos.x * cos(angleRad) - pos.y * sin(angleRad);
        float newY = pos.x * sin(angleRad) + pos.y * cos(angleRad);
        
        // 创建新节点（保持原ID和类型）
        Node rotatedNode = new Node(originalNode.getId(), new PVector(newX, newY), originalNode.getType());
        return rotatedNode;
    }
}