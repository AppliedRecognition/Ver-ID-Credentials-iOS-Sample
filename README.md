# Ver-ID Credentials Sample

![](ID%20Capture/Assets.xcassets/woman_with_licence.imageset/iStock-466158408.png)

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
5. Open [Google Firebase console](https://console.firebase.google.com) add an iOS app with bundle identifier `com.appliedrec.ID-Capture` to your project and download the generated **GoogleServices-Info.plist** file.
6. Add the **GoogleServices-Info.plist** file to the ID Capture project.
7. Alternatively, if you don't wish to log app crashes in your Firebase account:
	- Go to the Xcode project's **Build Phases** and remove the **Run Firebase Crashlytics** phase.
	- Open **AppDelegate.swift** and remove the lines `import Firebase` and `FirebaseApp.configure()`.
	- Delete **GoogleServices-Info.plist** in the Project navigator.

## Adding Ver-ID to your own Xcode project

1. Add **Ver-ID**:
    
    ```ruby
    pod 'Ver-ID', '~> 2.3'
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
8. Under **Deployment Info** check that **Deployment Target** is set to **11.0** or higher. If you need to target older iOS versions please contact us.
9. Ensure your app sets the **NSCameraUsageDescription** key in its **Info.plist** file.

## Adding Microblink to your Xcode project

1. Apply for an API key on the [Microblink website](https://microblink.com/products/blinkid).
2. Add **PPBlinkID** into your Podfile:

    ```ruby
    pod 'PPBlinkID', '~> 5.14'
    ```
3. Before calling the BlinkID API set your licence key:

    ```swift
    import Microblink
    
    let licenceKey = "keyObtainedInStep1"
    MBMicroblinkSDK.sharedInstance().setLicenseKey(licenceKey)
    ```
4. Detailed instructions are available on the [BlinkID Github page](https://github.com/BlinkID/blinkid-ios#getting-started-with-blinkid-sdk)
