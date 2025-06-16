#! /usr/bin/make  -f

#SHELL - Use bash
SHELL:=/bin/bash


# Database Information.  Make sure that you have your .pgservice_conf
# and maybe .pgpass specified so you don't need to use a password to
# log into this account.  T

service:=calvin

# This configuration doesn't include initializing your database.  You might need to RTFM, but 
# pgdir:=/usr/share/postgresql/9.1/contrib/postgis-2.0/
# psql service=${service} -c "create extension plpgsql" 
# psql service=${service} -f ${pgdir}/postgis.sql
# for rasters
#psql service=${service} -f ${pgdir}/rtpostgis.sql


# Projection information.  This is id in the spatial_ref_sys table.
srid:=3310

# Snap information.  This is used (by some) to snap points to a grid
snap:=1

# If you are using a non-standard projection, then you need to update
# this table.  See the rule 'add-spatialref' below for getting that
# from www.spatialref.org.  If you do that, note that ESRI srids
# sometimes have an additional 9 prepended.
#
#add-spatialref:srid-url:=http://spatialreference.org/ref/sr-org/${srid}/postgis/
#add-spatialref:
#       wget -nv -O - ${srid-url} | ${PG}

#################################################################
# Shouldn't need to touch below: Well maybe to find programs.
#
#################################################################
# Verify have read the configuration data
configure.mk:=1

# standard variables for text
comma:= ,
empty:=
space:= $(empty) $(empty)

# For writing CSV files
PG:=psql service=${service} --variable=srid=${srid} --variable=snap=${snap}
PG-CSV:=${PG} -A -F',' --pset footer
PG-TSV:=${PG} -A -F'    ' --pset footer

# Postgis commands.
shp2pgsql:=shp2pgsql
pgsql2shp:=pgsql2shp

# ogr for dbf only data since Postgis is screwed up now.
# OGR parameters
ogrdsn:=PG:"service=${service}"
OGR:=ogr2ogr -f "PostgreSQL" ${ogrdsn}
ogr_dbf:=ogr2ogr -overwrite -f "PostgreSQL" ${ogrdsn}
db2kml:=ogr2ogr -overwrite -f KML 


# Remove at set of Zipfiles , use with $(call rm_zipfiles,${zip})
define rm_zipfiles
f=`unzip -l $1 | head -n -2 | tail -n +4 | tr -s ' ' | cut -d ' ' -f 5`;echo rm $$f;rm $$f
endef

define rm_7zfiles
f=`7z -slt l $1 | grep Path | sed -e 's/Path = //' | tail -n +2`; echo rm $$f; rm $$f
endef

# These are some helper functions you can use in your own makefiles
define comma-sep
        $$(subst ${space},${comma},$1)
endef
