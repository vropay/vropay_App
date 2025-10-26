import 'package:flutter/material.dart';

/// Utility widget to disable back navigation for the wrapped subtree.
///
/// This widget combines a `WillPopScope` with a route-level
/// `addScopedWillPopCallback` so that both Android hardware back and
/// iOS edge-swipe (interactive pop) are blocked while the widget is
/// visible. Set `allowBack: true` to allow normal pop behavior.
class NoBackScope extends StatefulWidget {
  final Widget child;
  final bool allowBack;

  const NoBackScope({Key? key, required this.child, this.allowBack = false})
      : super(key: key);

  @override
  _NoBackScopeState createState() => _NoBackScopeState();
}

class _NoBackScopeState extends State<NoBackScope> {
  ModalRoute<dynamic>? _route;

  Future<bool> _onWillPop() async {
    return widget.allowBack;
  }

  void _registerCallback() {
    // Register only once
    final route = ModalRoute.of(context);
    if (route != null && _route != route) {
      // Remove previous if any
      _route?.removeScopedWillPopCallback(_onWillPop);
      _route = route;
      _route?.addScopedWillPopCallback(_onWillPop);
    }
  }

  void _unregisterCallback() {
    _route?.removeScopedWillPopCallback(_onWillPop);
    _route = null;
  }

  @override
  void initState() {
    super.initState();
    // Registration requires a valid context, defer until first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _registerCallback();
    });
  }

  @override
  void didUpdateWidget(covariant NoBackScope oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Re-register to ensure callback reflects new allowBack value
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _registerCallback();
    });
  }

  @override
  void dispose() {
    _unregisterCallback();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: widget.child,
    );
  }
}

/// Simple helper to create an AppBar without the default back/leading
/// button. If your screen is the root/main screen (like Learn), use this
/// instead of the default AppBar to avoid showing the back arrow.
PreferredSizeWidget noBackAppBar({
  Key? key,
  Widget? title,
  List<Widget>? actions,
  Color? backgroundColor,
  double? elevation,
}) {
  return AppBar(
    key: key,
    automaticallyImplyLeading: false,
    title: title,
    actions: actions,
    backgroundColor: backgroundColor,
    elevation: elevation ?? 0.8,
  );
}

/// NOTES / Usage tips:
/// - Wrap the top-level widget of a screen (usually the `Scaffold`) with
///   `NoBackScope` to prevent Navigator pop when the user presses the
///   hardware/system back button.
/// - To remove the AppBar back arrow, either use `noBackAppBar(...)` or
///   set `AppBar(automaticallyImplyLeading: false)` directly in that
///   screen.
/// - On iOS, the edge-swipe (back gesture) can still work depending on the
///   route used. If you need to disable the swipe-back gesture, push the
///   screen using a `PageRoute` that disables gestures (e.g. use a
///   `PageRouteBuilder` and set `gestureEnabled: false` when available) or
///   add a scoped will-pop callback in `initState` of the screen's
///   `StatefulWidget`.
