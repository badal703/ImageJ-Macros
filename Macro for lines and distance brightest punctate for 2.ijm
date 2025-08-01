// Create results table for distance measurements
run("Clear Results");
setResult("ROI", 0, "ROI");
setResult("Distance_pixels", 0, "Distance (pixels)");
setResult("Distance_um", 0, "Distance (µm)");
updateResults();

// Get pixel size for distance conversion
getPixelSize(unit, pixelWidth, pixelHeight);

for (i = 0; i < 20; i++) {
    // Initialize variables for brightest points
    maxC1 = 0;
    maxC2 = 0;
    maxC1_pos = 0;
    maxC2_pos = 0;
    
    // Plot profile for C2 and find brightest point
    selectImage("C2-frame_t_0.ets - CF488, CF561");
    roiManager("Select", i);
    run("Plot Profile");
    
    // Get plot values for C2
    Plot.getValues(xValues_C2, yValues_C2);
    
    // Find maximum intensity position in C2
    for (j = 0; j < yValues_C2.length; j++) {
        if (yValues_C2[j] > maxC2) {
            maxC2 = yValues_C2[j];
            maxC2_pos = j;
        }
    }
    
    // Store C2 plot window name
    c2PlotName = getTitle();
    
    // Plot profile for C1 and find brightest point
    selectImage("C1-frame_t_0.ets - CF488, CF561");
    roiManager("Select", i);
    run("Plot Profile");
    
    // Get plot values for C1
    Plot.getValues(xValues_C1, yValues_C1);
    
    // Find maximum intensity position in C1
    for (j = 0; j < yValues_C1.length; j++) {
        if (yValues_C1[j] > maxC1) {
            maxC1 = yValues_C1[j];
            maxC1_pos = j;
        }
    }
    
    // Store C1 plot window name
    c1PlotName = getTitle();
    
    // Calculate distance between brightest points
    distance_pixels = abs(maxC1_pos - maxC2_pos);
    distance_um = distance_pixels * pixelWidth;
    
    // Store distance measurements in results table
    setResult("ROI", i, i);
    setResult("Distance_pixels", i, distance_pixels);
    setResult("Distance_um", i, distance_um);
    setResult("C1_Max_Intensity", i, maxC1);
    setResult("C2_Max_Intensity", i, maxC2);
    setResult("C1_Max_Position", i, maxC1_pos);
    setResult("C2_Max_Position", i, maxC2_pos);
    updateResults();
    
    // Merge channels
    run("Merge Channels...", "c1=[" + c2PlotName + "] c2=[" + c1PlotName + "] create");
    
    // Save merged image
    saveAs("Tiff", "F:/temp for copy/Folder_20250709/Composite " + i + ".tif");
    
    // Close merged image
    close();
    
    // Print distance information to log
    print("ROI " + i + ": Distance between brightest punctate = " + distance_pixels + " pixels (" + distance_um + " " + unit + ")");
}

// Save results table
saveAs("Results", "F:/temp for copy/Folder_20250709/_unc-101 gfp sam-4 mscarlet 200 expo 10 % 488 20% 561 w2_Multichannel Z-Stack_20250709_11247current_/stack1/Distance_Measurements.csv");

// Display summary statistics
Array.getStatistics(newArray(), distance_mean, distance_min, distance_max, distance_std);
print("Summary Statistics:");
print("Mean distance: " + distance_mean + " " + unit);
print("Min distance: " + distance_min + " " + unit);
print("Max distance: " + distance_max + " " + unit);
print("Std deviation: " + distance_std + " " + unit);