# Templates and tools for Subsurface's latex export

Sometimes, a diver needs to show a printed divelog so he can be
authorized to dive in an spot.

I don't like how Subsurface prints its dives, even after recent changes.
Fortunately, Subsurface can export dive data into a latex file which can be
rendered using a template to complete a full latex archive.
This is what I'm currently using to render nice -for my taste- pdf files which
I could print whenever I'm demanded a hardcopied proof of recent dives.

The repo contains:
- ***subsurfacelatextemplate.tex***: A template in landscape format for A5 paper. The goal of this template is to
have preformated pages which can then be grouped and printed using a viewer
like Evince, to a 2 in 1 A4 paper in portrait mode, or 4 in 1 A4 paper in
landscape mode. In this last style, if we have a capable printer and viewer or
other tool, we can place 8 dives in every paper sheet so we can use as little
paper as possible.
- ***subsurfacelatextemplate_A4.tex***: A template in portrait format for A4 paper. The goal of this template is to
have preformated pages with as many info as possible -ideally, every single
piece of data exported by Subsurface- whithout being limited by the paper size.
We get bigger fonts and real state, although a recreational diver will probably
just need the previous A5 version. By the way, a tech diver, may get his full
data with detailed info about his weights,  his -multiple- tanks and a lot of
space for his commonly extensive notes about the dive.
- ***process_export.sh***: A bash script to render and append (if needed) the export to a previous pdf
file containing dives. This tool is needed because of latex low render speed,
and the high number of dives a divelog can contain. E.g: A 400 dives divelog
would need to be exported in blocks of 100/150 dives or latex will be unable of
manage the needed memory amount.
- ***pdf_multipage.sh***: Another bash script to render, using latex too, pdfs with multiple dives
per sheet. Using the --booklet option, we can get a file that can be printed
in both sheet sides and produce booklet format, if our viewer can't do it
itself.

## Workflow

* Export dives or full divelog from Subsurface and store it in a file, lets
name it mydivelog.tex. It has to be placed in the folder containing the
templates

* Edit the first line of mydivelog.tex and choose "subsurfacelatextemplate_A4.tex"
instead of the usual and predefined "subsurfacelatextemplate.tex" ***if you need it.

* Run `process_export.sh -n mydivelog.tex` and you will get mydivelog.pdf
containing all exported dives. At this stage you're probably done. Alternatively
you can just run pdflatex mydivelog.tex

* Let's say you had a previous pdf file, and you have just exported last year's
dives to add to the complete divelog.  Then the command to run, would be:
`process_export  -o mycompletedivelog.pdf -i mynewlyexporteddives.tex`
This will render the new dives and append them to the complete divelog, while
keeping backup copies, just in case.

## Other templates

Subsurface's latex export author has another template in [his blog](
http://www.atdotde.de/~robert/subsurfacetemplate)

