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
First, run the python script to read in the par files (giving the numbers of each
reconstruction so it knows how to split them up). This script simply combines
the occupancy column of each par file and separates them by run into a number of
`###_occupancies.csv` files, where `###` is the number cisTEM gives to the
reconstruction.

Next, you must manually edit the R script to indicate which class is what state
of protein, and how to group the classes. This will result in a graph of which
particles belong to which state, and you can also output a new par file of
just one (or more) states for further processing.
