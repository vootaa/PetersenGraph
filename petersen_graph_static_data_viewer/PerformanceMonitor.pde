class PerformanceMonitor {
  private HashMap<String, Long> startTimes;
  private HashMap<String, ArrayList<Long>> results;
  
  PerformanceMonitor() {
    startTimes = new HashMap<String, Long>();
    results = new HashMap<String, ArrayList<Long>>();
  }
  
  void startTiming(String operation) {
    startTimes.put(operation, System.nanoTime());
  }
  
  long endTiming(String operation) {
    Long startTime = startTimes.get(operation);
    if (startTime == null) {
      println("Warning: No start time found for operation: " + operation);
      return 0;
    }
    
    long endTime = System.nanoTime();
    long duration = endTime - startTime;
    float milliseconds = duration / 1000000.0;
    
    // Record results
    if (!results.containsKey(operation)) {
      results.put(operation, new ArrayList<Long>());
    }
    results.get(operation).add(duration);
    
    println("Performance: " + operation + " took " + nf(milliseconds, 0, 3) + " ms");
    return duration;
  }
  
  void printSummary() {
    println("\n=== Performance Summary ===");
    for (String operation : results.keySet()) {
      ArrayList<Long> times = results.get(operation);
      if (times.size() > 0) {
        long total = 0;
        for (Long time : times) {
          total += time;
        }
        float avgMs = (total / times.size()) / 1000000.0;
        println(operation + ": " + times.size() + " runs, avg " + nf(avgMs, 0, 3) + " ms");
      }
    }
    
    printMemoryUsage();
  }
  
  void printMemoryUsage() {
    Runtime runtime = Runtime.getRuntime();
    long totalMemory = runtime.totalMemory();
    long freeMemory = runtime.freeMemory();
    long usedMemory = totalMemory - freeMemory;
    
    println("Memory Usage: " + (usedMemory / 1024 / 1024) + " MB used, " + 
            (freeMemory / 1024 / 1024) + " MB free");
  }
}