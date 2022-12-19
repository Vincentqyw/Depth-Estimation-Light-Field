#include "mex.h"
#include "math.h"
#include <stdlib.h>

/* Computes local STD */
// ********************************* USAGE IN MATLAB

/* Input Arguments */
#define	X_size_fin			prhs[0]
#define	Y_size_fin          prhs[1]
#define	Window_side         prhs[2]
#define	Stereo_diff         prhs[3]
// buffer
#define	Im_in_remap         prhs[4]

/* Output Arguments */
// buffer
#define	Im_out_remap        prhs[5]
#define	Output_image        prhs[6]

/* RULING ARGUMENT */
#define	Alpha               prhs[7]

// PADDING
int index_y(int y, int height)
	{
	if (0 <= y && y < height)
		return y;
    else if (y < 0)
        return 0;
    else
        return height-1;
	}
int index_x(int x, int width)
	{
	if (0 <= x && x < width)
		return x;
    else if (x < 0)
        return 0;
    else
        return width-1;
    }

void remapping
        (
        double * im_in_remap,
        double * im_out_remap,
        double * output_image,
        unsigned short width,
        unsigned short height,
        unsigned short window_side,
        unsigned short stereo_diff,
        double         alpha
        )
    {
    int                 x,y                                             ;
    unsigned int        x_1,x_2,y_1,y_2                                 ;
    int                 i,j                                             ;
    double              x_ind,y_ind                                     ;
    double              x_floor,y_floor                                 ;
    double              x_1_w,x_2_w,y_1_w,y_2_w                         ;
    unsigned int        x_1_index,x_2_index,y_1_index,y_2_index         ;
    unsigned int        x_index_remap,y_index_remap                     ;
    double              interp_color_R,interp_color_G,interp_color_B    ;
    double              output_color_R,output_color_G,output_color_B    ;
    unsigned int        height_of_remap, width_of_remap, pixels_of_remap;
    int                 window_size                                     ;
    
    window_size = window_side*window_side               ;
    
    height_of_remap = height*window_side                ;
    width_of_remap  = width*window_side                 ;
    pixels_of_remap = height_of_remap*width_of_remap    ;
    
    for (x = 0; x < width; ++x)
        for (y = 0; y < height; ++y)
        {
        output_color_R =0;
        output_color_G =0;
        output_color_B =0;
        
        for (i = -stereo_diff; i < stereo_diff+1; ++i)
            for (j = -stereo_diff; j < stereo_diff+1; ++j)
            {
            x_ind   = i*(1-1/alpha) + x;
            y_ind   = j*(1-1/alpha) + y;
            
            x_floor = floor(x_ind);
            y_floor = floor(y_ind);
            
            x_1     = index_x(x_floor  ,width );
            y_1     = index_y(y_floor  ,height);
            x_2     = index_x(x_floor+1,width );
            y_2     = index_y(y_floor+1,height);
            
            x_1_w   = 1-(x_ind-x_floor)        ;
            x_2_w   = 1-x_1_w                  ;
            y_1_w   = 1-(y_ind-y_floor)        ;
            y_2_w   = 1-y_1_w                  ;
            
            x_1_index = i+stereo_diff + (x_1)*window_side   ;
            y_1_index = j+stereo_diff + (y_1)*window_side   ;
            x_2_index = i+stereo_diff + (x_2)*window_side   ;
            y_2_index = j+stereo_diff + (y_2)*window_side   ;
            
            interp_color_R = y_1_w*x_1_w*im_in_remap[y_1_index+x_1_index*height_of_remap+0*pixels_of_remap]+
                             y_2_w*x_1_w*im_in_remap[y_2_index+x_1_index*height_of_remap+0*pixels_of_remap]+
                             y_1_w*x_2_w*im_in_remap[y_1_index+x_2_index*height_of_remap+0*pixels_of_remap]+
                             y_2_w*x_2_w*im_in_remap[y_2_index+x_2_index*height_of_remap+0*pixels_of_remap];
            interp_color_G = y_1_w*x_1_w*im_in_remap[y_1_index+x_1_index*height_of_remap+1*pixels_of_remap]+
                             y_2_w*x_1_w*im_in_remap[y_2_index+x_1_index*height_of_remap+1*pixels_of_remap]+
                             y_1_w*x_2_w*im_in_remap[y_1_index+x_2_index*height_of_remap+1*pixels_of_remap]+
                             y_2_w*x_2_w*im_in_remap[y_2_index+x_2_index*height_of_remap+1*pixels_of_remap];
            interp_color_B = y_1_w*x_1_w*im_in_remap[y_1_index+x_1_index*height_of_remap+2*pixels_of_remap]+
                             y_2_w*x_1_w*im_in_remap[y_2_index+x_1_index*height_of_remap+2*pixels_of_remap]+
                             y_1_w*x_2_w*im_in_remap[y_1_index+x_2_index*height_of_remap+2*pixels_of_remap]+
                             y_2_w*x_2_w*im_in_remap[y_2_index+x_2_index*height_of_remap+2*pixels_of_remap];
            
           
            
            // CORRESPONDENCE ANALYSIS
            x_index_remap = i+stereo_diff + (x)*window_side   ;
            y_index_remap = j+stereo_diff + (y)*window_side   ;
            
            im_out_remap[y_index_remap + x_index_remap*height_of_remap + 0*pixels_of_remap] = interp_color_R;
            im_out_remap[y_index_remap + x_index_remap*height_of_remap + 1*pixels_of_remap] = interp_color_G;
            im_out_remap[y_index_remap + x_index_remap*height_of_remap + 2*pixels_of_remap] = interp_color_B;
            
            // DEFOCUS ANALYSIS
            output_color_R = interp_color_R + output_color_R;
            output_color_G = interp_color_G + output_color_G;
            output_color_B = interp_color_B + output_color_B;
            
            }
        output_image[y + x * height + 0 * height*width] = output_color_R/window_size;
        output_image[y + x * height + 1 * height*width] = output_color_G/window_size;
        output_image[y + x * height + 2 * height*width] = output_color_B/window_size;
        
        }
    }

// /* Input Arguments */
// #define	X_size_fin			prhs[0]
// #define	Y_size_fin          prhs[1]
// #define	Window_side         prhs[2]
// #define	Stereo_diff         prhs[3]
// // buffer
// #define	Im_in_remap         prhs[4]
// 
// /* Output Arguments */
// // buffer
// #define	Im_out_remap        prhs[5]

void mexFunction( int nlhs, mxArray *plhs[], int nrhs, const mxArray*prhs[])

	{ 
	double *x_size_fin_pt, *y_size_fin_pt, *window_side_pt, *stereo_diff_pt, *im_in_remap_pt, *im_out_remap_pt, *output_image_pt, *alpha_pt;

	/* Check for proper number of arguments */

	if (nrhs != 8)  
		mexErrMsgTxt("Eight input arguments required."); 
	else if (nlhs > 1)
		mexErrMsgTxt("Too many output arguments."); 
 
	
    
	/* Assign pointers to the various parameters */ 

	x_size_fin_pt           = (double *) mxGetPr(X_size_fin)    ;
	y_size_fin_pt           = (double *) mxGetPr(Y_size_fin)    ;
	window_side_pt          = (double *) mxGetPr(Window_side)   ;
	stereo_diff_pt          = (double *) mxGetPr(Stereo_diff)   ;
    im_in_remap_pt          = (double *) mxGetPr(Im_in_remap)   ;
	im_out_remap_pt         = (double *) mxGetPr(Im_out_remap)  ;
    output_image_pt         = (double *) mxGetPr(Output_image)  ;
    alpha_pt                = (double *) mxGetPr(Alpha)         ;

	/* Do the actual computations in a subroutine */
    remapping
        (
        im_in_remap_pt,
        im_out_remap_pt,
        output_image_pt,
        *x_size_fin_pt,
        *y_size_fin_pt,
        *window_side_pt,
        *stereo_diff_pt,
        *alpha_pt
        );
            
    
	return;
	}