//
//  MGKalman.h
//  MGKalmanProject
//
//  Created by Mohamed GHENANIA on 27/11/2015.
//  Copyright © 2015 Braimble. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MGMatrix.h"


/*-------------------------------------------------*\
 |  Kalman Filter equations                         |
 |                                                  |
 |  state equation                                  |
 |  x(k) = A.x(k-1)+B.u(k)+w(k-1)                   |
 |                                                  |
 |  observations equation                           |
 |  z(k) = H.x(k)+y(k)                              |
 |                                                  |
 |  prediction equations                            |
 |  x^(k|k-1) = A.x^(k-1|k-1) + B.u(k)              |
 |  P(k|k-1) = A.P(k-1).A^T + Q                     |
 |                                                  |
 |  correction equations                            |
 |  K(k) = P(k).H^T . (H.P^(k).H^T + R)^-1          |
 |  x^(k|k) = x^(k|k-1) + K(k).(z(k) - H*x^(k|k-1)) |
 |  P(k) = (I - K(k).H).P(k|k-1)                    |
 |                                                  |
 \*------------------------------------------------*/


#define LOG_ENABLED    1


@interface MGKalman : NSObject


// timestep k
@property (nonatomic, assign) NSUInteger n;

// Kalman orders
@property (nonatomic, assign) NSUInteger state_order;
@property (nonatomic, assign) NSUInteger observation_order;

// -- Matrixes for Predictions step --
//    x^(k|k-1) = A.x^(k-1) + B.u(k)
//    P^(k|k-1) = A.P(k-1).A^T + Q
@property (nonatomic, strong) MGMatrix* x_predicted;    // predicted state
@property (nonatomic, strong) MGMatrix* A;              // Transition Matrix
@property (nonatomic, strong) MGMatrix* x_estimated;    // Estimated state after correction
@property (nonatomic, strong) MGMatrix* B;              // Control model matrix (default: identity matrix)
@property (nonatomic, strong) MGMatrix* u;              // control signal (default: zero vector to be ignored)
@property (nonatomic, strong) MGMatrix* P_predicted;    // Predicted estimated Covariance Matrix P(k|k-1)
@property (nonatomic, strong) MGMatrix* Q;              // Process Noise Covariance matrix


// -- Matrixes Correction step --
//    K(k) = P^(k).H^T . (H.P^(k).H^T + R)^-1
//    x^(k|k) = x^(k|k-1) + K(k).(z(k) - H*x^(k|k-1))
//    P(k|k) = (I - K(k).H).P(k|k-1)
@property (nonatomic, strong) MGMatrix* H;              // Observation model matrix
@property (nonatomic, strong) MGMatrix* R;              // Observation noise covariance matrix
@property (nonatomic, strong) MGMatrix* K;              // Kalman gain matrix
@property (nonatomic, strong) MGMatrix* z;              // Observation
@property (nonatomic, strong) MGMatrix* P_estimated;    // Estimated Covariance Matrix P(k|k)


@property (nonatomic, strong) MGMatrix* y;              // Innovation
@property (nonatomic, strong) MGMatrix* S;              // Innovation covariance



+(MGKalman*) filterWithStateOrder:(NSUInteger) state observationOrder:(NSUInteger) observation;
- (void) estimateWithNewObservation:(MGMatrix*) newObservation;


@end
