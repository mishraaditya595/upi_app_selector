import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:get_upi/get_upi.dart';

void main() {
  runApp(
    MaterialApp(
      theme: ThemeData(useMaterial3: true),
      home: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  List upiAppsList = [];
  List<UpiObject> upiAppsListAndroid = [];

  MethodChannel methodChannel = const MethodChannel("get_upi");
  @override
  void initState() {
    super.initState();
  }

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Plugin example app'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            if (Platform.isAndroid) {
              GetUPI.openNativeIntent(
                url: 'your mandate url',
              );
            } else if (Platform.isIOS) {
              getUpi().then((_) {
                GetUPI().showUpiSheet(
                  context,
                  upiAppsList: upiAppsList,
                  mandateUrl: "your mandate url",
                );
              });
            }
          },
          child: const Text("Native Intent"),
        ),
      ),
    );
  }
}
