// petersen_graph_processing.pde

PetersenGraph petersenGraph;
DataExporter dataExporter;
GraphRenderer renderer;
DebugModule debugModule;
JSONObject config;

void setup() {
  size(800, 800);
  
  // Load configuration from data folder
  config = loadJSONObject("config.json");
  
  petersenGraph = new PetersenGraph(config);
  renderer = new GraphRenderer(petersenGraph);
  dataExporter = new DataExporter();
  debugModule = new DebugModule();

  // Initialize debug functionality
  debugModule.initialize(petersenGraph);
}

void draw() {
  // Get background color from config
  JSONArray bgColor = config.getJSONObject("backgroundColor").getJSONArray("rgb");
  background(bgColor.getInt(0), bgColor.getInt(1), bgColor.getInt(2));
  
  renderer.render();

  // Render debug information
  debugModule.renderDebugInfo(petersenGraph);
}

void keyPressed() {
  // Delegate keyboard handling to debug module
  debugModule.handleKeyPressed(petersenGraph);
}