#import "KUIViewController.h"
#import "KUIRingView.h"
#import "KUIDateViewController.h"
#import "KUITimeViewController.h"
#import "KUIColorViewController.h"
#import "KUIAlbumViewController.h"

@interface KUIViewController () <KUIRingViewDelegate, KUIRingViewDataSource>

@property (nonatomic, strong) IBOutlet KUIRingView *ringView;

@end

@implementation KUIViewController

- (void)viewDidLoad {
    [super viewDidLoad];
	
	self.ringView.delegate = self;
	self.ringView.dataSource = self;
}

#pragma mark -
#pragma mark KUIRingViewDelegate

- (void)ringView:(KUIRingView *)ringView didSelectItemAtIndex:(NSUInteger)index {
	switch (index) {
		case 0:
			[self performSegueWithIdentifier:@"Date" sender:self];
			break;
		case 1:
			[self performSegueWithIdentifier:@"Time" sender:self];
			break;
		case 2:
			[self performSegueWithIdentifier:@"Color" sender:self];
			break;
		case 3:
			[self performSegueWithIdentifier:@"Album" sender:self];
			break;
		default:
			@throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"Never happens." userInfo:nil];
	}
}

#pragma mark -
#pragma mark KUIRingViewDataSource

- (NSUInteger)ringViewNumberOfItems:(KUIRingView *)ringView {
	return 4;
}

- (KUIRingViewItem *)ringView:(KUIRingView *)ringView itemAtIndex:(NSUInteger)index {
	switch (index) {
		case 0:
			return [[KUIRingViewItem alloc] initWithTitle:@"Date"];
		case 1:
			return [[KUIRingViewItem alloc] initWithTitle:@"Time"];
		case 2:
			return [[KUIRingViewItem alloc] initWithTitle:@"Color"];
		case 3:
			return [[KUIRingViewItem alloc] initWithTitle:@"Album"];
		default:
			@throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"Never happens." userInfo:nil];
	}
}

@end
