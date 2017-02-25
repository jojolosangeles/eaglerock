**CSV to Map**

To visualize City CSV data on a map, each CSV row needs to be transformed into a map location and associated text.

Here is the script:

# 1. Initialize environment variable GOOGLE_API_KEY
```
. ./keys/setup
```
# 2. Create a variable name for each CSV column heading
```
# Permit Data
head -3 data/Building_and_Safety_Permit_Information.csv > working/Building_and_Safety_Permit_Information.3_lines
ruby generateCSV_variable_names.rb working/Building_and_Safety_Permit_Information.3_lines > working/Building_and_Safety_Permit_Information.variable_names

# Crime Data
head -3 data/LAPD_Crime_and_Collision_Raw_Data_for_2016.csv > working/LAPD_Crime_and_Collision_Raw_Data_for_2016.3_lines
ruby generateCSV_variable_names.rb working/LAPD_Crime_and_Collision_Raw_Data_for_2016.3_lines > working/LAPD_Crime_and_Collision_Raw_Data_for_2016.variable_names
```
# data source specific filtering, here filtering Building_and_Safety_Permit_Information.csv by zip code
```
head -1 data/Building_and_Safety_Permit_Information.csv > working/Building_and_Safety_Permit_Information.filtered.csv
egrep -h "90041|90042|90065" data/Building_and_Safety_Permit_Information.csv >> working/Building_and_Safety_Permit_Information.filtered.csv
```
# 3. Filter by city location (specified in "config/cities.cfg")
```
head -1 working/Building_and_Safety_Permit_Information.filtered.csv > working/Building_and_Safety_Permit_Information.eagle_rock.csv
ruby filterLocationByCity.rb "Eagle Rock" working/Building_and_Safety_Permit_Information.filtered.csv latitude_longitude >> working/Building_and_Safety_Permit_Information.eagle_rock.csv
head -1 data/LAPD_Crime_and_Collision_Raw_Data_for_2016.csv > working/LAPD_Crime_and_Collision_Raw_Data_for_2016.eagle_rock.csv
ruby filterLocationByCity.rb "Eagle Rock" data/LAPD_Crime_and_Collision_Raw_Data_for_2016.csv location_1 >> working/LAPD_Crime_and_Collision_Raw_Data_for_2016.eagle_rock.csv
```
# 4. Generate a list of MAP_MARKER Location and Text
```
ruby generateMarkerInfo.rb working/Building_and_Safety_Permit_Information.eagle_rock.csv latitude_longitude templates/Building_and_Safety_Permit_Information.Marker_Title.erb issue_date 1/1/2017 > working/Building_and_Safety_Permit_Information.eagle_rock.marker_info
ruby generateMarkerInfo.rb working/LAPD_Crime_and_Collision_Raw_Data_for_2016.eagle_rock.csv location_1 templates/LAPD_Crime_and_Collision_Raw_Data_for_2016.Marker_Title.erb date_occ 12/1/2016 > working/LAPD_Crime_and_Collision_Raw_Data_for_2016.eagle_rock.marker_info
```
#
# 5. Create Template-specific String variables, using _map_bounds, _center, _markers and
#    combine to create static HTML for Google Map display with markers.  Generate the static HTML.
```
ruby generateText.rb templates/Building_and_Safety_Permit_Information.erb working/Building_and_Safety_Permit_Information.eagle_rock.marker_info > results/Building_and_Safety_Permit_Information.eagle_rock.html
ruby generateText.rb templates/LAPD_Crime_and_Collision_Raw_Data_for_2016.erb working/LAPD_Crime_and_Collision_Raw_Data_for_2016.eagle_rock.marker_info > results/LAPD_Crime_and_Collision_Raw_Data_for_2016.eagle_rock.html
```
# 6. Deploy the HTML from Step #4
# NOT implemented: copy to S3 static website
