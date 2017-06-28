// A Quick Tour of Stata
// Germán Rodríguez - Fall 2015
/*
 http://data.princeton.edu/stata/
*/

version 14
clear
capture log close
log using QuickTour, text replace

display 2+2
display 2 * ttail(20,2.1)

// load sample data and inspect
sysuse lifeexp
desc
summarize lexp gnppc
list country gnppc if missing(gnppc)

graph twoway scatter lexp gnppc, ///
  title(Life Expectancy and GNP ) xtitle(GNP per capita)
// save the graph in PNG format
graph export scatter.png, width(400) replace	
gen loggnppc = log(gnppc)
regress lexp loggnppc

predict plexp

graph twoway (scatter lexp loggnppc) (lfit lexp loggnppc) ///
	,  title(Life Expectancy and GNP) xtitle(log GNP per capita)
graph export fit.png, width(400) replace

list country lexp plexp if lexp < 55, clean
list gnppc loggnppc lexp plexp if country == "United States", clean
log close
