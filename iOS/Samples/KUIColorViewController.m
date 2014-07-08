#import "KUIColorViewController.h"
#import "KUIRingView.h"

@interface KUIColorViewController () <KUIRingViewDelegate, KUIRingViewDataSource>

@property (nonatomic, strong) IBOutlet KUIRingView *ringView;

@end

@implementation KUIColorViewController

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
	return 1536;
}

- (KUIRingViewItem *)ringView:(KUIRingView *)ringView itemAtIndex:(NSUInteger)index {
	NSString *title = nil;
	if (index % 128 == 0) {
		switch (index / 128) {
			case 0:
				title = @"Red";
				break;
			case 1:
				title = @"Orange";
				break;
			case 2:
				title = @"Yellow";
				break;
			case 3:
				title = @"Spring";
				break;
			case 4:
				title = @"Green";
				break;
			case 5:
				title = @"Teal";
				break;
			case 6:
				title = @"Cyan";
				break;
			case 7:
				title = @"Azure";
				break;
			case 8:
				title = @"Blue";
				break;
			case 9:
				title = @"Violet";
				break;
			case 10:
				title = @"Magenta";
				break;
			case 11:
				title = @"Pink";
				break;
			default:
				@throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"Never happens." userInfo:nil];
		}
	}

	NSUInteger red, green, blue;
	NSUInteger value = index % 256;
	
	switch (index / 256) {
		case 0:
			red = 255;
			green = value;
			blue = 0;
			break;
		case 1:
			red = 255 - value;
			green = 255;
			blue = 0;
			break;
		case 2:
			red = 0;
			green = 255;
			blue = value;
			break;
		case 3:
			red = 0;
			green = 255 - value;
			blue = 255;
			break;
		case 4:
			red = value;
			green = 0;
			blue = 255;
			break;
		case 5:
			red = 255;
			green = 0;
			blue = 255 - value;
			break;
		default:
			@throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"Never happens." userInfo:nil];
	}
	
	if (!title) {
		title = [NSString stringWithFormat:@"#%02lx%02lx%02lx", (unsigned long)red, (unsigned long)green, (unsigned long)blue];
	}
	
	KUIRingViewItem *item = [[KUIRingViewItem alloc] initWithTitle:title];
	[item setItemColor:[[UIColor alloc] initWithRed:red / 255.0 green:green / 255.0 blue:blue / 255.0 alpha:1.0] forState:UIControlStateNormal];
	
	return item;
}

@end
