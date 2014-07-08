#import "KUITimeViewController.h"
#import "KUIRingView.h"

@interface KUITimeViewController () <KUIRingViewDelegate, KUIRingViewDataSource>

@property (nonatomic, strong) IBOutlet KUIRingView *ringView;

@end

@implementation KUITimeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
	
	self.ringView.delegate = self;
	self.ringView.dataSource = self;
}

#pragma mark -
#pragma mark KUIRingViewDelegate

- (void)ringView:(KUIRingView *)ringView didSelectItemAtIndex:(NSUInteger)index {
	KUIRingViewItem *item = [self ringView:ringView itemAtIndex:index];
	[[[UIAlertView alloc] initWithTitle:item.title message:[NSString stringWithFormat:@"%@ is selected.", item.title] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
}

#pragma mark -
#pragma mark KUIRingViewDataSource

- (NSUInteger)ringViewNumberOfItems:(KUIRingView *)ringView {
	return 24 * 60;
}

- (KUIRingViewItem *)ringView:(KUIRingView *)ringView itemAtIndex:(NSUInteger)index {
	return [[KUIRingViewItem alloc] initWithTitle:[NSString stringWithFormat:@"%lu:%02lu", (unsigned long)index / 60, (unsigned long)index % 60]];
}

@end
