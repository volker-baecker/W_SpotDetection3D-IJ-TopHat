noise_filter_radius_xy = 1;
noise_filter_radius_z = 0.5;
top_hat_radius_xy = 7.5;
top_hat_radius_z = 3.5;
dynamic = 75;
connectivity = 6;

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
columnNames = split(Table.headings, "\t");
X = Table.getColumn(columnNames[1]);
Y = Table.getColumn(columnNames[2]);
Z = Table.getColumn(columnNames[3]);
Table.sort(columnNames[3]);
run("Select All");
run("Clear", "stack");
run("Select None");

for (i = 0; i < X.length; i++) {
    x = X[i];
    y = Y[i];
    z = Z[i];
    Stack.setSlice(z);
    setPixel(x, y, 65535);
}

