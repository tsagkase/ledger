#!/bin/bash

# This script facilities plotting of a ledger register report.  If you
# use OS/X, and have AquaTerm installed, you will probably want to set
# LEDGER_TERM to "aqua".
#
# It is based on work found at https://www.sundialdreams.com/report-scripts-for-ledger-cli-with-gnuplot/
#
# Examples of use:
#
#   monthly-income-vs-expenses ledger.dat

usage() {
	echo "Usage: $0 ledger-data-file [period]"
	exit 1
}

err_report() {
    echo "Error on line $1"
}

trap 'err_report $LINENO' ERR


if [ $# -lt 1 ] || [ $# -gt 2 ] ; then
    usage
else
    LEDGER_DATA_FILE=$1
fi

if [ $# -eq 2 ] ; then
    PERIOD=$2
fi

if [ -z "$LEDGER_TERM" ]; then
  LEDGER_TERM="x11 size 1280,720 persist"
fi

if [ -n "$PERIOD" ]; then
	ledger -f $LEDGER_DATA_FILE -j reg ^Income -M --collapse --empty --plot-amount-format="%(format_date(date, \"%Y-%m-%d\")) %(abs(quantity(scrub(display_amount))))\n" -p "$PERIOD" > ledgeroutput1.tmp
	ledger -f $LEDGER_DATA_FILE -j reg ^Expenses -M --collapse --empty -p "$PERIOD" > ledgeroutput2.tmp
else
	ledger -f $LEDGER_DATA_FILE -j reg ^Income -M --collapse --empty --plot-amount-format="%(format_date(date, \"%Y-%m-%d\")) %(abs(quantity(scrub(display_amount))))\n" > ledgeroutput1.tmp
	ledger -f $LEDGER_DATA_FILE -j reg ^Expenses -M --collapse --empty > ledgeroutput2.tmp
fi

# The following section is meant to catch a bug in ledger where --empty
# is not respected for empty initial entry
LINES_COUNT1=$(wc -l ledgeroutput1.tmp | cut -f1 -d\ )
LINES_COUNT2=$(wc -l ledgeroutput2.tmp | cut -f1 -d\ )
if [ $LINES_COUNT1 -ne $LINES_COUNT2 ]; then
	echo "ERROR: Income entries found to be $LINES_COUNT1 whilst expenses entries were $LINES_COUNT2. Exiting ..."
	exit -1
fi

(cat <<EOF) | gnuplot
  set terminal $LEDGER_TERM
  set style data histogram
  set style histogram clustered gap 1
  set style fill transparent solid 0.4 noborder
  set xtics nomirror scale 0 center
  set ytics add ('' 0) scale 0
  set border 1
  set grid ytics
  set title "Monthly Income and Expenses"
  set ylabel "Amount"
  plot "ledgeroutput1.tmp" using 2:xticlabels(strftime('%b ''%y', strptime('%Y-%m-%d', strcol(1)))) title "Income" linecolor rgb "light-salmon", '' using 0:2:2 with labels left font "Courier,8" rotate by 15 offset -4,0.5 textcolor linestyle 0 notitle, "ledgeroutput2.tmp" using 2 title "Expenses" linecolor rgb "light-green", '' using 0:2:2 with labels left font "Courier,8" rotate by 15 offset 0,0.5 textcolor linestyle 0 notitle
EOF

rm ledgeroutput*.tmp

