# paper-copyright-watermark
## Adds a watermark on your paper pre-prints with all information needed to refer to the final version.

Given a PDF and the related BibTeX file, automatically generates
a new PDF file with watermark explaining that it is a pre-print version of the published manuscript, and adds citation
and BibTeX of the final paper in an extra page.
Errata corrige files can be appended as well, optionally.

### Requirements
BibTeX files should have already been tidied by bibtool
(https://ctan.org/tex-archive/biblio/bibtex/utils/bibtool)
and contain one entry (excluding referenced ones). This is
already done by the `slice-and-dice-my-BibTeX.sh` script.
You'd better invoke it first on your BibTeX files.

It requires the installation of:
- LaTeX 2015+ with PDFlatex command (https://www.latex-project.org/),
- biber tool (http://biblatex-biber.sourceforge.net/), and
- PDFtk (https://www.pdflabs.com/tools/pdftk-the-pdf-toolkit/).

It has been tested on an Ubuntu Linux 16.04 machine and on a Mac OS X Lion.

### Usage
To run it, launch `invoke-copyright-adder.sh`.
You can modify that script to run it with your files.
