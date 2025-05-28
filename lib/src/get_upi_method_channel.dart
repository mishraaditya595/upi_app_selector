import 'dart:convert';
import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_upi/src/image_file.dart';
import 'package:get_upi/src/upi_meta.dart';

class GetUPI {
  static const _methodChannel = MethodChannel('GET_UPI_IPPO');

  static Future<UpiMeta> apps() async {
    try {
      final version =
          await _methodChannel.invokeMethod<String>('get_available_upi');
      log(version.toString());

      if (version != null) {
        final decode = jsonDecode(version);

        return UpiMeta.fromJson(decode);
      }
    } catch (e) {
      log("GET AVAILABLE UPI APPS EXCEPTION : ${e.toString()}");
    }
    return const UpiMeta(data: []);
  }

  static Future<List> iosApps() async {
    try {
      final version =
          await _methodChannel.invokeMethod<String>('get_available_upi');
      log(version.toString());

      if (version != null) {
        final decode = jsonDecode(version);

        return decode;
      }
    } catch (e) {
      log("GET AVAILABLE UPI APPS EXCEPTION : ${e.toString()}");
    }
    return [];
  }

  static Future<String> launch({
    required String package,
    required String url,
  }) async {
    String? result;
    try {
      result = await _methodChannel.invokeMethod<String>(
        'open_upi_app',
        {
          'package': package,
          'url': url,
        },
      );
      log(result.toString());
    } catch (e) {
      log("OPEN UPI APPS EXCEPTION : ${e.toString()}");
    }
    return result ?? '';
  }

  static Future<String?> openNativeIntent({required String url}) async {
    String? result;
    try {
      result = await _methodChannel.invokeMethod<String>(
        'native_intent',
        {
          'url': url,
        },
      );
      log(result.toString());
    } catch (e) {
      log("OPEN UPI APPS EXCEPTION : ${e.toString()}");
    }
    return result ?? '';
  }

  static Future<String?> openIosIntent({
    required String url,
    required String package,
  }) async {
    String? result;
    try {
      result = await _methodChannel.invokeMethod<String>(
        'ios_intent',
        {
          'url': url,
          'package': package,
        },
      );
      log(result.toString());
    } catch (e) {
      log("OPEN UPI APPS EXCEPTION : ${e.toString()}");
    }
    return result ?? '';
  }

  Future<void> showUpiSheet(
    BuildContext context, {
    required String mandateUrl,
    required List upiAppsList,
  }) {
    return showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return DraggableScrollableSheet(
          expand: false,
          builder: (context, controller) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.fromLTRB(16, 0, 16, 10),
                  child: Text(
                    'Select an option',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Expanded(
                  child: CupertinoScrollbar(
                    controller: controller,
                    child: GridView.builder(
                      controller: controller,
                      itemCount: upiAppsList.length,
                      shrinkWrap: true,
                      physics: const ClampingScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 4,
                        crossAxisSpacing: 5,
                        mainAxisSpacing: 5,
                      ),
                      itemBuilder: (context, index) {
                        return InkWell(
                          onTap: () {
                            GetUPI.openIosIntent(
                              package: upiAppsList[index]['package'],
                              url: mandateUrl,
                            );
                          },
                          child: GridTile(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                CircleAvatar(
                                  backgroundColor: const Color(0xffDCE0E6),
                                  radius: 20,
                                  child: Image.asset(
                                    getAppLogo(
                                      appName: upiAppsList[index]['package']
                                          .toString()
                                          .toLowerCase(),
                                    ),
                                    package: "get_upi",
                                    width: 40,
                                    height: 40,
                                    fit: BoxFit.fill,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  upiAppsList[index]["name"],
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(fontSize: 14),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

String getAppLogo({required String appName}) {
  debugPrint(appName);
  try {
    if (appName == "gpay") {
      return ImageFile.gpay;
    } else if (appName == "phonepe") {
      return ImageFile.phonepay;
    } else if (appName == "paytm") {
      return ImageFile.paytm;
    } else if (appName == "payzapp") {
      return ImageFile.payzap;
    } else if (appName == "bhim") {
      return ImageFile.bhim;
    } else if (appName == "cred") {
      return ImageFile.cred;
    } else if (appName == "amazon") {
      return ImageFile.amazon;
    } else {
      return ImageFile.cred;
    }
  } catch (e) {
    log(e.toString());
    return "";
  }
}
