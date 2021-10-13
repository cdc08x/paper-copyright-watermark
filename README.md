# Paper copyright-watermarker
## Adds a watermark on your paper pre-prints with all information needed to refer to the final version.

Given a PDF and the related BibTeX file, automatically generates
a new PDF file with watermark explaining that it is a pre-print version of the published manuscript, and adds citation
and BibTeX of the final paper in an extra page.
Errata corrige files can be appended as well, optionally.


All pre- and post-prints on my website ([`diciccio.net`](https://diciccio.net/#cdc08x-pubs)) are watermarked with this toolkit.
Curious? Keep on reading!

### Requirements
BibTeX files should have already been tidied by BibTool
(https://ctan.org/tex-archive/biblio/bibtex/utils/bibtool)
and contain one entry (excluding referenced ones). This is
already done by the `slice-and-dice-my-BibTeX.sh` script.
You'd better invoke it first on your BibTeX files.

It requires the installation of:
- LaTeX 2015+ with PDFlatex command (https://www.latex-project.org/),
- BibTool (https://ctan.org/tex-archive/biblio/bibtex/utils/bibtool),
- Biber (http://biblatex-biber.sourceforge.net/), and
- PDFtk (https://www.pdflabs.com/tools/pdftk-the-pdf-toolkit/).

It has been tested on Ubuntu Linux 16.04+ machines and on a Mac OS X Lion computer.

### Usage
To run it, launch
[`slice-and-dice-my-BibTeX.sh`](https://github.com/cdc08x/paper-copyright-watermark/tree/master/slice-and-dice-my-BibTeX.sh)
first (you will see that you need some options – follow the suggestion!) and then
[`invoke-copyright-adder.sh`](https://github.com/cdc08x/paper-copyright-watermark/tree/master/invoke-copyright-adder.sh).
The former slices a BibTeX file with (possibly) many entries into single `.bib` files, which are also linted by bibtool.
The latter creates the watermark on existing pre-prints. You can modify that script to run it with your files.
More explanations below.

### Usage example
Some folders are already filled in with example material.

In
[`bibsource/`](https://github.com/cdc08x/paper-copyright-watermark/tree/master/bibsource)
you can find a BibTeX file with two sample publications, which I named `diciccio.bib` for egocentrism. Ideally, it would be your own BibTeX file with your publications.

To lint it and split it into single-entry bibliography files, to be stored in
[`bibs/`](https://github.com/cdc08x/paper-copyright-watermark/tree/master/bibs)
for example, run:
```bash
./slice-and-dice-my-BibTeX.sh bibsource/DiCiccio.bib bibs true
```
The last parameter imposes to remove existing files from the 
[`bibs/`](https://github.com/cdc08x/paper-copyright-watermark/tree/master/bibs)
directory, so watch out.
You should see the two files preloaded in 
[`bibs/`](https://github.com/cdc08x/paper-copyright-watermark/tree/master/bibs)
as the result:
[`Surnamev-etal-Symp2017.bib`](https://github.com/cdc08x/paper-copyright-watermark/tree/master/bibs/Surnamev-etal-Symp2017.bib)
and
[`Author-etal-Conf2018.bib`](https://github.com/cdc08x/paper-copyright-watermark/tree/master/bibs/Author-etal-Conf2018.bib).
Notice that the file names are automatically generated based on the BibTeX keys of the respective entries.

In
[`pre-prints/`](https://github.com/cdc08x/paper-copyright-watermark/tree/master/pre-prints/)
you can find the PDF files of the papers.
At this stage, have a look at
[`invoke-copyright-adder.sh`](https://github.com/cdc08x/paper-copyright-watermark/tree/master/invoke-copyright-adder.sh).
You should see that
[`add-copyright-marks-on-preprint.sh`](https://github.com/cdc08x/paper-copyright-watermark/tree/master/add-copyright-marks-on-preprint.sh)
is invoked twice to add the copyright watermark on those pre-prints, associated to the respective BibTeX single-entry files:
```bash
./add-copyright-marks-on-preprint.sh "bibs/Surnamev-etal-Symp2017.bib" "pre-prints/Surnamev-etal-Symp2017.pdf" "copyright-marked"
./add-copyright-marks-on-preprint.sh "bibs/Author-etal-Conf2018.bib" "pre-prints/Author-etal-Conf2018.pdf" "copyright-marked"
```
The results are stored in
[`copyright-marked/`](https://github.com/cdc08x/paper-copyright-watermark/tree/master/copyright-marked/). 

Notice that every page has as a super-imposed footnote its DOI and publisher. A last page is also appended with bibliographic information.
I created
[`invoke-copyright-adder.sh`](https://github.com/cdc08x/paper-copyright-watermark/tree/master/invoke-copyright-adder.sh)
for convenience of batch calls. Feel free to invoke
[`add-copyright-marks-on-preprint.sh`](https://github.com/cdc08x/paper-copyright-watermark/tree/master/add-copyright-marks-on-preprint.sh)
directly on single files, of course.

The software also relies on an auxiliary folder (`tmp/`) to store temporary data. For debugging reasons, the software does not remove the temporary files at the end of the run. To change the location of the folder, feel free to alter the following line in
[`add-copyright-marks-on-preprint.sh`](https://github.com/cdc08x/paper-copyright-watermark/tree/master/add-copyright-marks-on-preprint.sh):
```bash
TMP_DIR="${BASE_DIR}/tmp"
```
Have fun!
