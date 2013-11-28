//
//  AppDelegate.m
//  CardScan
//
//  Created by Dawn on 13-11-26.
//  Copyright (c) 2013年 Dawn. All rights reserved.
//

#import "AppDelegate.h"
#import "opencv2/opencv.hpp"
#import "UIImage+OpenCV.h"
#import <QuartzCore/QuartzCore.h>

@implementation AppDelegate

- (void)dealloc
{
    [_window release];
    [super dealloc];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];
    // Override point for customization after application launch.
    self.window.backgroundColor = [UIColor whiteColor];
   
    
    //457 × 292
    cardView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 40, 320, 320 * 292.0/457)];
    [self.window addSubview:cardView];
    [cardView release];
    cardView.image = [UIImage imageNamed:@"card3.png"];
    
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    btn.frame = CGRectMake(20, 320, 320 - 40, 40);
    [btn setTitle:@"处理" forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(imageToDeal) forControlEvents:UIControlEventTouchUpInside];
    [self.window addSubview:btn];

     [self.window makeKeyAndVisible];
    return YES;
}

- (void) imageToDeal{
    /*
    UIImage *inputImage = cardView.image;
    cv::Mat inputMat = [inputImage CVMat];
    cv::Mat grayMat;
    cv::cvtColor(inputMat, grayMat, CV_BGR2GRAY );
    inputMat.release();
//    cv::Mat detected_edges;
//    cv::blur(grayMat, detected_edges, cv::Size(3,3));
//    grayMat.release();
//    cv::Mat outputMat;
//    cv::Canny(detected_edges, outputMat, 10, 100);
//    detected_edges.release();
    
    cv::Mat bin;
    cv::threshold(grayMat, bin, 140, 255,CV_THRESH_BINARY);
    cv::Mat blur;
    cv::medianBlur(bin, blur, 3);
    grayMat.release();
    
    
    UIImage *newImage = [UIImage imageWithCVMat:blur];
    
    cardView.image = newImage;
     */
//    UIImage *cardImage = [[UIImage alloc] initWithCGImage:cardView.image.CGImage];
//    cardView.image = [self grayscale:cardImage type:1];
//    [cardImage release];
    
    UIImage *inputImage = cardView.image;
    cv::Mat inputMat = [inputImage CVMat];
    
    cv::Mat gray;
    cv::cvtColor(inputMat, gray, CV_RGB2GRAY);
    
    
    //cv::Mat blur;
    //cv::medianBlur(gray, blur, 3);
    
    cv::Mat bin;
    cv::threshold(gray, bin,80, 255, CV_THRESH_BINARY_INV);
    
//    cv::Mat commonBlur;
//    cv::blur(bin, commonBlur, cv::Size(4,4));
    
    cv::Mat blur;
    cv::medianBlur(bin, blur, 3);
 
    cv::Mat erode;
    cv::Mat element = cv::getStructuringElement(0,cv::Size( 3, 3 ),cv::Point( 0, 0 ) );
    cv::erode(blur, erode, element);
    
    cv::Mat dilate;
    cv::Mat element2 = cv::getStructuringElement(0,cv::Size(2,2 ),cv::Point( 0, 0 ) );
    cv::dilate(erode, dilate, element2);
    
    
    cv::Mat bin2;
    cv::threshold(dilate, bin2, 100, 255, CV_THRESH_BINARY_INV);
    

    
    UIImage *newImage = [UIImage imageWithCVMat:bin2];
    cardView.image = newImage;
    

    cv::vector< cv::vector<cv::Point> > contours;
    cv::findContours(bin2, contours, CV_RETR_EXTERNAL, CV_CHAIN_APPROX_NONE);
    
    
    cv::vector<cv::vector<cv::Point> >::iterator it = contours.begin();
    while (it!=contours.end()) {
        cv::RotatedRect rect = minAreaRect(cv::Mat(*it));
        if(rect.size.height < 30 && rect.size.height > 10 && rect.center.y > 150 && rect.center.y < 195 ){
            ++it; // A valid rectangle found
        } else {
            it= contours.erase(it);
        }
    }

    cv::vector<cv::Rect> boundRect(contours.size());
    for (int i = 0; i < contours.size(); ++i) {
        boundRect[i] = cv::boundingRect(cv::Mat(contours[i]));
        
        NSLog(@"%d,%d,%d,%d",boundRect[i].x,boundRect[i].y,boundRect[i].width,boundRect[i].height);
        
        UILabel *testLbl = [[UILabel alloc] initWithFrame:CGRectMake(boundRect[i].x * 320.0/457, boundRect[i].y*320.0/457, boundRect[i].width*320.0/457, boundRect[i].height*320.0/457)];
        testLbl.layer.borderColor = [UIColor greenColor].CGColor;
        testLbl.layer.borderWidth = 1.0f;
        testLbl.backgroundColor = [UIColor clearColor];
        [cardView addSubview:testLbl];
        [testLbl release];
        
        
    }

}

- (UIImage*) grayscale:(UIImage*)anImage type:(char)type {
    CGImageRef  imageRef;
    imageRef = anImage.CGImage;
    
    size_t width  = CGImageGetWidth(imageRef);
    size_t height = CGImageGetHeight(imageRef);
    
    // ピクセルを構成するRGB各要素が何ビットで構成されている
    size_t                  bitsPerComponent;
    bitsPerComponent = CGImageGetBitsPerComponent(imageRef);
    
    // ピクセル全体は何ビットで構成されているか
    size_t                  bitsPerPixel;
    bitsPerPixel = CGImageGetBitsPerPixel(imageRef);
    
    // 画像の横1ライン分のデータが、何バイトで構成されているか
    size_t                  bytesPerRow;
    bytesPerRow = CGImageGetBytesPerRow(imageRef);
    
    // 画像の色空間
    CGColorSpaceRef         colorSpace;
    colorSpace = CGImageGetColorSpace(imageRef);
    
    // 画像のBitmap情報
    CGBitmapInfo            bitmapInfo;
    bitmapInfo = CGImageGetBitmapInfo(imageRef);
    
    // 画像がピクセル間の補完をしているか
    bool                    shouldInterpolate;
    shouldInterpolate = CGImageGetShouldInterpolate(imageRef);
    
    // 表示装置によって補正をしているか
    CGColorRenderingIntent  intent;
    intent = CGImageGetRenderingIntent(imageRef);
    
    // 画像のデータプロバイダを取得する
    CGDataProviderRef   dataProvider;
    dataProvider = CGImageGetDataProvider(imageRef);
    
    // データプロバイダから画像のbitmap生データ取得
    CFDataRef   data;
    UInt8*      buffer;
    data = CGDataProviderCopyData(dataProvider);
    buffer = (UInt8*)CFDataGetBytePtr(data);
    
    // 1ピクセルずつ画像を処理
    NSUInteger  x, y;
    for (y = 0; y < height; y++) {
        for (x = 0; x < width; x++) {
            UInt8*  tmp;
            tmp = buffer + y * bytesPerRow + x * 4; // RGBAの4つ値をもっているので、1ピクセルごとに*4してずらす
            
            // RGB値を取得
            UInt8 red,green,blue;
            red = *(tmp + 0);
            green = *(tmp + 1);
            blue = *(tmp + 2);
            
            UInt8 brightness;
            
            switch (type) {
                case 1://モノクロ
                    // 輝度計算
                    brightness = MAX(blue,MAX(red, green)); // 0.299 * red + 0.587 * green + 0.114 * blue;
                    /*
                    if (brightness > 200) {
                        brightness = 0;
                    }else{
                        brightness = 255;
                    }
                     */

                    *(tmp + 0) = brightness;
                    *(tmp + 1) = brightness;
                    *(tmp + 2) = brightness;
                    break;
                    
                case 2://セピア
                    *(tmp + 0) = red;
                    *(tmp + 1) = green * 0.7;
                    *(tmp + 2) = blue * 0.4;
                    break;
                    
                case 3://色反転
                    *(tmp + 0) = 255 - red;
                    *(tmp + 1) = 255 - green;
                    *(tmp + 2) = 255 - blue;
                    break;
                default:
                    *(tmp + 0) = red;
                    *(tmp + 1) = green;
                    *(tmp + 2) = blue;
                    break;
            }
            
        }
    }
    
    // 効果を与えたデータ生成
    CFDataRef   effectedData;
    effectedData = CFDataCreate(NULL, buffer, CFDataGetLength(data));
    
    // 効果を与えたデータプロバイダを生成
    CGDataProviderRef   effectedDataProvider;
    effectedDataProvider = CGDataProviderCreateWithCFData(effectedData);
    
    // 画像を生成
    CGImageRef  effectedCgImage;
    UIImage*    effectedImage;
    effectedCgImage = CGImageCreate(
                                    width, height,
                                    bitsPerComponent, bitsPerPixel, bytesPerRow,
                                    colorSpace, bitmapInfo, effectedDataProvider,
                                    NULL, shouldInterpolate, intent);
    effectedImage = [[UIImage alloc] initWithCGImage:effectedCgImage];
    
    // データの解放
    CGImageRelease(effectedCgImage);
    CFRelease(effectedDataProvider);
    CFRelease(effectedData);
    CFRelease(data);
    
    return [effectedImage autorelease];
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
