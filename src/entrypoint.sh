#!/bin/bash


#Set fonts
NORM=`tput sgr0`
BOLD=`tput bold`
REV=`tput smso`

CURDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

function show_usage () {
    echo -e "${BOLD}Basic usage:${NORM} entrypoint.sh [-vh] CONF_FILE TRIPS YEAR OUT_PATH"
}

function show_help () {
    echo -e "${BOLD}entrypoint.sh${NORM}: Runs the Connector from matsim-irtx to copert"\\n
    show_usage
    echo -e "\n${BOLD}Required arguments:${NORM}"
    echo -e "${REV}CONF_FILE${NORM}\t the configuration json file"
    echo -e "${REV}TRIPS${NORM}\t trips csv file originated by matsim model"
    echo -e "${REV}YEAR${NORM}\t the year to be used"
    echo -e "${REV}OUT_PATH${NORM}\t the output path"\\n
    echo -e "${BOLD}Optional arguments:${NORM}"
    echo -e "${REV}-v${NORM}\tSets verbosity level"
    echo -e "${REV}-h${NORM}\tShows this message"
    echo -e "${BOLD}Examples:${NORM}"
    echo -e "entrypoint.sh -v configuration.json trips.json 2022 ./output/"
}

##############################################################################
# GETOPTS                                                                    #
##############################################################################
# A POSIX variable
# Reset in case getopts has been used previously in the shell.
OPTIND=1

# Initialize vars:
verbose=0

# while getopts
while getopts 'hv' OPTION; do
    case "$OPTION" in
        h)
            show_help
            kill -INT $$
            ;;
        v)
            verbose=1
            ;;
        ?)
            show_usage >&2
            kill -INT $$
            ;;
    esac
done

shift "$(($OPTIND -1))"

leftovers=(${@})
CONF_FILE=${leftovers[0]}
TRIPS=${leftovers[1]}
YEAR=${leftovers[2]}
OUT_PATH=${leftovers[3]}

##############################################################################
# Input checks                                                               #
##############################################################################
if [ ! -f "${CONF_FILE}" ]; then
     echo -e "Give a ${BOLD}valid${NORM} path to the conversion configuration file\n"; show_usage; exit 1
fi
if [ ! -f "${TRIPS}" ]; then
    echo -e "Give a ${BOLD}valid${NORM} Path to the trips file originated by matsim model\n"; show_usage; exit 1
fi

if [ ! -d "${OUT_PATH}" ]; then
     echo -e "Give a ${BOLD}valid${NORM} output directory\n"; show_usage; exit 1
fi


##############################################################################
# Execution                                                                  #
##############################################################################
papermill ${CURDIR}/Convert.ipynb /dev/null \
  -pconfiguration_path ${CONF_FILE} \
  -ptrips_path ${TRIPS} \
  -pyear ${YEAR} \
  -poutput_path ${OUT_PATH}
