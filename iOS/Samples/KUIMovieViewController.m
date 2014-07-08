#import "KUIMovieViewController.h"

#import <MediaPlayer/MediaPlayer.h>

@interface KUIMovieViewController () {
	MPMoviePlayerController *_controller;
}

@end

@implementation KUIMovieViewController

- (void)viewDidLoad {
    [super viewDidLoad];
	
	_controller = [[MPMoviePlayerController alloc] initWithContentURL:_URL];
	[_controller prepareToPlay];
	_controller.controlStyle = MPMovieControlStyleNone;
	
	UIView *moviePlayerView = _controller.view;
	moviePlayerView.userInteractionEnabled = NO;
	moviePlayerView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	moviePlayerView.frame = self.view.bounds;
	[self.view addSubview:moviePlayerView];
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	
	[_controller play];
}

- (void)viewWillDisappear:(BOOL)animated {
	[_controller stop];
	
	[super viewWillDisappear:animated];
}

- (IBAction)onTap:(id)sender {
	[self.navigationController setNavigationBarHidden:!self.navigationController.navigationBarHidden animated:YES];
}

@end
