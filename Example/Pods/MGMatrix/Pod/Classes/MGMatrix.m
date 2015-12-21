//
//  MGMatrix.m
//  MGKalmanProject
//
//  Created by Mohamed GHENANIA on 27/11/2015.
//  Copyright © 2015 Braimble. All rights reserved.
//

#import "MGMatrix.h"
#import <Accelerate/Accelerate.h>

/*==================================================================================================*/
/* Private Interface                                                                                */
/*==================================================================================================*/
#pragma mark - Private Interface

@interface MGMatrix ()
@end




@implementation MGMatrix


/*=================================================================================================*/
/* Instanciation methods                                                                           */
/*=================================================================================================*/
#pragma mark - Instanciation methods

+(MGMatrix*) rows:(NSUInteger)rows columns:(NSUInteger)columns
{
    NSAssert(rows>0 && columns >0, @"Rows and Columns numbers must be greater than 0");
    MGMatrix* matrix = [MGMatrix new];
    matrix.rows = rows;
    matrix.columns = columns;
    
    matrix.data = (double*) malloc(sizeof(double)* rows*columns);
    memset((void*)matrix.data, 0, sizeof(double)* rows*columns);
    
    return matrix;
}

+(MGMatrix*) rows:(NSUInteger)rows columns:(NSUInteger)columns values:(double)m,...
{
    MGMatrix* matrix = [MGMatrix rows:rows columns:columns];
    
    va_list list;
    va_start(list,m);
    matrix.data[0]=m;
    for(int i=1; i<rows*columns; i++) matrix.data[i] = va_arg(list,double);
    va_end(list);

    return matrix;
}

+(MGMatrix*) identity:(NSUInteger)dimension
{
    MGMatrix* matrix = [MGMatrix rows:dimension columns:dimension];
    [matrix setIdentity];
    
    return matrix;
}

-(MGMatrix*) copy
{
    MGMatrix* output = [MGMatrix rows:_rows columns:_columns];
    memcpy(output.data, _data, _rows*_columns*sizeof(double));
    
    return output;
}

- (void) dealloc
{
    free(_data);
}

/*=================================================================================================*/
/* Data access                                                                                     */
/*=================================================================================================*/
#pragma mark - Data access

-(void) set:(double)m,...
{
    _data[0]=m;
    va_list list;
    va_start(list,m);
    for(int i=1; i<_rows*_columns; i++) _data[i] = va_arg(list,double);
    va_end(list);
}

-(void) setIdentity
{
    for(int r=0; r<_rows; r++)
    {
        for(int c=0; c<_columns; c++)
        {
            _data[c + r*_columns] = r==c ? 1.0 : 0.0;
        }
    }
}


-(double) :(NSInteger)r : (NSUInteger)c
{
    NSAssert(r<_rows, @" method M(i,j): Invalid row number i=%lu while mtarix has %lu rows", (unsigned long)r, (unsigned long)_rows);
    NSAssert(c<_columns, @" method M(i,j): Invalid column number j=%lu while mtarix has %lu colums", (unsigned long)c, (unsigned long)_columns);
    
    return _data[c + r*_columns];
}

-(double*) p:(NSInteger)r : (NSUInteger)c
{
    NSAssert(r<_rows, @" method M(i,j): Invalid row number i=%lu while mtarix has %lu rows", (unsigned long)r, (unsigned long)_rows);
    NSAssert(c<_columns, @" method M(i,j): Invalid column number j=%lu while mtarix has %lu colums", (unsigned long)c, (unsigned long)_columns);
    
    return &_data[c + r*_columns];
}



/*=================================================================================================*/
/* Algebric methods                                                                                */
/*=================================================================================================*/
#pragma mark - Algebric methods

-(MGMatrix*) transpose
{
    MGMatrix* output = [MGMatrix rows:_columns columns:_rows];
    
    vDSP_mtransD(_data, 1, output.data, 1, _columns, _rows);
    
    return output;
}


-(MGMatrix*) invert
{
    MGMatrix* output = [self copy];
    
    int error=0;
    int* pivot = (int*) malloc(MIN(_rows, _columns)*sizeof(int));
    double* workspace = (double*) malloc(MAX(_rows, _columns)*sizeof(double));
    
    //  LU factorisation
    __CLPK_integer M = (__CLPK_integer)_rows;
    __CLPK_integer N = (__CLPK_integer)_columns;
    __CLPK_integer LDA = MAX(M,N);
    dgetrf_(&M, &N, output.data, &LDA, pivot, &error);
    
    if (error)
    {
        NSLog(@"LU factorisation failed");
        free(pivot);
        free(workspace);
        return nil;
    }
    
    //  matrix inversion
    dgetri_(&N, output.data, &N, pivot, workspace, &N, &error);
    if (error)
    {
        NSLog(@"Invesrion Failed");
        free(pivot);
        free(workspace);
        return nil;
    }
    
    free(pivot);
    free(workspace);
    
    return output;
}



/*=================================================================================================*/
/* Arithmetic methods                                                                              */
/*=================================================================================================*/
#pragma mark - Arithmetic methods

-(MGMatrix*) plus:(MGMatrix*)B
{
    NSAssert(_rows==B.rows, @"Method Add: Matrixes haven't same number of rows: %lu ≠ %lu", (unsigned long)_rows, (unsigned long)B.rows);
    NSAssert(_columns==B.columns, @"Method Add: Matrixes haven't same number of columns : %lu ≠ %lu", (unsigned long)_columns, (unsigned long)B.columns);

    MGMatrix* output = [MGMatrix rows:_rows columns:_columns];
    vDSP_vaddD(self.data, 1, B.data, 1, output.data, 1, _rows*_columns);
    
    return output;

}
-(MGMatrix*) minus:(MGMatrix*)B
{
    NSAssert(_rows==B.rows, @"Method Substract: Matrixes haven't same number of rows: %lu ≠ %lu", (unsigned long)_rows, (unsigned long)B.rows);
    NSAssert(_columns==B.columns, @"Method Substract: Matrixes haven't same number of columns : %lu ≠ %lu", (unsigned long)_columns, (unsigned long)B.columns);
    double neg = -1.0;
    
    MGMatrix* output = [MGMatrix rows:_rows columns:_columns];
    vDSP_vsmaD(B.data, 1, &neg, self.data, 1, output.data, 1, _rows*_columns);
    
    return output;
}

-(MGMatrix*) multiplyBy:(MGMatrix*)B
{
    NSAssert(_columns==B.rows, @"Method Multiply: Left Matrix number of columns ≠ Right Matrix number of Rows: %lu ≠ %lu", (unsigned long)_columns, (unsigned long)B.rows);

    MGMatrix* output = [MGMatrix rows:_rows columns:B.columns];
    vDSP_mmulD(self.data, 1, B.data, 1, output.data, 1, _rows, B.columns, _columns);
    
    return output;
}


-(MGMatrix*) multiplyByTransposeOf:(MGMatrix*)B
{
    NSAssert(_columns==B.columns, @"Method multiplyByTransposeOf: Left Matrix number of columns ≠ Right Matrix number of columns: %lu ≠ %lu", (unsigned long)_columns, (unsigned long)B.columns);
    return [self multiplyBy:[B transpose]];
}

-(MGMatrix*) multiplyByInverseOf:(MGMatrix*)B
{
    return [self multiplyBy:[B invert]];
}

- (MGMatrix*) scaleBy:(double)scalar
{
    MGMatrix* output = [MGMatrix rows:_rows columns:_columns];
    vDSP_vsmulD(self.data, 1, &scalar, output.data, 1, _rows*_columns);
    
    return output;
}


- (MGMatrix*) scaleBy:(double)scalar plus:(MGMatrix *)B
{
    NSAssert(_rows==B.rows, @"Method scaleBy:Add: Matrixes haven't same number of rows: %lu ≠ %lu", (unsigned long)_rows, (unsigned long)B.rows);
    NSAssert(_columns==B.columns, @"Method scaleBy:Add: Matrixes haven't same number of columns : %lu ≠ %lu", (unsigned long)_columns, (unsigned long)B.columns);

    MGMatrix* output = [MGMatrix rows:_rows columns:B.columns];
    vDSP_vsmaD(_data, 1, &scalar, B.data, 1, output.data, 1, _rows*_columns);
    
    return output;
}

- (MGMatrix*) scaleBy:(double)scalar minus:(MGMatrix *)B
{
    NSAssert(_rows==B.rows, @"Method scaleBy:Add: Matrixes haven't same number of rows: %lu ≠ %lu", (unsigned long)_rows, (unsigned long)B.rows);
    NSAssert(_columns==B.columns, @"Method scaleBy:Add: Matrixes haven't same number of columns : %lu ≠ %lu", (unsigned long)_columns, (unsigned long)B.columns);
    
    MGMatrix* output = [MGMatrix rows:_rows columns:B.columns];
    vDSP_vsmsbD(_data, 1, &scalar, B.data, 1, output.data, 1, _rows*_columns);
    
    return output;
}

- (MGMatrix*) multiplyBy:(MGMatrix *)B plus:(MGMatrix*) C
{
    NSAssert(_columns==B.rows, @"Method Multiply:Plus: Left Matrix number of columns ≠ Right B number of Rows: %lu ≠ %lu", (unsigned long)_columns, (unsigned long)B.rows);
    NSAssert(_rows==C.rows, @"Method Multiply:Plus: C matrix haven't right number of rows: %lu ≠ %lu", (unsigned long)_rows, (unsigned long)B.rows);
    NSAssert(C.columns==B.columns, @"Method Multiply:Plus: C matrix haven't right number of columns : %lu ≠ %lu", (unsigned long)C.columns, (unsigned long)B.columns);

    return [[self multiplyBy:B] plus:C];

}

- (MGMatrix*) multiplyBy:(MGMatrix *)B minus:(MGMatrix*) C
{
    NSAssert(_columns==B.rows, @"Method Multiply:Minus: Left Matrix number of columns ≠ Right B number of Rows: %lu ≠ %lu", (unsigned long)_columns, (unsigned long)B.rows);
    NSAssert(_rows==C.rows, @"Method Multiply:Minus: C matrix haven't right number of rows: %lu ≠ %lu", (unsigned long)_rows, (unsigned long)B.rows);
    NSAssert(C.columns==B.columns, @"Method Multiply:Minus: C matrix haven't right number of columns : %lu ≠ %lu", (unsigned long)C.columns, (unsigned long)B.columns);
    
    return [[self multiplyBy:B] minus:C];

}


/*=================================================================================================*/
/* Logging methods                                                                                 */
/*=================================================================================================*/
#pragma mark - Logging methods

-(void) prettyLog
{
    printf("\n");
    for(int r=0; r<_rows; r++)
    {
        printf("(");
        for(int c=0; c<_columns; c++)
        {
            printf(" %f ", _data[c + r*_columns]);
        }
        printf(")\n");
    }
    printf("\n");
}

-(void) prettyLogWithName:(NSString*) matrixName
{
    printf("%s = ", matrixName.UTF8String);
    [self prettyLog];
}



@end
