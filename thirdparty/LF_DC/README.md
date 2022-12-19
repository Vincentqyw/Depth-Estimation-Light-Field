This package contains the following:

**I.  compute_LFdepth.m   : estimates depth of a Lytro LF Image**

**II. raw2jpeg/raw2jpeg.m : converts lytro .lfp image to .jpeg**


**demo_run** is an example for compute_LFdepth.m
raw2jpeg/demo_run is an example for raw2jpeg.m



# I. compute_LFdepth
computes the depth estimation of a Lytro LF Image

**Input**  : file_path    (file path to the .jpeg file)

**Output** : depth_output (x,y) buffer that contains 0-255; 0 is closest, 255 is farthest

NOTE   : This function supports our Lytro camera. Lytro cameras have manufacturing inconsistencies for the micro-lens array.

## SYSTEM REQUIREMENTS:
PC/MAC/LINUX
MATLAB 2009B (tested)

## CONTACT:
Michael W. Tao (mtao@eecs.berkeley.edu)

## TERMS OF USE : 
Any scientific work that makes use of our code should appropriately mention this in the text and cite our ICCV 2013 paper. For commerical use, please contact us.

## PAPER TO CITE:
Michael W. Tao, Sunil Hadap, Jitendra Malik, and Ravi Ramamoorthi. [Depth
from Combining Defocus and Correspondence Using Light-Field Cameras](http://graphics.berkeley.edu/papers/Tao-DFC-2013-12/). In Proceedings of International Conference on Computer Vision (ICCV), 2013.

## BIBTEX TO CITE:
@inproceedings{Tao13,
author={Tao, {M. W.} and Hadap, S. and Malik, J. and Ramamoorthi, R.},
title={Depth from combining defocus and correspondence using light-field cameras},
year={2013},
booktitle={ICCV}
}

Copyright (c) 2013 All rights reserved.
Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

* Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
* Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
* Proper citation to the paper above

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED  ARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.


## LYTRO COPYRIGHT
We are not affiliated, associated, authorized, endorsed by, or in any way officially connected with Lytro, or any of its subsidiaries or its affiliates. The official Lytro web site is available at www.lytro.com. All Lytro hardware, software, etc. are registered trademarks of Lytro.

## ACKNOWLEDGEMENTS
We thank Jon Barron for the code on the MRF regularizer.





#  II. raw2jpeg
converts lfp to jpeg

Input  : file_path    (file path to the .lfp file)
Output : jpeg         jpeg version of the lfp
                      (single channel, requires demosaicing using 'rggb')

## SYSTEM REQUIREMENTS:
MAC/LINUX
MATLAB 2009B (tested)

## CONTACT:
nrpatel (https://github.com/nrpatel/lfptools)

## TERMS OF USE : 
https://github.com/nrpatel/lfptools

## ACKNOWLEDGEMENTS :
We thank nrpatel from github for contributing to the lfptools. The original
website can be accessed here: https://github.com/nrpatel/lfptools

## LFPTOOLS NOTES :
Platform independent tools for working with Lytro LFP files.

Lytro has not announced much about their file formats other than that they have software for OS X and will have Windows supported in 2012.  To enable support for other platforms, it will be useful to develop open source software to process their files.

This tool supports both the large raw files that come from the Lytro camera and the compressed files that the desktop software produces for web display.

Note: The description below refers to .lfp file format for files generated using Lytro's Version 1 processing software. See README_V2 for a description of .lfp format changes as of Lytro's December 2012 update (Version 2).

## .lfp file format

The file itself is formatted as follows.  First, a header:

    # magic 12 byte header (LFP)
    89 4C 46 50 0D 0A 1A 0A 00 00 00 01
    # 4 byte length (0, since there is nothing in this section)
    00 00 00 00

After this are a number of sections.  The data in the first is plain text JSON table of contents describing what the rest of the sections in the file contain.  The remaining sections can be additional metadata, a depth lookup table, compressed jpg images, or raw sensor data depending on the file. The sections are formatted as follows:

    # magic 12 byte header (containing a type like LFM or LFC)
    89 4C 46 4D 0D 0A 1A 0A 00 00 00 00
    # 4 byte length, not including header, sha1, or null padding
    00 00 07 A7
    # 45 bytes of sha1 hash as hex in ascii
    73 68 61 31 ...
    # 35 bytes of null padding
    00 00 00 00 ...
    # the data of length previously specified
    7B 22 70 69 ...
    # 0 or more bytes of null padding
    00 00 00 00 ...

## .lfp web files

The Lytro desktop app exports compressed representations of the light field captured by the Lytro camera to reduce file times and rendering requirements for web display.  The .lfp files are simply a set of JPEG files representing the unique visually interesting sections of the light field.  That is, a set in which each image shows a different area in focus.  It appears to do so dynamically, picking the minimum number of images necessary to show all *focusable* objects in narrow depths of field.

These images are stored along with their estimated depths and a depth lookup
table for the image.  This allows for HTML5 and Flash applications in which the
user clicks on a region of the image, the value of that region is looked up,
and the depth image closest to that value is displayed.

## .lfp raw files

The files that come directly from the camera are roughly 16MB, made primarily of one section which is a raw Bayer array of the 3280 x 3280 pixel sensor. There are also two metadata files, one containing detailed information about the format of the captured image, and the other containing serial numbers.

## lfpsplitter

lfpsplitter is a commandline tool that reads in a .lfp file and splits it into a plaintext metadata file, a plaintext listing of the depth lookup table, and the component jpgs.

    make
        gcc -O3 -Wall    -c -o lfpsplitter.o lfpsplitter.c
        gcc -o lfpsplitter lfpsplitter.o  -O3 -Wall 

    ./lfpsplitter IMG_0001.lfp
        Saved IMG_0001_table.json
        Saved IMG_0001_imageRef0.raw
        Saved IMG_0001_metadataRef.json
        Saved IMG_0001_privateMetadataRef.json

    ./lfpsplitter IMG_0001-stk.lfp
        Saved IMG_0001-stk_table.json
        Saved IMG_0001-stk_depth.txt
        Saved IMG_0001-stk_0.jpg
        Saved IMG_0001-stk_1.jpg
        Saved IMG_0001-stk_2.jpg
        Saved IMG_0001-stk_3.jpg
