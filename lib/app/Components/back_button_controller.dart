import 'package:get/get.dart';

/// Simple global controller to enable/disable the top-nav back action.
///
/// Usage:
/// - To disable back button globally: `BackButtonController.disable();`
/// - To enable back button: `BackButtonController.enable();`
/// - To set directly: `BackButtonController.setEnabled(false);`
class BackButtonController {
  // Using an RxBool so other widgets/controllers can listen if needed.
  static final RxBool _enabled = true.obs;

  /// Returns the current enabled state
  static bool get isEnabled => _enabled.value;

  /// Stream/obs for reactive listening
  static RxBool get enabledStream => _enabled;

  /// Enable the back button
  static void enable() => _enabled.value = true;

  /// Disable the back button
  static void disable() => _enabled.value = false;

  /// Set enabled state
  static void setEnabled(bool v) => _enabled.value = v;
}
