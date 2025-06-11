PetersenDataReader dataReader;
AnalysisEngine analysisEngine;
UIRenderer uiRenderer;

void setup() {
    size(1200, 800);
    
    // Initialize data reader
    dataReader = new PetersenDataReader();
    
    // Load Petersen graph data
    if (dataReader.loadFromFile("../data/petersen_graph_static_data_2025611_9258.json")) {
        // Create analysis engine
        analysisEngine = new AnalysisEngine(dataReader);
        
        // Create UI renderer
        uiRenderer = new UIRenderer();
        
        // Print data summary
        dataReader.printStatistics();
        
        println("\nData loaded successfully. Key commands:");
        println("P - Polar coordinate analysis");
        println("E - Edge analysis");
        println("V - Toggle view (standard/symmetric)");
        println("S - Save screenshot");
        println("+ - Zoom in");
        println("- - Zoom out");
        
    } else {
        println("Data loading failed, please check file path: ../data/petersen_graph_static_data_2025611_9258.json");
    }
}

void draw() {
    background(50);
    
    if (analysisEngine != null && uiRenderer != null) {
        uiRenderer.renderAnalysis(analysisEngine);
    } else {
        // Show error message
        fill(255, 0, 0);
        textAlign(CENTER);
        textSize(16);
        text("Data loading failed", width/2, height/2);
        text("Please ensure ../data/petersen_graph_static_data_2025611_9258.json file exists", width/2, height/2 + 20);
    }
}

void keyPressed() {
    if (analysisEngine == null) return;
    
    switch (key) {
        case 'p':
        case 'P':
            // Polar coordinate analysis
            analysisEngine.performPolarAnalysis();
            break;
            
        case 'g':
        case 'G':
            // Polygon component analysis
            analysisEngine.performPolygonAnalysis();
            break;
            
        case 'a':
        case 'A':
            // Complete analysis
            analysisEngine.performCompleteAnalysis();
            break;
            
        case 'v':
        case 'V':
            // Toggle symmetry view
            if (uiRenderer != null) {
                uiRenderer.toggleSymmetryView();
            }
            break;
            
        case 's':
        case 'S':
            // Save screenshot
            String timestamp = year() + nf(month(), 2) + nf(day(), 2) + "_" + 
                              nf(hour(), 2) + nf(minute(), 2) + nf(second(), 2);
            saveFrame("../exports/petersen_graph_static_data_analysis_" + timestamp + ".png");
            println("Screenshot saved: petersen_static_data_analysis_" + timestamp + ".png");
            break;
            
        default:
            println("Available keys:");
            println("P - Polar coordinate analysis");
            println("G - Polygon component analysis");
            println("A - Complete analysis");
            println("V - Toggle view");
            println("S - Screenshot");
    }
}