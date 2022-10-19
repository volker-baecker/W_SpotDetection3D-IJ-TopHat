// Author: Sébastien Tosi (IRB Barcelona)
// Version: 1.1
// Date: 21/04/2017

// Path to input image and result table
inputDir = "/media/baecker/DONNEES/mri/2019/neubias/data";
outputDir = "/media/baecker/DONNEES/mri/2019/neubias/out";

// Functional parameters
ij_radius = 2.5;
ij_threshold = -2;

arg = getArgument();
parts = split(arg, ",");

setBatchMode(true);

for(i=0; i<parts.length; i++) {
	nameAndValue = split(parts[i], "=");
	if (indexOf(nameAndValue[0], "input")>-1) inputDir=nameAndValue[1];
	if (indexOf(nameAndValue[0], "output")>-1) outputDir=nameAndValue[1];
	if (indexOf(nameAndValue[0], "radius")>-1) ij_radius=nameAndValue[1];
	if (indexOf(nameAndValue[0], "threshold")>-1) ij_threshold=nameAndValue[1];
}

images = getFileList(inputDir);

for(i=0; i<images.length; i++) {
	image = images[i];
	if (endsWith(image, ".tif")) {
		// Open image
		open(inputDir + "/" + image);
		run("Set Scale...", "distance=0 known=0 pixel=1 unit=pixel");
		
		// Processing
		run("Set Measurements...", "  center stack redirect=None decimal=2");
		run("FeatureJ Laplacian", "compute smoothing="+d2s(ij_radius,2));
		rename("Flt");
		run("Minimum (3D)");
		rename("Min");
		imageCalculator("Subtract create stack", "Flt","Min");
		setThreshold(0, 0);
		run("Convert to Mask", "method=Default background=Dark");
		rename("Msk");
		selectImage("Flt");
		setThreshold(-9999, ij_threshold);
		run("Convert to Mask", "method=Default background=Dark");
		imageCalculator("And stack", "Flt","Msk");
		run("Analyze Particles...", "display clear stack");
		
		// Export results
		save(outputDir + "/" + image);
		
		// Cleanup
		run("Close All");
		if(isOpen("Results"))
		{
			selectWindow("Results");
			run("Close");
		}
	}
}
run("Quit");
