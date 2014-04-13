//
//  DateSlider.m
//  SlidingDateSelector
//
//  Created by Vincent Nguyen on 4/4/14.
//  Copyright (c) 2014 nvson28. All rights reserved.
//

#import "VSHorizontalDateSlider.h"


#pragma mark - ScrollViewContainerView class

@interface ScrollViewContainerView : UIView
@property (nonatomic, strong) UIScrollView *scrollView;
@end

@implementation ScrollViewContainerView
- (void)setScrollView:(UIScrollView *)scrollView {
    if (_scrollView) {
        [_scrollView removeFromSuperview];
        _scrollView = nil;
    }
    
    [self addSubview:scrollView];
    _scrollView = scrollView;
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    if ([self pointInside:point withEvent:event]) {
        UIView *hitView = [super hitTest:point withEvent:event];
        if (point.y >= CGRectGetMinY(_scrollView.frame) && point.y <= CGRectGetMaxY(_scrollView.frame))
            return _scrollView;
        else
            return hitView;
	}
	return nil;
}
@end


#pragma mark -
#pragma mark - SlidingContainerView class

@protocol SlidingContainerViewDelegate;

@interface SlidingContainerView : ScrollViewContainerView <UIScrollViewDelegate>
@property (nonatomic, strong) UIView *scrollerContentView;
@property (nonatomic, strong) NSArray *labels;
@property (nonatomic, assign) NSUInteger offset;
@property (nonatomic, weak) id<SlidingContainerViewDelegate>delegate;
@end

@protocol SlidingContainerViewDelegate <NSObject>
- (void)slidingContainerView:(SlidingContainerView *)slidingContainerView
           didScrollToOffset:(NSUInteger)offset;
@end

@implementation SlidingContainerView
- (id)init {
    self = [super init];
    if (self) {
        [self commonInit];
   }
    
    return self;
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self commonInit];
    }
    
    return self;
}

- (void)commonInit {
    self.labels = [NSArray array];
    self.offset = 0;
    
    self.translatesAutoresizingMaskIntoConstraints = NO;
    self.clipsToBounds = YES;
    
    // Init subviews
    self.scrollView = [[UIScrollView alloc] init];
    self.scrollView.translatesAutoresizingMaskIntoConstraints = NO;
    self.scrollView.showsHorizontalScrollIndicator = NO;
    self.scrollView.clipsToBounds = NO;
    self.scrollView.pagingEnabled = YES;
    self.scrollView.delegate = self;
    
    self.scrollView.backgroundColor = [UIColor cyanColor];
    
    self.scrollerContentView = [[UIView alloc] init];
    self.scrollerContentView.backgroundColor = [UIColor clearColor];
    [self.scrollView addSubview:self.scrollerContentView];
    
    // Layout
    NSLayoutConstraint *aConstraint;
    aConstraint = [NSLayoutConstraint constraintWithItem:self
                                               attribute:NSLayoutAttributeHeight
                                               relatedBy:NSLayoutRelationEqual
                                                  toItem:self.scrollView
                                               attribute:NSLayoutAttributeHeight
                                              multiplier:1.0
                                                constant:0.0];
    [self addConstraint:aConstraint];
    
    aConstraint = [NSLayoutConstraint constraintWithItem:self.scrollView
                                               attribute:NSLayoutAttributeHeight
                                               relatedBy:NSLayoutRelationEqual
                                                  toItem:self.scrollView
                                               attribute:NSLayoutAttributeWidth
                                              multiplier:1.0
                                                constant:0.0];
    [self.scrollView addConstraint:aConstraint];
    
    aConstraint = [NSLayoutConstraint constraintWithItem:self
                                               attribute:NSLayoutAttributeCenterX
                                               relatedBy:NSLayoutRelationEqual
                                                  toItem:self.scrollView
                                               attribute:NSLayoutAttributeCenterX
                                              multiplier:1.0
                                                constant:0.0];
    [self addConstraint:aConstraint];
    
    aConstraint = [NSLayoutConstraint constraintWithItem:self
                                               attribute:NSLayoutAttributeCenterY
                                               relatedBy:NSLayoutRelationEqual
                                                  toItem:self.scrollView
                                               attribute:NSLayoutAttributeCenterY
                                              multiplier:1.0
                                                constant:0.0];
    [self addConstraint:aConstraint];
    
    // KVO
    [self addObserver:self forKeyPath:@"scrollView.bounds" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:nil];
}

- (void)dealloc {
    [self removeObserver:self forKeyPath:@"scrollView.frame"];
}

- (void)setOffset:(NSUInteger)offset {
    _offset = offset;
    
    [self.scrollView setContentOffset:CGPointMake(offset*self.scrollView.frame.size.width, 0) animated:YES];
}

- (void)buildLabelsWithInitialOffset:(NSUInteger)offset {
    NSString *visualFormat = [NSString stringWithFormat:@"H:|"];
    NSMutableDictionary *labels = [NSMutableDictionary dictionary];
    
    for (NSInteger i = 0; i < self.labels.count; i++) {
        UILabel *label = self.labels[i];
        label.translatesAutoresizingMaskIntoConstraints = NO;
        [self.scrollerContentView addSubview:label];
        
        NSArray *constraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[label]|"
                                                                       options:0
                                                                       metrics:nil
                                                                         views:@{@"label":label}];
        [self.scrollerContentView addConstraints:constraints];
        
        NSLayoutConstraint *constraint = [NSLayoutConstraint constraintWithItem:label
                                                                      attribute:NSLayoutAttributeWidth
                                                                      relatedBy:NSLayoutRelationEqual
                                                                         toItem:label
                                                                      attribute:NSLayoutAttributeHeight
                                                                     multiplier:1
                                                                       constant:0];
        [self.scrollerContentView addConstraint:constraint];
        
        visualFormat = [visualFormat stringByAppendingString:[NSString stringWithFormat:@"[label%d]",i]];
        [labels setValue:label forKey:[NSString stringWithFormat:@"label%d",i]];
    }
    
    if (self.labels.count > 0) {
        NSArray *constraints = [NSLayoutConstraint constraintsWithVisualFormat:visualFormat
                                                                       options:0
                                                                       metrics:nil
                                                                         views:labels];
        [self.scrollerContentView addConstraints:constraints];
    }
    
    self.scrollView.contentSize = CGSizeMake(self.labels.count*self.frame.size.height, self.frame.size.height);
    self.scrollerContentView.frame = CGRectMake(0, 0, self.labels.count*self.frame.size.height, self.frame.size.height);
    
    self.offset = offset;
}

- (void)setLabels:(NSArray *)labels {
    // delete the current labels if any from superview
    for (UILabel *label in _labels) {
        [label removeFromSuperview];
    }
    
    _labels = labels;
    
    [self buildLabelsWithInitialOffset:0];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    CGFloat pageWidth = scrollView.frame.size.width;
    float fractionalPage = scrollView.contentOffset.x / pageWidth;
    NSInteger newOffset = lround(fractionalPage);
    
    if (self.offset != newOffset) {
        _offset = newOffset;
        
        if (self.delegate) {
            [self.delegate slidingContainerView:self
                              didScrollToOffset:self.offset];
        }
    }
}


#pragma mark - KVO
- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
    NSValue *newValue = (NSValue *)[change objectForKey:NSKeyValueChangeNewKey];
    NSValue *oldValue = (NSValue *)[change objectForKey:NSKeyValueChangeOldKey];
    
    if (![newValue isEqual:[NSNull null]] && ![oldValue isEqual:[NSNull null]]) {
        CGRect newRect;
        [newValue getValue:&newRect];
        
        CGRect oldRect;
        [oldValue getValue:&oldRect];
        
        CGFloat newWidth = newRect.size.width;
        CGFloat oldWidth = oldRect.size.width;
        
        if (newWidth != oldWidth) {
            [self buildLabelsWithInitialOffset:self.offset];
        }
    }
}

@end

#pragma mark -
#pragma mark - VSHorizontalDateSlider class

static const NSUInteger defaultStartYear = 1970;
static const NSUInteger defaultEndYear = 2100;

@interface VSHorizontalDateSlider() <SlidingContainerViewDelegate>

@property (nonatomic, assign) NSUInteger startYear;
@property (nonatomic, assign) NSUInteger endYear;

@property (nonatomic, strong) SlidingContainerView *yearScrollerView;
@property (nonatomic, strong) SlidingContainerView *monthScrollerView;
@property (nonatomic, strong) SlidingContainerView *dayScrollerView;

@property (nonatomic, strong) NSDateFormatter *dateFormatter;
@end

@implementation VSHorizontalDateSlider

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self commonInit];
        [self buildView];
    }
    
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self commonInit];
        [self buildView];
    }
    return self;
}

- (void)commonInit {
    self.startYear = defaultStartYear;
    self.endYear = defaultEndYear;
    
    self.dateFormatter = [[NSDateFormatter alloc] init];
    [self.dateFormatter setDateFormat:@"yyyy-MM-dd"];
}

- (void)buildView {
    
    self.yearScrollerView = [[SlidingContainerView alloc] init];
    self.yearScrollerView.delegate = self;
    [self addSubview:self.yearScrollerView];
    
    self.monthScrollerView = [[SlidingContainerView alloc] init];
    self.monthScrollerView.delegate = self;
    [self addSubview:self.monthScrollerView];
    
    self.dayScrollerView = [[SlidingContainerView alloc] init];
    self.dayScrollerView.delegate = self;
    [self addSubview:self.dayScrollerView];
    
    [self layoutConstraints];
    
    [self buildYearScroller];
    [self buildMonthScroller];
    [self buildDayScroller];
}

#pragma mark - Getters and setters
- (void)setDate:(NSDate *)date {
    NSDictionary *offSetValues = [self dateToOffsets:date];
    if (offSetValues) {
        NSUInteger yearOffset = [offSetValues[@"yearOffset"] integerValue];
        NSUInteger monthOffset = [offSetValues[@"monthOffset"] integerValue];
        NSUInteger dayOffset = [offSetValues[@"dayOffset"] integerValue];
        
        self.yearScrollerView.offset= yearOffset;
        self.monthScrollerView.offset = monthOffset;
        self.dayScrollerView.offset = dayOffset;
    }
    
    _date = date;
    
    [self sendActionsForControlEvents:UIControlEventValueChanged];
}

- (void)setSelectedDateBackgroundColor:(UIColor *)selectedDateBackgroundColor {
    _selectedDateBackgroundColor = selectedDateBackgroundColor;
    
    _yearScrollerView.scrollView.backgroundColor = selectedDateBackgroundColor;
    _monthScrollerView.scrollView.backgroundColor = selectedDateBackgroundColor;
    _dayScrollerView.scrollView.backgroundColor = selectedDateBackgroundColor;
}

#pragma mark - Layouts

- (void)layoutConstraints {
    // container views
    NSArray *constraints;
    NSString *visualFormat;
    
    visualFormat = @"V:|[yearView][monthView(==yearView)][dayView(==monthView)]|";
    constraints = [NSLayoutConstraint constraintsWithVisualFormat:visualFormat
                                                          options:NSLayoutFormatAlignAllCenterX
                                                          metrics:nil
                                                            views:@{
                                                                    @"yearView":self.yearScrollerView,
                                                                    @"monthView":self.monthScrollerView,
                                                                    @"dayView":self.dayScrollerView
                                                                    }];
    [self addConstraints:constraints];
    
    visualFormat = @"H:|[yearView(==monthView)]|";
    constraints = [NSLayoutConstraint constraintsWithVisualFormat:visualFormat
                                                          options:NSLayoutFormatAlignAllLeft
                                                          metrics:nil
                                                            views:@{
                                                                    @"yearView":self.yearScrollerView,
                                                                    @"monthView":self.monthScrollerView
                                                                    }];
    [self addConstraints:constraints];
    
    visualFormat = @"H:|[monthView(==dayView)]|";
    constraints = [NSLayoutConstraint constraintsWithVisualFormat:visualFormat
                                                          options:NSLayoutFormatAlignAllLeft
                                                          metrics:nil
                                                            views:@{
                                                                    @"monthView":self.monthScrollerView,
                                                                    @"dayView":self.dayScrollerView
                                                                    }];
    [self addConstraints:constraints];
}

- (void)buildYearScroller
{
    NSMutableArray *labels = [NSMutableArray array];
    for (NSInteger i = self.startYear; i < self.endYear; i++) {
        UILabel *label = [[UILabel alloc] init];
        label.text = [NSString stringWithFormat:@"%d",i];
        label.textAlignment = NSTextAlignmentCenter;
        label.translatesAutoresizingMaskIntoConstraints = NO;
        
        [labels addObject:label];
    }
    
    self.yearScrollerView.labels = labels;
}

- (void)buildMonthScroller {
    NSMutableArray *labels = [NSMutableArray array];
    for (NSInteger i = 0; i < 12; i++) {
        UILabel *label = [[UILabel alloc] init];
        label.textAlignment = NSTextAlignmentCenter;
        label.translatesAutoresizingMaskIntoConstraints = NO;
        
        NSString *labelText = @"";
        switch (i) {
            case 0:
                labelText = @"Jan";
                break;
            case 1:
                labelText = @"Feb";
                break;
            case 2:
                labelText = @"Mar";
                break;
            case 3:
                labelText = @"Apr";
                break;
            case 4:
                labelText = @"May";
                break;
            case 5:
                labelText = @"Jun";
                break;
            case 6:
                labelText = @"Jul";
                break;
            case 7:
                labelText = @"Aug";
                break;
            case 8:
                labelText = @"Sep";
                break;
            case 9:
                labelText = @"Oct";
                break;
            case 10:
                labelText = @"Nov";
                break;
            case 11:
                labelText = @"Dec";
                break;
                
            default:
                break;
        }
        label.text = labelText;
        
        [labels addObject:label];
    }
    
    self.monthScrollerView.labels = labels;
}

- (void)buildDayScroller
{
    NSDate *dayInMonth = [self.dateFormatter dateFromString:[NSString stringWithFormat:@"%d-%d-15",self.yearScrollerView.offset+self.startYear, self.monthScrollerView.offset+1]];
    NSUInteger numberOfDays = 31;
    
    if (dayInMonth) {
        NSCalendar *c = [NSCalendar currentCalendar];
        NSRange days = [c rangeOfUnit:NSDayCalendarUnit
                               inUnit:NSMonthCalendarUnit
                              forDate:dayInMonth];
        
        numberOfDays = days.length;
    }
    
    NSMutableArray *labels = [NSMutableArray array];
    
    for (NSInteger i = 1; i <= numberOfDays; i++) {
        UILabel *label = [[UILabel alloc] init];
        label.textAlignment = NSTextAlignmentCenter;
        label.text = [NSString stringWithFormat:@"%d", i];
        label.translatesAutoresizingMaskIntoConstraints = NO;
        
        [labels addObject:label];
    }
    
    self.dayScrollerView.labels = labels;
}

+ (BOOL)requiresConstraintBasedLayout {
    return YES;
}

#pragma mark - SlidingContainerViewDelegate
- (void)slidingContainerView:(SlidingContainerView *)slidingContainerView
           didScrollToOffset:(NSUInteger)offset
{
    BOOL dateScrollerInvalidated = NO;
    
    if (slidingContainerView == self.yearScrollerView) {
        dateScrollerInvalidated = YES;
    }
    else if (slidingContainerView == self.monthScrollerView) {
        dateScrollerInvalidated = YES;
    }
    else if (slidingContainerView == self.dayScrollerView) {
        
    }
    
    if (dateScrollerInvalidated) {
        [self buildDayScroller];
    }
    
    NSDate *date = [self.dateFormatter dateFromString:[NSString stringWithFormat:@"%d-%d-%d", self.yearScrollerView.offset+self.startYear, self.monthScrollerView.offset+1, self.dayScrollerView.offset+1]];
    self.date = date;
}

#pragma mark - Utilities

- (NSDictionary *)dateToOffsets:(NSDate *)date {
    NSString *dateInString = [self.dateFormatter stringFromDate:date];
    if (dateInString) {
        NSArray *components = [dateInString componentsSeparatedByString:@"-"];
        if (components.count < 3) {
            return nil;
        }
        else {
            NSUInteger year = [components[0] integerValue];
            NSUInteger month = [components[1] integerValue];
            NSUInteger day = [components[2] integerValue];
            
            return @{@"yearOffset":[NSNumber numberWithInteger:(year - self.startYear)],
                     @"monthOffset":[NSNumber numberWithInteger:(month - 1)],
                     @"dayOffset":[NSNumber numberWithInteger:(day - 1)]
                     };
        }
    }
    
    return nil;
}

@end