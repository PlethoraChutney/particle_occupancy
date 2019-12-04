# cisTEM / Frealign particle comparison scripts

## Purpose
These scripts read in par files and determine which class each particle belongs
to by comparing their occupancy scores across the different par files for a given
classification. These class memberships can then be used to identify a particle
by its membership in various classes across different focused classification
runs.

For instance, focused classification on two different regions of a map (
classifications A and B) will result in two different sets of five classes each
(A1-A5 and B1-B5). One may be interested in finding particles that are a member
of both class A1 and B3, or class A2 and B3-B5. These scripts help you do that.

## Use
### Required R libraries
 * tidyverse
 * ggplot2
 * treemapify
 * ggupset
 * UpSetR
 * RColorBrewer

### Script functions
First, run the python script to read in the par files (giving the numbers of each
reconstruction so it knows how to split them up). This script simply combines
the occupancy column of each par file and separates them by run into alpha and
gamma occupancy star files.

Next, you must manually edit the R script to indicate which class is what state
of protein, and how to group the classes. All of this hardcoding is at the top
of the script. The R script generates a treemap of particle states as well as
two simpler treemaps. It also creats an Upset chart, which is a series of
barcharts with category information displayed below them. Finally, the R script
also spits out two csv files which are a single column each, containing particle
numbers that are fully cleaved or fully uncleaved, respectively.

To make a new star file, first you'll need to clone Craig's pystar from
https://github.com/PlethoraChutney/pystar.git. Next, run `star_maker.py` and
tell it where your input .star (from cisTEM or wherever you got the par files from)
is, where your desired class .csv file is (from the R script), and where you want
it to save the resulting filtered .star file.
