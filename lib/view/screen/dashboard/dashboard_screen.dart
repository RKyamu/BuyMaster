import 'package:flutter/material.dart';
import 'package:flutter_sixvalley_ecommerce/helper/network_info.dart';
import 'package:flutter_sixvalley_ecommerce/provider/splash_provider.dart';
import 'package:flutter_sixvalley_ecommerce/view/screen/chat/inbox_screen.dart';
import 'package:flutter_sixvalley_ecommerce/localization/language_constrants.dart';
import 'package:flutter_sixvalley_ecommerce/utill/images.dart';
import 'package:flutter_sixvalley_ecommerce/view/screen/home/home_screens.dart';
import 'package:flutter_sixvalley_ecommerce/view/screen/more/more_screen.dart';
import 'package:flutter_sixvalley_ecommerce/view/screen/notification/notification_screen.dart';
import 'package:flutter_sixvalley_ecommerce/view/screen/order/order_screen.dart';
import 'package:provider/provider.dart';

class DashBoardScreen extends StatefulWidget {
  @override
  _DashBoardScreenState createState() => _DashBoardScreenState();
}

class _DashBoardScreenState extends State<DashBoardScreen> {
  PageController _pageController = PageController();
  int _pageIndex = 0;
  List<Widget> _screens;
  GlobalKey<ScaffoldMessengerState> _scaffoldKey = GlobalKey();
  int isNotify = 0;

  bool singleVendor = false;
  @override
  void initState() {
    super.initState();
    singleVendor = Provider.of<SplashProvider>(context, listen: false)
            .configModel
            .businessMode ==
        "single";
    isNotify = Provider.of<SplashProvider>(context, listen: false)
        .configModel
        .seenNotification;

    _screens = [
      HomePage(),
      singleVendor
          ? OrderScreen(isBacButtonExist: false)
          : InboxScreen(isBackButtonExist: false),
      singleVendor
          ? NotificationScreen(isBacButtonExist: false)
          : OrderScreen(isBacButtonExist: false),
      singleVendor ? MoreScreen() : NotificationScreen(isBacButtonExist: false),
      singleVendor ? SizedBox() : MoreScreen(),
    ];

    NetworkInfo.checkConnectivity(context);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (_pageIndex != 0) {
          _setPage(0);
          return false;
        } else {
          return true;
        }
      },
      child: Scaffold(
        key: _scaffoldKey,
        bottomNavigationBar: BottomNavigationBar(
          selectedItemColor: Theme.of(context).primaryColor,
          unselectedItemColor: Theme.of(context).textTheme.bodyText1.color,
          showUnselectedLabels: true,
          currentIndex: _pageIndex,
          type: BottomNavigationBarType.fixed,
          items: _getBottomWidget(singleVendor),
          onTap: (int index) {
            if (index == 3) {
              print('notifications - page');
              Provider.of<SplashProvider>(context, listen: false)
                  .setSeenNotification();
            }
            _setPage(index);
          },
        ),
        body: PageView.builder(
          controller: _pageController,
          itemCount: _screens.length,
          physics: NeverScrollableScrollPhysics(),
          itemBuilder: (context, index) {
            return _screens[index];
          },
        ),
      ),
    );
  }

  BottomNavigationBarItem _barItem(
      String icon, String label, int index, int showBadge) {
    return BottomNavigationBarItem(
      icon: Stack(
        children: [
          Image.asset(
            icon,
            color: index == _pageIndex
                ? Theme.of(context).primaryColor
                : Theme.of(context).textTheme.bodyText1.color.withOpacity(0.5),
            height: 25,
            width: 25,
          ),
          if (showBadge == 0) // conditionally show badge
            Consumer<SplashProvider>(
              builder: (context, splashProvider, _) {
                if (splashProvider.seen_notification == 0) {
                  return Positioned(
                    top: 0,
                    right: 0,
                    child: Container(
                      padding: EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.red,
                      ),
                      child: Icon(
                        Icons.brightness_1,
                        size: 10,
                        color: Colors.white,
                      ),
                    ),
                  );
                } else {
                  return SizedBox.shrink();
                }
              },
            ),
        ],
      ),
      label: label,
    );

    // return BottomNavigationBarItem(
    //   icon: Image.asset(
    //     icon,
    //     color: index == _pageIndex
    //         ? Theme.of(context).primaryColor
    //         : Theme.of(context).textTheme.bodyText1.color.withOpacity(0.5),
    //     height: 25,
    //     width: 25,
    //   ),
    //   label: label,
    // );
  }

  void _setPage(int pageIndex) {
    setState(() {
      _pageController.jumpToPage(pageIndex);
      _pageIndex = pageIndex;
    });
  }

  List<BottomNavigationBarItem> _getBottomWidget(bool isSingleVendor) {
    List<BottomNavigationBarItem> _list = [];

    if (!isSingleVendor) {
      _list.add(
          _barItem(Images.home_image, getTranslated('home', context), 0, 1));
      _list.add(_barItem(
          Images.message_image, getTranslated('inbox', context), 1, 1));
      _list.add(_barItem(
          Images.shopping_image, getTranslated('orders', context), 2, 1));
      _list.add(_barItem(Images.notification,
          getTranslated('notification', context), 3, this.isNotify));
      _list.add(
          _barItem(Images.more_image, getTranslated('more', context), 4, 1));
    } else {
      _list.add(
          _barItem(Images.home_image, getTranslated('home', context), 0, 1));
      _list.add(_barItem(
          Images.shopping_image, getTranslated('orders', context), 1, 1));
      _list.add(_barItem(Images.notification,
          getTranslated('notification', context), 2, this.isNotify));
      _list.add(
          _barItem(Images.more_image, getTranslated('more', context), 3, 1));
    }
    return _list;
  }
}
