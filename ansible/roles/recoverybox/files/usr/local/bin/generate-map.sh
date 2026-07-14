#!/bin/bash

## Generate .mbtiles file from OSM PBF data using Planetiler

SRVMSG=' =+= '
MSGGREEN='\033[0;32m'
MSGYELLOW='\033[0;33m'
MSGRED='\033[0;31m'
MSGNC='\033[0m'
TileserverDir="/data/tileserver"
WorkDir="/data/planetiler"
Zone=""
ZoneCont=""
MemoryLimit=$(free -g | grep "Mem" | awk '{print $2}')
ZoomLevel=6

mkdir -p "$WorkDir" "$WorkDir/output" "$WorkDir/tmp" "$TileserverDir"

cleanup_pt() {
    rm -rf "${WorkDir}/tmp/"* 2>/dev/null || true
    rm -f "${WorkDir}/${Zone}-latest.osm.pbf"
    rm -rf "${WorkDir}/sources/"* 2>/dev/null || true
    rm -f "${WorkDir}/tile_weights.tsv.gz"
}
trap cleanup_pt EXIT

####################################

echo -e "${MSGGREEN}\n\n############################################################################################## "
echo -e "${SRVMSG} Welcome to the Map Generation Script for Recovery Box"
echo -e "${SRVMSG} This script will generate map areas"
echo -e "${SRVMSG} Please ensure you have enough disk space and memory available before proceeding."
echo -e "${SRVMSG} This can take a while depending on the size of the area and zoom level you choose."

echo -e "############################################################################################## \n${MSGNC}"

echo -e "${SRVMSG} Generate the map for :"
echo -e "1) Continent"
echo -e "2) Country"
while true; do
    read -rp "Choose an option (1 or 2): " MapOption
    case $MapOption in
        1)
            echo -e "${SRVMSG} Continents available: africa, antartica,asia, australia-oceania, central-america, europe, north-america, south-america"
            read -rp "Enter the continent name : " Continent
            Zone="$Continent"
            break
            ;;
        2)
            read -rp "Enter the country name (e.g., france, germany): " MapCountry
            Zone="$MapCountry"
            echo -e "${SRVMSG} Continents available: africa, antartica,asia, australia-oceania, central-america, europe, north-america, south-america"
            read -rp "In which continent is the country located ? (e.g., europe, asia): " Continent
            ZoneCont="$Continent/"
            break
            ;;
        *)
            echo -e "${MSGRED}${SRVMSG}Invalid option. Please choose 1 or 2.${MSGNC}"
            ;;
    esac
done

UrlPbf="https://download.geofabrik.de/${ZoneCont}${Zone}-latest.osm.pbf"

echo -e "${SRVMSG} Zoom level available : "
echo -e "1) Overview (Zoom 6) - Ultra-lightweight / Global coverage"
echo -e "2) Tactical (Zoom 10) - Road network & Navigation"
echo -e "3) Operational (Zoom 12) - Urban details & Local coordination"
echo -e "4) High Precision (Zoom 14) - Full terrain details & Buildings"
echo -e "Note: High Precision (Zoom 14) can be up to 50x larger than Overview."
while true; do
    read -rp "Choose a zoom level (1-4): " ZoomOption
    case $ZoomOption in
        1)
            ZoomLevel=6
            break
            ;;
        2)
            ZoomLevel=10
            break
            ;;
        3)
            ZoomLevel=12
            break
            ;;
        4)
            ZoomLevel=14
            break
            ;;
        *)
            echo -e "${MSGRED}${SRVMSG}Invalid option. Please choose 1-4.${MSGNC}"
            ;;
    esac
done

####################################

echo -e "${MSGGREEN}${SRVMSG} Downloading fresh data for $Zone ${MSGNC}"
wget -N "$UrlPbf" -P "$WorkDir/"
if [ $? -ne 0 ]; then
    echo -e "${MSGRED}${SRVMSG}Failed to download ${UrlPbf}.${MSGNC}"
    exit 1
fi

####################################

echo -e "${MSGGREEN}${SRVMSG} Generating .mbtiles file ---"

rm -rf "${WorkDir}/tmp/"* 2>/dev/null || true

docker run --rm \
  -e JAVA_OPTS="-Xmx${MemoryLimit}g" \
  -v "${WorkDir}:/data" \
  ghcr.io/onthegomap/planetiler:latest \
  --download \
  --osm_path="/data/${Zone}-latest.osm.pbf" \
  --output="/data/output/${Zone}.mbtiles" \
  --maxzoom=${ZoomLevel} \
  --tmpdir="/data/tmp" \
  --force

if [ $? -ne 0 ]; then
    echo -e "${MSGRED}${SRVMSG}Error during map generation.${MSGNC}"
    cleanup_pt
    exit 1
else
    echo -e "${MSGGREEN}${SRVMSG}Map generation completed successfully.${MSGNC}"
fi

cleanup_pt



####################################

echo -e "${MSGYELLOW}${SRVMSG} Moving .mbtiles file to tileserver directory ---"
mv "$WorkDir/output/${Zone}.mbtiles" "$TileserverDir/"

if [ -e "$TileserverDir/map.mbtiles" ]; then
    echo -e "${MSGYELLOW}${SRVMSG}Fusioning map files...${MSGNC}"
    mv "$TileserverDir/map.mbtiles" "$TileserverDir/world.mbtiles" 2>/dev/null || true
    tile-join -o "$TileserverDir/map.mbtiles" "$TileserverDir/world.mbtiles" "$TileserverDir/${Zone}.mbtiles"
    if [ $? -ne 0 ]; then
        echo -e "${MSGRED}${SRVMSG}Error during map fusion. Rollback...${MSGNC}"
        mv "$TileserverDir/world.mbtiles" "$TileserverDir/map.mbtiles" 2>/dev/null || true
        exit 1
    else
        echo -e "${MSGGREEN}${SRVMSG}Map fusion completed successfully.${MSGNC}"
        rm "$TileserverDir/world.mbtiles" -f
    fi
else
    mv "$TileserverDir/${Zone}.mbtiles" "$TileserverDir/map.mbtiles"
fi


while true; do
    read -rp "${MSGYELLOW}Would you restart the tile server now ? (y/n) : ${MSGNC}" RestartOption
    case $RestartOption in
    y|Y)
        echo -e "${SRVMSG} Restarting tile server ---"
        systemctl restart tileserver-gl.service
        if [ $? -ne 0 ]; then
            echo -e "${MSGRED}${SRVMSG}Error restarting tile server.${MSGNC}"
        else
            echo -e "${MSGGREEN}${SRVMSG}Tile server restarted successfully.${MSGNC}"
            echo -e "${MSGGREEN}${SRVMSG}The map for ${Zone} is now available.${MSGNC}"
        fi
        break
        ;;
    n|N)
        echo -e "${SRVMSG} Please remember to restart the tile server to apply changes."
        break
        ;;
    *)
        echo -e "${MSGRED}${SRVMSG}Invalid option. Please answer y or n.${MSGNC}"
        ;;
    esac
done