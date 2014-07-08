#import "KUIImageViewController.h"

@interface KUIImageViewController ()

@property (nonatomic, strong) IBOutlet UIImageView *imageView;

@end

@implementation KUIImageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
	
	self.imageView.contentMode = UIViewContentModeScaleAspectFit;
	self.imageView.image = _image;
}

- (IBAction)onTap:(id)sender {
	[self.navigationController setNavigationBarHidden:!self.navigationController.navigationBarHidden animated:YES];
}

@end
