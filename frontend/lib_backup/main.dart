import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'features/home/home_screen.dart';
void main() { runApp(const CanisOddApp()); }
class CanisOddApp extends StatelessWidget {
  const CanisOddApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(title:'Canis Odd Music.Com',debugShowCheckedModeBanner:false,theme:AppTheme.light,darkTheme:AppTheme.dark,home:const HomeScreen());
}
