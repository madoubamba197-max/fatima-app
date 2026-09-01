import 'package:flutter/material.dart';
import '../config/business_config.dart';

class AppTheme {

  static ThemeData lightTheme = ThemeData(

    primaryColor: BusinessConfig.primaryColor,

    scaffoldBackgroundColor:
        BusinessConfig.backgroundColor,

    appBarTheme: AppBarTheme(

      backgroundColor:
          BusinessConfig.primaryColor,

      foregroundColor:
          Colors.white,

    ),

  );

}