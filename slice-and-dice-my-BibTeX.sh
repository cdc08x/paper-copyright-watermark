#!/bin/bash
#
###############################################################
# AUTOMATED BIBTEX FILE SLICER
# -------------------------------------------------------------
# Given a BiBTeX file, automatically slices into smaller files
# each containing a single entry and the related cross-ref’d
# ones.
# The name of the new BiBTeX files are based on the BiBTeX ID
# of the saved entries.
#
###############################################################
#
# Author: Claudio Di Ciccio
# Version: 14/06/2018
#
# Requires:
# 1. installation of bibtool (https://ctan.org/tex-archive/biblio/bibtex/utils/bibtool)
#
###############################################################


### Execution environment
### --------------------------------

#       Path of the file with the BibTool rule
BIBTOOL_COMMANDS="bibtool-rules.br"

#       Path of the directory where separate BiBTeX entries are stored in different files. It gets overwritten by the second (optional) parameter
BIB_DIR="bibs"

#       If set to true, it cleans the temporary bibtex files. It gets overridden by the third (optional) parameter
CLEAR_TMP=true

#       Types of entry that are parsed by this script
ENTRY_TYPES=(
 "Article"
 "InProceedings"
 "InCollection"
)

### Preliminary tests
### --------------------------------

if [ $# -lt 1 ]; then
  echo "Usage: $0 <bibtex> [<outputdir>=$BIB_DIR] [<clean-tmp-files>]"
  echo "Example: $0 bibsource/DiCiccio.bib bibs true"
  exit
fi

if [ ! -f "$BIBTOOL_COMMANDS" ]; then
  echo "Internal error: please check bibtool rules file path"
  exit
fi

srcbibtex="$1"
if [ ! -f "$srcbibtex" ]; then
  echo "Illegal parameter: $srcbibtex does not exists, is not a file or is not readable"
  exit
fi

### Variables assignment
### --------------------------------

if [ $# -gt 1 ]; then
  outdir="$2"
else
  outdir="$BIB_DIR"
fi

if [ $# -gt 2 ]; then
  cleartmpfiles=$3
else
  cleartmpfiles=$CLEAR_TMP
fi

bibtext=$(less "$srcbibtex")

extracounterforoverlappingentries=1

entrytypesforrex=`echo ${ENTRY_TYPES[@]} | sed 's/ /\\\\)\\\\|\\\\(/g'`


################################################################
### Run
################################################################

BASE_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "${BASE_DIR}"

if [ "$cleartmpfiles" == "true" ]; then
  rm "${outdir}"/* 2> /dev/null
fi

while read line; do
  bibtexkey=$(echo "$line" | grep -m 1 -i "^\\@\\(${entrytypesforrex}\\)" | sed -e 's/[^{]*{\([^,]*\),.*/\1/')
  if [ ! -z "$bibtexkey" -a "$bibtexkey" != " " ]; then
    echo Analysing\: $bibtexkey
    rootname=${bibtexkey%\:*}
    rootname="${rootname//[^0-9^a-z^A-Z]/-}"
    if [ -f "$BIB_DIR/$rootname.bib" ]; then
      extracounterforoverlappingentries=$((extracounterforoverlappingentries+1))
      rootname="$rootname-$extracounterforoverlappingentries"
    else
      extracounterforoverlappingentries=1
    fi
    echo "Saving in: $rootname.bib"
    echo "Executing: bibtool -- select" {\$key \"$bibtexkey\"} " -r $BIBTOOL_COMMANDS" -v "$srcbibtex" -o "$outdir/$rootname.bib"
    bibtool -- "select {\$key \"$bibtexkey\"}" -r "$BIBTOOL_COMMANDS" -v "$srcbibtex" -o "$outdir/$rootname.bib"
    # Following and expanding the cross-reference
    crossrefkey=$(grep -i -e 'crossref' "$outdir/$rootname.bib" | sed -e 's/[^{]*{\([^}]*\)}.*/\1/gi')
    if [ $crossrefkey ]; then
      echo Executing\: bibtool -- "select {\$key \"{^$crossrefkey$}\"}" -r "$BIBTOOL_COMMANDS" -v "$srcbibtex" -o "$outdir/$rootname.bib"
      crossrefd=`bibtool -- "select {\$key \"^$crossrefkey$\"}" -r "$BIBTOOL_COMMANDS" -v "$srcbibtex"`
      echo "$crossrefd" >> "$outdir/$rootname.bib"
    fi
  fi
done < "$srcbibtex"
