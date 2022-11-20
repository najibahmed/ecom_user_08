import 'package:ecom_user_08/auth/authservice.dart';
import 'package:ecom_user_08/pages/cart_page.dart';
import 'package:ecom_user_08/pages/order_successful_page.dart';
import 'package:ecom_user_08/pages/otp_verification_page.dart';
import 'package:ecom_user_08/pages/user_profile_page.dart';
import 'package:ecom_user_08/providers/cart_provider.dart';
import 'package:ecom_user_08/providers/product_provider.dart';
import 'package:ecom_user_08/providers/user_provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'pages/checkout_page.dart';
import 'pages/launcher_page.dart';
import 'pages/login_page.dart';
import 'pages/order_page.dart';
import 'pages/product_details_page.dart';
import 'pages/view_product_page.dart';
import 'providers/notification_provider.dart';
import 'providers/order_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MultiProvider(providers: [
    ChangeNotifierProvider(create: (_) => ProductProvider()),
    ChangeNotifierProvider(create: (_) => OrderProvider()),
    ChangeNotifierProvider(create: (_) => UserProvider()),
    ChangeNotifierProvider(create: (_) => CartProvider()),
    ChangeNotifierProvider(create: (_) => NotificationProvider()),
  ], child: const MyApp()));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    super.initState();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.paused:
        print('My App Paused');
        break;
      case AppLifecycleState.resumed:
        print('My App Resumed');
        break;

      case AppLifecycleState.detached:
        print('My App Detached');
        break;

      case AppLifecycleState.inactive:
        print('My App Inactive');
        if (AuthService.currentUser!.isAnonymous) {
          AuthService.logout();
        }
        break;
    }
    super.didChangeAppLifecycleState(state);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        textTheme: GoogleFonts.russoOneTextTheme(),
        primarySwatch: Colors.blue,
      ),
      builder: EasyLoading.init(),
      initialRoute: LauncherPage.routeName,
      routes: {
        LauncherPage.routeName: (_) => const LauncherPage(),
        LoginPage.routeName: (_) => const LoginPage(),
        ViewProductPage.routeName: (_) => const ViewProductPage(),
        ProductDetailsPage.routeName: (_) => const ProductDetailsPage(),
        OrderPage.routeName: (_) => const OrderPage(),
        CartPage.routeName: (_) => const CartPage(),
        OrderSuccessfulPage.routeName: (_) => const OrderSuccessfulPage(),
        UserProfilePage.routeName: (_) => const UserProfilePage(),
        OtpVerificationPage.routeName: (_) => const OtpVerificationPage(),
        CheckoutPage.routeName: (_) => const CheckoutPage(),
      },
    );
  }
}
