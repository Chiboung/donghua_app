/// Static app metadata shown on the About screen. There's no
/// `package_info_plus` dependency in this project to read the version
/// from `pubspec.yaml` at runtime, so it's kept here instead — update
/// [version] and [buildNumber] to match `pubspec.yaml` whenever you
/// bump them.
class AppInfo {
  AppInfo._();

  static const String appName = 'Donghua App';
  static const String version = '1.0.0';
  static const String buildNumber = '';
  static const String description =
      'Track and discover donghua, and with other users.';
  static const String developer = 'Donghua App Team';
  static const String supportEmail = 'support@donghua-app.com';
  static const String made = 'Made in Cambodia';
}
