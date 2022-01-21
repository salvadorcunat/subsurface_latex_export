#!/bin/bash

_usage="
	A tiny script to build a pdf file with many pages for each page.
	Depends on pdflatex. This is only useful if your pdf viewer (e.g evince)
	is not booklet capable. Otherwise you can get the hardcopies directly
	from the viewer.

	pdf_multipage.sh [-p|--paper <portrait|landscape>] [-r|--rows <n>]
	[-c|--cols <n>] [--booklet] -i inputpdffile.pdf

	-r and -c are number of rows/columns in page (both default to 2)
	example: to place 2 A4 printouts in a single page -p landscape -r 1 -c 2 
	would be the correct choose. To place 4 A5 in a single page
	-p landscape -r 2 -c 2 would give a nice printout.

	--booklet option reverses rows and columns so take it into account when
	usinf this option.

	To get a correct multipage booklet two passes are needed, the first one
	building the pages, the second one building the booklet.
	"

BLUE="\033[0;34m"
GREEN="\033[0;32m"
LIGHT_RED="\033[1;31m"
DEFAULT="\033[0m"
_PDFL="$(command -v pdflatex)"; [[ -z $_PDFL ]] && { error_msg "${0##*/}" "Unable to find pdflatex"; exit 1; }
_SRC_DIR="$PWD"
_TMP_DIR="/tmp/ssrf_tmp_$$"
_PAPER="landscape"		#
_ROWS=2				# default values
_COLUMNS=2			#

report_msg()
{
	printf " -- %b --> %b\n" "$BLUE$1$DEFAULT" "$GREEN$2$DEFAULT" || return 1
}
error_msg()
{
	printf " -- %b --> %b\n" "$BLUE$1$DEFAULT" "$LIGHT_RED$2$DEFAULT" || return 1
}

# check arguments
# we need an input file at least
#
if [ "$#" -lt 2 ]; then
	echo "$_usage"
	exit 1
fi

while [ "$#" -gt 0 ]; do
	case "$1" in
		-i|--input)_INF="$2"
			shift 2
			;;
		-p|--paper)_PAPER="$2"
			shift 2
			;;
		-r|--rows)_ROWS="$2"
			shift 2
			;;
		-c|--cols)_COLUMNS="$2"
			shift 2
			;;
		--booklet)_BOOKLET=", booklet"
			shift 1
			;;
		*)	echo "$_usage"
			exit 1
			;;
	esac
done

[[ -z "$_INF" ]] && \
	{ error_msg "${0##*/}" "PDF inputfile is mandatory"; echo "$_usage"; exit 1; }

[[ -f $_INF ]] || \
	{ error_msg "${0##*/}" "Unable to find $_INF"; exit 1; }

file -b "$_INF" |grep -q "PDF" || \
	{ error_msg "${0##*/}" "$_INF doesn't look like a .pdf file"; exit 1; }

_FBASEN="${_INF%%\.*}"
mkdir -p "/tmp/ssrf_tmp_$$" || \
	{ error_msg "${0##*/}" "Unable to create $_TMP_DIR"; exit 1; }
cp "$_SRC_DIR/$_INF" "$_TMP_DIR/$_INF"
cd "$_TMP_DIR" || \
	{ error_msg "${0##*/}" "Unable to enter $_TMP_DIR"; exit 1; }

# beging building
#
report_msg "${0##*/}" "Building in $_TMP_DIR"
echo "
%/* vim: cindent tabstop=2 shiftwidth=2
\documentclass[spanish]{article}
\usepackage[final]{pdfpages}

\begin{document}
	\includepdf[pages=-, $_PAPER, nup=${_COLUMNS}x${_ROWS}$_BOOKLET]{$_INF}
\end{document}
" > "${_FBASEN}_processed.tex"

"$_PDFL" -interaction batchmode "${_FBASEN}_processed.tex"

# check if we have a .pdf file from pdflatex
#
[[ -f "${_FBASEN}_processed.pdf" ]] || \
	{ error_msg "${0##*/}" "pdflatex have failed, look for $_FBASEN.log in $_TMP_DIR"; exit 1; }
cp -b -u -v "${_FBASEN}_processed.pdf" "$_SRC_DIR/${_FBASEN}_processed.pdf"
report_msg "${0##*/}" "Building done. Check  $_SRC_DIR/${_FBASEN}_processed.pdf"

# At this point everything has gone smoothly, remove the tmp dir and quit
#
rm -rf "$_TMP_DIR"
