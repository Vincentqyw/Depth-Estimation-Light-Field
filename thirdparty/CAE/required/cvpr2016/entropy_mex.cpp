#include "mex.h"
#include "math.h"
#include <stdlib.h>
#include <iostream>
#include <vector>

// Input Parameter
#define	Xres                prhs[0]
#define	Yres                prhs[1]
#define	Angular_size        prhs[2]
#define	Angular_radius      prhs[3]
#define	Sigma               prhs[4]

// Input Array
#define	Im_in_remap         prhs[5]

// Output Array
#define	Output_response     prhs[6]

using namespace std;

void corresp_cost
        (
            double * im_in_remap,
            double * response,
            int width,
            int height,
            int angular_size,
            int angular_radius,
            double sigma
        )
{
    int                 x,y;
    int                 i,j;
    int                 x_ind,y_ind;    
    int                 height_of_remap, width_of_remap, pixels_of_remap;
    int                 angular_area;
        
    float max_val;
    float pixel;
    int index;
    float cR,cG,cB;
    float sumR,sumG,sumB;
    float correspR,correspG,correspB;
    
    angular_area = angular_size*angular_size;
    height_of_remap = height*angular_size;
    width_of_remap  = width*angular_size;
    pixels_of_remap = height_of_remap*width_of_remap;    
    
    float *center_patch = (float*)malloc(sizeof(float)*angular_area*3);  
    float *histR1 = (float*)malloc(sizeof(float)*256);
    float *histG1 = (float*)malloc(sizeof(float)*256);
    float *histB1 = (float*)malloc(sizeof(float)*256);
    
    for (y = 0; y < height; y++)
    {       
        for (x = 0; x < width; x++)
        {
            memset(histR1,0,sizeof(float)*256);
            memset(histG1,0,sizeof(float)*256);
            memset(histB1,0,sizeof(float)*256);
            
            x_ind = (int)(angular_size/2) + x * angular_size;
            y_ind = (int)(angular_size/2) + y * angular_size;
            cR = im_in_remap[y_ind + x_ind*height_of_remap + 0*pixels_of_remap];
            cG = im_in_remap[y_ind + x_ind*height_of_remap + 1*pixels_of_remap];
            cB = im_in_remap[y_ind + x_ind*height_of_remap + 2*pixels_of_remap];
            
            for (i = 0; i < angular_size; i++)
            {
                for (j = 0; j < angular_size; j++)
                {
                    x_ind = j + x * angular_size;
                    y_ind = i + y * angular_size;                    
                    
                    center_patch[(i*angular_size+j)*3+0] = im_in_remap[y_ind + x_ind*height_of_remap + 0*pixels_of_remap];
                    center_patch[(i*angular_size+j)*3+1] = im_in_remap[y_ind + x_ind*height_of_remap + 1*pixels_of_remap];
                    center_patch[(i*angular_size+j)*3+2] = im_in_remap[y_ind + x_ind*height_of_remap + 2*pixels_of_remap];
                    
                    pixel = center_patch[(i*angular_size+j)*3+0];
                    index = round(pixel);
                    histR1[index] = histR1[index] + 1;
                    
                    pixel = center_patch[(i*angular_size+j)*3+1];
                    index = round(pixel);
                    histG1[index] = histG1[index] + 1;
                    
                    pixel = center_patch[(i*angular_size+j)*3+2];
                    index = round(pixel);
                    histB1[index] = histB1[index] + 1;
                }
            }
            for(i=0;i<256;i++)
            {
                histR1[i] = histR1[i] / (float)(angular_area);
                histG1[i] = histG1[i] / (float)(angular_area);
                histB1[i] = histB1[i] / (float)(angular_area);
            }
            
            max_val = 0;
            for(i=0;i<256;i++)
            {
                if(histR1[i] > 0)
                    max_val += log(histR1[i]) * histR1[i];
            }
            correspR = max_val * -1;
            
            max_val = 0;
            for(i=0;i<256;i++)
            {
                if(histG1[i] > 0)
                    max_val += log(histG1[i]) * histG1[i];
            }
            correspG = max_val * -1;
            
            max_val = 0;
            for(i=0;i<256;i++)
            {
                if(histB1[i] > 0)
                    max_val += log(histB1[i]) * histB1[i];
            }
            correspB = max_val * -1;
            response[y + x * height] = (correspR + correspG + correspB) / 3.0;
        }
    }
    
    free(center_patch);
    free(histR1);
    free(histG1);
    free(histB1);
}

void mexFunction( int nlhs, mxArray *plhs[], int nrhs, const mxArray*prhs[])
{ 
	double *xres_pt, *yres_pt, *angular_size_pt, *angular_radius_pt, *sigma_pt, *im_in_remap_pt, *output_response_pt;

	if (nrhs != 7)  
		mexErrMsgTxt("Seven input arguments required."); 
	else if (nlhs > 1)
		mexErrMsgTxt("Too many output arguments."); 
 
	// Assign pointers to the various parameters
	xres_pt           = (double *) mxGetPr(Xres)    ;
	yres_pt           = (double *) mxGetPr(Yres)    ;
	angular_size_pt          = (double *) mxGetPr(Angular_size)   ;
	angular_radius_pt          = (double *) mxGetPr(Angular_radius)   ;
	sigma_pt          = (double *) mxGetPr(Sigma)   ;
    im_in_remap_pt          = (double *) mxGetPr(Im_in_remap)   ;
    output_response_pt         = (double *) mxGetPr(Output_response)  ;

	// Call function
    corresp_cost
        (
            im_in_remap_pt,
            output_response_pt,
            *xres_pt,
            *yres_pt,
            *angular_size_pt,
            *angular_radius_pt,
            *sigma_pt
        );
                
	return;
	}