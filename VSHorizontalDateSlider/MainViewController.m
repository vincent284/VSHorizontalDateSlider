//
//  MainViewController.m
//  SlidingDateSelector
//
//  Created by Vincent Nguyen on 4/4/14.
//  Copyright (c) 2014 nvson28. All rights reserved.
//

#import "MainViewController.h"
#import "VSHorizontalDateSlider.h"

@interface MainViewController ()
@property (nonatomic, strong) VSHorizontalDateSlider *dateSlider;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@end

@implementation MainViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.dateSlider = [[VSHorizontalDateSlider alloc] init];
    self.dateSlider.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.dateSlider];
    self.dateSlider.selectedDateBackgroundColor = [UIColor magentaColor];
    self.dateSlider.backgroundColor = [UIColor lightGrayColor];
    
    self.dateSlider.date = [NSDate date];
    
    [self.dateSlider addTarget:self
                        action:@selector(dateSliderValueChanged:)
              forControlEvents:UIControlEventValueChanged];
    
    NSArray *constraints;
    NSString *visualFormat;
    visualFormat = @"V:|-100-[dateSlider(==150)]";
    constraints = [NSLayoutConstraint constraintsWithVisualFormat:visualFormat
                                                          options:NSLayoutFormatAlignAllTop
                                                          metrics:nil
                                                            views:@{
                                                                    @"dateSlider":self.dateSlider
                                                                    }];
    [self.view addConstraints:constraints];
    
    visualFormat = @"H:|-[dateSlider]-|";
    constraints = [NSLayoutConstraint constraintsWithVisualFormat:visualFormat
                                                          options:NSLayoutFormatAlignAllTop
                                                          metrics:nil
                                                            views:@{
                                                                    @"dateSlider":self.dateSlider
                                                                    }];
    [self.view addConstraints:constraints];
    
    
}

- (void)dateSliderValueChanged:(id)sender {
    VSHorizontalDateSlider *dateSlider = (VSHorizontalDateSlider *)sender;
    NSDate *date = dateSlider.date;
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MMM-dd"];
    
    self.dateLabel.text = [dateFormatter stringFromDate:date];
    NSLog(@"%@", date);
}

- (IBAction)todayBtnPressed:(id)sender {
    self.dateSlider.date = [NSDate date];
}
@end
