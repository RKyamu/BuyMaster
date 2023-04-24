import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/services.dart';
import '/view/screen/product/product_details_screen.dart';
import 'firebase_options.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'provider/facebook_login_provider.dart';
import 'provider/featured_deal_provider.dart';
import 'provider/google_sign_in_provider.dart';
import 'provider/home_category_product_provider.dart';
import 'provider/location_provider.dart';
import 'provider/top_seller_provider.dart';
import 'provider/wallet_transaction_provider.dart';
import 'view/screen/notification/notification_screen.dart';
import 'view/screen/order/order_details_screen.dart';
import 'provider/auth_provider.dart';
import 'provider/brand_provider.dart';
import 'provider/cart_provider.dart';
import 'provider/category_provider.dart';
import 'provider/chat_provider.dart';
import 'provider/coupon_provider.dart';
import 'provider/localization_provider.dart';
import 'provider/notification_provider.dart';
import 'provider/onboarding_provider.dart';
import 'provider/order_provider.dart';
import 'provider/profile_provider.dart';
import 'provider/search_provider.dart';
import 'provider/seller_provider.dart';
import 'provider/splash_provider.dart';
import 'provider/support_ticket_provider.dart';
import 'provider/theme_provider.dart';
import 'provider/wishlist_provider.dart';
import 'theme/dark_theme.dart';
import 'theme/light_theme.dart';
import 'utill/app_constants.dart';
import 'view/screen/splash/splash_screen.dart';
import 'package:provider/provider.dart';

import 'di_container.dart' as di;
import 'helper/custom_delegate.dart';
import 'localization/app_localization.dart';
import 'notification/my_notification.dart';
import 'provider/product_details_provider.dart';
import 'provider/banner_provider.dart';
import 'provider/flash_deal_provider.dart';
import 'provider/product_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:uni_links/uni_links.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> main() async {
  HttpOverrides.global = new MyHttpOverrides();
  WidgetsFlutterBinding.ensureInitialized();
  await initUniLinks();
  if (kIsWeb) {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: "AIzaSyA4Ive3p0NmH8D63KrrPKUrcgV-FNWzR2c",
        authDomain: "buy-master-multi-vendor.firebaseapp.com",
        databaseURL:
            "https://buy-master-multi-vendor-default-rtdb.firebaseio.com",
        projectId: "buy-master-multi-vendor",
        storageBucket: "buy-master-multi-vendor.appspot.com",
        messagingSenderId: "890542118180",
        appId: "1:890542118180:web:eab2652a3f5f8c812ccfb1",
        measurementId: "G-K68394082S",
      ),
    );
  }

  //Remove this method to stop OneSignal Debugging
  OneSignal.shared.setLogLevel(OSLogLevel.verbose, OSLogLevel.none);

  OneSignal.shared.setAppId("c5fabebb-0e25-49e3-9438-4f1ffcfb42c5");

  // The promptForPushNotificationsWithUserResponse function will show the iOS or Android push notification prompt. We recommend removing the following code and instead using an In-App Message to prompt for notification permission
  OneSignal.shared.promptUserForPushNotificationPermission().then((accepted) {
    print("Accepted permission: $accepted");
  });

  OneSignal.shared
      .setNotificationOpenedHandler((OSNotificationOpenedResult result) {
    print("notification - clicked inside build ${result}");
    SplashProvider provider = Provider.of<SplashProvider>(
        MyApp.navigatorKey.currentContext,
        listen: false);
    provider.setSeenNotification();
    Navigator.push(
      MyApp.navigatorKey.currentContext,
      MaterialPageRoute(
        builder: (_) => NotificationScreen(isBacButtonExist: false),
      ),
    );
  });

  OneSignal.shared.setPermissionObserver((OSPermissionStateChanges changes) {
    // Will be called whenever the permission changes
    // (ie. user taps Allow on the permission prompt in iOS)
  });

  OneSignal.shared
      .setSubscriptionObserver((OSSubscriptionStateChanges changes) {
    // Will be called whenever the subscription changes
    // (ie. user gets registered with OneSignal and gets a user ID)
  });

  OneSignal.shared.setEmailSubscriptionObserver(
      (OSEmailSubscriptionStateChanges emailChanges) {
    // Will be called whenever then user's email subscription changes
    // (ie. OneSignal.setEmail(email) is called and the user gets registered
  });

  await Firebase.initializeApp(
      // options: DefaultFirebaseOptions.currentPlatform,
      );
  if (!kIsWeb && !FlutterDownloader.initialized) {
    await FlutterDownloader.initialize(debug: true, ignoreSsl: true);
  }
  await di.init();
  final NotificationAppLaunchDetails notificationAppLaunchDetails =
      await flutterLocalNotificationsPlugin.getNotificationAppLaunchDetails();
  int _orderID;

  if (notificationAppLaunchDetails?.didNotificationLaunchApp ?? false) {
    _orderID = (notificationAppLaunchDetails.payload != null &&
            notificationAppLaunchDetails.payload.isNotEmpty)
        ? int.parse(notificationAppLaunchDetails.payload)
        : null;
  }
  final RemoteMessage remoteMessage =
      await FirebaseMessaging.instance.getInitialMessage();
  if (remoteMessage != null) {
    _orderID = remoteMessage.notification.titleLocKey != null
        ? int.parse(remoteMessage.notification.titleLocKey)
        : null;
  }
  print('========-notification-----$_orderID----===========');

  await MyNotification.initialize(flutterLocalNotificationsPlugin);
  FirebaseMessaging.onBackgroundMessage(myBackgroundMessageHandler);
  customRunApp(_orderID);
}

void customRunApp(orderId) {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => di.sl<CategoryProvider>()),
        ChangeNotifierProvider(
            create: (context) => di.sl<HomeCategoryProductProvider>()),
        ChangeNotifierProvider(create: (context) => di.sl<TopSellerProvider>()),
        ChangeNotifierProvider(create: (context) => di.sl<FlashDealProvider>()),
        ChangeNotifierProvider(
            create: (context) => di.sl<FeaturedDealProvider>()),
        ChangeNotifierProvider(create: (context) => di.sl<BrandProvider>()),
        ChangeNotifierProvider(create: (context) => di.sl<ProductProvider>()),
        ChangeNotifierProvider(create: (context) => di.sl<BannerProvider>()),
        ChangeNotifierProvider(
            create: (context) => di.sl<ProductDetailsProvider>()),
        ChangeNotifierProvider(
            create: (context) => di.sl<OnBoardingProvider>()),
        ChangeNotifierProvider(create: (context) => di.sl<AuthProvider>()),
        ChangeNotifierProvider(create: (context) => di.sl<SearchProvider>()),
        ChangeNotifierProvider(create: (context) => di.sl<SellerProvider>()),
        ChangeNotifierProvider(create: (context) => di.sl<CouponProvider>()),
        ChangeNotifierProvider(create: (context) => di.sl<ChatProvider>()),
        ChangeNotifierProvider(create: (context) => di.sl<OrderProvider>()),
        ChangeNotifierProvider(
            create: (context) => di.sl<NotificationProvider>()),
        ChangeNotifierProvider(create: (context) => di.sl<ProfileProvider>()),
        ChangeNotifierProvider(create: (context) => di.sl<WishListProvider>()),
        ChangeNotifierProvider(create: (context) => di.sl<SplashProvider>()),
        ChangeNotifierProvider(create: (context) => di.sl<CartProvider>()),
        ChangeNotifierProvider(
            create: (context) => di.sl<SupportTicketProvider>()),
        ChangeNotifierProvider(
            create: (context) => di.sl<LocalizationProvider>()),
        ChangeNotifierProvider(create: (context) => di.sl<ThemeProvider>()),
        ChangeNotifierProvider(
            create: (context) => di.sl<GoogleSignInProvider>()),
        ChangeNotifierProvider(
            create: (context) => di.sl<FacebookLoginProvider>()),
        ChangeNotifierProvider(create: (context) => di.sl<LocationProvider>()),
        ChangeNotifierProvider(
            create: (context) => di.sl<WalletTransactionProvider>()),
      ],
      child: MyApp(
        orderId: orderId,
      ),
    ),
  );
}

void initUniLinks() async {
  // Get the initial link when the app is launched
  String initialLink = await getInitialLink();

  // Handle the initial link
  handleDeepLink(initialLink);

  // Listen for incoming links
  getLinksStream().listen((String link) {
    // Handle the incoming link
    handleDeepLink(link);
  });
}

void handleDeepLink(String link) {
  print("link - $link");
  if (link != null) {
    var url = Uri.parse(link);
    int productId = int.parse(url.pathSegments.last);
    var slug = url.pathSegments[1];
    print("link - productId - $productId");
    print("link - slug - $slug");
    MyApp.productId = productId;
    MyApp.slug = slug;
    MyApp.isFromProductLink = true;
    main();
  }
}

class MyApp extends StatelessWidget {
  final int orderId;
  static bool isFromProductLink = false;
  static int productId = null;
  static var slug = null;
  MyApp({
    @required this.orderId,
  });

  static final navigatorKey = new GlobalKey<NavigatorState>();

  void initOneSignal(BuildContext context) {
    OneSignal.shared.setNotificationWillShowInForegroundHandler(
      (OSNotificationReceivedEvent event) {
        // Will be called whenever a notification is received in foreground
        // Display Notification, pass null param for not displaying the notification
        print("notification - received");
        Provider.of<SplashProvider>(context, listen: false)
            .setNewNotification();
        event.complete(event.notification);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    initOneSignal(context);
    List<Locale> _locals = [];
    AppConstants.languages.forEach((language) {
      _locals.add(Locale(language.languageCode, language.countryCode));
    });

    return MaterialApp(
      title: AppConstants.APP_NAME,
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      theme: light,
      // theme: Provider.of<ThemeProvider>(context).darkTheme ? dark : light,
      locale: Locale(
        AppConstants.languages[0].languageCode,
        AppConstants.languages[0].countryCode,
      ),
      localizationsDelegates: [
        AppLocalization.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        FallbackLocalizationDelegate()
      ],
      supportedLocales: _locals,
      home: orderId == null
          ? SplashScreen(
              isProductLink: isFromProductLink,
              productId: productId,
              slug: slug,
            )
          : OrderDetailsScreen(
              orderId: orderId,
              orderType: 'default_type',
              isNotification: true,
            ),
    );
  }
}

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}
