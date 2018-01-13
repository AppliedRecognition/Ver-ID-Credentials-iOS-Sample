# Ver-ID Credentials SDK

## Introduction

Ver-ID gives your application the ability to capture and parse government-issued ID cards.

## Adding Ver-ID Credentials SDK to Your iOS Project

1. [Request an API secret](https://dev.ver-id.com/admin/register) for your app.
1. In Xcode open your project's **Info.plist** file and add the following entry,  substituting `[your API secret]` for the API secret received in step 1.

	~~~xml
	<key>com.appliedrec.verid.apiSecret</key>
	<string>[your API secret]</string>
	~~~
1. Download the latest [**VerIDCredentials framework**](https://github.com/AppliedRecognition/Ver-ID-Credentials-iOS-Sample/tree/master/Frameworks/VerIDCredentials.framework) and [**VerID framework**](https://github.com/AppliedRecognition/Ver-ID-Credentials-iOS-Sample/tree/master/Frameworks/VerID.framework).
2. Open your Xcode project and select the ***.xcodeproj** file in the Project navigator.
3. Select your target and click on the **General** tab.
4. Under **Deployment Info** check that **Deployment Target** is set to **11.0** or higher. If you need to target older iOS versions please contact us.
5. Next click the **+** button in the **Embedded Binaries** section and in the dialog click the **Add Other ...** button.
6. Navigate to the SDK folder and select **VerIDCredentials.framework**. After clicking OK make sure you tick the box **Copy items if needed**.
7. Repeat steps 5 and 6 with **VerID.framework**.
7. Ver-ID Credentials currently does not support bitcode. Switch to the **Build Settings** tab, scroll down to **Build Options** and set **Enable Bitcode** to **No**.
8. Ensure your app sets the **NSCameraUsageDescription** key in its **Info.plist** file.
9. Import Ver-ID Credentials:
	- In Swift add `import VerIDCredentials` statement in your code that uses Ver-ID ID Capture.
	- In Objective-C add `#import <VerIDCredentials/VerIDCredentials-Swift.h>`

## Using Ver-ID Credentials SDK

1. Create an instance of `IDCaptureSession` in your application. 
2. Implement the `IDCaptureSessionDelegate` protocol in your class.
3. Assign your class as delegate of the `IDCaptureSession` instance.
4. Start the capture session.
5. Receive the result of the session in your delegate class.

### Swift example

MyViewController.swift
	
~~~swift
import UIKit
import VerIDCredentials
	
class MyViewController: UIViewController, IDCaptureSessionDelegate {
	
	func startCapture() {
        // Settings with a blank ISO ID-1 card. The app will ask the user to select a region.
        let settings = IDCaptureSessionSettings(idBundle: IDBundle(cards: [Card(format: .id1)]))
        let session = IDCaptureSession(settings: settings)
        session.delegate = self
        session.start()
	}
	
	// MARK: - Ver-ID Credentials Session Delegate
	
	func idCaptureSession(_ session: IDCaptureSession, didFinishWithResult result: IDCaptureSessionResult) {
		if result.status == .finished, let detectedIdBundle = result.idBundle {
			// The session finished with a captured ID card
			if let face = detectedIdBundle.faces.first?.value {
				// Detected a face on the card
			}
		}
	}
}
~~~

### Objective C example

MyViewController.h

~~~objc
#import <UIKit/UIKit.h>
#import <VerIDCredentials/VerIDCredentials-Swift.h>
@interface MyViewController : UIViewController<IDCaptureSessionDelegate>
	
@end
~~~	
MyViewController.m
	
~~~objc
#import "MyViewController.h"
	
@interface MyViewController ()

@end

@implementation MyViewController

- (void) startCapture {
    // Settings with a blank ISO ID-1 card. The app will ask the user to select a region.
    IDCaptureSessionSettings *settings = [[IDCaptureSessionSettings alloc] initWithIdBundle: [[IDBundle alloc] initWithCards: @[[[Card alloc] initWithFormat: ISOCardFormatId1]]]]
    IDCaptureSession *session = [[IDCaptureSession alloc] initWithSettings: settings];
    [session setDelegate:self];
    [session start];
}

// MARK: - ID Capture Delegate

- (void) idCaptureSession:(IDCaptureSession *)session didFinishWithResult:(IDCaptureSessionResult *)result {
    if (result.status == IDCaptureSessionResultStatusFinished && result.idBundle != NULL) {
	    // The session finished with a captured ID card
    }
}

@end
~~~

## Documentation
For full API reference visit the project's [Github page](https://appliedrecognition.github.io/Ver-ID-Credentials-iOS-Sample/).
