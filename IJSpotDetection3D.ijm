// Path to input image and output mask
inputDir = "/home/baecker/Documents/mri/2022/neubias/data/";
outputDir = "/home/baecker/Documents/mri/2022/neubias/out/";

// Functional parameters
noise_filter_radius_xy = 1;
noise_filter_radius_z = 0.5;
top_hat_radius_xy = 7.5;
top_hat_radius_z = 3.5;
dynamic = 75;
connectivity = 6;

// Read command-line parameters, if any
arg = getArgument();
parts = split(arg, ",");

for(i=0; i<parts.length; i++) {
    nameAndValue = split(parts[i], "=");
    if (indexOf(nameAndValue[0], "input") > -1) inputDir = nameAndValue[1];
    if (indexOf(nameAndValue[0], "output") > -1) outputDir = nameAndValue[1];
    if (indexOf(nameAndValue[0], "filter_xy") > -1) noise_filter_radius_xy = nameAndValue[1];
    if (indexOf(nameAndValue[0], "filter_z") > -1) noise_filter_radius_z = nameAndValue[1];
    if (indexOf(nameAndValue[0], "top_hat_xy") > -1) top_hat_radius_xy = nameAndValue[1];
    if (indexOf(nameAndValue[0], "top_hat_z") > -1) top_hat_radius_z = nameAndValue[1];
    if (indexOf(nameAndValue[0], "dynamic") > -1) dynamic = nameAndValue[1];
    if (indexOf(nameAndValue[0], "connectivity") > -1) connectivity  = nameAndValue[1];
}

// batch process images in the input folder
setBatchMode(true);
images = getFileList(inputDir);
for(i=0; i<images.length; i++) {
    image = images[i];
    if (!endsWith(image, ".tif")) continue;
    open(inputDir + "/" + image);
    
    // the bio-image analysis workflow
    run("Set Scale...", "distance=0 known=0 pixel=1 unit=pixel");
    getDimensions(width, height, channels, slices, frames);
    Stack.setSlice(1);
    run("Select All");
    run("Clear", "slice");
    Stack.setSlice(slices);
    run("Clear", "slice");
    run("Select None");
    run("Median 3D...", "x="+noise_filter_radius_xy+" y="+noise_filter_radius_xy+" z="+noise_filter_radius_z);
    run("Morphological Filters (3D)", "operation=[White Top Hat] element=Cube x-radius="+top_hat_radius_xy+" y-radius="+top_hat_radius_xy+" z-radius="+top_hat_radius_z);
    run("Extended Min & Max 3D", "operation=[Extended Maxima] dynamic="+dynamic+" connectivity="+connectivity);
    run("Connected Components Labeling", "connectivity="+connectivity+" type=[16 bits]");
    run("Analyze Regions 3D", "centroid surface_area_method=[Crofton (13 dirs.)] euler_connectivity=6");
    
    // Create the output image
    columnNames = split(Table.headings, "\t");
    X = Table.getColumn(columnNames[1]);
    Y = Table.getColumn(columnNames[2]);
    Z = Table.getColumn(columnNames[3]);
    Table.sort(columnNames[3]);
    run("Select All");
    run("Clear", "stack");
    run("Select None");
    
    for (c = 0; c < X.length; c++) {
        x = X[c];
        y = Y[c];
        z = Z[c];
        Stack.setSlice(z);
        setPixel(x, y, 65535);
    }
    
    // Export results
    title = getTitle();
    save(outputDir + "/" + image);
        
    // Cleanup
    run("Close All");
    close(title + "-morpho");
}

// Quit the jvm process
run("Quit");
