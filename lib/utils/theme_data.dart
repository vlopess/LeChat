import 'package:flutter/material.dart';
import 'package:lechat/utils/couleurs.dart';


class AppTheme {
  static final ThemeData theme = ThemeData(
    //CircularProgressIndicator    
    dialogTheme: const DialogTheme(
      backgroundColor: Couleurs.greyDark
    ),
    buttonTheme:  const ButtonThemeData(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(30.0)),
      ),      
      buttonColor: Couleurs.greyVeryLight,    
    ),
    inputDecorationTheme: const InputDecorationTheme(
      hintStyle: TextStyle(color: Couleurs.white),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(20.0)),
      ),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Couleurs.greyVeryLight, width: 1.0),
        borderRadius: BorderRadius.all(Radius.circular(32.0)),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Couleurs.greyVeryLight, width: 2.0),
        borderRadius: BorderRadius.all(Radius.circular(32.0)),
      ),
    ),
    outlinedButtonTheme: const OutlinedButtonThemeData(    
      style: ButtonStyle(        
        backgroundColor: MaterialStatePropertyAll(Couleurs.greyVeryLight)        
      )
    ),
    scaffoldBackgroundColor: Couleurs.greyDark,
    colorScheme: ColorScheme.fromSeed(seedColor: Couleurs.greyVeryLight),
    fontFamily: 'Barlow',
    drawerTheme: const DrawerThemeData(
      backgroundColor: Couleurs.greyDark,
    ),
    useMaterial3: true,
    textTheme: const TextTheme(
      bodySmall: TextStyle(
        color: Couleurs.white,
        fontFamily: 'Glass Antiqua'
      ),
      bodyMedium: TextStyle(
        color: Couleurs.white,
        fontFamily: 'Glass Antiqua'
      ),
      bodyLarge: TextStyle(
        color: Couleurs.white,
        fontFamily: 'Glass Antiqua'
      )
    ),
    hintColor: Couleurs.white,
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: Couleurs.primaryColor
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Couleurs.greyVeryLight,
    )
  );
  static final ThemeData darktheme = ThemeData(
    colorScheme: ColorScheme.fromSeed(seedColor: Couleurs.greyDark),
    useMaterial3: true,
    appBarTheme: const AppBarTheme(
      backgroundColor: Couleurs.greyDark,
    )
  );
}
