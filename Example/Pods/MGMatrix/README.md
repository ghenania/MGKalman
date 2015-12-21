# MGMatrix
MGMatrix provides a high efficiency implementation of many standards Matrix operations.
It is built over Accelerate iOS and uses vDSP and LAPAC for performances. 
MGMatrix interface is easy to use and Debug tools are here too help you during your developments.

## How to

**Easily instantiate Matrix**

```ObjC
MGMatrix* A = [MGMatrix rows:2 columns:2 values:
1.0,   2.0,
3.0,   4.0
];
MGMatrix* B = [MGMatrix identity:2];
```

**Algebric operations**

```ObjC
// A^T
[A transpose];

// A^-1
[A invert];
```    
**Artithmetic operations**

```ObjC
// A + B
[A plus:B];

// A - B
[A minus:B];

// A * B
[A multiplyBy:B];

// A * A^-1
[A multiplyByInverseOf:A];

// A * B^T
[A multiplyByTransposeOf:B];

// 3*A + B
[A scaleBy:3.0 plus:B];

// A * B + C
[A multiplyBy:B plus:C];

// A * B - C
[A multiplyBy:B minus:C];
```

**Pretty logging**

```ObjC
// C
[C prettyLogWithName:@"C"];
```

C = 
( -1.500000  -4.500000 )
( -3.000000  -6.000000 )


##Todo
Ask me which opetaions you need and I'll implement them.


##ARC

MGMatrix needs ARC.


## Usage

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements
<Accelerate.Framework>
iOS 8+

## Installation

MGMatrix is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod "MGMatrix"
```

## Author

Mohamed GHENANIA, mohamed.ghenania@intersection-lab.com

## License

MGMatrix is available under the MIT license. See the LICENSE file for more info.
