import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:public_market/Screens/login_screen.dart';
import 'package:public_market/Screens/settings_screen.dart';
import 'package:public_market/Screens/splash_screen.dart';
import 'package:public_market/Screens/home_screen.dart';
import 'package:public_market/Screens/profile_screen.dart';
import 'package:public_market/Screens/ProfileData.dart';
import 'package:back_button_interceptor/back_button_interceptor.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => ApiResponseProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        initialRoute: '/',
        routes: {
          '/': (context) => SplashScreen(),
          '/settings': (context) => SettingsScreen(),
          '/login': (context) => LoginScreen(),
          '/home': (context) => HomeScreen(),

        },
      ),
    ),
  );
}
bool myInterceptor(bool stopDefaultButtonEvent, RouteInfo info) {
  print("BACK BUTTON!"); // Do some stuff.
  return true;
}

