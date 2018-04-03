#include "mex.h"
#include "math.h"
#include <stdlib.h>
#include <iostream>
#include <vector>

/* Input Arguments */
#define	X_size_fin			prhs[0]
#define	Y_size_fin          prhs[1]
#define	Window_side         prhs[2]
#define	Stereo_diff         prhs[3]
// buffer
#define	Im_in_remap         prhs[4]
#define	Im_refocus         prhs[5]

/* Output Arguments */
// buffer
#define	Output_responseR        prhs[6]
#define	Output_responseG        prhs[7]
#define	Output_responseB        prhs[8]

using namespace std;

void hist_cost
        (
        double * im_in_remap,
        double * im_refocus,
        double * responseR,
        double * responseG,
        double * responseB,
        unsigned short width,
        unsigned short height,
        unsigned short window_side,
        unsigned short stereo_diff
        )
    {
    int                 x,y                                             ;
    int                 i,j                                             ;
    int                 k,l                                             ;
    int              x_ind,y_ind                                     ;
    unsigned int        height_of_remap, width_of_remap, pixels_of_remap;
    int                 window_size                                     ;
    float maxHist;
    float pixel = 0;
    
    window_size = window_side*window_side               ;
    
    float *center_patch = (float*)malloc(sizeof(float)*window_size*3);  
    float *histR = (float*)malloc(sizeof(float)*256);
    float *histG = (float*)malloc(sizeof(float)*256);
    float *histB = (float*)malloc(sizeof(float)*256);
    float *temp = (float*)malloc(sizeof(float)*256);
    
    height_of_remap = height*window_side                ;
    width_of_remap  = width*window_side                 ;
    pixels_of_remap = height_of_remap*width_of_remap    ;
    
    for (y = 0; y < height; ++y)
    {       
        for (x = 0; x < width; ++x)
        {
            memset(histR,0,sizeof(float)*256);
            memset(histG,0,sizeof(float)*256);
            memset(histB,0,sizeof(float)*256);
            for (i = 0; i < window_side; i++)
            {
                for (j = 0; j < window_side; j++)
                {
                    x_ind = j + (x)*window_side   ;
                    y_ind = i + (y)*window_side   ;                    
                    
                    center_patch[(i*window_side+j)*3+0] = im_in_remap[y_ind + x_ind*height_of_remap + 0*pixels_of_remap];
                    center_patch[(i*window_side+j)*3+1] = im_in_remap[y_ind + x_ind*height_of_remap + 1*pixels_of_remap];
                    center_patch[(i*window_side+j)*3+2] = im_in_remap[y_ind + x_ind*height_of_remap + 2*pixels_of_remap];

                    pixel = center_patch[(i*window_side+j)*3+0];
                    histR[(int)pixel] = histR[(int)pixel] + 1;
                    pixel = center_patch[(i*window_side+j)*3+1];
                    histG[(int)pixel] = histG[(int)pixel] + 1;
                    pixel = center_patch[(i*window_side+j)*3+2];
                    histB[(int)pixel] = histB[(int)pixel] + 1;
                }
            }
            for(i=0;i<256;i++)
            {
                histR[i] = histR[i] / (float)window_size;
            }

            maxHist = 0;
            for(i=0;i<256;i++)
            {
                if(histR[i] > 0)
                    maxHist += log(histR[i]) * histR[i];
            }
            maxHist *= -1;             
            responseR[y + x * height] = maxHist;
            
            
            for(i=0;i<256;i++)
            {
                histG[i] = histG[i] / (float)window_size;
            }
            maxHist = 0;
            for(i=0;i<256;i++)
            {
                if(histG[i] > 0)
                    maxHist += log(histG[i]) * histG[i];
            }
            maxHist *= -1;
            responseG[y + x * height] = maxHist;
            
            
            for(i=0;i<256;i++)
            {
                histB[i] = histB[i] / (float)window_size;
            }
            maxHist = 0;
            for(i=0;i<256;i++)
            {                
                if(histB[i] > 0)
                    maxHist += log(histB[i]) * histB[i];
            }
            maxHist *= -1;
            responseB[y + x * height] = maxHist;
        }
    }
    
    free(center_patch);
    free(histR);
    free(histG);
    free(histB);
    free(temp);
}

void mexFunction( int nlhs, mxArray *plhs[], int nrhs, const mxArray*prhs[])

	{ 
	double *x_size_fin_pt, *y_size_fin_pt, *window_side_pt, *stereo_diff_pt, *im_in_remap_pt, *output_responseR_pt, *output_responseG_pt, *output_responseB_pt, *im_refocus_pt;

	/* Check for proper number of arguments */
	if (nrhs != 9)  
		mexErrMsgTxt("Seven input arguments required."); 
	else if (nlhs > 1)
		mexErrMsgTxt("Too many output arguments."); 
 
	/* Assign pointers to the various parameters */ 

	x_size_fin_pt           = (double *) mxGetPr(X_size_fin)    ;
	y_size_fin_pt           = (double *) mxGetPr(Y_size_fin)    ;
	window_side_pt          = (double *) mxGetPr(Window_side)   ;
	stereo_diff_pt          = (double *) mxGetPr(Stereo_diff)   ;
    im_in_remap_pt          = (double *) mxGetPr(Im_in_remap)   ;
    im_refocus_pt          = (double *) mxGetPr(Im_refocus)   ;
    output_responseR_pt         = (double *) mxGetPr(Output_responseR)  ;
    output_responseG_pt         = (double *) mxGetPr(Output_responseG)  ;
    output_responseB_pt         = (double *) mxGetPr(Output_responseB)  ;

	/* Do the actual computations in a subroutine */
    hist_cost
        (
        im_in_remap_pt,
        im_refocus_pt,
        output_responseR_pt,
        output_responseG_pt,
        output_responseB_pt,
        *x_size_fin_pt,
        *y_size_fin_pt,
        *window_side_pt,
        *stereo_diff_pt
        );
                
	return;
	}