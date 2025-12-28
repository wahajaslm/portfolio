//
//  LKViewController.m
//  PanScrollView


#import "LKViewController.h"
#import <QuartzCore/QuartzCore.h>


@interface LKViewController ()
{
    
    BOOL isPaning;
    BOOL isLeftShow,isLeftDragging;
    
}

@end

@implementation LKViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
 
    /* Adding pan gesture on view*/
    UIPanGestureRecognizer* pan = [[UIPanGestureRecognizer alloc]init];
    [pan addTarget:self action:@selector(handlePan:)];
    [self.view_content addGestureRecognizer:pan];
    
    
   // self.PageScrollView.frame = self.view_content.frame;
   
    
    /*Initializing Page view controller*/
    self.pitchBendViewController=[[PitchBendViewController alloc]initWithNibName:@"PitchBendViewController" bundle:nil];
    self.schordsViewController=[[SchordsViewController alloc]initWithNibName:@"SchordsViewController" bundle:nil];
    self.quanTempViewController=[[QuanTempViewController alloc]initWithNibName:@"QuanTempViewController" bundle:nil];
    self.plotViewController=[[PlotViewController alloc]initWithNibName:@"PlotViewController" bundle:nil];
    self.debugViewController=[[DebugViewController alloc]initWithNibName:@"DebugViewController" bundle:nil];
    


    /* Adding view controllers in array*/
    self.viewControllerArray= [[NSMutableArray alloc]initWithObjects:self.pitchBendViewController,self.schordsViewController,self.quanTempViewController,self.plotViewController,self.debugViewController, nil];
    
   
    /* Creating Content offset for scroll view */
       [self.PageScrollView setContentSize:CGSizeMake(self.PageScrollView.frame.size.width* [self.viewControllerArray count], self.PageScrollView.frame.size.height)];
   
  
    /* Adding subviews in PageScrollView*/
    for (int i =0; i < [_viewControllerArray count]; i++)
    {
		UIViewController* viewcontroller= [self.viewControllerArray objectAtIndex:i];
        
        CGRect frame;
        frame.origin.x=self.PageScrollView.frame.size.width*i;
        frame.origin.y=0;
        frame.size= self.PageScrollView.frame.size;
        self.PageScrollView.autoresizingMask=YES;
        [viewcontroller.view setFrame:frame];
        
        [self.PageScrollView addSubview:viewcontroller.view];
	}
    
    
    self.PageControl.numberOfPages=[self.viewControllerArray count];
    self.PageControl.currentPage=0;
    self.PageControl.pageIndicatorTintColor = [UIColor lightGrayColor];
    self.PageControl.currentPageIndicatorTintColor = [UIColor blackColor];
    
    
    self.PageScrollView.delegate=self;
    self.PageScrollView.pagingEnabled = YES;
    [self.PageScrollView.panGestureRecognizer addTarget:self action:@selector(scrollHandlePan:)];
  
    
    
    //Setting up midi, audiocontroller ,and the buffer to start processing
    /*Use this control under the button */
    [NetworkMidiController sharedInstance];
    audioController = [AudioController sharedInstance];
    audioController.muteAudio=YES;
    bufferManager = [audioController getBufferManagerInstance];
 
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updatePlotDebug:) name:@"updatePlotDebug" object:nil];
    
}


-(void)updatePlotDebug:(NSNotification*)note
{
    
    [self.plotViewController SetupPlot:bufferManager];
   // [self.debugViewController SetupDebugView:bufferManager];
    
}



- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
     if (touch.view == self.pitchBendViewController.view)
    {return 0;}
    
     else
     {
         return 1;
     }
}


- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}


- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    CGFloat viewWidth = self.PageScrollView.frame.size.width;
    // content offset - tells by how much the scroll view has scrolled.
    
    NSInteger pagenumber=floor((self.PageScrollView.contentOffset.x - viewWidth / 2) / viewWidth) + 1;
    
 //   NSLog(@"page %li", (long)pagenumber);
    
    self.PageControl.currentPage = pagenumber;
}




-(void)scrollHandlePan:(UIPanGestureRecognizer*) panParam
{
 //   NSLog(@"contentOffset %f", self.PageScrollView.contentOffset.x);
    if(self.PageScrollView.contentOffset.x < 0)
    {
        isPaning = YES;
        isLeftDragging = YES;
     
    }
    
       if(isPaning)
    {
        [self handlePan:panParam];
    }
    

}



-(void)handlePan:(UIPanGestureRecognizer*) panParam
{
    if(isLeftShow)
    {
        isLeftDragging = YES;
    }
   
    else if(!isLeftDragging)
    {
        float v_X = [panParam velocityInView:panParam.view].x;
        if(v_X>0)
        {
            isLeftDragging = YES;
        }
       
    }
    CGPoint point = [panParam translationInView:panParam.view];
    [panParam setTranslation:CGPointZero inView:panParam.view];
    
    float contentX = self.view_content.frame.origin.x;
    if(isLeftDragging)
    {
        contentX +=point.x;
        if(contentX > 200)
        {
            contentX = 200;
        }
        else if(contentX < 0)
        {
            contentX = 0;
        }
    }
    
    CGRect frame = self.view_content.frame;
    frame.origin.x = contentX;
    self.view_content.frame= frame;
    
    if(panParam.state == UIGestureRecognizerStateCancelled || panParam.state == UIGestureRecognizerStateEnded)
    {
        float v_X = [panParam velocityInView:panParam.view].x;
        float diff = 0;
        float finishedX = 0;
        if(isLeftDragging)
        {
            if(v_X > 0)
            {
                diff = 200 - contentX;
                finishedX = 200;
                self.PageScrollView.scrollEnabled = NO;
                   isLeftShow = YES;
            }
            else
            {
                diff = contentX;
                finishedX = 0;
                self.PageScrollView.scrollEnabled = YES;
                isLeftShow = NO;
             
            }
        }
      
        
        NSTimeInterval duration = MIN(0.3f,ABS(diff/v_X));
        [UIView animateWithDuration:duration
                              delay:0
                            options:UIViewAnimationOptionCurveLinear
                         animations:^{
                             CGRect frame = self.view_content.frame;
                             frame.origin.x = finishedX;
                             self.view_content.frame= frame;
                         }
                         completion:^(BOOL finished) {
                             isPaning = NO;
                             isLeftDragging = NO;
                             self.PageControl.currentPage=0;
                            
                         }];
        
        
    }
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)PageChanged:(UIPageControl *)sender {
   
    NSInteger pageNumber = self.PageControl.currentPage;
    
    CGRect frame = self.PageScrollView.frame;
    frame.origin.x = frame.size.width*pageNumber;
    frame.origin.y=0;
    
    [self.PageScrollView scrollRectToVisible:frame animated:YES];

}

- (IBAction)AdvanceSettingsPressed:(id)sender {
    
    AdvancedSettingViewController *controller = [[AdvancedSettingViewController alloc] initWithNibName:@"AdvancedSettingViewController" bundle:nil];
    [[self navigationController] pushViewController:controller animated:YES];
    
    self.navigationController.navigationBar.hidden= NO;

}

- (IBAction)SettingPressed:(UIButton *)sender {
  
    SettingsViewController *controller = [[SettingsViewController alloc] initWithNibName:@"SettingsView" bundle:nil];
   [[self navigationController] pushViewController:controller animated:YES];

    self.navigationController.navigationBar.hidden= NO;

}
- (IBAction)TracksPressed:(id)sender {
    
    TracksViewController *controller = [[TracksViewController alloc] initWithNibName:@"TracksViewController" bundle:nil];
    [[self navigationController] pushViewController:controller animated:YES];
    
    self.navigationController.navigationBar.hidden= NO;
    
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBar.hidden=YES;
}

@end
