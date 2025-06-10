// petersen_graph_processing.pde

PetersenGraph petersenGraph;
GraphRenderer renderer;
JSONObject config;

void setup() {
  size(800, 800);
  
  // Load configuration from data folder
  config = loadJSONObject("config.json");
  
  petersenGraph = new PetersenGraph(config);
  renderer = new GraphRenderer(petersenGraph);
}

void draw() {
  // Get background color from config
  JSONArray bgColor = config.getJSONObject("backgroundColor").getJSONArray("rgb");
  background(bgColor.getInt(0), bgColor.getInt(1), bgColor.getInt(2));
  
  renderer.render();
}
