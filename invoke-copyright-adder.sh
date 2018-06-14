#!/bin/bash
#
###############################################################
# INVOKES THE AUTOMATED COPYRIGHT WATERMARK ADDER IN BATCH.
# -------------------------------------------------------------
# See the "add-copyright-marks-on-preprint.sh" for further
# explanation
###############################################################
#
# Author: Claudio Di Ciccio
# Version: 14/06/2018
#
# Requires:
# 1. installation of LaTeX 2015+ with PDFlatex command (https://www.latex-project.org/)
# 2. installation of biber tool (http://biblatex-biber.sourceforge.net/)
# 3. installation of PDFtk (https://www.pdflabs.com/tools/pdftk-the-pdf-toolkit/)
#
###############################################################

### Execution environment
### --------------------------------


################################################################
### Run
################################################################


BASE_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "${BASE_DIR}"

./add-copyright-marks-on-preprint.sh "bibs/Author-etal-Conf2018.bib" "pre-prints/Author-etal-Conf2018.pdf" "copyright-marked"

exit
# ls bibs | sed -e 's/  */\n/g' | sed -e 's/^\(.*\).bib/.\/add-copyright-marks-on-preprint.sh "bibs\/\1.bib" "pre-prints\/\1.pdf" "copyright-marked"/g'
