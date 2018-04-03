#include "mex.h"
#include "math.h"
#include <stdlib.h>
#include <string.h>

/* Computes local STD */
// ********************************* USAGE IN MATLAB
// double* output = FAST_STDFILT(double* input, double radius)

/* Output Arguments */
#define	Image_OutC          plhs[0]

/* Input Arguments */
#define	Image_InC			prhs[0]
#define	RADIUS      	    prhs[1]

/* Intermediate Buffers */
// original image
int         CANVAS_WIDTH             ;
int         CANVAS_HEIGHT            ;
// padding
double *    Image_In_Padded_R        ;
double *    Image_In_Padded_G        ;
double *    Image_In_Padded_B        ;
double *    Image_Out_Padded_R       ;
double *    Image_Out_Padded_G       ;
double *    Image_Out_Padded_B       ;
int         PAD_WIDTH                ;
int         PAD_HEIGHT               ;
int         image_pad_size           ;

double fastSqrt_2(const double x)  
	{
	union
		{
		long i;
		double x;
		} u;
	u.x = x;
	u.i = (((long)1)<<61) + (u.i >> 1) - (((long)1)<<51); 
	return u.x;
	}
	
double square(double x)
	{
	return x*x;
	}
       
void fast_stdfilt
                       (
                       double *Src,
                       double *Dst,
                       int height,
                       int width,
                       int radius,
                       int row_offset
                       )
    {
	/* iterators */
	int h,w,j,i;

	double val;
	double summation  ;
	double summation_2;
    
    double *columnssums;
    double *columnssums_2;
    
	double weight = 1/((2*(double)radius+1)*(2*(double) radius+1));

	/* used to store the column summations */
	columnssums = (double*) malloc(sizeof(double)*(width+2*radius));
	memset(columnssums,0.0f,sizeof(double)*(width+2*radius));
	columnssums_2 = (double*) malloc(sizeof(double)*(width+2*radius));
	memset(columnssums_2,0.0f,sizeof(double)*(width+2*radius));
        
	/********************** first row: uses the Huang's method */

	/* hardcode the first window */
	summation   = 0;
	summation_2 = 0;
	for (i = -radius; i < radius+1; ++i)
		{
		for (j = -radius; j < radius+1; ++j)
			{
			val              = Src[j*row_offset+i];
			columnssums[i+radius]  += val;
			summation       += val;
			val              = val*val;
			columnssums_2[i+radius]+= val;
			summation_2     += val;
			}
		}
		
	Dst[0*row_offset+0]=fastSqrt_2(summation_2*weight-square(summation*weight));

	/* Huang's method the first row */
	for (w = 1; w < width; ++w)
		{
		for (j = -radius; j < radius+1; ++j)
			{
			/* subtract old */
			i			 = w-radius-1;
			
			val			 = Src[j*row_offset+i];
			summation   -= val;
			
			val			 = val*val;
			summation_2 -= val;
			/* add new */
			i			 = w+radius;
			
			val			 = Src[j*row_offset+i];
			summation	+= val;
			columnssums[i+radius] += val;

			val			 = val*val;
			summation_2 += val;
			columnssums_2[i+radius] += val;

			}
		Dst[0*row_offset+w]=fastSqrt_2(summation_2*weight-(summation*weight)*(summation*weight));
		}

	/********************** second row and beyond: uses the extended method */
	for (h = 1; h < height; ++h)
		{
		summation   = 0;
		summation_2 = 0;
		/* 1st- update all columns */
		for (i = -radius; i < radius+1; ++i)
			{
			/*minus top*/
			val = Src[(h-(radius+1))*row_offset];
			columnssums[i+radius] -= val;

			val = val*val;
			columnssums_2[i+radius] -= val;

			/*add bottom */
			val = Src[(h+radius)*row_offset];
			columnssums[i+radius] += val;

			val = val*val;
			columnssums_2[i+radius] += val;

			summation   += columnssums[i+radius];
			summation_2 += columnssums_2[i+radius];
			}
			
		Dst[h*row_offset+0]=fastSqrt_2(summation_2*weight-(summation*weight)*(summation*weight));
		/* 2nd+ - update summation */

		for (w= 1; w <width; ++w)
			{
			/*minus left*/
			i=w-(radius+1);
			summation   -= columnssums[i+radius];
			summation_2 -= columnssums_2[i+radius];
			/*add right*/
			i=w+radius;
			columnssums[i+radius]   -= Src[(h-(radius+1))*row_offset+i];
			columnssums_2[i+radius] -= square(Src[(h-(radius+1))*row_offset+i]);
			columnssums[i+radius]   += Src[(h+radius)*row_offset+i];
			columnssums_2[i+radius] += square(Src[(h+radius)*row_offset+i]);
			
			summation  +=columnssums[i+radius];
			summation_2+=columnssums_2[i+radius];

			Dst[h*row_offset+w]=fastSqrt_2(summation_2*weight-square(summation*weight));
			}
		}
	free(columnssums)  ;
	free(columnssums_2);
	}

void image2pad_symmetric
       (
       double * image_in,
       double * image_in_pad,
       int      rows,
       int      cols,
       int      radius,
       int      pad_offset
       )
    {
    int w, h;
    
    // left-top corner
    for (h = 0; h < radius; ++h)
        for (w = 0; w < radius; ++w)
            image_in_pad[w + pad_offset*h]  = image_in[radius - w - 1 + cols*(radius - h - 1)];  
    // left-bottom corner
    for (h = rows + radius; h < rows + 2*radius; ++h)
        for (w = 0; w < radius; ++w)
            image_in_pad[w + pad_offset*h]  = image_in[radius - w - 1 + cols*(2*rows + radius - h - 1)];
    // right-top corner
    for (h = 0; h < radius; ++h)
        for (w = cols + radius; w < cols + 2*radius; ++w)
            image_in_pad[w + pad_offset*h]  = image_in[2*cols + radius - w - 1 + cols*(radius - h - 1)];  
    // right-bottom corner
    for (h = rows + radius; h < rows + 2*radius; ++h)
        for (w = cols + radius; w < cols + 2*radius; ++w)
            image_in_pad[w + pad_offset*h]  = image_in[2*cols + radius - w - 1 + cols*(2*rows + radius - h - 1)];
    
    // left
    for (h = radius; h < rows+radius; ++h)
        for (w = 0; w < radius; ++ w)
            image_in_pad[w + pad_offset*h] = image_in[radius - w - 1 + cols*(h-radius)];
    // right
    for (h = radius; h < rows+radius; ++h)
        for (w = cols + radius; w < cols + 2*radius; ++ w)
            image_in_pad[w + pad_offset*h] = image_in[2*cols - w + radius - 1 + cols*(h-radius)];
    // top
    for (h = 0; h < radius; ++h)
        for (w = radius; w < cols+radius; ++ w)
            image_in_pad[w + pad_offset*h] = image_in[(w-radius) + cols*(radius - h - 1)];
    // bottom
    for (h = rows+radius; h < rows + 2*radius; ++h)
        for (w = radius; w < cols+radius; ++ w)
            image_in_pad[w + pad_offset*h] = image_in[(w-radius) + cols*(2*rows + radius - h - 1)];
    
    // body
    for (h = 0; h < rows; ++h)
        for (w = 0; w < cols; ++w)
            image_in_pad[w+radius + pad_offset*(h+radius)] = image_in[w + cols*h];
    
    }

void pad2image
       (
       double* im_out_pad,
       double* im_out,
       int     rows,
       int     cols,
       int     radius,
       int     pad_offset
       )
    {
    int w,h;
    
    for (h = 0; h < rows; ++h)
        for (w = 0; w < cols; ++w)
            im_out[w + cols*h] = im_out_pad[w+radius + pad_offset*(h+radius)];
    
    }

void mexFunction( int nlhs, mxArray *plhs[], int nrhs, const mxArray*prhs[])

	{ 
    
    /* Output Arguments */
    //#define       Image_OutC          plhs[0]

    /* Input Arguments */
    //#define       Image_InC			prhs[0]
    //#define       RADIUS      	    prhs[1]
    //#define       SIGMA_COLOR    	    prhs[2]

    /* Intermediate Buffers */
    //int           CANVAS_WIDTH            ;
    //int           CANVAS_HEIGHT           ;
    //double *      Image_In_Padded         ;

	double *cnvsout, *cnvsin, *srcin, *canvasheight, *canvaswidth, *radius;
    double *pad_height, *pad_width;
    double *row_offset;
    int    image_size;
    int    pad_start_offset;
    int    dim[3];

	/* Check for proper number of arguments */

	if (nlhs != 1 && nrhs != 2)  
		mexErrMsgTxt("double* output = FAST_STDFILT(double* input, double^ radius)"); 
	
	/* Assign pointers to the various parameters */ 
    
    // Dimensions
    CANVAS_HEIGHT   = (int)      mxGetM(Image_InC)              ;
    CANVAS_WIDTH    = (int)      mxGetN(Image_InC)              ;
    CANVAS_WIDTH    =            CANVAS_WIDTH/3                 ;
    dim[0]          =            CANVAS_HEIGHT                  ;
    dim[1]          =            CANVAS_WIDTH                   ;
    dim[2]          =            3                              ;
    image_size      = (CANVAS_WIDTH)*(CANVAS_HEIGHT)            ;
    // Create Output Buffer
    Image_OutC      = mxCreateNumericArray(3,dim, mxDOUBLE_CLASS, mxREAL) ;
    // Extract pointers
	cnvsin          = (double *) mxGetPr(Image_InC)     ;
	cnvsout         = (double *) mxGetPr(Image_OutC)    ;
    radius          = (double *) mxGetPr(RADIUS)        ;
    // Pad Image_In
    PAD_WIDTH           = CANVAS_WIDTH  + 2*(*radius)                                  ;
    PAD_HEIGHT          = CANVAS_HEIGHT + 2*(*radius)                                  ;
    image_pad_size      = PAD_WIDTH * PAD_HEIGHT                                       ;
    pad_start_offset    = (*radius) + (*radius)*PAD_HEIGHT                             ;
    // Allocate Memory
    Image_In_Padded_R  = (double *) malloc(sizeof(double)*PAD_WIDTH*PAD_HEIGHT)       ;
    Image_In_Padded_G  = (double *) malloc(sizeof(double)*PAD_WIDTH*PAD_HEIGHT)       ;
    Image_In_Padded_B  = (double *) malloc(sizeof(double)*PAD_WIDTH*PAD_HEIGHT)       ;
    Image_Out_Padded_R    = (double *) malloc(sizeof(double)*PAD_WIDTH*PAD_HEIGHT)       ;
	Image_Out_Padded_G    = (double *) malloc(sizeof(double)*PAD_WIDTH*PAD_HEIGHT)       ;
	Image_Out_Padded_B    = (double *) malloc(sizeof(double)*PAD_WIDTH*PAD_HEIGHT)       ;
   
        
    /* Do the actual computations in a subroutine */
    // PAD (Three Channels)
    image2pad_symmetric
       (
       cnvsin,
       Image_In_Padded_R,
       CANVAS_WIDTH,
       CANVAS_HEIGHT,
       *radius,
       PAD_HEIGHT
       );
    image2pad_symmetric
       (
       cnvsin + image_size,
       Image_In_Padded_G,
       CANVAS_WIDTH,
       CANVAS_HEIGHT,
       *radius,
       PAD_HEIGHT
       );
    image2pad_symmetric
       (
       cnvsin + 2*image_size,
       Image_In_Padded_B,
       CANVAS_WIDTH,
       CANVAS_HEIGHT,
       *radius,
       PAD_HEIGHT
       );
    // Fast Standard Deviation
   fast_stdfilt
		(
        Image_In_Padded_R  + pad_start_offset,
		Image_Out_Padded_R  + pad_start_offset,
		CANVAS_WIDTH,
		CANVAS_HEIGHT,
        *radius,
        PAD_HEIGHT
		);
	fast_stdfilt
		(
        Image_In_Padded_G  + pad_start_offset,
		Image_Out_Padded_G  + pad_start_offset,
		CANVAS_WIDTH,
		CANVAS_HEIGHT,
        *radius,
        PAD_HEIGHT
		);
	fast_stdfilt
		(
        Image_In_Padded_B  + pad_start_offset,
		Image_Out_Padded_B  + pad_start_offset,
		CANVAS_WIDTH,
		CANVAS_HEIGHT,
        *radius,
        PAD_HEIGHT
		);
    // UNPAD (Three Channels)
    pad2image
       (
       Image_Out_Padded_R,
       cnvsout,
       CANVAS_WIDTH,
       CANVAS_HEIGHT,
       *radius,
       PAD_HEIGHT
       );
    pad2image
       (
       Image_Out_Padded_G,
       cnvsout + image_size,
       CANVAS_WIDTH,
       CANVAS_HEIGHT,
       *radius,
       PAD_HEIGHT
       );
   pad2image
       (
       Image_Out_Padded_B,
       cnvsout + 2*image_size,
       CANVAS_WIDTH,
       CANVAS_HEIGHT,
       *radius,
       PAD_HEIGHT
       );
    // demalloc
    free(Image_In_Padded_R);
    free(Image_In_Padded_G);
    free(Image_In_Padded_B);
	free(Image_Out_Padded_R);
    free(Image_Out_Padded_G);
    free(Image_Out_Padded_B);
    
	return;
	}