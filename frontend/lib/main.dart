import 'package:easy_dynamic_theme/easy_dynamic_theme.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_strategy/url_strategy.dart';

import 'app.dart';

void main() async {
  var a = await SharedPreferences.getInstance();
  await a.reload();
  setPathUrlStrategy();
  runApp(EasyDynamicThemeWidget(
    child: CodetestApp(a),
  ));
}
