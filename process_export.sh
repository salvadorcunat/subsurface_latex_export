#!/bin/bash

_usage="
	A tiny script to process subsurface's latex exported files and append
	the resulting pdf to a preexistent pdf divelog if any.
	Depends on latex, pdflatex and pdfunite (poppler-utils package in debian).

	process_export.sh [-n] [-o originaldivelog.pdf] -i ssrfexporteddives.tex
	"
BLUE="\033[0;34m"
GREEN="\033[0;32m"
LIGHT_RED="\033[1;31m"
DEFAULT="\033[0m"
report_msg()
{
	printf " -- %b --> %b\n" "$BLUE$1$DEFAULT" "$GREEN$2$DEFAULT" || return 1
}
error_msg()
{
	printf " -- %b --> %b\n" "$BLUE$1$DEFAULT" "$LIGHT_RED$2$DEFAULT" || return 1
}

_PDFL="$(command -v pdflatex)"; [[ -z $_PDFL ]] && { error_msg "${0##*/}" "Unable to find pdflatex"; exit 1; }
_PDFU="$(command -v pdfunite)"; [[ -z $_PDFU ]] && { error_msg "${0##*/}" "Unable to find pdfunite"; exit 1; }
# check arguments
# we need an input file at least
#
if [ "$#" -lt 2 ]; then
	echo "$_usage"
	exit 1
fi
_SRC_DIR="$PWD"
_OUTF="divelog.pdf"		# a default value for output file
_TMP_DIR="/tmp/ssrf_tmp_$$"
_APPEND=0			# default value no append

while [ "$#" -gt 0 ]; do
	case "$1" in
		-i|--input)_INF="$2"
			shift 2
			;;
		-o|--output)_OUTF="$2"
			shift 2
			_APPEND=1
			;;
		-n|--noappend)	_APPEND=0
			shift 1
			;;
		*)	echo "$_usage"
			exit 0
			;;
	esac
done

# check input file. Must be a .tex file.
#
[[ -f $_INF ]] || \
	{ error_msg "${0##*/}" "Unable to find $_INF"; exit 1; }
_FTYPE="${_INF##*\.}"; [[ $_FTYPE != "tex" ]] && { error_msg "${0##*/}" "$_INF doesn't look like a .tex file"; exit 1; }
_FBASEN="${_INF%%\.*}"

# we should have a file named subsurfacelatextemplate.tex in $_SRC_DIR
#
[[ -f "$_SRC_DIR/subsurfacelatextemplate.tex" ]] || \
	{ error_msg "${0##*/}" "Unable to find subsurface's latex template in $_SRC_DIR"; exit 1; }
mkdir -p "/tmp/ssrf_tmp_$$" || \
	{ error_msg "${0##*/}" "Unable to create $_TMP_DIR"; exit 1; }
cp "$_SRC_DIR/subsurfacelatextemplate.tex" "$_TMP_DIR/subsurfacelatextemplate.tex"
cp "$_SRC_DIR/subsurfacelatextemplate_A4.tex" "$_TMP_DIR/subsurfacelatextemplate_A4.tex"
cp "$_SRC_DIR/$_INF" "$_TMP_DIR/$_INF"
cp ./*.png "$_TMP_DIR"
cd "$_TMP_DIR" || \
	{ error_msg "${0##*/}" "Unable to enter $_TMP_DIR"; exit 1; }

# Build .pdf
#
report_msg "${0##*/}" "Building $_FBASEN in $_TMP_DIR"
"$_PDFL" -interaction batchmode "$_INF"
echo -e ""

# check if we have a .pdf file from pdflatex
#
[[ -f "$_FBASEN.pdf" ]] || \
	{ error_msg "${0##*/}" "pdflatex have failed, look for $_FBASEN.log in $_TMP_DIR"; exit 1; }

# If we just want to build the .tex file copy the .pdf and exit
#
cp -b -u -v "$_FBASEN.pdf" "$_SRC_DIR/$_FBASEN.pdf"
if [ "$_APPEND" -eq 0 ]; then
	report_msg "${0##*/}" "No append or no output selected. $_TMP_DIR/$_FBASEN.pdf built."
	cd "$_SRC_DIR"
	rm -rf "$_TMP_DIR"
	exit 0
fi
# Keep on going
#
"$_PDFU" "$_SRC_DIR/$_OUTF" "$_FBASEN.pdf" "$_OUTF" || \
	{ error_msg "${0##*/}" "$_PDFU failed, check $_TMP_DIR"; exit 1; }
[[ -f "$_OUTF" ]] || \
	{ error_msg "${0##*/}" "$_PDFU failed, check $_TMP_DIR"; exit 1; }
cd "$_SRC_DIR"
# Be extra careful and backup the original divelog file
#
cp -b -u -v "$_TMP_DIR/$_OUTF" "./$_OUTF"

# At this point everything has gone smoothly, remove the tmp dir and quit
#
rm -rf "$_TMP_DIR"
