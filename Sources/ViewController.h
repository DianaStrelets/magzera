//
//  ORSSerialPortDemoController.h
//  ORSSerialPortDemo
//
//  Created by Andrew R. Madsen on 6/27/12.
//	Copyright (c) 2012-2014 Andrew R. Madsen (andrew@openreelsoftware.com)
//	
//	Permission is hereby granted, free of charge, to any person obtaining a
//	copy of this software and associated documentation files (the
//	"Software"), to deal in the Software without restriction, including
//	without limitation the rights to use, copy, modify, merge, publish,
//	distribute, sublicense, and/or sell copies of the Software, and to
//	permit persons to whom the Software is furnished to do so, subject to
//	the following conditions:
//	
//	The above copyright notice and this permission notice shall be included
//	in all copies or substantial portions of the Software.
//	
//	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
//	OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
//	MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
//	IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
//	CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
//	TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
//	SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

#import <Cocoa/Cocoa.h>
#import "ORSSerialPort.h"

@class ORSSerialPortManager;

#if (MAC_OS_X_VERSION_MAX_ALLOWED <= MAC_OS_X_VERSION_10_7)
@protocol NSUserNotificationCenterDelegate <NSObject>
@end
#endif

@interface ORSSerialPortDemoController : NSObject <ORSSerialPortDelegate, NSUserNotificationCenterDelegate>

- (IBAction)send:(id)sender;
- (IBAction)openOrClosePort:(id)sender;

@property (unsafe_unretained) IBOutlet NSTextField *sendTextField;
@property (unsafe_unretained) IBOutlet NSTextView *receivedDataTextView;
@property (unsafe_unretained) IBOutlet NSButton *openCloseButton;
@property (unsafe_unretained) IBOutlet NSPopUpButton *lineEndingPopUpButton;

@property (nonatomic, strong) ORSSerialPortManager *serialPortManager;
@property (nonatomic, strong) ORSSerialPort *serialPort;
@property (nonatomic, strong) NSArray *availableBaudRates;
@property (nonatomic) BOOL shouldAddLineEnding;

//robocontrol

@property (unsafe_unretained) IBOutlet NSSegmentedControl *segmentedControlConnection;
@property (unsafe_unretained) IBOutlet NSTextField *labelConnectionState;
@property (unsafe_unretained) IBOutlet NSButton *checkBoxForward;
@property (unsafe_unretained) IBOutlet NSButton *checkBoxLeft;
@property (unsafe_unretained) IBOutlet NSButton *checkBoxRight;
@property (unsafe_unretained) IBOutlet NSButton *checkBoxBack;
@property (unsafe_unretained) IBOutlet NSButton *checkBoxShellAntiCW;
@property (unsafe_unretained) IBOutlet NSButton *checkBoxShellCW;
@property (unsafe_unretained) IBOutlet NSSlider *sliderSpeed;
@property (unsafe_unretained) IBOutlet NSSlider *sliderShellSpeed;
@property (unsafe_unretained) IBOutlet NSTextField *textFieldSpeed;
@property (unsafe_unretained) IBOutlet NSTextField *textFieldShellSpeed;

- (IBAction)segmentedControlConnection:(id)sender;
- (IBAction)buttonForward:(id)sender;
- (IBAction)buttonLeft:(id)sender;
- (IBAction)buttonRight:(id)sender;
- (IBAction)buttonBack:(id)sender;
- (IBAction)buttonShellAntiCW:(id)sender;
- (IBAction)buttonShellCW:(id)sender;
- (IBAction)checkBoxForward:(id)sender;
- (IBAction)checkBoxRight:(id)sender;
- (IBAction)checkBoxLeft:(id)sender;
- (IBAction)checkBoxBack:(id)sender;
- (IBAction)checkBoxShellCW:(id)sender;
- (IBAction)checkBoxShellAntiCw:(id)sender;
- (IBAction)sliderShellSpeed:(id)sender;
- (IBAction)sliderSpeed:(id)sender;
- (IBAction)enterButtonShellSpeed:(id)sender;
- (IBAction)enterButtonSpeed:(id)sender;
- (IBAction)buttonStop:(id)sender;
- (IBAction)buttonStopShell:(id)sender;













- (void) sendPocket:(NSString*)string;





@end
