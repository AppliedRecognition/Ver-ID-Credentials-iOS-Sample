# Ver-ID ID Capture Sample

![](ID%20Capture/Assets.xcassets/woman_with_licence.imageset/iStock-466158408.png)

The project contains a sample application that uses Microblink's [BlinkID SDK](https://github.com/BlinkID/blinkid-ios) to scan an ID card. The app uses [Ver-ID SDK](https://github.com/AppliedRecognition/Ver-ID-UI-iOS) to detect a face on the captured ID card and compare it to a live selfie taken with the iOS device's camera.

## Project setup
1. Download and install [CocoaPods](https://cocoapods.org/).
2. Clone this project:

    ```shell
    git clone https://github.com/AppliedRecognition/Ver-ID-Credentials-iOS-Sample.git
    ```
3. In Terminal navigate to the project's root folder (the one that contains **Podfile**) and install the project's dependencies:

    ```shell
    pod install
    ```
4. Open the generated **ID Capture.xcworkspace** in Xcode.
5. Open the **Signing & Capabilities** tab and change **Team** to your account
6. Click on the **Pods** project, click on **Ver-ID-VerIDUIResources**
7. Navigate to **Signing & Capabilities** and change **Team** to your account

## Adding Ver-ID to your own Xcode project

1. Add **Ver-ID**:
    
    ```ruby
    pod 'Ver-ID', '~> 2.10'
    ```
    into your Podfile and run:
    
    ```shell
    pod install
    ```    
2. [Register your app](https://dev.ver-id.com/licensing/). You will need your app's bundle identifier.
3. Registering your app will generate an evaluation licence for your app. The licence is valid for 30 days. If you need a production licence please [contact Applied Recognition](mailto:sales@appliedrec.com).
4. When you finish the registration you'll receive a file called **Ver-ID identity.p12** and a password. Copy the password to a secure location and add the **Ver-ID identity.p12** file in your app:    
    - Open your project in Xcode.
    - From the top menu select **File/Add files to “[your project name]”...** or press **⌥⌘A** and browse to select the downloaded **Ver-ID identity.p12** file.
    - Reveal the options by clicking the **Options** button on the bottom left of the dialog.
    - Tick **Copy items if needed** under **Destination**.
    - Under **Added to targets** select your app target.
5. Ver-ID will need the password you received at registration.    
    - You can either specify the password when you create an instance of `VerIDFactory`:

        ~~~swift
        let veridFactory = VerIDFactory(veridPassword: "your password goes here")
        ~~~
    - Or you can add the password in your app's **Info.plist**:

        ~~~xml
        <key>com.appliedrec.verid.password</key>
        <string>your password goes here</string>
        ~~~
6. Open your Xcode project and select the ***.xcodeproj** file in the Project navigator.
7. Select your target and click on the **General** tab.
8. Under **Deployment Info** check that **Deployment Target** is set to **15.0** or higher. If you need to target older iOS versions please contact us.
9. Ensure your app sets the **NSCameraUsageDescription** key in its **Info.plist** file.

## Adding Microblink to your Xcode project

1. Apply for an API key on the [Microblink website](https://microblink.com/products/blinkid).
2. Open your workspace in **Xcode** and click on your app project
3. Navigate to the **Package Dependencies** tab and under Packages click the + button
4. Enter **https://github.com/BlinkID/blinkid-ios** in the search bar of the dialog that just opened
5. Select **blinkid-ios** in the menu and under **Dependency Rule** select **Up to Next Major Version** and enter 6.1.2
6. Select your project in the **Add to Project** dropdown menu
7. Press the **Add Package** button
8. Before calling the BlinkID API set your licence key:

    ```swift
    import BlinkID
    
    let licenceKey = "keyObtainedInStep1"
    MBMicroblinkSDK.shared().setLicenseKey(key) { error in
        // TODO: Handle error
    }
    ```
9. Detailed instructions are available on the [BlinkID Github page](https://github.com/BlinkID/blinkid-ios#getting-started-with-blinkid-sdk)

## Example 1 – Capture ID card

~~~swift
import UIKit
import BlinkID

class MyViewController: UIViewController, MBBlinkIdOverlayViewControllerDelegate {

    private var blinkIdRecognizer: MBBlinkIdMultiSideRecognizer?

    func captureIdCard() {
        let recognizer = MBBlinkIdMultiSideRecognizer()
        recognizer.returnFullDocumentImage = true
        self.blinkIdRecognizer = recognizer
        let settings = MBBlinkIdOverlaySettings()
        let recognizerCollection = MBRecognizerCollection(recognizers: [recognizer])
        let blinkIdOverlayViewController = MBBlinkIdOverlayViewController(
            settings: settings, 
            recognizerCollection: recognizerCollection, 
            delegate: self)
        guard let recognizerRunnerViewController = MBViewControllerFactory
            .recognizerRunnerViewController(withOverlayViewController: blinkIdOverlayViewController) else {
            return
        }
    }
    
    // MARK: - MBBlinkIdOverlayViewControllerDelegate
    
    func blinkIdOverlayViewControllerDidFinishScanning(_ blinkIdOverlayViewController: MBBlinkIdOverlayViewController, state: MBRecognizerResultState) {
        if state == .valid {
            blinkIdOverlayViewController.recognizerRunnerViewController?.pauseScanning()
            DispatchQueue.main.async {
                blinkIdOverlayViewController.dismiss(animated: true, completion: nil)
                guard let result = self.blinkIdRecognizer?.result else {
                    return
                }
                guard let documentImage: UIImage = result.fullDocumentBackImage?.image else {
                    return
                }
                // You can pass documentImage to Ver-ID face detection
            }
        }
    }
    
    func blinkIdOverlayViewControllerDidTapClose(_ blinkIdOverlayViewController: MBBlinkIdOverlayViewController) {
        blinkIdOverlayViewController.dismiss(animated: true)
    }
}
~~~

## Example 2 – Capture live face

~~~swift
import UIKit
import VerIDCore
import VerIDUI

class MyViewController: UIViewController, VerIDSessionDelegate {

    var verID: VerID?
    
    lazy var faceDetectionRecognitionWithAuthenticityCheck: VerIDFaceDetectionRecognitionFactory? = {
        let detrecFactory = VerIDFaceDetectionRecognitionFactory(apiSecret: nil)
        guard let classifierPath = Bundle.main.path(forResource: "license01-20210820ay-xiypjic%2200-q08", ofType: "nv") else {
            return nil
        }
        let classifier = Classifier(name: "licence", filename: classifierPath)
        detrecFactory.additionalFaceClassifiers = [classifier]
        return detrecFactory
    }()

    func createVerID() {
        if verID != nil {
            // Return if Ver-ID is already loaded
            return
        }
        let veridFactory = VerIDFactory()
        
        // To enable authenticity check on supported Canadian ID documents include
        // bundle the ID Capture/license01-20210820ay-xiypjic%2200-q08.nv file
        // with your app
        if let detRecFactory = self.faceDetectionRecognitionWithAuthenticityCheck {
            veridFactory.faceDetectionFactory = detRecFactory
            veridFactory.faceRecognitionFactory = detRecFactory
        }
        // Skip the above 4 lines to disable authenticity check
        
        veridFactory.delegate = self
        veridFactory.createVerID { result in
            switch result {
            case .success(let verID):
                self.verID = verID
                // TODO: This is a good place to enable a button that launches a face capture session
            case .failure(let error):
                // TODO: Handle error
            }
        }
    }
    
    func startFaceCapture() {
        guard let verID = self.verID else {
            // TODO: Handle this
            return
        }
        let settings = LivenessDetectionSessionSettings()
        let session = VerIDSession(environment: verID, settings: settings)
        session.delegate = self
        session.start()
    }
    
    // MARK: - VerIDSessionDelegate
    
    func didFinishSession(_ session: VerIDSession, withResult result: VerIDSessionResult) {
        if let error = result.error {
            // TODO: Handle session failure
            return
        }
        guard let face = result.faces(withBearing: .straight).first else {
            return
        }
        // You can use face for comparison
    }
}
~~~

## Example 3 - Compare face on ID card with live face

Building on example 1 and 2, you can use the results of the ID capture and liveness detection sessions and compare their faces.

~~~swift
class FaceUtilities {

    let verID: VerID
    
    // This must be the same name you used in the Classifier constructor 
    // (see faceDetectionRecognitionWithAuthenticityCheck in example 2 above)
    private let authenticityClassifierName = "licence"
    
    init(verID: VerID) {
        self.verID = verID
    }

    // Compare live face with a face detected in an ID card image
    func compareFaceToIDCard(face: RecognizableFace, idCardImage: UIImage) throws -> Float {
        // Get an instance of face detection utilities, this will always be available unless
        // you supplied your own implementation of face recognition to VerIDFactory
        guard let faceDetectionUtilities = verID.utilities?.faceDetection else {
            throw FaceUtilitiesError.faceDetectionUtilitiesUnavailable
        }
        // Detect a face on the ID card
        guard let idCardFace: RecognizableFace = try faceDetectionUtilities.detectRecognizableFacesInImage(idCardImage, 1).first else {
            throw FaceUtilitiesError.faceNotFound
        }
        // Compare faces
        return try verID.faceRecognition.compareSubjectFaces([face], toFaces: [idCardFace])
    }
    
    // Check document authenticity (works with select Canadian documents)
    func checkDocumentAuthenticity(idCardImage: UIImage) throws -> Float {
        guard let faceDetection = verID.faceDetection as? VerIDFaceDetection else {
            throw FaceUtilitiesError.unsupportedFaceDetectionImplementation
        }
        guard let face: Face = try faceDetection.detectFacesInImage(idCardImage, limit: 1, options: 0).first else {
            throw FaceUtilitiesError.faceNotFound
        }
        return try faceDetection..extractAttributeFromFace(face, image: idCardImage, using: authenticityClassifierName)
    }
}

enum FaceUtilitiesError: Error, Int {
    case faceDetectionUtilitiesUnavailable
    case faceNotFound
    case unsupportedFaceDetectionImplementation
}
~~~