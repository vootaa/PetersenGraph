// Data exporter class
class DataExporter {
  JSONObject config;
  String outputDirectory;
  
  DataExporter(JSONObject config) {
    this.config = config;
    // Read output directory from config, with fallback
    JSONObject exportConfig = config.getJSONObject("export");
    this.outputDirectory = exportConfig.getString("outputDirectory");
    
    // Ensure directory ends with slash
    if (!this.outputDirectory.endsWith("/")) {
      this.outputDirectory += "/";
    }
    
    println("Export directory set to: " + this.outputDirectory);
  }
  
  // Export to JSON format
  void exportToJSON(PetersenGraph graph, String filename) {
    // Check if JSON export is enabled
    JSONObject exportConfig = config.getJSONObject("export");
    JSONObject fileFormats = exportConfig.getJSONObject("fileFormats");
    if (!fileFormats.getBoolean("json")) {
      println("JSON export is disabled in configuration");
      return;
    }
    
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

    // Export intersection data
    JSONArray intersectionsArray = new JSONArray();
    ArrayList<Intersection> intersections = graph.getIntersections();
    for (int i = 0; i < intersections.size(); i++) {
      Intersection intersection = intersections.get(i);
      JSONObject intersectionObj = new JSONObject();
      intersectionObj.setInt("intersectionId", intersection.intersectionId);
      intersectionObj.setFloat("x", intersection.x);
      intersectionObj.setFloat("y", intersection.y);
      intersectionObj.setInt("edge1Id", intersection.edge1Id);
      intersectionObj.setInt("edge2Id", intersection.edge2Id);
      intersectionObj.setFloat("r", intersection.r);
      intersectionObj.setFloat("g", intersection.g);
      intersectionObj.setFloat("b", intersection.b);
      intersectionObj.setFloat("radius", intersection.radius);
      intersectionsArray.setJSONObject(i, intersectionObj);
    }
    json.setJSONArray("intersections", intersectionsArray);
    
    // Save file with configured directory
    String fullPath = outputDirectory + filename;
    saveJSONObject(json, fullPath);
    println("Graph data exported to: " + fullPath);
    println("  Nodes: " + graph.nodes.size());
    println("  Edges: " + graph.edges.size());
    println("  Intersections: " + intersections.size());
  }
  
  // Export to CSV format
  void exportToCSV(PetersenGraph graph, String nodesFile, String edgesFile, String intersectionsFile) {
    // Check if CSV export is enabled
    JSONObject exportConfig = config.getJSONObject("export");
    JSONObject fileFormats = exportConfig.getJSONObject("fileFormats");
    if (!fileFormats.getBoolean("csv")) {
      println("CSV export is disabled in configuration");
      return;
    }
    
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
    
    String nodesPath = outputDirectory + nodesFile;
    saveTable(nodesTable, nodesPath);
    
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

    String edgesPath = outputDirectory + edgesFile;
    saveTable(edgesTable, edgesPath);

    // Export intersections CSV
    Table intersectionsTable = new Table();
    intersectionsTable.addColumn("intersectionId");
    intersectionsTable.addColumn("x");
    intersectionsTable.addColumn("y");
    intersectionsTable.addColumn("edge1Id");
    intersectionsTable.addColumn("edge2Id");
    intersectionsTable.addColumn("r");
    intersectionsTable.addColumn("g");
    intersectionsTable.addColumn("b");
    intersectionsTable.addColumn("radius");
    
    ArrayList<Intersection> intersections = graph.getIntersections();
    for (int i = 0; i < intersections.size(); i++) {
      Intersection intersection = intersections.get(i);
      TableRow row = intersectionsTable.addRow();
      row.setInt("intersectionId", intersection.intersectionId);
      row.setFloat("x", intersection.x);
      row.setFloat("y", intersection.y);
      row.setInt("edge1Id", intersection.edge1Id);
      row.setInt("edge2Id", intersection.edge2Id);
      row.setFloat("r", intersection.r);
      row.setFloat("g", intersection.g);
      row.setFloat("b", intersection.b);
      row.setFloat("radius", intersection.radius);
    }

    String intersectionsPath = outputDirectory + intersectionsFile;
    saveTable(intersectionsTable, intersectionsPath);
    
    println("Graph data exported to CSV files:");
    println("  Nodes: " + nodesPath);
    println("  Edges: " + edgesPath);
    println("  Intersections: " + intersectionsPath);
  }
  
  // Get export directory for external use
  String getOutputDirectory() {
    return outputDirectory;
  }
  
  // Set custom output directory (overrides config)
  void setOutputDirectory(String directory) {
    this.outputDirectory = directory;
    if (!this.outputDirectory.endsWith("/")) {
      this.outputDirectory += "/";
    }
    println("Export directory changed to: " + this.outputDirectory);
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