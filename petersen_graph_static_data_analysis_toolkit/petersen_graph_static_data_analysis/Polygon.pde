class PolygonComponent {
    ArrayList<Node> vertices;
    ArrayList<Edge> edges;
    int componentId;
    
    PolygonComponent(int id) {
        this.componentId = id;
        this.vertices = new ArrayList<Node>();
        this.edges = new ArrayList<Edge>();
    }
    
    void addVertex(Node vertex) {
        if (!vertices.contains(vertex)) {
            vertices.add(vertex);
        }
    }
    
    void addEdge(Edge edge) {
        if (!edges.contains(edge)) {
            edges.add(edge);
            addVertex(edge.getStartNode());
            addVertex(edge.getEndNode());
        }
    }
    
    int getVertexCount() { return vertices.size(); }
    int getEdgeCount() { return edges.size(); }
    int getId() { return componentId; }
    
    ArrayList<Node> getVertices() { return vertices; }
    ArrayList<Edge> getEdges() { return edges; }
    
    // Check if this is a closed polygon
    boolean isClosed() {
        return vertices.size() == edges.size() && vertices.size() >= 3;
    }
    
    // Get component type description
    String getTypeDescription() {
        if (isClosed()) {
            return vertices.size() + "-边形";
        } else {
            return "开放路径(" + vertices.size() + "点" + edges.size() + "边)";
        }
    }
}

class PolygonAnalysis {
    ArrayList<Node> nodes;
    ArrayList<Edge> edges;
    ArrayList<PolygonComponent> components;
    HashMap<Integer, ArrayList<PolygonComponent>> symmetryComponents;
    
    PolygonAnalysis(ArrayList<Node> nodes, ArrayList<Edge> edges) {
        this.nodes = nodes;
        this.edges = edges;
        this.components = new ArrayList<PolygonComponent>();
        this.symmetryComponents = new HashMap<Integer, ArrayList<PolygonComponent>>();
    }
    
    // Main polygon analysis
    void performAnalysis() {
        println("\n=== 多边形组件分析 ===");
        
        // Group edges by parent edge (original edge before segmentation)
        HashMap<Integer, ArrayList<Edge>> parentGroups = groupEdgesByParent();
        
        // Analyze each parent edge group as potential polygon component
        analyzeParentGroups(parentGroups);
        
        // Check for 5-fold symmetry in components
        analyzeComponentSymmetry();
        
        // Output structured results
        outputPolygonResults();
        
        // Verify total segment count
        verifySegmentCount();
    }
    
    // Group edges by parent edge ID
    HashMap<Integer, ArrayList<Edge>> groupEdgesByParent() {
        HashMap<Integer, ArrayList<Edge>> parentGroups = new HashMap<Integer, ArrayList<Edge>>();
        
        for (Edge edge : edges) {
            int parentId = edge.getType(); // Type represents parent edge ID
            if (!parentGroups.containsKey(parentId)) {
                parentGroups.put(parentId, new ArrayList<Edge>());
            }
            parentGroups.get(parentId).add(edge);
        }
        
        return parentGroups;
    }
    
    // Analyze each parent group as polygon component
    void analyzeParentGroups(HashMap<Integer, ArrayList<Edge>> parentGroups) {
        components.clear();
        
        ArrayList<Integer> sortedParents = new ArrayList<Integer>(parentGroups.keySet());
        Collections.sort(sortedParents);
        
        for (Integer parentId : sortedParents) {
            ArrayList<Edge> groupEdges = parentGroups.get(parentId);
            
            PolygonComponent component = new PolygonComponent(parentId);
            for (Edge edge : groupEdges) {
                component.addEdge(edge);
            }
            
            components.add(component);
        }
    }
    
    // Analyze component symmetry
    void analyzeComponentSymmetry() {
        symmetryComponents.clear();
        
        for (PolygonComponent component : components) {
            // Determine which symmetry group this component belongs to
            int symmetryGroup = getComponentSymmetryGroup(component);
            
            if (!symmetryComponents.containsKey(symmetryGroup)) {
                symmetryComponents.put(symmetryGroup, new ArrayList<PolygonComponent>());
            }
            symmetryComponents.get(symmetryGroup).add(component);
        }
    }
    
    // Determine symmetry group based on component's angular position
    int getComponentSymmetryGroup(PolygonComponent component) {
        // Calculate average angle of component's vertices
        float totalAngle = 0;
        int count = 0;
        
        for (Node vertex : component.getVertices()) {
            totalAngle += vertex.getNormalizedAngleDegrees();
            count++;
        }
        
        if (count == 0) return 0;
        
        float avgAngle = totalAngle / count;
        return (int)(avgAngle / 72.0) % 5;
    }
    
    // Output polygon analysis results
    void outputPolygonResults() {
        println("\n--- 多边形组件结构化输出 ---");
        
        // Output individual components
        println("\n// 多边形组件数据");
        println("polygonComponents = {");
        
        for (int i = 0; i < components.size(); i++) {
            PolygonComponent comp = components.get(i);
            
            print("  component" + comp.getId() + ": {");
            print("vertices: [");
            
            ArrayList<Node> vertices = comp.getVertices();
            sortNodesByID(vertices);
            for (int j = 0; j < vertices.size(); j++) {
                print(vertices.get(j).getId());
                if (j < vertices.size() - 1) print(", ");
            }
            
            print("], edges: " + comp.getEdgeCount());
            print(", type: \"" + comp.getTypeDescription() + "\"");
            print("}");
            
            if (i < components.size() - 1) print(",");
            println();
        }
        println("};");
        
        // Output symmetry groups
        println("\n// 对称组件分布");
        println("symmetryComponentGroups = {");
        
        for (int group = 0; group < 5; group++) {
            print("  group" + group + ": [");
            
            if (symmetryComponents.containsKey(group)) {
                ArrayList<PolygonComponent> groupComps = symmetryComponents.get(group);
                for (int j = 0; j < groupComps.size(); j++) {
                    print("component" + groupComps.get(j).getId());
                    if (j < groupComps.size() - 1) print(", ");
                }
            }
            
            print("]");
            if (group < 4) print(",");
            println();
        }
        println("};");
    }
    
    // Verify segment count
    void verifySegmentCount() {
        println("\n--- 段数量验证 ---");
        
        int totalSegments = 0;
        for (PolygonComponent comp : components) {
            totalSegments += comp.getEdgeCount();
        }
        
        println("总段数: " + totalSegments);
        println("期望段数: 70");
        println("验证结果: " + (totalSegments == 70 ? "✓" : "✗"));
        
        if (totalSegments % 5 == 0) {
            println("可平均分为5组: ✓ (每组 " + (totalSegments / 5) + " 段)");
        } else {
            println("无法平均分为5组: ✗");
        }
        
        // Component distribution analysis
        println("\n组件分布:");
        for (PolygonComponent comp : components) {
            println("组件" + comp.getId() + ": " + comp.getEdgeCount() + "段, " + 
                   comp.getTypeDescription());
        }
    }
    
    // Helper method to sort nodes by ID
    void sortNodesByID(ArrayList<Node> nodeList) {
        for (int i = 0; i < nodeList.size() - 1; i++) {
            for (int j = i + 1; j < nodeList.size(); j++) {
                if (nodeList.get(i).getId() > nodeList.get(j).getId()) {
                    Node temp = nodeList.get(i);
                    nodeList.set(i, nodeList.get(j));
                    nodeList.set(j, temp);
                }
            }
        }
    }
    
    // Get components in a specific symmetry group
    ArrayList<PolygonComponent> getSymmetryGroupComponents(int group) {
        return symmetryComponents.get(group);
    }
    
    // Get all components
    ArrayList<PolygonComponent> getAllComponents() {
        return components;
    }
    
    // Get component by ID
    PolygonComponent getComponent(int id) {
        for (PolygonComponent comp : components) {
            if (comp.getId() == id) {
                return comp;
            }
        }
        return null;
    }
}