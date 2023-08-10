import 'dart:io';

import 'package:admob_flutter/admob_flutter.dart';
import 'package:flutter/material.dart';

class InterstitialAdManager {
  static AdmobInterstitial? _interstitialAd;
  static bool _isAdLoaded = false;
  static bool _isAdShowing = false;

  static void initialize() {
    _interstitialAd = AdmobInterstitial(
      adUnitId: AdHelper.interstitialAdUnitId,
    );

    _interstitialAd?.load();
  }

  static void showInterstitialAd() {
    if (_interstitialAd != null) {
      _interstitialAd!.show();
      _interstitialAd = AdmobInterstitial(
        adUnitId: AdHelper.interstitialAdUnitId,
      );
      _interstitialAd?.load();
    } else {
      print('Interstitial ad is not yet loaded');
    }
  }

  static void dispose() {
    _interstitialAd?.dispose();
  }
}


class AdHelper {
  static String get bannerAdUnitId {
    if (Platform.isAndroid) {
      //working banner id ca-app-pub-7181343877669077/1377492143   ca-app-pub-7181343877669077/1377492143
      // return 'ca-app-pub-3940256099942544/6300978111';
      return 'ca-app-pub-7181343877669077/5678624787';
    } else if (Platform.isIOS) {
      // return 'ca-app-pub-7181343877669077/5410197832';
      return 'ca-app-pub-7181343877669077/2375844027';
      // return 'ca-app-pub-3940256099942544/2934735716';
    } else {
      throw new UnsupportedError('Unsupported platform');
    }
  }

  static String get interstitialAdUnitId {
    if (Platform.isAndroid) {
      // return "ca-app-pub-7181343877669077/9813069201";
      return "ca-app-pub-7181343877669077/5759349989";
    } else if (Platform.isIOS) {
      // return "ca-app-pub-7181343877669077/5345359476";
      return "ca-app-pub-7181343877669077/9871190663";
      //return "ca-app-pub-3940256099942544/4411468910";
    } else {
      throw new UnsupportedError("Unsupported platform");
    }
  }

  static String get rewardedAdUnitId {
    if (Platform.isAndroid) {
      return "ca-app-pub-3940256099942544/5224354917";
    } else if (Platform.isIOS) {
      return "ca-app-pub-3940256099942544/1712485313";
    } else {
      throw new UnsupportedError("Unsupported platform");
    }
  }
}

class AdBannerWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Implement your ad banner widget here
    // For example:
    return AdmobBanner(
      adUnitId: AdHelper.bannerAdUnitId,
      adSize: AdmobBannerSize.ADAPTIVE_BANNER(
        width: MediaQuery.of(context).size.width.toInt(),
      ),
    );
  }
}
