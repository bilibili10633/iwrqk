import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:iwrqk/i18n/strings.g.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../../const/config.dart';
import '../../data/providers/config_provider.dart';
import '../../data/providers/storage_provider.dart';
import '../../data/services/account_service.dart';
import '../../data/services/config_service.dart';
import '../../data/services/download_service.dart';
import '../../data/services/plugin/pl_player/service_locator.dart';
import '../../routes/pages.dart';
import '../../utils/display_util.dart';
import '../../utils/log_util.dart';

class SettingsController extends GetxController {
  final ConfigService configService = Get.find();
  final AccountService accountService = Get.find();
  final DownloadService downloadService = Get.find();

  ThemeMode getCurrentTheme() {
    return configService.themeMode;
  }

  void setThemeMode(ThemeMode themeMode) {
    configService.themeMode = themeMode;
  }

  String getCurrentLocalecode() {
    return DisplayUtil.getLocalecode();
  }

  void setLanguage(AppLocale locale) {
    configService.setLocale(locale);
    Get.updateLocale(locale.flutterLocale);
  }

  final RxBool _enableLogging = false.obs;
  bool get enableLogging => _enableLogging.value;
  set enableLogging(bool value) {
    _enableLogging.value = value;
    StorageProvider.config[StorageKey.loggingEnable] = value;
  }

  final RxString _logSize = 'N/A'.obs;
  String get logSize => _logSize.value;

  final RxBool _enableVerboseLogging = false.obs;
  bool get enableVerboseLogging => _enableVerboseLogging.value;
  set enableVerboseLogging(bool value) {
    _enableVerboseLogging.value = value;
    StorageProvider.config[StorageKey.verboseLoggingEnable] = value;
  }

  final RxBool _autoPlay = false.obs;
  bool get autoPlay => _autoPlay.value;
  set autoPlay(bool value) {
    _autoPlay.value = value;
    StorageProvider.config[PLPlayerConfigKey.enableQuickDouble] = value;
  }

  final RxBool _backgroundPlay = false.obs;
  bool get backgroundPlay => _backgroundPlay.value;
  set backgroundPlay(bool value) {
    _backgroundPlay.value = value;
    videoPlayerServiceHandler.enableBackgroundPlay = value;
    StorageProvider.config[PLPlayerConfigKey.enableBackgroundPlay] = value;
  }

  final Rx<Directory?> _downloadPath = Rx<Directory?>(null);
  Directory? get downloadPath => _downloadPath.value;
  String get downloadPathText => _downloadPath.value?.path ?? 'N/A';
  set downloadPath(Directory? value) {
    _downloadPath.value = value;
    StorageProvider.config[StorageKey.downloadDirectory] = value?.path;
    downloadService.resetAllowMediaScan();
  }

  final RxBool _allowMediaScan = false.obs;
  bool get allowMediaScan => _allowMediaScan.value;
  set allowMediaScan(bool value) {
    _allowMediaScan.value = value;
    StorageProvider.config[StorageKey.allowMediaScan] = value;
  }

  final RxBool _enableProxy = false.obs;
  bool get enableProxy => _enableProxy.value;
  set enableProxy(bool value) {
    _enableProxy.value = value;
    StorageProvider.config[StorageKey.proxyEnable] = value;
  }

  bool get workMode => configService.workMode;
  set workMode(bool value) {
    configService.workMode = value;
  }

  @override
  void onInit() {
    super.onInit();

    _autoPlay.value =
        configService.setting[PLPlayerConfigKey.enableQuickDouble] ?? true;

    _downloadPath.value = downloadService.downloadDirectory;

    _backgroundPlay.value =
        configService.setting[PLPlayerConfigKey.enableBackgroundPlay] ?? false;

    _enableProxy.value =
        StorageProvider.config[StorageKey.proxyEnable] ?? false;

    _enableLogging.value =
        StorageProvider.config[StorageKey.loggingEnable] ?? true;

    _enableVerboseLogging.value =
        StorageProvider.config[StorageKey.verboseLoggingEnable] ?? false;

    LogUtil.getSize().then((value) => _logSize.value = value);
  }

  void logout() {
    accountService.logout();
    Get.offNamedUntil(AppRoutes.home, (route) => false);
  }

  void changeDownloadPath() async {
    if (!await downloadService.checkPermission(true)) return;

    String? result;

    try {
      result = await FilePicker.platform.getDirectoryPath();
    } on Exception catch (e) {
      LogUtil.error('Pick download path failed', e);
    }

    if (result == null) return;

    if (!downloadService.checkPermissionForPath(result)) {
      SmartDialog.showToast(t.error.invalid_path);
      return;
    }

    downloadPath = Directory(result);
  }

  void clearLogs() async {
    await LogUtil.clear();
    _logSize.value = await LogUtil.getSize();
  }

  Future<void> checkLatestVersion() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    String currentVersion = packageInfo.version;

    await ConfigProvider.getLatestVersion().then((value) async {
      if (value.success) {
        if (compareVersion(currentVersion, value.data!) < 0) {
          Get.dialog(AlertDialog(
            title: Text(t.message.update.update_available),
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(t.message.update.current_version(version: currentVersion)),
                Text(t.message.update.latest_version(version: value.data!)),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Get.back();
                },
                child: Text(t.notifications.cancel),
              ),
              TextButton(
                onPressed: () async {
                  Get.back();
                  launchUrlString(ConfigConst.updateUrl,
                      mode: LaunchMode.externalApplication);
                },
                child: Text(t.message.update.view_update),
              ),
            ],
          ));
        } else {
          SmartDialog.showToast(t.message.update.already_latest_version);
        }
      } else {
        LogUtil.error('Check update failed', value.message);
        SmartDialog.showToast(t.message.update.check_update_failed);
      }
    });
  }

  int compareVersion(String a, String b) {
    List<String> numberA = a.replaceFirst('v', '').split('.');
    List<String> numberB = b.replaceFirst('v', '').split('.');

    if (numberA.length != numberB.length) {
      return 0;
    }

    for (int i = 0; i < numberA.length; i++) {
      int a = int.parse(numberA[i]);
      int b = int.parse(numberB[i]);
      if (a > b) {
        return 1;
      } else if (a < b) {
        return -1;
      }
    }

    return 0;
  }
}
