#!/bin/bash
# By Sandylaw <waytoarcher@gmail.com>
# Fri, 04 Dec 2020 09:49:21 PM +0800
function k2pdf() {
	local file=${1}
	if [ -f "${file}" ]; then
		k2pdfopt -dev kv -ocr -ocrlang eng+chi_sim -wrap+ -x -ws 0.01 -as- -c -ui- "${file}"
	else
		echo "Please check the pdf file."
	fi
}
k2pdf "${1}"
