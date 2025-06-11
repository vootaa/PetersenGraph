# Petersen Graph Static Data Analysis

## 项目概述
Petersen Graph Static Data Analysis 是一个用于分析和可视化 Petersen 图的工具。该项目提供了对极坐标数据的静态分析、对称性分析以及相应的用户界面展示。

## 文件结构
```
petersen_graph_static_data_analysis
├── src
│   ├── petersen_graph_static_data_analysis.pde        # 应用程序的主入口
│   ├── DataLoader.pde                                   # 数据加载和解析模块
│   ├── AnalysisEngine.pde                               # 数据分析引擎
│   ├── UIRenderer.pde                                   # 用户界面渲染模块
│   ├── PolarAnalysis.pde                                # 极坐标数据分析功能
│   ├── SymmetryAnalysis.pde                             # 对称性分析功能
│   └── types
│       ├── Node.pde                                     # 节点类定义
│       ├── Edge.pde                                     # 边类定义
│       └── Polygon.pde                                  # 多边形类定义
├── data
│   └── README.md                                        # 数据使用说明
├── exports
│   └── README.md                                        # 导出功能说明
└── README.md                                            # 项目文档
```

## 安装与使用
1. **克隆项目**
   ```
   git clone <repository-url>
   cd petersen_graph_static_data_analysis
   ```

2. **运行应用**
   使用支持 Processing 的 IDE 打开 `src/petersen_graph_static_data_analysis.pde` 文件并运行。

3. **数据格式**
   数据应以 JSON 格式存储在 `data` 文件夹中，具体格式和示例请参见 `data/README.md`。

## 功能
- **数据加载**: 使用 `DataLoader` 类从 JSON 文件中加载数据。
- **数据分析**: 
  - `PolarAnalysis` 提供极坐标数据的静态分析。
  - `SymmetryAnalysis` 检查边段是否可以组合成多边形，并评估其旋转对称性。
- **用户界面**: `UIRenderer` 类负责绘制图形和数据显示。

## 贡献
欢迎任何形式的贡献！请提交问题或拉取请求。

## 许可证
本项目遵循 MIT 许可证。