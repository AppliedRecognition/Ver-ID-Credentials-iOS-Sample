![Cocoapods](https://img.shields.io/cocoapods/v/Ver-ID-Credentials-Beta.svg)

# Ver-ID Credentials SDK

## Introduction

Ver-ID gives your application the ability to capture and parse government-issued ID cards.

## Adding Ver-ID Credentials to Your iOS Project

### Using CocoaPods

1. Add **Ver-ID-Credentials** in your **Podfile**:
	
	~~~ruby
	pod 'Ver-ID-Credentials-Beta', '~> 3.0'
	~~~
1. Install the dependencies using `pod install`.\*
1. Open the generated **xcworkspace** in Xcode.

\*If you receive an error `[!] Unable to find a specification for Ver-ID-Credentials-Beta (~> 3.0)` try running `pod repo update` before trying `pod install` again.

### Manual Installation

1. [Download zip file](https://ver-id.s3.amazonaws.com/ios/ver-id-credentials-beta/3.0.0/VerIDCredentials.zip) containing the Ver- ID Credentials framework.
1. Unzip the downloaded archive and place **VerIDCredentials.framework** in your Xcode project's directory.
1. [Download zip file](https://ver-id.s3.amazonaws.com/ios/veridcore/1.0.6/VerIDCore.zip) containing the Ver-ID Core framework.
1. Unzip the downloaded archive and place **VerIDCore.framework** in your Xcode project's directory.
1. Open your project in Xcode.
1. Select File/Add Files to "*your project name*"... and add the downloaded **VerIDCredentials.framework** and **VerIDCore.framework**.
1. Select your app target, click on the **General** tab and scroll down to **Embedded binaries**.
1. Click the **+** button on the bottom of the pane and add **VerIDCredentials.framework** and **VerIDCore.framework**.

## Project Setup
1. In Xcode open your project's **Info.plist** file and add the following entry,  substituting `[your API secret]` for the API secret received in step 1.

	~~~xml
	<key>com.appliedrec.verid.apiSecret</key>
	<string>[your API secret]</string>
	~~~
1. Clone [Ver-ID models](https://github.com/AppliedRecognition/Ver-ID-Models/tree/matrix-16) and add them to your app:

	1. Install [Git LFS](https://git-lfs.github.com) on your system.
	2. Clone the Ver-ID models repository into a **VerIDModels** folder in your Xcode project:
	
	~~~bash
	git clone -b matrix-16 https://github.com/AppliedRecognition/Ver-ID-Models.git VerIDModels
	~~~
	3. In Xcode select File/Add Files to "*your project name*"...
	4. Select the downloaded **VerIDModels** folder and under **Options** select **Create folder references**.
2. Open your Xcode project and select the ***.xcodeproj** file in the Project navigator.
3. Select your target and click on the **General** tab.
4. Under **Deployment Info** check that **Deployment Target** is set to **11.0** or higher. If you need to target older iOS versions please contact us.
8. Ensure your app sets the **NSCameraUsageDescription** key in its **Info.plist** file.
1. You can now import the Ver-ID Credentials and Ver-ID frameworks in your Swift files using `import VerIDCredentials` and `import VerID`.

## Using Ver-ID Credentials SDK

1. Create an instance of `IDCaptureSession` in your application. 
2. Implement the `IDCaptureSessionDelegate` protocol in your class.
3. Assign your class as delegate of the `IDCaptureSession` instance.
4. Start the capture session.
5. Receive the result of the session in your delegate class.

### Example

MyViewController.swift
	
~~~swift
import UIKit
import VerIDCore
import VerIDCredentials
	
class MyViewController: UIViewController, IDCaptureSessionDelegate {

	var verid: VerID? // Instance of Ver-ID must be created before starting an ID capture session
	
	func startCapture() {
		guard let verid = self.verid else {
			// The ID capture session requires an instance of VerID.
			// Create the instance using VerIDFactory before starting
			// an ID capture session.
			return
		}
		// Create a description of the ID document you wish to capture
		// This example will scan an ISO ID1 photo card (credit card size) 
		// with a photo on the front and PDF417 barcode on the back
		let document = IDDocument(pages: [ISOID1PhotoCard(), ISOID1CardWithPDF417Barcode()])
		let settings = IDCaptureSessionSettings(environment: verid, document: document)
		let session = IDCaptureSession(settings: settings)
		// Set the session delegate to this class
		session.delegate = self
		// Start the session
		session.start()
	}
	
	// MARK: - Ver-ID Credentials Session Delegate
	
	func idCaptureSession(_ session: IDCaptureSession, didCaptureIDDocument document: IDDocument) {
		// ID Capture succeeded
	}

	func idCaptureSession(_ session: IDCaptureSession, didFailWithError error: Error) {
		// ID Capture failed
	}

	func didCancelIDCaptureSession(_ session: IDCaptureSession) {
		// ID capture was cancelled
	}
}
~~~

<!--## Documentation
For full API reference visit the project's [Github page](https://appliedrecognition.github.io/Ver-ID-Credentials-Apple).-->
