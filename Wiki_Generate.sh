#!/bin/bash

PATHSOURCES="wiki-sources"
PATHDESTINATION="../ansible/roles/recoverybox/files/data/www/wiki"
MKDOCS_PLUGIN="mkdocs-material"
PATHVENV="/data/recoverybox_env"

print_help() {
    echo "Usage: $0 "
    echo -e "This script generate the wiki from the sources in $PATHSOURCES and copy it to $PATHDESTINATION."
    echo -e "you need to run this script in a virtualenv"
    echo -e "This script will install mkdocs if it is not already installed."
}

check_rb_virtualenv() {
    if [[ -z "$VIRTUAL_ENV" ]]; then
        if [[ -f "$PATHVENV/bin/activate" ]]; then
            echo "Activating virtual environment..."
            # shellcheck source=/dev/null
            source "$PATHVENV/bin/activate"
        else
            echo "No virtual environment found. Please create a virtual environment and activate it before running this script."
            exit 1
        fi
    fi
}

get_mkdocs() {
    echo "Downloading and installing MkDocs..."
    # Download the latest version of MkDocs
    pip install mkdocs
    for plugin in $MKDOCS_PLUGIN; do
        pip install "$plugin"
    done
}

generate_wiki() {
    echo "Generating the wiki..."
    mkdocs build -f $PATHSOURCES/mkdocs.yml -d $PATHDESTINATION
    echo "Wiki generated successfully in $PATHDESTINATION."
}

main() {
    
    # Check if mkdocs is installed
    if ! command -v mkdocs &> /dev/null; then
        check_rb_virtualenv
        get_mkdocs
    fi
    generate_wiki
    deactivate
}

if [[ "$1" == "--help" || "$1" == "-h" ]]; then
    print_help
    exit 0
fi

main