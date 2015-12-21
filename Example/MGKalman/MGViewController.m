//
//  MGViewController.m
//  MGKalman
//
//  Created by Mohamed GHENANIA on 12/21/2015.
//  Copyright (c) 2015 Mohamed GHENANIA. All rights reserved.
//

#import "MGViewController.h"
#include <Accelerate/Accelerate.h>
#import "MGMatrix.h"
#import "MGKalman.h"


/*==================================================================================================*/
/* Private Interface                                                                                */
/*==================================================================================================*/
#pragma mark - Private Interface

@interface MGViewController  ()

@property (nonatomic, assign) BOOL isProcessing;
@property (strong, nonatomic) IBOutlet UILabel *x1Label;
@property (strong, nonatomic) IBOutlet UILabel *x2Label;
@property (strong, nonatomic) IBOutlet UILabel *gainLabel;
@property (strong, nonatomic) NSTimer* timer;
@property (strong, nonatomic) IBOutlet UIButton *filterButton;
@property (strong, nonatomic) MGKalman* kalmanFilter;
@property (strong, nonatomic) IBOutlet UILabel *timeStep;
@end





/*==================================================================================================*/
/* Constants and Macro                                                                              */
/*==================================================================================================*/
#pragma mark - Constants and Macro


#define  dT     0.1







@implementation MGViewController

/*=================================================================================================*/
/* Lifecycle methods                                                                               */
/*=================================================================================================*/
#pragma mark - Lifecycle methods

- (void)viewDidLoad
{
    [super viewDidLoad];
    _isProcessing = NO;
}


-(IBAction) filterButtonTouched:(id)sender
{
    if(_isProcessing)
    {
        [self stopProcessing];
        [_filterButton setTitle:@"Start Processing" forState:UIControlStateNormal];
    }
    else
    {
        [self startProcessing];
        [_filterButton setTitle:@"Stop" forState:UIControlStateNormal];
    }
}


- (void) startProcessing
{
    _isProcessing = YES;
    
    // init Kalman filter
    [self initKalmanFilter];
    
    // start
    self.timer = [NSTimer scheduledTimerWithTimeInterval:dT target:self selector:@selector(iterate) userInfo:nil repeats:YES];
}

- (void) iterate
{
    double z1 = 5 + [self gaussrandWithDeviation2:1. mean:0];
    double z2 = 3 + [self gaussrandWithDeviation2:1. mean:0];
    [self gaussrandWithDeviation2:2. mean:0]; // to force phase to flip
    
    [_kalmanFilter estimateWithNewObservation:[MGMatrix rows:2 columns:1 values:
                                               z1,
                                               z2
                                               ]];
    
    _x1Label.text = [NSString stringWithFormat:@"x1=%f", _kalmanFilter.x_predicted.data[0]];
    _x2Label.text = [NSString stringWithFormat:@"x1=%f", _kalmanFilter.x_predicted.data[1]];
    
    
    MGMatrix* K = _kalmanFilter.K;
    double gain = [K:0:0]*[K:0:0] + [K:1:1]* [K:1:1];
    _gainLabel.text = [NSString stringWithFormat:@"K=%f", gain];
    
    _timeStep.text = [NSString stringWithFormat:@"n = %lu",_kalmanFilter.n];
}

- (void) stopProcessing
{
    _isProcessing = NO;
    [_timer invalidate];
    self.kalmanFilter = nil;
}




/*=================================================================================================*/
/* Signal processing                                                                               */
/*=================================================================================================*/
#pragma mark - Signal processing

- (void) initKalmanFilter
{
    /*------------------------------------------*\
     |  Kalman model                              |
     |                                            |
     |  state quation                             |
     |  x(k) = A.x(k-1)+B.u(k)+w(k-1)             |
     |                                            |
     |  observations equation                     |
     |  z(k) = H.x(k)+y(k)                        |
     |                                            |
     |  prediction equations                      |
     |  x^(k) = A.x^(k-1) + B.u(k)                |
     |  P^(k) = A.P(k-1).A^T + Q                  |
     |                                            |
     |  correction equations                      |
     |  K(k) = P^(k).H^T . (H.P^(k).H^T + R)^-1   |
     |  x(k) = x^(k) + K(k).(z(k) - H*x^(k))      |
     |  P(k) = (I - K(k).H).P^(k)                 |
     |                                            |
     \*------------------------------------------*/
    
    NSUInteger stateOrder = 2;
    NSUInteger observationOrder = 2;
    
    // Kalman filter with order 2x2
    self.kalmanFilter= [MGKalman filterWithStateOrder:stateOrder observationOrder:observationOrder];
    
    
    // A matrix
    [_kalmanFilter setA:[MGMatrix identity:stateOrder]];
    
    /* H matrix */
    [_kalmanFilter setH:[MGMatrix rows:observationOrder columns:stateOrder values:
                         1.0,   0.0,
                         0.0,   1.0
                         ]];
    
    /* B Matrix */
    [_kalmanFilter setB:[MGMatrix rows:stateOrder columns:stateOrder]];
    
    // Q Matrix
    [_kalmanFilter setQ:[MGMatrix rows:stateOrder columns:stateOrder]];
    
    // R Matrix
    [_kalmanFilter setR:[MGMatrix rows:observationOrder columns:observationOrder values:
                         1.0,  0.0,
                         0.0,   1.
                         ]];
    
    
    // Po Matrix
    [_kalmanFilter setP_estimated:[MGMatrix rows:stateOrder columns:stateOrder values:
                                   1000.0,   0.0,
                                   0.0,   1000.0
                                   ]];
    
    // X(0)
    [_kalmanFilter setX_estimated:[MGMatrix rows:stateOrder columns:1 values:
                                   0.0,
                                   0.0
                                   ]];
}



/* ----------------------------------------------------------------------------*/
/* Methods to generate random numbers with a normal or Gaussian distribution   */
/* ----------------------------------------------------------------------------*/

// Method 1 : discussed in Knuth and due originally to Marsaglia)
- (double) gaussrandWithDeviation:(double) deviation mean:(double) mean
{
    static double V1, V2, S;
    static int phaseA = 0;
    double X;
    
    if(phaseA == 0) {
        do {
            double U1 = (double)rand() / RAND_MAX;
            double U2 = (double)rand() / RAND_MAX;
            
            V1 = 2 * U1 - 1;
            V2 = 2 * U2 - 1;
            S = V1 * V1 + V2 * V2;
        } while(S >= 1 || S == 0);
        
        X = V1 * sqrt(-2 * log(S) / S);
    } else
        X = V2 * sqrt(-2 * log(S) / S);
    
    phaseA = 1 - phaseA;
    
    return deviation*X + mean;
}


// Method 2 : method described by Abramowitz and Stegun
- (double) gaussrandWithDeviation2:(double) deviation mean:(double) mean
{
    static double U, V;
    static int phaseB = 0;
    double Z;
    
    if(phaseB == 0) {
        U = (rand() + 1.) / (RAND_MAX + 2.);
        V = rand() / (RAND_MAX + 1.);
        Z = sqrt(-2 * log(U)) * sin(2 * M_PI * V);
    } else
        Z = sqrt(-2 * log(U)) * cos(2 * M_PI * V);
    
    phaseB = 1 - phaseB;
    
    return deviation*Z + mean;
}

@end
