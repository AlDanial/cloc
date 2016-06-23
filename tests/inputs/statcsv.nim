# Example program to show the parsecsv module
# This program reads a CSV file and computes sum, mean, minimum, maximum and
# the standard deviation of its columns.
# The CSV file can have a header which is then used for the output.

import os, streams, parsecsv, strutils, math, stats

if paramCount() < 1:
  quit("Usage: statcsv filename[.csv]")

var filename = addFileExt(paramStr(1), "csv")
var s = newFileStream(filename, fmRead)
if s == nil: quit("cannot open the file " & filename)

var
  x: CsvParser
  header: seq[string]
  res: seq[RunningStat]
open(x, s, filename, separator=';', skipInitialSpace = true)
while readRow(x):
  if processedRows(x) == 1:
    newSeq(res, x.row.len) # allocate space for the result
    if validIdentifier(x.row[0]):
      # header line:
      header = x.row
    else:
      newSeq(header, x.row.len)
      for i in 0..x.row.len-1: header[i] = "Col " & $(i+1)
  else:
    # data line:
    for i in 0..x.row.len-1:
      push(res[i], parseFloat(x.row[i]))
x.close()

# Write results:
for i in 0..header.len-1:
  stdout.write("\t")
  stdout.write(header[i])
stdout.write("\nSum")
for i in 0..header.len-1:
  stdout.write("\t")
  stdout.write(res[i].sum)
stdout.write("\nMean")
for i in 0..header.len-1:
  stdout.write("\t")
  stdout.write(res[i].mean)
stdout.write("\nMin")
for i in 0..header.len-1:
  stdout.write("\t")
  stdout.write(res[i].min)
stdout.write("\nMax")
for i in 0..header.len-1:
  stdout.write("\t")
  stdout.write(res[i].max)
stdout.write("\nStdDev")
for i in 0..header.len-1:
  stdout.write("\t")
  stdout.write(res[i].standardDeviation)
stdout.write("\n")
