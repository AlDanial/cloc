#!/usr/bin/env python
import numpy as np

from pylab import gca

labels = ["Baseline", "System"]
data =   [3.75               , 4.75]
error =  [0.3497             , 0.3108]

xlocations = na.array(range(len(data)))+0.5
width = 0.6
# bar chart with hollow bars:
bar(xlocations, data, yerr=error, width=width, edgecolor='k', facecolor='none')
yticks(range(0, 8))
xticks(xlocations+ width/2, labels)
xlim(0, xlocations[-1]+width*2)
title("Average Ratings on the Training Set")
gca().get_xaxis().tick_bottom()
gca().get_yaxis().tick_left()

show()
