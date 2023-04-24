import 'dart:async';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_buymaster_user_app/localization/language_constrants.dart';
import 'package:flutter_buymaster_user_app/provider/auth_provider.dart';
import 'package:flutter_buymaster_user_app/provider/profile_provider.dart';
import 'package:flutter_buymaster_user_app/provider/splash_provider.dart';
import 'package:flutter_buymaster_user_app/provider/theme_provider.dart';
import 'package:flutter_buymaster_user_app/utill/color_resources.dart';
import 'package:flutter_buymaster_user_app/utill/images.dart';
import 'package:flutter_buymaster_user_app/view/basewidget/no_internet_screen.dart';
import 'package:flutter_buymaster_user_app/view/screen/auth/auth_screen.dart';
import 'package:flutter_buymaster_user_app/view/screen/dashboard/dashboard_screen.dart';
import 'package:flutter_buymaster_user_app/view/screen/maintenance/maintenance_screen.dart';
import 'package:flutter_buymaster_user_app/view/screen/onboarding/onboarding_screen.dart';
import 'package:flutter_buymaster_user_app/view/screen/product/product_details_screen.dart';
import 'package:flutter_buymaster_user_app/view/screen/splash/widget/splash_painter.dart';
import 'package:provider/provider.dart';

class SplashScreen extends StatefulWidget {
  var isProductLink = false;
  int productId;
  var slug;
  SplashScreen({@required this.isProductLink, this.productId, this.slug});
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  GlobalKey<ScaffoldMessengerState> _globalKey = GlobalKey();
  StreamSubscription<ConnectivityResult> _onConnectivityChanged;

  AnimationController _animationController;
  Animation<Offset> _animationSlide, _animationBounce;

  @override
  void initState() {
    super.initState();

    bool _firstTime = true;
    _onConnectivityChanged = Connectivity()
        .onConnectivityChanged
        .listen((ConnectivityResult result) {
      if (!_firstTime) {
        bool isNotConnected = result != ConnectivityResult.wifi &&
            result != ConnectivityResult.mobile;
        isNotConnected
            ? SizedBox()
            : ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          backgroundColor: Theme.of(context).primaryColor,
          duration: Duration(seconds: isNotConnected ? 6000 : 3),
          content: Text(
            isNotConnected
                ? getTranslated('no_connection', context)
                : getTranslated('connected', context),
            textAlign: TextAlign.center,
          ),
        ));
        if (!isNotConnected) {
          _route();
        }
      }
      _firstTime = false;
    });

    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 3000),
    );

    _animationSlide = Tween<Offset>(
      begin: Offset(-1.0, 0.0),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );

    _animationBounce = TweenSequence([
      TweenSequenceItem(
        tween: Tween<Offset>(begin: Offset(-1, 0), end: Offset(-0.25, 0))
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 40,
      ),
      TweenSequenceItem(
        tween: Tween<Offset>(begin: Offset(-0.25, 0), end: Offset(0.25, 0))
            .chain(CurveTween(curve: Curves.bounceOut)),
        weight: 20,
      ),
      TweenSequenceItem(
        tween: Tween<Offset>(begin: Offset(0.25, 0), end: Offset(0.0, 0))
            .chain(CurveTween(curve: Curves.bounceOut)),
        weight: 20,
      ),
      TweenSequenceItem(
        tween: Tween<Offset>(begin: Offset(0.0, 0), end: Offset(0.15, 0))
            .chain(CurveTween(curve: Curves.bounceOut)),
        weight: 10,
      ),
      TweenSequenceItem(
        tween: Tween<Offset>(begin: Offset(0.15, 0), end: Offset(0.0, 0))
            .chain(CurveTween(curve: Curves.bounceOut)),
        weight: 10,
      ),
    ]).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _animationController.forward();
    });

    _route();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
    _onConnectivityChanged.cancel();
  }

  void _route() {
    Provider.of<SplashProvider>(context, listen: false)
        .initConfig(context)
        .then((bool isSuccess) {
      if (isSuccess) {
        Provider.of<SplashProvider>(context, listen: false)
            .initSharedPrefData();
        Timer(Duration(seconds: 1), () {
          if (Provider.of<SplashProvider>(context, listen: false)
              .configModel
              .maintenanceMode) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (BuildContext context) => MaintenanceScreen(),
              ),
            );
          } else {
            if (Provider.of<AuthProvider>(context, listen: false)
                .isLoggedIn()) {
              Provider.of<AuthProvider>(context, listen: false)
                  .updateToken(context);
              Provider.of<ProfileProvider>(context, listen: false)
                  .getUserInfo(context);
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (BuildContext context) =>
                      widget.isProductLink != null && widget.isProductLink
                          ? ProductDetails(
                              productId: widget.productId,
                              slug: widget.slug,
                            )
                          : DashBoardScreen(),
                ),
              );
            } else {
              if (Provider.of<SplashProvider>(context, listen: false)
                  .showIntro()) {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (BuildContext context) => OnBoardingScreen(
                      indicatorColor: ColorResources.GREY,
                      selectedIndicatorColor: Theme.of(context).primaryColor,
                    ),
                  ),
                );
              } else {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (BuildContext context) => AuthScreen(),
                  ),
                );
              }
            }
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _globalKey,
      body: Provider.of<SplashProvider>(context).hasConnection
          ? Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height,
                  color: Colors.black,
                  // color: Provider.of<ThemeProvider>(context).darkTheme
                  //     ? Colors.black
                  //     : ColorResources.getPrimary(context),
                  child: CustomPaint(
                    painter: SplashPainter(),
                  ),
                ),
                AnimatedBuilder(
                  animation: _animationController,
                  builder: (BuildContext context, Widget child) {
                    return SlideTransition(
                      position: _animationSlide,
                      child: child,
                    );
                  },
                  child: Center(
                    child: Image.asset(
                      Images.splashScreenLogo,
                      height: 250.0,
                      fit: BoxFit.scaleDown,
                      width: 250.0,
                    ),
                  ),
                ),
                // Center(
                //   child: Column(
                //     mainAxisSize: MainAxisSize.min,
                //     children: [
                //       Image.asset(
                //         Images.splashScreenLogo,
                //         height: 250.0,
                //         fit: BoxFit.scaleDown,
                //         width: 250.0,
                //       ),
                //     ],
                //   ),
                // ),
              ],
            )
          : NoInternetOrDataScreen(isNoInternet: true, child: SplashScreen()),
    );
  }
}
