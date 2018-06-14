#!/bin/bash
#
###############################################################
# AUTOMATED COPYRIGHT WATERMARK ADDER.
# -------------------------------------------------------------
# Given a PDF and the related BiBTeX, automatically generates
# a new PDF file with watermark explaining that it is a pre-
# print version of the published manuscript, and adds citation
# and BiBTeX of the final paper in an extra page.
# "Errata corrige" files can be appended as well, optionally.
#
#
###############################################################
# REQUIREMENT.
# -------------------------------------------------------------
# BibTeX files should have already been tidied by bibtool
# (https://ctan.org/tex-archive/biblio/bibtex/utils/bibtool)
# and contain one entry (excluding referenced ones). This is
# already done by the "slice-and-dice-my-BibTeX.sh" script.
# You'd better invoke it first on your BibTeX files.
#
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
#
# Run "slide-and-dice-my-bibtex.sh" first to have the single BibTeX entry
#

### Execution environment
### --------------------------------

if [ $# -lt 3 ]; then
  echo "Usage: $0 <bibtex> <original_pdf_source> <copyrighted_output> [<errata_corrige>]"
  exit
fi

BASE_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "${BASE_DIR}"

TMP_DIR="${BASE_DIR}/tmp"

if [ ! -d "${BASE_DIR}/tmp" ]
then
 echo "Making tmp dir"
 mkdir "${BASE_DIR}/tmp"
fi


pdfsource="$2"
srcbibtex="$1"
bibtex=`basename "$srcbibtex"`

bibtexforimport="${bibtex/.bib/}"
bibtex="$TMP_DIR/$bibtex"

################################################################
### Run
################################################################

### BiBTeX analysis
### --------------------------------

cp "$srcbibtex" "$bibtex"

# sed -i -e 'N; s/^@comment.*\n//g' "$bibtex"
# sed -i -e 's/^%.*//g' "$bibtex"
# sed -i -e '/^$/d' "$bibtex"

bibtexkey=$(less "$bibtex" | grep -m 1 -i '^@\(IN\)\|@\(AR\)' | sed -e 's/[^{]*{\([^,]*\),/\1/' -e 's/^ *//' -e 's/ *$//')
publisherfield=$(less "$bibtex" | grep -m 1 -i 'publisher *=')
# publisher=$(less "$bibtex" | grep -m 1 -i 'publisher *=' | sed -e 's/[ ]*publisher[ ]*=[ ]*{\([^}]*\)}.*/\1/i' -e 's/^ *//' -e 's/ *$//')

if [ -z "$publisherfield" ]
then
  publisher=$(less "$bibtex" | grep -m 1 -Pzoi 'booktitle *='})
#  publisher=$(less "$bibtex" | grep -m 1 -Pzoi 'booktitle *= *{[^}]*}' | head -n 1 | sed -e ':a;N;s/\n//;ba' | sed -e 's/ *booktitle *= *//gi' -e 's/{//g' -e 's/}//g'  -e 's/  */ /g')
  if [ -z "$publisher" ] # It could be a journal
  then
    publisher="in \citefield{$bibtexkey}{journaltitle}"
#    publisher=$(less "$bibtex" | grep -m 1 -Pzoi 'journal *= *{[^}]*}' | head -n 1 | sed -e ':a;N;s/\n//;ba' | sed -e 's/ *journal *= *//gi' -e 's/{//g' -e 's/}//g'  -e 's/  */ /g')
  else
    publisher="in \citefield{$bibtexkey}{booktitle}"
  fi
else
#  publisher=$(echo ${publisherfield} | sed -e 's/[ ]*publisher[ ]*=[ ]*{\([^}]*\)},*.*/\1/i' -e 's/^ *//' -e 's/ *$//')
  # Read the BibTeX file | remove newlines | remove multiple spaces | extract the field
  publisher=$(less "$bibtex" | tr -d '\n' | sed -e 's/  */ /g' | sed -e 's/.*publisher = {\([^=]*\)}[,}].*/\1/g')
  publisher="by ${publisher}"
fi

if [ ! -z "`echo $publisherfield | grep -m 1 -i 'Springer'`" ]
then
  publisher="$publisher \\\\ (available at \href{http://link.springer.com/}{\nolinkurl{link.springer.com}})"
elif [ ! -z "`echo $publisherfield | grep -m 1 -i 'IEEE'`" ]
then
  publisher="$publisher \\\\ (available at \href{http://ieeexplore.ieee.org/}{\nolinkurl{ieeexplore.ieee.org}})"
elif [ ! -z "`echo $publisherfield | grep -m 1 -i 'ACM'`" ]
then
  publisher="$publisher \\\\ (available at \href{http://dl.acm.org/}{\nolinkurl{dl.acm.org}})"
elif [ ! -z "`echo $publisherfield | grep -m 1 -i 'CEUR'`" ]
then
  publisher="$publisher \\\\ (available at \href{http://ceur-ws.org/}{ceur-ws.org})"
fi

#doi=$(less "$bibtex" | grep -m 1 -i '^[ ]*doi[ ]*' | sed -e 's/[ ]*doi[ ]*=[ ]*{\([^}]*\)}.*/\1/gi' -e 's/^ *//' -e 's/ *$//')
doi=$(less "$bibtex" | grep -m 1 -i 'doi *=')

if [ "$doi" ]
then
#  longdoitextref="\vspace{1em} The final version of the paper is identified by the following DOI: \href{http://dx.doi.org/${doi}}{\nolinkurl{${doi}}}"
#  shortdoitextref="\\\\ {identified by DOI: \href{http://dx.doi.org/${doi}}{\nolinkurl{${doi}}}}"
  longdoitextref="\vspace{1em} The final version of the paper is identified by \citefield{$bibtexkey}[doi]{doi}"
  shortdoitextref="\\\\ {identified by \citefield{$bibtexkey}[doi]{doi}}"
else
  longdoitextref=""
  shortdoitextref=""
fi

### Copyright file preparation
### --------------------------------

bibtext=$(less "$bibtex")

bibtex=`basename "$srcbibtex"`
copyrightex=$(cat --<<EOF
\documentclass[11pt,a4paper,notitlepage,oneside]{article}

\usepackage[colorlinks=true,allcolors=blue]{hyperref}
\usepackage[utf8]{inputenc}    % utf8 support
\usepackage[T1]{fontenc}       % code for pdf file
\usepackage{csquotes}
\usepackage[backend=biber,style=authoryear,maxbibnames=64,hyperref]{biblatex}
\addbibresource{$bibtex}
\usepackage{framed}
\usepackage{spverbatim}

\makeatletter %%% http://tex.stackexchange.com/questions/27607/biblatex-authoryear-comp-and-hyperlinks
%Works without the last bracket ;-)
\let\abx@macro@citeOrig\abx@macro@cite
\renewbibmacro{cite}{%
   \bibhyperref{%
   \let\bibhyperref\relax\relax%
   \abx@macro@citeOrig%
   }%
}
\let\abx@macro@textciteOrig\abx@macro@textcite
\renewbibmacro{textcite}{%
   \bibhyperref{%
   \let\bibhyperref\relax\relax%
   \abx@macro@textciteOrig%
   }%
}%
\makeatother

\begin{document}
\thispagestyle{empty}

\begin{framed}
\begin{center}
This document is a pre-print copy of the manuscript \newline \autocite{$bibtexkey}

published ${publisher}.

${longdoitextref}
%
\end{center}
\end{framed}

\vspace{1em}
%\bibliographystyle{named}
%\bibliography{$bibtexforimport}
\printbibliography

\begin{samepage}
\section*{BibTeX}
\begin{scriptsize}
\begin{spverbatim}
$bibtext
\end{spverbatim}
\end{scriptsize}
\end{samepage}

\end{document}
EOF
)

rootname="${bibtexkey//[^0-9^a-z^A-Z]/-}"
copyrightexfilename="${rootname}-copydisclaimer.tex"
copyrightpdffilename="${copyrightexfilename/.tex/}.pdf"

echo "$copyrightex" > "$TMP_DIR/$copyrightexfilename"

echo "Running " pdflatex -interaction=batchmode -output-directory "$TMP_DIR" "$TMP_DIR/$copyrightexfilename"
pdflatex -interaction=batchmode -output-directory "$TMP_DIR" "$TMP_DIR/$copyrightexfilename"

echo "Running " biber --input-directory "$TMP_DIR" --output-directory "$TMP_DIR" "${copyrightexfilename/.tex/}"
biber --input-directory "$TMP_DIR" --output-directory "$TMP_DIR" "${copyrightexfilename/.tex/}"

echo "Running " pdflatex -interaction=batchmode -output-directory "$TMP_DIR" "$TMP_DIR/$copyrightexfilename"
pdflatex -interaction=batchmode -output-directory "$TMP_DIR" "$TMP_DIR/$copyrightexfilename"
echo "Running " pdflatex -interaction=batchmode -output-directory $TMP_DIR "$TMP_DIR/$copyrightexfilename"
pdflatex -interaction=batchmode -output-directory "$TMP_DIR" "$TMP_DIR/$copyrightexfilename"

### Copyright watermark preparation
### --------------------------------

copyrightwatermarktex=$(cat --<<EOF
\documentclass[a4paper,10pt]{scrartcl}% http://ctan.org/pkg/koma-script
\usepackage[utf8]{inputenc}    % utf8 support
\usepackage[T1]{fontenc}       % code for pdf file
\usepackage{csquotes}
\usepackage[backend=biber]{biblatex}
\addbibresource{$bibtex}
\usepackage{hyperref}
\usepackage{url}% http://ctan.org/pkg/url
\usepackage{eso-pic}% http://ctan.org/pkg/eso-pic

\thispagestyle{empty}

\AddToShipoutPictureBG{% Add picture to background of every page
  \AtPageLowerLeft{%
    \raisebox{3\baselineskip}{\makebox[\paperwidth]{\begin{minipage}{0.8\paperwidth}\centering
      {Pre-print copy of the manuscript published ${publisher}}
      ${shortdoitextref}
    \end{minipage}}}%
  }
}
\begin{document}
\hfill
\end{document}
EOF
)

copyrightwatermarktexfilename="${rootname}-copywatermark.tex"
copyrightwatermarkpdffilename="${copyrightwatermarktexfilename/.tex/}.pdf"
watermarkedpdf="${rootname}-watermarked.pdf"

echo "$copyrightwatermarktex" > "$TMP_DIR/$copyrightwatermarktexfilename"

echo "Running " pdflatex -interaction=batchmode -output-directory "$TMP_DIR" "$TMP_DIR/$copyrightwatermarktexfilename"
pdflatex -interaction=batchmode -output-directory "$TMP_DIR" "$TMP_DIR/$copyrightwatermarktexfilename"
echo "Running " biber --input-directory "$TMP_DIR" --output-directory "$TMP_DIR" "${copyrightwatermarktexfilename/.tex/}"
biber --input-directory "$TMP_DIR" --output-directory "$TMP_DIR" "${copyrightwatermarktexfilename/.tex/}"
echo "Running " pdflatex -interaction=batchmode -output-directory "$TMP_DIR" "$TMP_DIR/$copyrightwatermarktexfilename"
pdflatex -interaction=batchmode -output-directory "$TMP_DIR" "$TMP_DIR/$copyrightwatermarktexfilename"
echo "Running " pdflatex -interaction=batchmode -output-directory $TMP_DIR "$TMP_DIR/$copyrightwatermarktexfilename"
pdflatex -interaction=batchmode -output-directory "$TMP_DIR" "$TMP_DIR/$copyrightwatermarktexfilename"

### Merging of files
### --------------------------------

pdftk "$pdfsource" multistamp "$TMP_DIR/$copyrightwatermarkpdffilename" output "$TMP_DIR/$watermarkedpdf"

if [ -d "$3" ]
then
  pdfoutfile="$3/$rootname.pdf"
else
  pdfoutfile="$3"
fi

### (Optional) addition of errata corrige
### --------------------------------

# Errata corrige
if [ -z "$4" ]
then
    pdftk "$TMP_DIR/$watermarkedpdf" "$TMP_DIR/$copyrightpdffilename" cat output "$pdfoutfile"
else
    pdftk "$TMP_DIR/$watermarkedpdf" "$4" "$TMP_DIR/$copyrightpdffilename" cat output "$pdfoutfile"
fi
