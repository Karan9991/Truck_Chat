import 'dart:io';

//import 'package:admob_flutter/admob_flutter.dart';
import 'package:flutter/material.dart';

// import 'package:google_mobile_ads/google_mobile_ads.dart';
// import 'dart:io' show Platform;

// class AppOpenAdManager {
//   String adUnitId = Platform.isAndroid
//       ? 'ca-app-pub-7181343877669077/8346499195'
//       : 'ca-app-pub-7181343877669077/7556177613';

//   AppOpenAd? _appOpenAd;
//   bool _isShowingAd = false;



//   /// Whether an ad is available to be shown.
//   bool get isAdAvailable {
//     return _appOpenAd != null;
//   }

//     /// Load an AppOpenAd.
//   void loadAd() {
//     AppOpenAd.load(
//       adUnitId: adUnitId,
//       orientation: AppOpenAd.orientationPortrait,
//       request: AdRequest(),
//       adLoadCallback: AppOpenAdLoadCallback(
//         onAdLoaded: (ad) {
//           _appOpenAd = ad;
//         },
//         onAdFailedToLoad: (error) {
//           print('AppOpenAd failed to load: $error');
//           // Handle the error.
//         },
//       ),
//     );
//   }


//      void showAdIfAvailable() {
//     if (!isAdAvailable) {
//       print('Tried to show ad before available.');
//       loadAd();
//       return;
//     }
//     if (_isShowingAd) {
//       print('Tried to show ad while already showing an ad.');
//       return;
//     }
//     // Set the fullScreenContentCallback and show the ad.
//     _appOpenAd!.fullScreenContentCallback = FullScreenContentCallback(
//       onAdShowedFullScreenContent: (ad) {
//         _isShowingAd = true;
//         print('$ad onAdShowedFullScreenContent');
//       },
//       onAdFailedToShowFullScreenContent: (ad, error) {
//         print('$ad onAdFailedToShowFullScreenContent: $error');
//         _isShowingAd = false;
//         ad.dispose();
//         _appOpenAd = null;
//       },
//       onAdDismissedFullScreenContent: (ad) {
//         print('$ad onAdDismissedFullScreenContent');
//         _isShowingAd = false;
//         ad.dispose();
//         _appOpenAd = null;
//         loadAd();
//       },
//     );
//   }
// }


// /// Listens for app foreground events and shows app open ads.
// class AppLifecycleReactor {
//   final AppOpenAdManager appOpenAdManager;

//   AppLifecycleReactor({required this.appOpenAdManager});

//   void listenToAppStateChanges() {
//     AppStateEventNotifier.startListening();
//     AppStateEventNotifier.appStateStream
//         .forEach((state) => _onAppStateChanged(state));
//   }

//   void _onAppStateChanged(AppState appState) {
//     // Try to show an app open ad if the app is being resumed and
//     // we're not already showing an app open ad.
//     if (appState == AppState.foreground) {
//       appOpenAdManager.showAdIfAvailable();
//     }
//   }
// }

// class InterstitialAdManager {
  
//   static AdmobInterstitial? _interstitialAd;
//   static bool _isAdLoaded = false;
//   static bool _isAdShowing = false;


//   static Future<void> initialize() async {
//     _interstitialAd = AdmobInterstitial(
//       adUnitId: AdHelper.interstitialAdUnitId,
//     );

//     _interstitialAd?.load();
//   }

//   static Future<void> showInterstitialAd() async {
//     if (_interstitialAd != null) {
//       _interstitialAd!.show();
//       _interstitialAd = AdmobInterstitial(
//         adUnitId: AdHelper.interstitialAdUnitId,
//       );
//       _interstitialAd?.load();
//     } else {
//       print('Interstitial ad is not yet loaded');
//     }
//   }

//   static void dispose() {
//     _interstitialAd?.dispose();
//   }
// }

// class AdHelper {
//   static String get bannerAdUnitId {
//     if (Platform.isAndroid) {
//       //working banner id ca-app-pub-7181343877669077/1377492143   ca-app-pub-7181343877669077/1377492143
//       // return 'ca-app-pub-3940256099942544/6300978111';
//       return 'ca-app-pub-7181343877669077/5678624787';
//     } else if (Platform.isIOS) {
//       // return 'ca-app-pub-7181343877669077/5410197832';
//       return 'ca-app-pub-7181343877669077/2375844027';
//       // return 'ca-app-pub-3940256099942544/2934735716';
//     } else {
//       throw new UnsupportedError('Unsupported platform');
//     }
//   }

//   static String get interstitialAdUnitId {
//     if (Platform.isAndroid) {
//       // return "ca-app-pub-7181343877669077/9813069201";
//       return "ca-app-pub-7181343877669077/5759349989";
//     } else if (Platform.isIOS) {
//       // return "ca-app-pub-7181343877669077/5345359476";
//       return "ca-app-pub-7181343877669077/9871190663";
//       //return "ca-app-pub-3940256099942544/4411468910";
//     } else {
//       throw new UnsupportedError("Unsupported platform");
//     }
//   }

//   static String get rewardedAdUnitId {
//     if (Platform.isAndroid) {
//       return "ca-app-pub-3940256099942544/5224354917";
//     } else if (Platform.isIOS) {
//       return "ca-app-pub-3940256099942544/1712485313";
//     } else {
//       throw new UnsupportedError("Unsupported platform");
//     }
//   }
// }

// class AdBannerWidget extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     // Implement your ad banner widget here
//     // For example:
//     return AdmobBanner(
//       adUnitId: AdHelper.bannerAdUnitId,
//       adSize: AdmobBannerSize.ADAPTIVE_BANNER(
//         width: MediaQuery.of(context).size.width.toInt(),
//       ),
//     );
//   }
// }


// class AdBannerWidget extends StatefulWidget {
//   @override
//   _AdBannerWidgetState createState() => _AdBannerWidgetState();
// }

// class _AdBannerWidgetState extends State<AdBannerWidget> {
//   late AdmobBanner _admobBanner;

//   @override
//   void initState() {
//     super.initState();

//     _admobBanner = AdmobBanner(
//       adUnitId: AdHelper.bannerAdUnitId,
//       adSize: AdmobBannerSize.ADAPTIVE_BANNER(
//         width: MediaQuery.of(context).size.width.toInt(),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return _admobBanner;
//   }
// }



//new
// import 'package:google_mobile_ads/google_mobile_ads.dart';
// import 'dart:io' show Platform;

// class AppOpenAdManager {
  
//   String adUnitId = Platform.isAndroid
//     ? 'ca-app-pub-7181343877669077/8346499195'
//     : 'ca-app-pub-7181343877669077/7556177613';
  
//   AppOpenAd? _appOpenAd;
//   bool _isShowingAd = false;

//   /// Load an AppOpenAd.
//    void loadAd() {
//     AppOpenAd.load(
//       adUnitId: adUnitId,
//       orientation: AppOpenAd.orientationPortrait,
//       request: AdRequest(),
//       adLoadCallback: AppOpenAdLoadCallback(
//         onAdLoaded: (ad) {
//           _appOpenAd = ad;
//         },
//         onAdFailedToLoad: (error) {
//           print('AppOpenAd failed to load: $error');
//           // Handle the error.
//         },
//       ),
//     );
//   }

//   /// Whether an ad is available to be shown.
//   bool get isAdAvailable {
//     return _appOpenAd != null;
//   }

//      void showAdIfAvailable() {
//     if (!isAdAvailable) {
//       print('Tried to show ad before available.');
//       loadAd();
//       return;
//     }
//     if (_isShowingAd) {
//       print('Tried to show ad while already showing an ad.');
//       return;
//     }
//     // Set the fullScreenContentCallback and show the ad.
//     _appOpenAd!.fullScreenContentCallback = FullScreenContentCallback(
//       onAdShowedFullScreenContent: (ad) {
//         _isShowingAd = true;
//         print('$ad onAdShowedFullScreenContent');
//       },
//       onAdFailedToShowFullScreenContent: (ad, error) {
//         print('$ad onAdFailedToShowFullScreenContent: $error');
//         _isShowingAd = false;
//         ad.dispose();
//         _appOpenAd = null;
//       },
//       onAdDismissedFullScreenContent: (ad) {
//         print('$ad onAdDismissedFullScreenContent');
//         _isShowingAd = false;
//         ad.dispose();
//         _appOpenAd = null;
//         loadAd();
//       },
//     );
//   }
// }

// /// Listens for app foreground events and shows app open ads.
// class AppLifecycleReactor {
//   final AppOpenAdManager appOpenAdManager;

//   AppLifecycleReactor({required this.appOpenAdManager});

//   void listenToAppStateChanges() {
//     AppStateEventNotifier.startListening();
//     AppStateEventNotifier.appStateStream
//         .forEach((state) => _onAppStateChanged(state));
//   }

//   void _onAppStateChanged(AppState appState) {
//     // Try to show an app open ad if the app is being resumed and
//     // we're not already showing an app open ad.
//     if (appState == AppState.foreground) {
//       appOpenAdManager.showAdIfAvailable();
//     }
//   }
// }


//
 import 'package:google_mobile_ads/google_mobile_ads.dart';

class AppOpenAdManager {
  AppOpenAd? _appOpenAd;
  bool _isShowingAd = false;
  static bool isLoaded=false;

  /// Load an AppOpenAd.
  void loadAd() {
    AppOpenAd.load(
      adUnitId: "ca-app-pub-3940256099942544/3419835294",
      orientation: AppOpenAd.orientationPortrait,
      request: const AdRequest(),
      adLoadCallback: AppOpenAdLoadCallback(
        onAdLoaded: (ad) {
          print("Ad Loadede.................................");
          _appOpenAd = ad;
          isLoaded=true;
        },
        onAdFailedToLoad: (error) {
          // Handle the error.
        },
      ),
    );
  }

  // Whether an ad is available to be shown.
  bool get isAdAvailable {
    return _appOpenAd != null;
  }

  void showAdIfAvailable() {
    print("Called=====================================================================");
    if (_appOpenAd == null) {
      print('Tried to show ad before available.');
      loadAd();
      return;
    }
    if (_isShowingAd) {
      print('Tried to show ad while already showing an ad.');
      return;
    }
    // Set the fullScreenContentCallback and show the ad.
    _appOpenAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (ad) {
        _isShowingAd = true;
        print('$ad onAdShowedFullScreenContent');
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        print('$ad onAdFailedToShowFullScreenContent: $error');
        _isShowingAd = false;
        ad.dispose();
        _appOpenAd = null;
      },
      onAdDismissedFullScreenContent: (ad) {
        print('$ad onAdDismissedFullScreenContent');
        _isShowingAd = false;
        ad.dispose();
        _appOpenAd = null;
        loadAd();
      },
    );
    _appOpenAd!.show();
  }
}



class CustomBannerAd extends StatefulWidget {
  const CustomBannerAd({Key? key}) : super(key: key);

  @override
  State<CustomBannerAd> createState() => _CustomBannerAdState();
}

class _CustomBannerAdState extends State<CustomBannerAd> {
 late BannerAd bannerAd;
  bool isBannerAdLoaded = false;

  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
    bannerAd = BannerAd(
      size: AdSize.fullBanner,
      adUnitId: "ca-app-pub-7181343877669077/5678624787",
      listener: BannerAdListener(onAdFailedToLoad: (ad, error) {
        print("Ad Failed to Load");
        ad.dispose();
      }, onAdLoaded: (ad) {
        print("Ad Loaded");
        setState(() {
          isBannerAdLoaded = true;
        });
      }),
      request: const AdRequest(),
    );
    bannerAd.load();
  }

  @override
  Widget build(BuildContext context) {
    return isBannerAdLoaded
        ? SizedBox(
             width: double.infinity,
            height: 60,
            child: AdWidget(
              ad: bannerAd,
            ),
          )
        : SizedBox();
  }
// @override
//   Widget build(BuildContext context) {
//    return isBannerAdLoaded
//     ? SafeArea(
//         child: Container(
//           height: 60,
//           width: double.infinity,
//           child: Align(
//             alignment: Alignment.bottomCenter,
//             child: AdWidget(
//               ad: bannerAd,
//               key: UniqueKey(),
//             ),
//           ),
//         ),
//       )
//     : SizedBox();

//   }

}
 