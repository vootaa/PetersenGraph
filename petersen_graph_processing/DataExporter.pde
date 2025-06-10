// Data exporter class
class DataExporter {
  
  // Export to JSON format
  void exportToJSON(PetersenGraph graph, String filename) {
    JSONObject json = new JSONObject();
    
    // Export node data
    JSONArray nodesArray = new JSONArray();
    for (int i = 0; i < graph.nodes.size(); i++) {
      Node node = graph.nodes.get(i);
      JSONObject nodeObj = new JSONObject();
      nodeObj.setInt("index", i);
      nodeObj.setInt("chainId", node.chainId);
      nodeObj.setFloat("x", node.x);
      nodeObj.setFloat("y", node.y);
      nodeObj.setFloat("r", node.r);
      nodeObj.setFloat("g", node.g);
      nodeObj.setFloat("b", node.b);
      nodeObj.setFloat("radius", node.radius);
      nodesArray.setJSONObject(i, nodeObj);
    }
    json.setJSONArray("nodes", nodesArray);
    
    // Export edge data
    JSONArray edgesArray = new JSONArray();
    for (int i = 0; i < graph.edges.size(); i++) {
      Edge edge = graph.edges.get(i);
      JSONObject edgeObj = new JSONObject();
      edgeObj.setInt("index", i);
      edgeObj.setInt("type", edge.type);
      edgeObj.setInt("fromIndex", getNodeIndex(edge.from, graph));
      edgeObj.setInt("toIndex", getNodeIndex(edge.to, graph));
      edgeObj.setInt("fromChainId", edge.from.chainId);
      edgeObj.setInt("toChainId", edge.to.chainId);
      edgeObj.setFloat("r", edge.r);
      edgeObj.setFloat("g", edge.g);
      edgeObj.setFloat("b", edge.b);
      edgeObj.setFloat("thickness", edge.thickness);
      edgesArray.setJSONObject(i, edgeObj);
    }
    json.setJSONArray("edges", edgesArray);
    
    // Save file
    saveJSONObject(json, "data/" + filename);
    println("Graph data exported to: data/" + filename);
  }
  
  // Export to CSV format
  void exportToCSV(PetersenGraph graph, String nodesFile, String edgesFile) {
    // Export nodes CSV
    Table nodesTable = new Table();
    nodesTable.addColumn("index");
    nodesTable.addColumn("chainId");
    nodesTable.addColumn("x");
    nodesTable.addColumn("y");
    nodesTable.addColumn("r");
    nodesTable.addColumn("g");
    nodesTable.addColumn("b");
    nodesTable.addColumn("radius");
    
    for (int i = 0; i < graph.nodes.size(); i++) {
      Node node = graph.nodes.get(i);
      TableRow row = nodesTable.addRow();
      row.setInt("index", i);
      row.setInt("chainId", node.chainId);
      row.setFloat("x", node.x);
      row.setFloat("y", node.y);
      row.setFloat("r", node.r);
      row.setFloat("g", node.g);
      row.setFloat("b", node.b);
      row.setFloat("radius", node.radius);
    }
    
    saveTable(nodesTable, "data/" + nodesFile);
    
    // Export edges CSV
    Table edgesTable = new Table();
    edgesTable.addColumn("index");
    edgesTable.addColumn("type");
    edgesTable.addColumn("fromIndex");
    edgesTable.addColumn("toIndex");
    edgesTable.addColumn("fromChainId");
    edgesTable.addColumn("toChainId");
    edgesTable.addColumn("r");
    edgesTable.addColumn("g");
    edgesTable.addColumn("b");
    edgesTable.addColumn("thickness");
    
    for (int i = 0; i < graph.edges.size(); i++) {
      Edge edge = graph.edges.get(i);
      TableRow row = edgesTable.addRow();
      row.setInt("index", i);
      row.setInt("type", edge.type);
      row.setInt("fromIndex", getNodeIndex(edge.from, graph));
      row.setInt("toIndex", getNodeIndex(edge.to, graph));
      row.setInt("fromChainId", edge.from.chainId);
      row.setInt("toChainId", edge.to.chainId);
      row.setFloat("r", edge.r);
      row.setFloat("g", edge.g);
      row.setFloat("b", edge.b);
      row.setFloat("thickness", edge.thickness);
    }
    
    saveTable(edgesTable, "data/" + edgesFile);
    
    println("Graph data exported to CSV files:");
    println("  Nodes: data/" + nodesFile);
    println("  Edges: data/" + edgesFile);
  }
  
  private int getNodeIndex(Node node, PetersenGraph graph) {
    for (int i = 0; i < graph.nodes.size(); i++) {
      if (graph.nodes.get(i) == node) {
        return i;
      }
    }
    return -1;
  }
}