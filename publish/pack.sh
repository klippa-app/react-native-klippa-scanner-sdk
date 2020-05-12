#!/bin/bash

SOURCE_DIR=..;
PACK_DIR=package;
ROOT_DIR=..;
PUBLISH=--publish

install(){
    npm i
}

pack() {

    echo 'Clearing /package...'
    node_modules/.bin/rimraf "$PACK_DIR"

    echo 'Creating package...'

    # create package dir
    mkdir "$PACK_DIR"

    # create the package
    cd "$PACK_DIR"
    npm pack ../"$SOURCE_DIR"

    cd ..
}

install && pack
