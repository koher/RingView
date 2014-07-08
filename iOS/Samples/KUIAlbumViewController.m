#import "KUIAlbumViewController.h"
#import "KUIRingView.h"
#import "KUIImageViewController.h"
#import "KUIMovieViewController.h"

#import <AssetsLibrary/AssetsLibrary.h>

@interface KUIAlbumViewControllerItem : KUIRingViewItem

@property (nonatomic, readonly) ALAsset *asset;

- (id)initWithTitle:(NSString *)title asset:(ALAsset *)asset;

@end

@implementation KUIAlbumViewControllerItem

- (id)initWithTitle:(NSString *)title asset:(ALAsset *)asset {
	self = [super initWithTitle:title];
	if (self) {
		_asset = asset;
	}
	
	return self;
}

- (UIImage *)imageForState:(UIControlState)state {
	switch (state) {
		case UIControlStateNormal:
			return [UIImage imageWithCGImage:[_asset thumbnail]];
		default:
			return nil;
	}
}

@end

@interface KUIAlbumViewController () <KUIRingViewDelegate, KUIRingViewDataSource> {
	ALAssetsLibrary *_assetsLibrary;
	NSDateFormatter *_dateFormatter;
	
	NSMutableArray *_items;
	
	NSUInteger _selectedIndex;
}

@property (nonatomic, strong) IBOutlet KUIRingView *ringView;

- (IBAction)onSwitchValueChanged:(id)sender;

@end

@implementation KUIAlbumViewController

- (void)viewDidLoad {
    [super viewDidLoad];
	
	self.ringView.delegate = self;
	self.ringView.dataSource = self;
	
	_items = [[NSMutableArray alloc] initWithCapacity:10];
	
	_dateFormatter = [[NSDateFormatter alloc] init];
	_dateFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
	_dateFormatter.dateStyle = NSDateFormatterShortStyle;
	_dateFormatter.timeStyle = NSDateFormatterShortStyle;
	
	_assetsLibrary = [[ALAssetsLibrary alloc] init];
	[_assetsLibrary enumerateGroupsWithTypes:ALAssetsGroupSavedPhotos usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
		if (group) {
			[group enumerateAssetsUsingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
				KUIAlbumViewControllerItem *item = [[KUIAlbumViewControllerItem alloc] initWithTitle:[_dateFormatter stringFromDate:[result valueForProperty:ALAssetPropertyDate]] asset:result];
				[_items addObject:item];
				
				[self.ringView reloadData];
			}];
		}
	} failureBlock:^(NSError *error) {
	}];
}

- (IBAction)onSwitchValueChanged:(id)sender {
	for (KUIRingViewItem *item in _items) {
		item.clipsImage = [sender isOn];
	}
	
	[self.ringView reloadData];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
	KUIAlbumViewControllerItem *item = (KUIAlbumViewControllerItem *)[self ringView:self.ringView itemAtIndex:_selectedIndex];
	ALAsset *asset = item.asset;
	
	if ([@"Image" isEqual:segue.identifier]) {
		KUIImageViewController *viewController = segue.destinationViewController;
		viewController.title = item.title;
		viewController.image = [[UIImage alloc] initWithCGImage:[[asset defaultRepresentation] fullScreenImage]];
	} else if ([@"Movie" isEqual:segue.identifier]) {
		KUIMovieViewController *viewController = segue.destinationViewController;
		viewController.title = item.title;
		viewController.URL = [asset valueForProperty:ALAssetPropertyAssetURL];
	}
}

#pragma mark -
#pragma mark KUIRingViewDelegate

- (void)ringView:(KUIRingView *)ringView didSelectItemAtIndex:(NSUInteger)index {
	_selectedIndex = index;
	KUIAlbumViewControllerItem *item = (KUIAlbumViewControllerItem *)[self ringView:ringView itemAtIndex:_selectedIndex];

	NSString *assetType = [item.asset valueForProperty:ALAssetPropertyType];
	if ([ALAssetTypePhoto isEqual:assetType]) {
		[self performSegueWithIdentifier:@"Image" sender:self];
	} else if ([ALAssetTypeVideo isEqual:assetType]) {
		[self performSegueWithIdentifier:@"Movie" sender:self];
	} else {
		[[[UIAlertView alloc] initWithTitle:item.title message:@"The type of the selected item is unknown." delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles:nil] show];
		return;
	}
}

#pragma mark -
#pragma mark KUIRingViewDataSource

- (NSUInteger)ringViewNumberOfItems:(KUIRingView *)ringView {
	return _items.count;
}

- (KUIRingViewItem *)ringView:(KUIRingView *)ringView itemAtIndex:(NSUInteger)index {
	return _items[index];
}

@end
