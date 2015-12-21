//
//  MGMatrix.h
//  MGKalmanProject
//
//  Created by Mohamed GHENANIA on 27/11/2015.
//  Copyright © 2015 Braimble. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MGMatrix : NSObject

@property (nonatomic, assign) NSUInteger rows;
@property (nonatomic, assign) NSUInteger columns;
@property (nonatomic, assign) double* data;




/*
 * Instantiation methods
 ***************************************/
+(MGMatrix*) rows:(NSUInteger)row columns:(NSUInteger)column;
+(MGMatrix*) rows:(NSUInteger)row columns:(NSUInteger)column values:(double)m,...;
+(MGMatrix*) identity:(NSUInteger)dimension;
-(MGMatrix*) copy;



/*
 * Data access methods
 ***************************************/

// Read value at position [i,j].  A[i,j] = A:i:i
-(double) :(NSInteger)r :(NSUInteger)c;

// Get pointer for value at position [i,j] for edition. e.g *(p:0:1) = 5 <=> A[0,1]=5
-(double*) p:(NSInteger)r :(NSUInteger)c;

// Set raw values for whole matrix
-(void) set:(double)m,...;

// Set A = I
-(void) setIdentity;



/*
 * Algebric methods
 ***************************************/

// C = A^T
-(MGMatrix*) transpose;

// C = A^-1
-(MGMatrix*) invert;



/*
 * Artithmetic methods
 ***************************************/

// C = A + B
-(MGMatrix*) plus:(MGMatrix*)B;

// C = A - B
-(MGMatrix*) minus:(MGMatrix*)B;

// C = A * B
-(MGMatrix*) multiplyBy:(MGMatrix*)B;

// C = A * B^T
-(MGMatrix*) multiplyByTransposeOf:(MGMatrix*)B;

// C = A * B^-1
-(MGMatrix*) multiplyByInverseOf:(MGMatrix*)B;

// C = s * A, C[i,j] = s*A[i,j]
-(MGMatrix*) scaleBy:(double)scalar;

// C = s * A + B, C[i,j] = s*A[i,j] + B[i,j]
-(MGMatrix*) scaleBy:(double)scalar plus:(MGMatrix*)B;

// C = s * A - B, C[i,j] = s*A[i,j] - B[i,j]
- (MGMatrix*) scaleBy:(double)scalar minus:(MGMatrix *)B;

// C = A * B + C
- (MGMatrix*) multiplyBy:(MGMatrix *)B plus:(MGMatrix*) C;

// C = A * B - C
- (MGMatrix*) multiplyBy:(MGMatrix *)B minus:(MGMatrix*) C;


/*
 * Pretty logs methods
 ***************************************/

// Log formated data
-(void) prettyLog;

// prefix your log with the matrix name
-(void) prettyLogWithName:(NSString*) matrixName;


@end
