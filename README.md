# Ver-ID Credentials Sample

![](ID Capture/Assets.xcassets/woman_with_licence.imageset/iStock-466158408.png)

The project contains a sample application that uses either [ID Card Camera](https://github.com/AppliedRecognition/ID-Card-Camera) or Microblink's [BlinkID SDK](https://github.com/BlinkID/blinkid-ios) to scan an ID card. The app uses Ver-ID SDK to detect a face on the captured ID card and compare it to a live selfie taken with the iOS device's camera.

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

## Adding Ver-ID to your own Xcode project

The sample app uses a [Reactive implementation](https://github.com/AppliedRecognition/Rx-Ver-ID-Apple) of the Ver-ID SDK. It has the simplest Swift interface. If you wish to call Ver-ID directly from Objective-C please use the lower-level [VerIDUI](https://github.com/AppliedRecognition/Ver-ID-UI-iOS) framework.

1. Add either **Rx-Ver-ID**:

    ```ruby
    pod 'Rx-Ver-ID', '~> 1.1'
    ```
    or **Ver-ID-UI**:
    
    ```ruby
    pod 'Ver-ID-UI', '~> 1.9'
    ```
    into your Podfile and run:
    
    ```shell
    pod install
    ```    
1. [Request an API secret](https://dev.ver-id.com/admin/register) for your app.
1. Open your workspace in Xcode and add the following entry in your project's **Info.plist** file, substituting `[your API secret]` for the API secret received in step 1.

	~~~xml
	<key>com.appliedrec.verid.apiSecret</key>
	<string>[your API secret]</string>
	~~~
1. Open your Xcode project and select the ***.xcodeproj** file in the Project navigator.
1. Select your target and click on the **General** tab.
1. Under **Deployment Info** check that **Deployment Target** is set to **11.0** or higher. If you need to target older iOS versions please contact us.
1. Ensure your app sets the **NSCameraUsageDescription** key in its **Info.plist** file.

## Adding Microblink to your Xcode project

1. Apply for an API key on the [Microblink website](https://microblink.com/products/blinkid).
1. Add **PPBlinkID** into your Podfile:

    ```ruby
    pod 'PPBlinkID', '~> 5.0'
    ```
1. Before calling the BlinkID API set your licence key:

    ```swift
    import Microblink
    
    let licenceKey = "keyObtainedInStep1"
    MBMicroblinkSDK.sharedInstance().setLicenseKey(licenceKey)
    ```
1. Detailed instructions are available on the [BlinkID Github page](https://github.com/BlinkID/blinkid-ios#getting-started-with-blinkid-sdk)