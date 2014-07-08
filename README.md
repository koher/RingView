RingView
========

The RingView is a view used to select one from a large number of items.

Scroll bars are commonly used for the purpose. But scrolling takes long when there are a lot of items. Instead of scrolling, users can control the RingView by pan gestures. Pan gestures from the inside of the ring to the outside change the scale of the RingView and users can zoom in the destination items.

The RingView is based on the paper by Koshizawa et al __Å_[1Å_]__ although the details of the implementation are different because of the optimizations for touchscreens.

Supported Platforms
-------------------

- iOS 4.3 and later

How to Use
----------

### iOS

Put the following files into your project.

- iOS/RingView/KUIRingView.h 
- iOS/RingView/KUIRingView.m

The _KUIRingView_ class can be used like the _UITableView_ class. As the _UITableView_ needs the _UITableViewDataSource_ and the _UITableViewDelegate_, the _KUIRingView_ needs the _KUIRingViewDataSource_ and the _KUIRingViewDelegate_.

The following is the typical code to use the KUIRingView.

```objectivec

#import "KUIRingView.h"

@interface ViewController : UIViewController <KUIRingViewDelegate, KUIRingViewDataSource>
@property (nonatomic, strong) IBOutlet KUIRingView *ringView;
...
@end

@implementation KUIViewController

- (void)viewDidLoad {
    [super viewDidLoad];
	
	self.ringView.delegate = self;
	self.ringView.dataSource = self;
}

- (NSUInteger)ringViewNumberOfItems:(KUIRingView *)ringView {
	...
	return numberOfItems;
}

- (KUIRingViewItem *)ringView:(KUIRingView *)ringView itemAtIndex:(NSUInteger)index {
	...
	return return [[KUIRingViewItem alloc] initWithTitle:title];
}

- (void)ringView:(KUIRingView *)ringView didSelectItemAtIndex:(NSUInteger)index {
	...
}

...

@end

```

How to Execute the Sample
-------------------------

### iOS

1. Open [the Xcode project](iOS/RingView.xcodeproj).
2. Chose "Samples" as the build target.
3. Run the project.

License
-------

MIT License. Read [the LICENSE file](LICENSE).

References
----------

1. [Koshizawa, Y., Hiura, S. and Sato, K. : "Design and Evaluation of Pointing Interfaces for Selecting from Multiple Targets," Interaction 2008 (Japanese)](http://www.interaction-ipsj.org/archives/paper2008/oral/0030/paper0030.pdf)


