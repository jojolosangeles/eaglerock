**CSV to Map**

To visualize City CSV data on a map, each CSV row needs to be transformed into a map location and associated text.

The map location appears as a marker on the map.  The associated text appears when the marker is selected.

**Transformation Steps**

1. Create a variable name for each CSV column heading

ruby generateCSV_variable_names.rb <CSV File Path> > <CSV Variable Definition File Path>

The variable definition file format is:

_variable_name_1: "column heading 1"_
_variable_name_2: "column heading 2"_
-
-
_variable_name_N: "column heading N"_

2. Identify MARKER Location/Text in terms of CSV column variables:

ruby generateMarkerInfo.rb \<CSV File Path>
                           \<CSV Variable List File Path>
                           \<variable_containing_location>
                           \<MARKER Title Format String>
        > \<MARKER Info File Path>

This extracts MARKER Location and Title from each CSV line, and outputs:

<latitude>,<longitude>,<title>

3. Convert the **_Set of MARKER Latitude/Longitude_** into a **MAP Bounds** with a HUMAN input **MAP Margin**

ruby generateMapBounds.rb MARKER_INFO_FILE_PATH
                          HUMAN_INPUT_MAP_MARGIN
       > MARGIN_MAP_BOUNDS_FILE_PATH
       
The output file contains::

_map_bounds: [ LowerLeft, LowerRight, UpperRight, UpperLeft ]
_center: Center

where Center, LowerLeft, LowerRight, UpperRight, UpperLeft are all **Location** instances

4. Create Template-specific String variables, using _map_bounds, _center, _markers and combine to create
static HTML for Google Map display with markers.  Generate the static HTML.

5. Deploy the HTML from Step #4