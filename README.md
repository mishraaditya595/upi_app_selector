# Get UPI

Flutter plugin for Getting installed upi apps in the device,

- Getting Started
- Installation
- Requirements
- Usage

## Getting Started:

This flutter plugin is a wrapper around native Android and iOS SDKs.

## Installation:

Add this to dependencies in your pubspec.yaml file.

     get_upi: ^0.0.4

## Requirements

- Add the following in the manifest

<queries>
      <intent>
         <action android:name="android.intent.action.VIEW" />
         <category android:name="android.intent.category.DEFAULT" />
         <category android:name="android.intent.category.BROWSABLE" />
         <data
             android:host="mandate"
             android:scheme="upi" />
      </intent>
   </queries>

- If you're using this package for Upi mandate add the host as `mandate` else `pay`

## Usage:

Import package,

    import ‘package: get_upi/get_upi.dart’

- To get the all installed upi apps for android :

        List<UpiObject> upiAppsList = [];

            Future<void> getUpi() async {
                if (Platform.isAndroid) {
                var value = await GetUPI.apps();
                upiAppsListAndroid = value.data;
            } else if (Platform.isIOS) {
                var valueIos = await GetUPI.iosApps();
                upiAppsList.clear();
                upiAppsList = valueIos;
            }

    setState(() {});
  }


- To get the all installed upi apps in native intent :

    GetUPI.openNativeIntent(url: 'pass the upi string');

- To open the upi app from the upiAppsList:

    GetUPI.launch(
        package: upiApp.packageName,
        url: 'pass the upi string',
    );
