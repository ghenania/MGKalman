# MGKalman

[![Version](https://img.shields.io/cocoapods/v/MGKalman.svg?style=flat)](http://cocoapods.org/pods/MGKalman)
[![License](https://img.shields.io/cocoapods/l/MGKalman.svg?style=flat)](http://cocoapods.org/pods/MGKalman)
[![Platform](https://img.shields.io/cocoapods/p/MGKalman.svg?style=flat)](http://cocoapods.org/pods/MGKalman)

## How to

**Kalman filter equations**

```ObjC
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
```

**Easily instantiate Matrix**

```ObjC
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

```

**Estimate and correct**

```ObjC
    [_kalmanFilter estimateWithNewObservation:[MGMatrix rows:2 columns:1 values:
                                               z1,
                                               z2
                                               ]];
```


## Usage

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements

  - Accelerate.Framework
  - iOS 8+
  - pod "MGMatrix"
  

## Installation

MGKalman is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod "MGKalman"
```

## Author

Mohamed GHENANIA, mohamed.ghenania@intersection-lab.com

## License

MGKalman is available under the MIT license. See the LICENSE file for more info.
