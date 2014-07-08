#import <UIKit/UIKit.h>

@class KUIRingView;
@class KUIRingViewItem;

@protocol KUIRingViewDelegate <NSObject>

- (void)ringView:(KUIRingView *)ringView didSelectItemAtIndex:(NSUInteger)index;

@end

@protocol KUIRingViewDataSource <NSObject>

- (NSUInteger)ringViewNumberOfItems:(KUIRingView *)ringView;
- (KUIRingViewItem *)ringView:(KUIRingView *)ringView itemAtIndex:(NSUInteger)index;

@end

@interface KUIRingView : UIView

@property (nonatomic, weak) id <KUIRingViewDelegate> delegate;
@property (nonatomic, weak) id <KUIRingViewDataSource> dataSource;

@property (nonatomic, strong) UIFont *font;

- (instancetype)initWithFrame:(CGRect)frame;

- (UIColor *)itemColorForState:(UIControlState)state;
- (void)setItemColor:(UIColor *)color forState:(UIControlState)state;

- (UIColor *)titleColorForState:(UIControlState)state;
- (void)setTitleColor:(UIColor *)color forState:(UIControlState)state;

- (void)reloadData;

@end

@interface KUIRingViewItem : NSObject

@property (nonatomic, strong) NSString *title;

@property (nonatomic, assign) BOOL clipsImage;

- (id)initWithTitle:(NSString *)title;

- (UIColor *)itemColorForState:(UIControlState)state;
- (void)setItemColor:(UIColor *)color forState:(UIControlState)state;

- (UIColor *)titleColorForState:(UIControlState)state;
- (void)setTitleColor:(UIColor *)color forState:(UIControlState)state;

- (UIImage *)imageForState:(UIControlState)state;
- (void)setImage:(UIImage *)image forState:(UIControlState)state;

@end