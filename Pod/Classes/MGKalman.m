//
//  MGKalman.m
//  MGKalmanProject
//
//  Created by Mohamed GHENANIA on 27/11/2015.
//  Copyright © 2015 Braimble. All rights reserved.
//

#import "MGKalman.h"

@implementation MGKalman

+(MGKalman*) filterWithStateOrder:(NSUInteger) state observationOrder:(NSUInteger) observation;
{
    MGKalman* filter = [MGKalman new];
    filter.state_order = state;
    filter.observation_order = observation;
    filter.x_estimated = [MGMatrix rows:state columns:1];

    filter.A = [MGMatrix identity:state];
    filter.H = [MGMatrix rows:observation columns:state];
    filter.B = [MGMatrix rows:state columns:state];
    filter.u = [MGMatrix rows:state columns:1];
    
    filter.Q = [MGMatrix rows:state columns:state];
    filter.R = [MGMatrix identity:observation];
    filter.K = [MGMatrix rows:state columns:observation];
    filter.P_estimated = [MGMatrix identity:state];
    
    filter.n = 0;

    return filter;
}

/*----------------------------------------------*\
|  prediction equations                          |
|  x^(k|k-1) = A.x^(k-1|k-1) + B.u(k)            |
|  P(k|k-1) = A.P(k-1).A^T + Q                   |
\*----------------------------------------------*/
- (void) predict
{
    // Estimate State:
    //  x^(k) = A.x^(k-1) + B.u(k)
     self.x_predicted = [_A multiplyBy:_x_estimated plus:[_B multiplyBy:_u]];

    // Estimate state covariance:
    //  P^(k) = A.P(k-1).A^T + Q
    self.P_predicted = [[[_A multiplyBy:_P_estimated] multiplyByTransposeOf:_A] plus:_Q];
}


/*-------------------------------------------------*\
|  correction equations                            |
|  K(k) = P(k).H^T . (H.P^(k).H^T + R)^-1          |
|  x^(k|k) = x^(k|k-1) + K(k).(z(k) - H*x^(k|k-1)) |
|  P(k) = (I - K(k).H).P(k|k-1)                    |
|                                                  |
\*-------------------------------------------------*/

- (void) correct:(MGMatrix*) newObservation
{
    self.z = newObservation;
    
    // Kalman gain
    //   K(k) = P(k).H^T . (H.P^(k).H^T + R)^-1
    self.K = [[_P_predicted multiplyByTransposeOf:_H] multiplyByInverseOf:[[[_H multiplyBy:_P_predicted] multiplyByTransposeOf:_H] plus:_R]];
    
    // Correct predicted state with observation
    //  x^(k|k) = x^(k|k-1) + K(k).(z(k) - H*x^(k|k-1))
    self.x_estimated = [_x_predicted plus:[_K multiplyBy:[_z minus:[_H multiplyBy:_x_predicted]]]];
    
    // Update Covariance Error
    //  P(k) = (I - K(k).H).P(k|k-1)
    MGMatrix* I = [MGMatrix identity:_state_order];
    self.P_estimated = [[I minus:[_K multiplyBy:_H]] multiplyBy:_P_predicted];

    // Increment timestep
    _n +=1;
}

- (void) estimateWithNewObservation:(MGMatrix*) newObservation
{
    NSAssert(newObservation.rows == _observation_order && newObservation.columns == 1, @"Observation matrix dimensions are not correct");
    
    // Step 1 : Prediction
    [self predict];
    
    // Step 2 : Correction
    [self correct:newObservation];
 
    
#if LOG_ENABLED
    // Log avariables
    printf("\n----------------------  n = %lu ----------------------\n", _n-1);

    [_x_predicted prettyLogWithName:@"x_predicted"];
    [_P_predicted prettyLogWithName:@"P_predicted"];

    [_K prettyLogWithName:@"K"];
    [_x_estimated prettyLogWithName:@"x_estimated"];
    [_P_estimated prettyLogWithName:@"P_estimated"];
#endif

}


@end
