#import "KUIDateViewController.h"
#import "KUIRingView.h"

@interface KUIDateViewController () <KUIRingViewDelegate, KUIRingViewDataSource> {
	NSDateFormatter *_dateFormatter;
}

@property (nonatomic, strong) IBOutlet KUIRingView *ringView;

@end

@implementation KUIDateViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	self.ringView.delegate = self;
	self.ringView.dataSource = self;

	_dateFormatter = [[NSDateFormatter alloc] init];
	_dateFormatter.dateFormat = @"MMM dd";
	_dateFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
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
	return 365;
}

- (KUIRingViewItem *)ringView:(KUIRingView *)ringView itemAtIndex:(NSUInteger)index {
	NSDate *date = [[NSDate alloc] initWithTimeIntervalSince1970:index * 24 * 60 * 60];
	
	return [[KUIRingViewItem alloc] initWithTitle:[_dateFormatter stringFromDate:date]];
}

@end
