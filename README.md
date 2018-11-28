# Ver-ID Credentials SDK

## Introduction

Ver-ID gives your application the ability to capture and parse government-issued ID cards.

## Adding Ver-ID Credentials to Your iOS Project

### Using CocoaPods

1. Add **Ver-ID-Credentials** in your **Podfile**:
	
	~~~ruby
	pod 'Ver-ID-Credentials', '~> 2.1'
	~~~
1. Install the dependencies using `pod install`.\*
1. Open the generated **xcworkspace** in Xcode.

\*If you receive an error `[!] Unable to find a specification for Ver-ID-Credentials (~> 2.1)` try running `pod repo update` before trying `pod install` again.

### Manual Installation

1. [Download zip file](https://ver-id.s3.amazonaws.com/ios/ver-id-credentials/2.1.6/VerIDCredentials.zip) containing the Ver- ID Credentials framework.
1. Unzip the downloaded archive and place **VerIDCredentials.framework** in your Xcode project's directory.
1. [Download zip file](https://ver-id.s3.amazonaws.com/ios/ver-id/3.4.4/VerID.zip) containing the Ver-ID framework.
1. Unzip the downloaded archive and place **VerID.framework** in your Xcode project's directory.
1. Open your project in Xcode.
1. Select File/Add Files to "*your project name*"... and add the downloaded **VerIDCredentials.framework** and **VerID.framework**.
1. Select your app target, click on the **General** tab and scroll down to **Embedded binaries**.
1. Click the **+** button on the bottom of the pane and add **VerIDCredentials.framework** and **VerID.framework**.

## Project Setup
1. In Xcode open your project's **Info.plist** file and add the following entry,  substituting `[your API secret]` for the API secret received in step 1.

	~~~xml
	<key>com.appliedrec.verid.apiSecret</key>
	<string>[your API secret]</string>
	~~~
1. [Download Ver-ID resources](https://ver-id.s3.amazonaws.com/resources/models/v1/VerIDModels.zip) and add them to your app:

	1. In your project's folder create a folder called **VerIDModels**.
	2. Download ... and unzip it in to the **VerIDModels** folder created in the previous step.
	3. In Xcode select File/Add Files to "*your project name*"...
	4. Select the downloaded **VerIDModels** folder and under **Options** select **Create folder references**.
1. As an alternative to the previous step you can place the downloaded zip archive on a remote server. Ver-ID will download its resources on first run of your app making the app download smaller but the first run of the app slower. Add the following entry into your app's **Info.plist** replacing the URL with the zip file address on your server:
		
	~~~xml
	<key>com.appliedrec.verid.resourcesURL</key>
	<string>https://ver-id.s3.amazonaws.com/resources/models/v1/VerIDModels.zip</string>
	~~~
1. Select your app target and click on the **Build Settings** tab. Under **Build Options** set **Enable Bitcode** to **No**.
2. Open your Xcode project and select the ***.xcodeproj** file in the Project navigator.
3. Select your target and click on the **General** tab.
4. Under **Deployment Info** check that **Deployment Target** is set to **11.0** or higher. If you need to target older iOS versions please contact us.
7. Ver-ID Credentials currently does not support bitcode. Switch to the **Build Settings** tab, scroll down to **Build Options** and set **Enable Bitcode** to **No**.
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
import VerIDCredentials
	
class MyViewController: UIViewController, IDCaptureSessionDelegate {
	
	func startCapture() {
        // Settings with a blank ISO ID-1 card. The app will ask the user to select a region.
        let settings = IDCaptureSessionSettings(document: IDDocument(pages: [Page(format: .id1)]))
        let session = IDCaptureSession(settings: settings)
        session.delegate = self
        session.start()
	}
	
	// MARK: - Ver-ID Credentials Session Delegate
	
	func idCaptureSession(_ session: IDCaptureSession, didFinishWithResult result: IDCaptureSessionResult) {
		if result.status == .finished, let detectedIdDocument = result.document {
			// The session finished with a captured ID card
			if let face = detectedIdDocument.faces.first?.value {
				// Detected a face on the card
			}
		}
	}
}
~~~

<!--## Documentation
For full API reference visit the project's [Github page](https://appliedrecognition.github.io/Ver-ID-Credentials-iOS-Sample/).-->
