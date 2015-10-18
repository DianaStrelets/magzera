//
//  ORSSerialPortDemoController.m
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
#define MSG_BEGIN_MARK_CONST @"$"
#define MSG_BEGIN_MARK_SHORT @"#"
#define MSG_MOTOR_BOTH @"B"
#define MSG_MOTOR_LEFT @"L"
#define MSG_MOTOR_RIGHT @"R"
#define MSG_MOTOR_SHALL @"S"
#define MSG_DIRECTION_FORWARD @"D1"
#define MSG_DIRECTION_BACKWARD @"D0"
#define MSG_DIRECTION_LFRB @"D2"
#define MSG_DIRECTION_LBRF @"D3"
#define MSG_END_MARK @"\n"

#import "ViewController.h"
#import "ORSSerialPortManager.h"

@implementation ORSSerialPortDemoController

- (instancetype)init
{
   

	self = [super init];
	if (self)
	{
		self.serialPortManager = [ORSSerialPortManager sharedSerialPortManager];
		self.availableBaudRates = @[@300, @1200, @2400, @4800, @9600, @14400, @19200, @28800, @38400, @57600, @115200, @230400];
		
		NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
		[nc addObserver:self selector:@selector(serialPortsWereConnected:) name:ORSSerialPortsWereConnectedNotification object:nil];
		[nc addObserver:self selector:@selector(serialPortsWereDisconnected:) name:ORSSerialPortsWereDisconnectedNotification object:nil];
		
#if (MAC_OS_X_VERSION_MAX_ALLOWED > MAC_OS_X_VERSION_10_7)
		[[NSUserNotificationCenter defaultUserNotificationCenter] setDelegate:self];
#endif
	}
	return self;
}

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Actions

// Private
- (NSString *)lineEndingString
{
	NSDictionary *map = @{@0: @"\r", @1: @"\n", @2: @"\r\n"};
	NSString *result = map[@(self.lineEndingPopUpButton.selectedTag)];
	return result ?: @"\n";
}

- (IBAction)send:(id)sender
{
    [self sendPocket: self.sendTextField.stringValue];
}

- (IBAction)openOrClosePort:(id)sender
{
    self.serialPort.isOpen ? [self.serialPort close] : [self.serialPort open];
}

#pragma mark - ORSSerialPortDelegate Methods

- (void)serialPortWasOpened:(ORSSerialPort *)serialPort
{
	self.openCloseButton.title = @"Close";
    [_segmentedControlConnection setSelectedSegment:1];
}

- (void)serialPortWasClosed:(ORSSerialPort *)serialPort
{
	self.openCloseButton.title = @"Open";
    [_segmentedControlConnection setSelectedSegment:0];

}

- (void)serialPort:(ORSSerialPort *)serialPort didReceiveData:(NSData *)data
{
	NSString *string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
	if ([string length] == 0) return;
	[self.receivedDataTextView.textStorage.mutableString appendString:string];
	[self.receivedDataTextView setNeedsDisplay:YES];
}

- (void)serialPortWasRemovedFromSystem:(ORSSerialPort *)serialPort;
{
	// After a serial port is removed from the system, it is invalid and we must discard any references to it
	self.serialPort = nil;
	self.openCloseButton.title = @"Open";
}

- (void)serialPort:(ORSSerialPort *)serialPort didEncounterError:(NSError *)error
{
	NSLog(@"Serial port %@ encountered an error: %@", serialPort, error);
}

#pragma mark - NSUserNotificationCenterDelegate

#if (MAC_OS_X_VERSION_MAX_ALLOWED > MAC_OS_X_VERSION_10_7)

- (void)userNotificationCenter:(NSUserNotificationCenter *)center didDeliverNotification:(NSUserNotification *)notification
{
	dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 3.0 * NSEC_PER_SEC);
	dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
		[center removeDeliveredNotification:notification];
	});
}

- (BOOL)userNotificationCenter:(NSUserNotificationCenter *)center shouldPresentNotification:(NSUserNotification *)notification
{
	return YES;
}

#endif

#pragma mark - Notifications

- (void)serialPortsWereConnected:(NSNotification *)notification
{
	NSArray *connectedPorts = [notification userInfo][ORSConnectedSerialPortsKey];
	NSLog(@"Ports were connected: %@", connectedPorts);
	[self postUserNotificationForConnectedPorts:connectedPorts];
}

- (void)serialPortsWereDisconnected:(NSNotification *)notification
{
	NSArray *disconnectedPorts = [notification userInfo][ORSDisconnectedSerialPortsKey];
	NSLog(@"Ports were disconnected: %@", disconnectedPorts);
	[self postUserNotificationForDisconnectedPorts:disconnectedPorts];
	
}

- (void)postUserNotificationForConnectedPorts:(NSArray *)connectedPorts
{
#if (MAC_OS_X_VERSION_MAX_ALLOWED > MAC_OS_X_VERSION_10_7)
	if (!NSClassFromString(@"NSUserNotificationCenter")) return;
	
	NSUserNotificationCenter *unc = [NSUserNotificationCenter defaultUserNotificationCenter];
	for (ORSSerialPort *port in connectedPorts)
	{
		NSUserNotification *userNote = [[NSUserNotification alloc] init];
		userNote.title = NSLocalizedString(@"Serial Port Connected", @"Serial Port Connected");
		NSString *informativeTextFormat = NSLocalizedString(@"Serial Port %@ was connected to your Mac.", @"Serial port connected user notification informative text");
		userNote.informativeText = [NSString stringWithFormat:informativeTextFormat, port.name];
		userNote.soundName = nil;
		[unc deliverNotification:userNote];
	}
#endif
}

- (void)postUserNotificationForDisconnectedPorts:(NSArray *)disconnectedPorts
{
#if (MAC_OS_X_VERSION_MAX_ALLOWED > MAC_OS_X_VERSION_10_7)
	if (!NSClassFromString(@"NSUserNotificationCenter")) return;
	
	NSUserNotificationCenter *unc = [NSUserNotificationCenter defaultUserNotificationCenter];
	for (ORSSerialPort *port in disconnectedPorts)
	{
		NSUserNotification *userNote = [[NSUserNotification alloc] init];
		userNote.title = NSLocalizedString(@"Serial Port Disconnected", @"Serial Port Disconnected");
		NSString *informativeTextFormat = NSLocalizedString(@"Serial Port %@ was disconnected from your Mac.", @"Serial port disconnected user notification informative text");
		userNote.informativeText = [NSString stringWithFormat:informativeTextFormat, port.name];
		userNote.soundName = nil;
		[unc deliverNotification:userNote];
	}
#endif
}


#pragma mark - Properties

- (void)setSerialPort:(ORSSerialPort *)port
{
	if (port != _serialPort)
	{
		[_serialPort close];
		_serialPort.delegate = nil;
		
		_serialPort = port;
		
		_serialPort.delegate = self;
	}
}


- (IBAction)segmentedControlConnection:(id)sender {
    if (_segmentedControlConnection.selectedSegment==1)
    {
        //here insert work with comport
        self.serialPort.isOpen ? [self.serialPort close] : [self.serialPort open];
        
    }
    else
          self.serialPort.isOpen ? [self.serialPort close] : [self.serialPort open];

       
}
    

- (void) sendPocket:(NSString *)string
{
    
    //   string = self.sendTextField.stringValue;
    if (self.shouldAddLineEnding && ![string hasSuffix:[self lineEndingString]]) {
        string = [string stringByAppendingString:[self lineEndingString]];
    }
    NSData *dataToSend = [string dataUsingEncoding:NSUTF8StringEncoding];
    [self.serialPort sendData:dataToSend];
    
}

- (IBAction)buttonForward:(id)sender {
    NSString *string1 = [NSString stringWithFormat:@"%@%@%d%@%@", MSG_BEGIN_MARK_SHORT, MSG_MOTOR_BOTH, _sliderSpeed.intValue, MSG_DIRECTION_FORWARD, MSG_END_MARK];
    [self sendPocket: string1];
}

- (IBAction)buttonLeft:(id)sender {
    NSString *string1 = [NSString stringWithFormat:@"%@%@%d%@%@", MSG_BEGIN_MARK_SHORT, MSG_MOTOR_LEFT, 0, MSG_DIRECTION_FORWARD, MSG_END_MARK];
    [self sendPocket: string1];
}

- (IBAction)buttonRight:(id)sender {
    NSString *string1 = [NSString stringWithFormat:@"%@%@%d%@%@", MSG_BEGIN_MARK_SHORT, MSG_MOTOR_RIGHT, 0, MSG_DIRECTION_FORWARD, MSG_END_MARK];
    [self sendPocket: string1];
}

- (IBAction)buttonBack:(id)sender {
    NSString *string1 = [NSString stringWithFormat:@"%@%@%d%@%@", MSG_BEGIN_MARK_SHORT, MSG_MOTOR_BOTH, _sliderSpeed.intValue, MSG_DIRECTION_BACKWARD, MSG_END_MARK];
    [self sendPocket: string1];
}

- (IBAction)buttonShellAntiCW:(id)sender {
    NSString *string1 = [NSString stringWithFormat:@"%@%@%d%@%@", MSG_BEGIN_MARK_SHORT, MSG_MOTOR_SHALL, _sliderShellSpeed.intValue, MSG_DIRECTION_BACKWARD, MSG_END_MARK];
    [self sendPocket: string1];
}

- (IBAction)buttonShellCW:(id)sender {
    NSString *string1 = [NSString stringWithFormat:@"%@%@%d%@%@", MSG_BEGIN_MARK_SHORT, MSG_MOTOR_SHALL, _sliderShellSpeed.intValue, MSG_DIRECTION_FORWARD, MSG_END_MARK];
    [self sendPocket: string1];
}

- (IBAction)checkBoxForward:(id)sender {
   if (_checkBoxForward.state == 1 )
   {
       NSString *string1 = [NSString stringWithFormat:@"%@%@%d%@%@", MSG_BEGIN_MARK_CONST, MSG_MOTOR_BOTH, _sliderSpeed.intValue, MSG_DIRECTION_FORWARD, MSG_END_MARK];
       [self sendPocket: string1];
   }
    else
    {
        NSString *string1 = [NSString stringWithFormat:@"%@%@%d%@%@", MSG_BEGIN_MARK_CONST, MSG_MOTOR_BOTH, 0, MSG_DIRECTION_FORWARD, MSG_END_MARK];
        [self sendPocket: string1];
    }

        
}

- (IBAction)checkBoxRight:(id)sender {
    if (_checkBoxRight.state==1)
    {
        NSString *string1 = [NSString stringWithFormat:@"%@%@%d%@%@", MSG_BEGIN_MARK_CONST, MSG_MOTOR_BOTH, _sliderSpeed.intValue, MSG_DIRECTION_LFRB, MSG_END_MARK];
        [self sendPocket: string1];
    }
    else
    {
        NSString *string1 = [NSString stringWithFormat:@"%@%@%d%@%@", MSG_BEGIN_MARK_CONST, MSG_MOTOR_BOTH, 0, MSG_DIRECTION_LFRB, MSG_END_MARK];
        [self sendPocket: string1];
    }

}

- (IBAction)checkBoxBack:(id)sender {
    if (_checkBoxBack.state==1)
    {
        NSString *string1 = [NSString stringWithFormat:@"%@%@%d%@%@", MSG_BEGIN_MARK_CONST, MSG_MOTOR_BOTH, _sliderSpeed.intValue, MSG_DIRECTION_BACKWARD, MSG_END_MARK];
        [self sendPocket: string1];
    }
    else
    {
        NSString *string1 = [NSString stringWithFormat:@"%@%@%d%@%@", MSG_BEGIN_MARK_CONST, MSG_MOTOR_BOTH, 0, MSG_DIRECTION_BACKWARD, MSG_END_MARK];
        [self sendPocket: string1];
    }
}

- (IBAction)checkBoxLeft:(id)sender {
    if (_checkBoxLeft.state==1)
    {
        NSString *string1 = [NSString stringWithFormat:@"%@%@%d%@%@", MSG_BEGIN_MARK_CONST, MSG_MOTOR_BOTH, _sliderSpeed.intValue, MSG_DIRECTION_LBRF, MSG_END_MARK];
        [self sendPocket: string1];
    }
    else
    {
        NSString *string1 = [NSString stringWithFormat:@"%@%@%d%@%@", MSG_BEGIN_MARK_CONST, MSG_MOTOR_BOTH, 0, MSG_DIRECTION_LBRF, MSG_END_MARK];
        [self sendPocket: string1];
    }
}


- (IBAction)checkBoxShellCW:(id)sender {
    
    if (_checkBoxShellCW.state==1)
    {
        NSString *string1 = [NSString stringWithFormat:@"%@%@%d%@%@", MSG_BEGIN_MARK_CONST, MSG_MOTOR_SHALL, _sliderShellSpeed.intValue, MSG_DIRECTION_FORWARD, MSG_END_MARK];
        [self sendPocket: string1];
    }
    else
    {
        NSString *string1 = [NSString stringWithFormat:@"%@%@%d%@%@", MSG_BEGIN_MARK_CONST, MSG_MOTOR_SHALL, 0, MSG_DIRECTION_FORWARD, MSG_END_MARK];
        [self sendPocket: string1];
    }
    
    
}

- (IBAction)checkBoxShellAntiCw:(id)sender {
    
    
    if (_checkBoxShellAntiCW.state==1)
    {
        NSString *string1 = [NSString stringWithFormat:@"%@%@%d%@%@", MSG_BEGIN_MARK_CONST, MSG_MOTOR_SHALL, _sliderShellSpeed.intValue, MSG_DIRECTION_BACKWARD, MSG_END_MARK];
        [self sendPocket: string1];
    }
    else
    {
        NSString *string1 = [NSString stringWithFormat:@"%@%@%d%@%@", MSG_BEGIN_MARK_CONST, MSG_MOTOR_SHALL, 0, MSG_DIRECTION_BACKWARD, MSG_END_MARK];
        [self sendPocket: string1];
    }
    
    
}

- (IBAction)sliderShellSpeed:(id)sender {
    
    [ _textFieldShellSpeed setIntValue:[ _sliderShellSpeed intValue]];
    
    if (_checkBoxShellCW.state==1)
    {
        NSString *string1 = [NSString stringWithFormat:@"%@%@%d%@%@", MSG_BEGIN_MARK_CONST, MSG_MOTOR_SHALL, _sliderShellSpeed.intValue, MSG_DIRECTION_FORWARD, MSG_END_MARK];
        [self sendPocket: string1];
    }

    if (_checkBoxShellAntiCW.state==1)
    {
        NSString *string1 = [NSString stringWithFormat:@"%@%@%d%@%@", MSG_BEGIN_MARK_CONST, MSG_MOTOR_SHALL, _sliderShellSpeed.intValue, MSG_DIRECTION_BACKWARD, MSG_END_MARK];
        [self sendPocket: string1];
    }


}

- (IBAction)sliderSpeed:(id)sender {
    [ _textFieldSpeed setIntValue:[ _sliderSpeed intValue]];
    
    if (_checkBoxForward.state == 1 )
    {
        NSString *string1 = [NSString stringWithFormat:@"%@%@%d%@%@", MSG_BEGIN_MARK_CONST, MSG_MOTOR_BOTH, _sliderSpeed.intValue, MSG_DIRECTION_FORWARD, MSG_END_MARK];
        [self sendPocket: string1];
    }
    if (_checkBoxRight.state==1)
    {
        NSString *string1 = [NSString stringWithFormat:@"%@%@%d%@%@", MSG_BEGIN_MARK_CONST, MSG_MOTOR_BOTH, _sliderSpeed.intValue, MSG_DIRECTION_LFRB, MSG_END_MARK];
        [self sendPocket: string1];
    }
    if (_checkBoxBack.state==1)
    {
        NSString *string1 = [NSString stringWithFormat:@"%@%@%d%@%@", MSG_BEGIN_MARK_CONST, MSG_MOTOR_BOTH, _sliderSpeed.intValue, MSG_DIRECTION_BACKWARD, MSG_END_MARK];
        [self sendPocket: string1];
    }
    if (_checkBoxLeft.state==1)
    {
        NSString *string1 = [NSString stringWithFormat:@"%@%@%d%@%@", MSG_BEGIN_MARK_CONST, MSG_MOTOR_BOTH, _sliderSpeed.intValue, MSG_DIRECTION_LBRF, MSG_END_MARK];
        [self sendPocket: string1];
    }

    
    
}

- (IBAction)enterButtonShellSpeed:(id)sender {
    [ _sliderShellSpeed setIntValue:[ _textFieldShellSpeed intValue ]];
    
    if (_checkBoxShellCW.state==1)
    {
        NSString *string1 = [NSString stringWithFormat:@"%@%@%d%@%@", MSG_BEGIN_MARK_CONST, MSG_MOTOR_SHALL, _sliderShellSpeed.intValue, MSG_DIRECTION_FORWARD, MSG_END_MARK];
        [self sendPocket: string1];
    }
    
    if (_checkBoxShellAntiCW.state==1)
    {
        NSString *string1 = [NSString stringWithFormat:@"%@%@%d%@%@", MSG_BEGIN_MARK_CONST, MSG_MOTOR_SHALL, _sliderShellSpeed.intValue, MSG_DIRECTION_BACKWARD, MSG_END_MARK];
        [self sendPocket: string1];
    }
    
}

- (IBAction)enterButtonSpeed:(id)sender {
    [ _sliderSpeed setIntValue:[ _textFieldSpeed intValue ]];
    
    if (_checkBoxForward.state == 1 )
    {
        NSString *string1 = [NSString stringWithFormat:@"%@%@%d%@%@", MSG_BEGIN_MARK_CONST, MSG_MOTOR_BOTH, _sliderSpeed.intValue, MSG_DIRECTION_FORWARD, MSG_END_MARK];
        [self sendPocket: string1];
    }
    if (_checkBoxRight.state==1)
    {
        NSString *string1 = [NSString stringWithFormat:@"%@%@%d%@%@", MSG_BEGIN_MARK_CONST, MSG_MOTOR_BOTH, _sliderSpeed.intValue, MSG_DIRECTION_LFRB, MSG_END_MARK];
        [self sendPocket: string1];
    }
    if (_checkBoxBack.state==1)
    {
        NSString *string1 = [NSString stringWithFormat:@"%@%@%d%@%@", MSG_BEGIN_MARK_CONST, MSG_MOTOR_BOTH, _sliderSpeed.intValue, MSG_DIRECTION_BACKWARD, MSG_END_MARK];
        [self sendPocket: string1];
    }
    if (_checkBoxLeft.state==1)
    {
        NSString *string1 = [NSString stringWithFormat:@"%@%@%d%@%@", MSG_BEGIN_MARK_CONST, MSG_MOTOR_BOTH, _sliderSpeed.intValue, MSG_DIRECTION_LBRF, MSG_END_MARK];
        [self sendPocket: string1];
    }


}

- (IBAction)buttonStop:(id)sender {
    NSString *string1 = [NSString stringWithFormat:@"%@%@%d%@%@", MSG_BEGIN_MARK_CONST, MSG_MOTOR_BOTH, 0, MSG_DIRECTION_FORWARD, MSG_END_MARK];
    [self sendPocket: string1];
    
    if (_checkBoxBack.state==1) [_checkBoxBack setState: 0];
    if (_checkBoxForward.state==1) [_checkBoxForward setState: 0];
    if (_checkBoxLeft.state==1) [_checkBoxLeft setState: 0];
    if (_checkBoxRight.state==1) [_checkBoxRight setState: 0];
}

- (IBAction)buttonStopShell:(id)sender {
    NSString *string1 = [NSString stringWithFormat:@"%@%@%d%@%@", MSG_BEGIN_MARK_CONST, MSG_MOTOR_SHALL, 0, MSG_DIRECTION_BACKWARD, MSG_END_MARK];
    [self sendPocket: string1];
    
     if (_checkBoxShellCW.state==1) [_checkBoxShellCW setState: 0];
     if (_checkBoxShellAntiCW.state==1) [_checkBoxShellAntiCW setState: 0];
    
}


@end
