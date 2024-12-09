// Flutter web plugin registrant file.
//
// Generated file. Do not edit.
//

// @dart = 2.13
// ignore_for_file: type=lint

import 'package:file_picker/_internal/file_picker_web.dart';
import 'package:flutter_credit_card/src/plugin/flutter_credit_card_web.dart';
import 'package:google_maps_flutter_web/google_maps_flutter_web.dart';
import 'package:pointer_interceptor_web/pointer_interceptor_web.dart';
import 'package:rive_common/rive_web.dart';
import 'package:shared_preferences_web/shared_preferences_web.dart';
import 'package:url_launcher_web/url_launcher_web.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';

void registerPlugins([final Registrar? pluginRegistrar]) {
  final Registrar registrar = pluginRegistrar ?? webPluginRegistrar;
  FilePickerWeb.registerWith(registrar);
  FlutterCreditCardWeb.registerWith(registrar);
  GoogleMapsPlugin.registerWith(registrar);
  PointerInterceptorWeb.registerWith(registrar);
  RivePlugin.registerWith(registrar);
  SharedPreferencesPlugin.registerWith(registrar);
  UrlLauncherPlugin.registerWith(registrar);
  registrar.registerMessageHandler();
}