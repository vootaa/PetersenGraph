PetersenDataReader dataReader;
DataValidator dataValidator;
DataStructureInspector inspector;
AnalysisEngine analysisEngine;
UIRenderer uiRenderer;

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
            
            dataReader.printStatistics();

            println("\nData loaded and validated successfully. Key commands:");
            println("P - Polar coordinate analysis");
            println("G - Polygon component analysis");
            println("A - Complete analysis");
            println("V - Toggle view");
            println("S - Screenshot");
        } else {
            // Data validation failed
            dataValidator.printValidationReport();
            println("\n⚠️  Program halted. Please fix data issues and retry.");
        }
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
        text("Data validation failed or program not properly initialized", width/2, height/2);
        
        if (dataValidator != null && !dataValidator.isValid()) {
            textSize(12);
            text("Error: " + dataValidator.getError(), width/2, height/2 + 30);
            text("Please check JSON data file", width/2, height/2 + 50);
        }
        
    }
}

void keyPressed() {
    if (analysisEngine == null || !dataValidator.isValid()) {
        println("❌ Data not ready, unable to perform analysis");
        return;
    }
    
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