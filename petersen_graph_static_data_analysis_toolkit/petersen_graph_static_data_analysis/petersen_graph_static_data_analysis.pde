PetersenDataReader dataReader;
AnalysisEngine analysisEngine;
UIRenderer uiRenderer;

void setup() {
    size(1200, 800);
    
    // Initialize data reader
    dataReader = new PetersenDataReader();
    
    // Load Petersen graph data
    if (dataReader.loadFromFile("data/petersen_static_data_2025611_9258.json")) {
        // Create analysis engine
        analysisEngine = new AnalysisEngine(dataReader);
        
        // Create UI renderer
        uiRenderer = new UIRenderer();
        
        // Print data summary
        dataReader.printStatistics();
        
        println("\n数据加载完成，按键说明:");
        println("P - 极坐标分析");
        println("E - 边分析");
        println("V - 切换视图(标准/对称)");
        println("S - 保存截图");
        println("+ - 放大");
        println("- - 缩小");
        
    } else {
        println("数据加载失败，请检查文件路径: data/petersen_static_data_2025611_9258.json");
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
        text("数据加载失败", width/2, height/2);
        text("请确保 data/petersen_static_data_latest.json 文件存在", width/2, height/2 + 20);
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
            saveFrame("exports/petersen_analysis_" + timestamp + ".png");
            println("截图已保存: petersen_analysis_" + timestamp + ".png");
            break;
            
        default:
            println("可用按键:");
            println("P - 极坐标分析");
            println("G - 多边形组件分析");
            println("A - 完整分析");
            println("V - 切换视图");
            println("S - 截图");
    }
}