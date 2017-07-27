#! /usr/bin/make -f

include configure.mk

schema:=public

orig.shp:=i08_B118_CA_GroundwaterBasins.shp

DEFAULT: geojson/groundwater_basins.geojson shp

# Converting to WGS84 is a more accepted GEOJSON format.
geojson/groundwater_basins.geojson: src/groundwater_basins.vrt src/${orig.shp}
	[[ -d geojson ]] || mkdir geojson;
	ogr2ogr -f GEOJSON  -t_srs WGS84 $@ $<

# Here's an Example of materializing that VRT file, for example to
# upload to Google Maps.
shp: src/groundwater_basins.vrt 
	ogr2ogr $@ $<

# While we may store the original data in the GITHUB repository, we
# also want to show how we got the data.
src/${orig.shp}:zip:=src/B118_GW_Basins.zip
src/${orig.shp}:url:=http://www.water.ca.gov/groundwater/sgm/files/B118_CA_GroundwaterBasins.zip
src/${orig.shp}:
	[[ -f ${zip} ]] || curl ${url} > ${zip}
	unzip -d src -u ${zip}
	rm ${zip}

# Additionally, we may want to show alternative import strateigies.
# This rule will create a PostGIS version in ${schema}
.PHONY: postgis
postgis: src/groundwater_basins.vrt src/${orig.shp} 
	${OGR} src/groundwater_basins.vrt

# In order to use our PostGIS import, we include some standard
# configuration file.  This is pulled from a specific version, as a
# github GIST.  This, we probably don't save in our repo.  Want users
# to see where it came from.  Update to newer version if required.
configure.mk:gist:=https://gist.githubusercontent.com/qjhart/052c63d3b1a8b48e4d4f
configure.mk:
	wget ${gist}/raw/e30543c3b8d8ff18a950750a0f340788cc8c1931/configure.mk

# Some convience functions for testing and repreoducing
clean:
	rm -rf configure.mk shp geojson

clean-all: clean
	rm src/i08* src/I08*
