/** 
 * @file:   ggn.c
 * @author: Damjan Cicin-Sain
 * @email:  damjan.cicin@crg.es
 *
 * Created on Apr 30, 2014, 12:10 PM
 */

#include "global.h"
#include "mathLib.h"            /* Trunc function is in there */    
#include "fly_sa.h"             /* MoveX function is in here */
#include <string.h>
#include <stdlib.h>
#include <stdio.h>
#include "ggn.h"


/* This is the model function that gets in input an array of parameters and the size of that array 
and returns the score. 
 * IMPORTANT:
 * The mask array defines which model parameters are we optimizing on, so the number of parameters (elements of 
 * the array x) has to correspond to the number of ones in the array mask;
of ones in the mask array. */

double ggn(double x[], int size) {    //we need to pass also the number of parameters
    static double y;
    //mask corresponds to the data (parameters, mask) in the input file
    static int mask[56] = {1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 1, 1, 1, 0, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 0, 0, 0, 0};
    static int i, masksize;    
    static int init = 1;    /* init = 1 means 'initialization loop' */
    static int jacobian = 0;    /* set this if you need the Jacobian matrix */
    static Files files;
    static char* inputfile = "dm_hkgn53_wls_5_003";
    static int nParm = 0;  // number of parameters of the problem - this corresponds to the number of ones in the mask.

    masksize = sizeof(mask) / sizeof(int);
        
    for (i = 0; i<masksize; i++) {
        if (mask[i] == 1) {
            nParm++;
        }
    }
    
    static ScoreOutput out;
    
    out.score = 1e38;       /*start with a very large number*/
    out.penalty = 0;
    out.size_resid_arr = 0;
    out.jacobian = NULL;
    out.residuals = NULL;
    
    
    /* allocate memory for static file names */

    files.inputfile = ( char * ) calloc( MAX_RECORD, sizeof( char ) );
    files.statefile = ( char * ) calloc( MAX_RECORD, sizeof( char ) );

    if (size != nParm) {
        printf("WRONG number of parameters: must correspond to the number of ones in the mask array \n");
        init = 0;
        free(files.inputfile);
        free(files.statefile);
        free(out.jacobian);
        free(out.residuals); 
        y = 1e38;
        return y;
    } 
    
    
    for (i=0; i<nParm; i++) {
        x[i] = Trunc(x[i], 5);      /*this is needed to avoid errors due to lack of precision*/
    }
           
    strcpy( files.inputfile, inputfile);
    
    sprintf( files.statefile, "%s.state", files.inputfile );
    MoveX(x, mask, &out, &files, init, jacobian, 1); /* Solvers: 0 Rkck, 1 Direct-Band */
    if (out.score < 0) {    /* maybe eliminate later and deal only with 1e38 */
        printf("OUT_OF_BOUND - setting score to 0 and penalty to 1e38\n");
        out.score = 0;
        out.penalty = 1e38;
    }
    y = out.score + out.penalty; /*comment this to test without penalties*/
        
    init = 0;
    free(files.inputfile);
    free(files.statefile);
    free(out.jacobian);
    free(out.residuals);
    return y;
}

int main(int argc, char** argv) {
    // example - one iteration
    int n = 37; //number of parameters. Don't change unless you change also the mask and eventually the input file
    double par[] = {30, 29.9998, 17.9103, 19.3859, -0.14647, -0.16443, 0.01901, -0.41791, -0.12796, -0.00053, -0.07268, -0.02871, -0.00946, -0.39451, 0.01984, 0.00479, -0.13268, -0.01254, -0.07873, 0.04014, 0.64947, -0.01383, 0.53103, -1.90012, 0.33423, 0.01054, -0.00038, 0.07956, 0.0255, -0.13691, 0.02622, 0.0177, -0.33254, 11.655, 5, 5.42123, 5.14696}; 
    double score = ggn(par, n);
    printf("score: %lg\n", score);
    return (EXIT_SUCCESS);
}