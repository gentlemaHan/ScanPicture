//
//  ViewController.m
//  ScanPicture
//
//  Created by 韩小东 on 16/3/21.
//  Copyright © 2016年 HXD. All rights reserved.
//

#import "ViewController.h"
#import "WebViewController.h"
#import <AVFoundation/AVFoundation.h>

@interface ViewController ()<AVCaptureMetadataOutputObjectsDelegate>
@property (nonatomic,strong)    AVCaptureSession    *session;
@property (nonatomic,strong)    AVCaptureVideoPreviewLayer *previewLayer;
@property (nonatomic,strong)    AVCaptureMetadataOutput *metadataOutput;
@property (weak, nonatomic) IBOutlet UIButton *startBtn;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(startFail) name:AVCaptureSessionRuntimeErrorNotification object:nil];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(AVCapDesDidChange) name:AVCaptureInputPortFormatDescriptionDidChangeNotification object:nil];
    
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (IBAction)start:(id)sender {
    AVAuthorizationStatus autuorizationStation = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if (autuorizationStation == AVAuthorizationStatusNotDetermined) {
        [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
            if (granted) {
                [self startScanPicture];
            }
        }];
    }else if (autuorizationStation == AVAuthorizationStatusAuthorized){
        [self startScanPicture];
    }
}

-(void)startFail{
    [self.session stopRunning];
    [self.previewLayer removeFromSuperlayer];
    self.startBtn.hidden = NO;
}

-(void)AVCapDesDidChange{
    self.metadataOutput.rectOfInterest = [self.previewLayer metadataOutputRectOfInterestForRect:CGRectMake(80, 80, 160, 160)];
}

-(void)startScanPicture{
    self.session = [[AVCaptureSession alloc] init];
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    NSError *error;
    AVCaptureDeviceInput *deviceInput = [AVCaptureDeviceInput deviceInputWithDevice:device error:&error];
    if (deviceInput) {
        [self.session addInput:deviceInput];
        self.metadataOutput = [[AVCaptureMetadataOutput alloc] init];
        [self.metadataOutput setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
        [self.session addOutput:self.metadataOutput];
        self.metadataOutput.metadataObjectTypes = @[AVMetadataObjectTypeQRCode];
        self.previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.session];
        self.previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
        self.previewLayer.frame = self.view.frame;
        [self.view.layer insertSublayer:self.previewLayer atIndex:0];
        [self.session startRunning];
        self.startBtn.hidden = YES;
        
    }else{
        NSLog(@"%@",error);
    }
}

-(void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection{
    [self.session stopRunning];
    AVMetadataMachineReadableCodeObject *metadataObject = metadataObjects.firstObject;
    NSLog(@"%@",metadataObject.stringValue);
    [self.previewLayer removeFromSuperlayer];
    self.startBtn.hidden = NO;
    WebViewController   *webViewC = [[WebViewController alloc] init];
    [webViewC setUrlStr:metadataObject.stringValue];
    [self.navigationController pushViewController:webViewC animated:YES];
}

@end
