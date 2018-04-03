#include "mex.h"
#include "math.h"
#include <stdlib.h>
#include <iostream>
#include <vector>

// Input Parameter
#define	Xres                prhs[0]
#define	Yres                prhs[1]
#define	Small_r             prhs[2]
#define	Large_r             prhs[3]
#define Gamma               prhs[4]

// Input Array
#define	Im_refocus          prhs[5]
#define	Im_pinhole          prhs[6]

// Output Array
#define	Output_response     prhs[7]

using namespace std;

void defocus_cost
        (
        double* im_pinhole,
        double* im_refocus,
        double* response,
        int width,
        int height,
        int small_r,
        int large_r,
        double gamma
        )
    {
    int                 x,y;
    int                 i,j;        
    int index;
    
    double diffR,diffG,diffB,diff_val;
    double avg;
    double min_avg;
    double total_val;
    
    int heightL = height + 2 * large_r;
    int widthL = width + 2 * large_r;
    int areaL = heightL*widthL;
    
    int small_diameter = small_r*2+1;
    int medium_radius = large_r - small_r;
    int medium_diameter = medium_radius*2+1;
    int medium_center = floor((medium_diameter*medium_diameter)/2);
    
    double *defocus_map = (double*)malloc(sizeof(double)*widthL*heightL);
    double *diff_map = (double*)malloc(sizeof(double)*widthL*heightL);
    
    int *offsetS = (int*)malloc(sizeof(int)*small_diameter*small_diameter);
    int *offsetM = (int*)malloc(sizeof(int)*medium_diameter*medium_diameter);
    int *offsetM_inv = (int*)malloc(sizeof(int)*medium_diameter*medium_diameter);
    double *center_diff = (double*)malloc(sizeof(double)*medium_diameter*medium_diameter);
    
    memset(defocus_map,0,sizeof(double)*widthL*heightL);
    memset(diff_map,0,sizeof(double)*widthL*heightL);    
    
    for(y = 0; y < heightL; y++)
    {
        for(x = 0; x < widthL; x++)
        {
            diffR = (im_refocus[y + heightL * x + 0 * areaL]-im_pinhole[y + heightL * x + 0 * areaL]) / 255;
            diffG = (im_refocus[y + heightL * x + 1 * areaL]-im_pinhole[y + heightL * x + 1 * areaL]) / 255;
            diffB = (im_refocus[y + heightL * x + 2 * areaL]-im_pinhole[y + heightL * x + 2 * areaL]) / 255;
            diff_map[y * widthL + x] = sqrt(diffR*diffR + diffG*diffG + diffB*diffB);
        }
    }
    
    index = 0;
    for(i = -small_r; i <= small_r; i++)
    {
        for(j = -small_r; j <= small_r; j++)
        {
            offsetS[index] = i * widthL + j;
            index++;
        }
    }
    
    for(y = small_r; y < heightL-small_r; y++)
    {
        for(x = small_r; x < widthL-small_r; x++)
        {
            avg = 0;
            for(index = 0; index < small_diameter*small_diameter; index++)
            {
                avg += diff_map[y * widthL + x + offsetS[index]];
            }
            avg /= (small_diameter*small_diameter);
            defocus_map[y * widthL + x] = avg;
        }
    }    
    
    index = 0;
    for(i = -medium_radius; i <= medium_radius; i++)
    {
        for(j = -medium_radius; j <= medium_radius; j++)
        {
            offsetM[index] = i * widthL + j;
            offsetM_inv[index] = i + heightL * j;
            index++;
        }
    }    
    
    for(y = medium_radius; y < heightL-medium_radius; y++)
    {
        for(x = medium_radius; x < widthL-medium_radius; x++)
        {
            min_avg = 1e20;
            for(index = 0; index < medium_diameter*medium_diameter; index++)
            {
                diffR = (im_pinhole[y + heightL * x + 0 * areaL + offsetM_inv[index]]-im_pinhole[y + heightL * x + 0 * areaL]) / 255;
                diffG = (im_pinhole[y + heightL * x + 1 * areaL + offsetM_inv[index]]-im_pinhole[y + heightL * x + 1 * areaL]) / 255;
                diffB = (im_pinhole[y + heightL * x + 2 * areaL + offsetM_inv[index]]-im_pinhole[y + heightL * x + 2 * areaL]) / 255;
                diff_val = sqrt(diffR*diffR + diffG*diffG + diffB*diffB);
                center_diff[index] = diff_val;
                if(min_avg > diff_val && index != medium_center)
                    min_avg = diff_val;
            }
            center_diff[medium_center] = min_avg;
            
            min_avg = 1e20;
            for(index = 0; index < medium_diameter*medium_diameter; index++)
            {
                total_val =  center_diff[index] + defocus_map[y * widthL + x + offsetM[index]] * gamma;
                if(min_avg > total_val)
                    min_avg = total_val;
            }
            diff_map[y * widthL + x] = min_avg;
        }
    }
    
    for(y = 0; y < height; y++)
    {
        for(x = 0; x < width; x++)
        {
            i = y + large_r;
            j = x + large_r;
            response[y + height * x] = diff_map[i * widthL + j];
        }
    }
    
    free(defocus_map);
    free(diff_map);
    free(offsetS);
    free(offsetM);
    free(offsetM_inv);
    free(center_diff);
}

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray* prhs[])
{ 
	double *xres_pt, *yres_pt, *small_r_pt, *large_r_pt, *gamma_pt, *im_pinhole_pt, *im_refocus_pt, *output_response_pt;

    if (nrhs != 8)  
		mexErrMsgTxt("Eight input arguments required."); 
	else if (nlhs > 1)
		mexErrMsgTxt("Too many output arguments."); 
 
	// Assign pointers to the various parameters
	xres_pt           = (double *) mxGetPr(Xres)    ;
	yres_pt           = (double *) mxGetPr(Yres)    ;
	small_r_pt          = (double *) mxGetPr(Small_r)   ;
	large_r_pt          = (double *) mxGetPr(Large_r)   ;
	gamma_pt          = (double *) mxGetPr(Gamma)   ;
    im_pinhole_pt          = (double *) mxGetPr(Im_pinhole)   ;
    im_refocus_pt          = (double *) mxGetPr(Im_refocus)   ;
    output_response_pt         = (double *) mxGetPr(Output_response)  ;
    
    // Call function
    defocus_cost
        (
            im_pinhole_pt,
            im_refocus_pt,
            output_response_pt,
            *xres_pt,
            *yres_pt,
            *small_r_pt,
            *large_r_pt,
            *gamma_pt
        );
                
	return;
	}