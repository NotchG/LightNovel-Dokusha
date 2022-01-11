import 'package:firstflutterproject/pages/Settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'pages/home.dart';
import 'pages/LNDetails.dart';
import 'pages/LNViewer.dart';

void main() {


  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    title: 'World Time',
    initialRoute: '/',
    routes: {
      '/': (context) => Home(),
      '/viewer': (context) => Viewer(),
      '/details': (context) => Details(),
      '/settings': (context) => Settings()
    },
  ));
}


