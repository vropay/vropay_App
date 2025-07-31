import 'package:get/get.dart';

import '../modules/Screens/OtpScreen/bindings/otp_screen_binding.dart';
import '../modules/Screens/OtpScreen/views/otp_screen_view.dart';
import '../modules/Screens/TrialTransitionView/trial_transition_view.dart';
import '../modules/Screens/community_forum/bindings/community_forum_binding.dart';
import '../modules/Screens/community_forum/views/community_forum_view.dart';
import '../modules/Screens/dashboard/bindings/dashboard_binding.dart';
import '../modules/Screens/dashboard/views/dashboard_view.dart';
import '../modules/Screens/deactivate_screen/bindings/deactivate_screen_binding.dart';
import '../modules/Screens/deactivate_screen/views/deactivate_screen_view.dart';
import '../modules/Screens/home/bindings/home_binding.dart';
import '../modules/Screens/home/views/home_view.dart';
import '../modules/Screens/knowledge_center_Screen/bindings/knowledge_center_screen_binding.dart';
import '../modules/Screens/knowledge_center_Screen/views/knowledge_center_screen_view.dart';
import '../modules/Screens/learn_screen/bindings/learn_screen_binding.dart';
import '../modules/Screens/learn_screen/views/learn_screen.dart';
import '../modules/Screens/notifications/bindings/notifications_binding.dart';
import '../modules/Screens/notifications/views/notifications_view.dart';
import '../modules/Screens/onBoarding/bindings/on_boarding_binding.dart';
import '../modules/Screens/onBoarding/views/on_boarding_view.dart';
import '../modules/Screens/payment_screen/bindings/payment_screen_binding.dart';
import '../modules/Screens/payment_screen/views/payment_screen_view.dart';
import '../modules/Screens/phone_verification/bindings/phone_verification_binding.dart';
import '../modules/Screens/phone_verification/views/phone_verification_view.dart';
import '../modules/Screens/profile/bindings/profile_binding.dart';
import '../modules/Screens/profile/views/profile_view.dart';
import '../modules/Screens/signUp/bindings/sign_up_binding.dart';
import '../modules/Screens/signUp/views/sign_up_view.dart';
import '../modules/Screens/signoutScreen/bindings/signout_screen_binding.dart';
import '../modules/Screens/subscription/bindings/subscription_binding.dart';
import '../modules/Screens/subscription/views/subscription_view.dart';
import '../modules/Screens/track_selection/bindings/track_selection_binding.dart';
import '../modules/Screens/track_selection/views/track_selection_view.dart';
import '../modules/common/firstTimeSplash.dart';
import '../modules/common/welcomeBackSplash.dart';


import '../modules/Screens/signoutScreen/views/signout_screen_view.dart'
    show SignoutScreenView;

part 'app_routes.dart';

class AppPages {
  AppPages._();

  static const INITIAL = Routes.PROFILE;

  static final routes = [
    GetPage(
      name: _Paths.ON_BOARDING,
      page: () => OnBoardingView(),
      binding: OnBoardingBinding(),
    ),
    GetPage(
      name: _Paths.SIGN_UP,
      page: () => SignUpView(),
      binding: SignUpBinding(),
    ),
    GetPage(
      name: _Paths.OTP_SCREEN,
      page: () => OtpScreenView(),
      binding: OtpScreenBinding(),
    ),
    GetPage(
      name: _Paths.PHONE_VERIFICATION,
      page: () => PhoneVerificationView(),
      binding: PhoneVerificationBinding(),
    ),
    GetPage(
      name: _Paths.HOME,
      page: () => HomeView(),
      binding: HomeBinding(),
    ),
    GetPage(
      name: _Paths.SUBSCRIPTION,
      page: () => SubscriptionView(),
      binding: SubscriptionBinding(),
    ),
    GetPage(name: '/trial-transition', page: () => TrialTransitionView()),
    GetPage(
      name: _Paths.NOTIFICATIONS,
      page: () => NotificationsView(),
      binding: NotificationsBinding(),
    ),
    GetPage(
      name: _Paths.TRACK_SELECTION,
      page: () => TrackSelectionView(),
      binding: TrackSelectionBinding(),
    ),
    GetPage(
      name: _Paths.LEARN_SCREEN,
      page: () => LearnScreenView(),
      binding: LearnScreenBinding(),
    ),
    GetPage(
      name: _Paths.COMMUNITY_FORUM,
      page: () => CommunityForumView(),
      binding: CommunityForumBinding(),
    ),
    GetPage(
      name: _Paths.PAYMENT_SCREEN,
      page: () => PaymentScreenView(),
      binding: PaymentScreenBinding(),
    ),
    GetPage(
      name: _Paths.PROFILE,
      page: () => ProfileView(),
      binding: ProfileBinding(),
    ),
    GetPage(
      name: _Paths.DASHBOARD,
      page: () => const DashboardView(),
      binding: DashboardBinding(),
    ),
    GetPage(
      name: _Paths.DEACTIVATE_SCREEN,
      page: () => DeactivateScreenView(),
      binding: DeactivateScreenBinding(),
    ),
    GetPage(
      name: _Paths.firstTimeSplash,
      page: () => FirstTimeSplashScreen(),
    ),
    GetPage(
      name: _Paths.welcomeSplash,
      page: () => WelcomeBackSplashScreen(),
    ),
    GetPage(
      name: _Paths.SIGNOUT_SCREEN,
      page: () => const SignoutScreenView(),
      binding: SignoutScreenBinding(),
    ),
    GetPage(
      name: _Paths.KNOWLEDGE_CENTER_SCREEN,
      page: () => const KnowledgeCenterScreenView(),
      binding: KnowledgeCenterScreenBinding(),
    ),
  ];
}
