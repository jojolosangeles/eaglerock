**CSV to Map**

To visualize City CSV data on a map, each CSV row needs to be transformed into a map location and associated text.

Here is the script:
```
# 1. Initialize environment variable GOOGLE_API_KEY
. ./keys/setup
# 1. Create a variable name for each CSV column heading
head -3 data/Building_and_Safety_Permit_Information.csv > working/Building_and_Safety_Permit_Information.3_lines
ruby generateCSV_variable_names.rb working/Building_and_Safety_Permit_Information.3_lines > working/Building_and_Safety_Permit_Information.variable_names
# some filtering specific to this data source, here filtering based on zip code
head -1 data/Building_and_Safety_Permit_Information.csv > working/Building_and_Safety_Permit_Information.filtered.csv
egrep -h "90041|90042|90065" data/Building_and_Safety_Permit_Information.csv >> working/Building_and_Safety_Permit_Information.filtered.csv
# 2. Identify "Map_Marker" Location/Text in terms of CSV column variables
ruby generateMarkerInfo.rb working/Building_and_Safety_Permit_Information.filtered.csv latitude_longitude templates/MARKER_Title.erb issue_date 1/1/2017 > working/Building_and_Safety_Permit_Information.marker_info
# 3. Convert the 'Set of "Map_Marker" Latitude/Longitude' into a 'MAP Bounds' with a Configurable 'MAP Margin'
# generateMapBounds.rb NOT implemented, see below for detail.
# 4. Create Template-specific String variables, using _map_bounds, _center, _markers and 
#    combine to create static HTML for Google Map display with markers.  Generate the static HTML.
ruby generateHTML.rb templates/permits.erb working/Building_and_Safety_Permit_Information.marker_info > results/Building_and_Safety_Permit_Information.html
5. Deploy the HTML from Step #4
# NOT implemented: copy to S3 static website
```
The map location appears as a marker on the map.  The associated text appears when the marker is selected.

**Transformation Steps**

1. Create a variable name for each CSV column heading
```
ruby generateCSV_variable_names.rb CSV_FILE_PATH > VARIABLE_DEFINITIONS.txt
```
The Variable Definition output file contains one variable name on each line of the text file:
```
variable_name_1
variable_name_2
 .
 .
variable_name_N
```
2. Generate "Map_Marker" Location/Text based on CSV file column variables:
```
ruby generateMarkerInfo.rb CSV_file VARIABLE_LIST_file variable_containing_location Marker_Info_ERB_template
        > MAP_MARKER_INFO_file
```
This extracts MAP_MARKER Location and Title from each CSV line, and outputs:
```
<latitude>,<longitude>,<title>
```
3. Filter the data by city
```
ruby filterLocationByCity CITY_NAME 
```
4. Convert the **MAP_MARKER_INFO_file** into a **MAP_BOUNDARY_file**
```
ruby generateMapBounds.rb MAP_MARKER_INFO_file MAP_MARGIN > MAP_BOUNDARY_file
```       
The output file contains 2 locations, upper left and lower right:
```
upper_left_latitude,upper_left_longitude
lower_right_latitude,lower_right_longitude
```

4. Create Template-specific String variables, using _map_bounds, _center, _markers and combine to create
static HTML for Google Map display with markers.  Generate the static HTML.
```
ruby generateText.rb ERB_FILE_PATH "Map_Marker"_INFO_FILE_PATH > output_file_path
```
5. Deploy the HTML from Step #4