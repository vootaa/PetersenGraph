PetersenDataReader dataReader;
DataValidator dataValidator;
DataStructureInspector inspector;
AnalysisEngine analysisEngine;
UIRenderer uiRenderer;
StaticDataReader staticDataReader;

void setup() {
    size(1200, 800);
    
    // Initialize data reader
    dataReader = new PetersenDataReader();
    
    // Load Petersen graph data
    if (dataReader.loadFromFile("../data/petersen_graph_static_data_2025611_9258.json")) {
        // First, inspect the data structure
        inspector = new DataStructureInspector(dataReader);
        inspector.inspectDataStructures();

        // Then validate data
        dataValidator = new DataValidator(dataReader);

        if (dataValidator.validateData()) {
            // Data is valid, proceed with analysis
            analysisEngine = new AnalysisEngine(dataReader);
            uiRenderer = new UIRenderer();
            
            // Initialize static polygon data
            staticDataReader = new StaticDataReader();
            staticDataReader.linkWithAnalysisEngine(analysisEngine);
            uiRenderer.setStaticDataReader(staticDataReader);
            
            dataReader.printStatistics();

            println("\nData loaded and validated successfully. Key commands:");
            println("P - Toggle polygon view");
            println("R - Toggle rotated copies (in polygon view)");
            println("O - Output polygon polar coordinate data");
            println("+ / - - Zoom in/out");
            println("0 - Reset zoom");
            println("S - Save screenshot");
            println("D - Debug unmatched segments");
            
        } else {
            println("❌ Data validation failed: " + dataValidator.getError());
        }
    } else {
        println("❌ Failed to load data file");
    }
}

void draw() {
    background(30);
    
    if (analysisEngine != null && uiRenderer != null && dataValidator.isValid()) {
        // Render the analysis
        uiRenderer.renderAnalysis(analysisEngine);
    } else {
        // Show error message
        fill(255);
        textAlign(CENTER);
        textSize(16);
        text("Failed to load or validate Petersen graph data", width/2, height/2);
        
        if (dataValidator != null && !dataValidator.isValid()) {
            text("Error: " + dataValidator.getError(), width/2, height/2 + 30);
            text("Please check JSON data file", width/2, height/2 + 50);
        }
    }
}

void keyPressed() {
    if (analysisEngine == null || !dataValidator.isValid()) {
        println("❌ Data not ready, unable to perform operations");
        return;
    }
    
    switch (key) {
        case 'p':
        case 'P':
            // Toggle polygon view
            if (uiRenderer != null) {
                uiRenderer.togglePolygonView();
            }
            break;
            
        case 'r':
        case 'R':
            // Toggle rotated copies
            if (uiRenderer != null) {
                uiRenderer.toggleRotatedCopies();
            }
            break;
            
        case 'o':
        case 'O':
            // Output polygon polar coordinate data
            if (staticDataReader != null) {
                staticDataReader.printPolygonPolarData();
                staticDataReader.printDetailedPolygonPolarData();
                staticDataReader.printCopyablePolygonData();
            } else {
                println("❌ Static polygon data not available");
            }
            break;
            
        case 's':
        case 'S':
            // Save screenshot
            String timestamp = year() + nf(month(), 2) + nf(day(), 2) + "_" + 
                              nf(hour(), 2) + nf(minute(), 2) + nf(second(), 2);
            saveFrame("../exports/petersen_graph_polygon_view_" + timestamp + ".png");
            println("Screenshot saved: petersen_polygon_view_" + timestamp + ".png");
            break;
            
        case '+':
        case '=':
            // Zoom in
            if (uiRenderer != null) {
                uiRenderer.adjustScale(1.2);
            }
            break;
            
        case '-':
        case '_':
            // Zoom out
            if (uiRenderer != null) {
                uiRenderer.adjustScale(0.8);
            }
            break;
            
        case '0':
            // Reset zoom to default
            if (uiRenderer != null) {
                uiRenderer.scale = 600; // Reset to default scale
            }
            break;
            
        case 'd':
        case 'D':
            // Debug - show unmatched segments
            if (analysisEngine != null) {
                analysisEngine.debugUnmatchedSegments();
            }
            break;
           
        default:
            println("Available keys:");
            println("P - Toggle polygon view");
            println("R - Toggle rotated copies");
            println("O - Output polygon polar data");
            println("S - Screenshot");
            println("+ - Zoom in");
            println("- - Zoom out");
            println("0 - Reset zoom");
            println("D - Debug unmatched segments");
    }
}