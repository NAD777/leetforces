import 'package:easy_dynamic_theme/easy_dynamic_theme.dart';
import 'package:flutter/material.dart';
import 'package:frontend/router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';

void main() async {
  var a = await SharedPreferences.getInstance();
  await a.reload();
  AppRouter.setupRouter();
  runApp(EasyDynamicThemeWidget(
    child: CodetestApp(a),
  ));
}
