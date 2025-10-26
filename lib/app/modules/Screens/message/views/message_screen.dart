import 'dart:math';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:vropay_final/Components/back_icon.dart';
import 'package:vropay_final/Utilities/constants/KImages.dart';
import 'package:vropay_final/Utilities/screen_utils.dart';
import 'package:vropay_final/app/modules/Screens/message/controllers/message_controller.dart';
import 'package:vropay_final/app/core/services/learn_service.dart';
import 'package:vropay_final/app/modules/Screens/news/controllers/news_controller.dart';
import 'dart:ui';

class MessageScreen extends StatefulWidget {
  const MessageScreen({super.key});

  @override
  State<MessageScreen> createState() => _MessageScreenState();
}

class _MessageScreenState extends State<MessageScreen> {
  final MessageController controller = Get.put(MessageController());

  final TextEditingController _importantMessageController =
      TextEditingController();
  final TextEditingController _searchController =
      TextEditingController(); // Add this
  bool _showImportantMessage = false;
  bool _showSearchOverlay = false; // Add this
  bool _showConfirmationOptions = false;
  final RxBool _showQuickReplies = false.obs;
  final ScrollController _scrollController = ScrollController();
  Timer? _loadMoreDebounceTimer;

  @override
  void initState() {
    super.initState();
    controller.setScrollCallback(() {
      if (_scrollController.hasClients &&
          _scrollController.position.maxScrollExtent > 0) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });

    // Add scroll listener for dynamic loading
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    // Check if user has scrolled to the top (within 100 pixels)
    if (_scrollController.position.pixels <= 100 &&
        _scrollController.position.pixels > 0) {
      // User is near the top, load more messages if available and not already loading
      if (controller.hasNextPage && !controller.isLoading.value) {
        // Debounce to prevent multiple rapid calls
        _loadMoreDebounceTimer?.cancel();
        _loadMoreDebounceTimer = Timer(Duration(milliseconds: 300), () {
          if (controller.hasNextPage && !controller.isLoading.value) {
            print('🔄 [MESSAGE SCREEN] Loading more messages automatically');
            controller.loadMoreMessages();
          }
        });
      }
    }
  }

  @override
  void dispose() {
    _importantMessageController.dispose();
    _searchController.dispose(); // Add this
    _scrollController.dispose();
    _loadMoreDebounceTimer?.cancel(); // Clean up timer
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      body: Stack(
        children: [
          CustomScrollView(
            controller: _scrollController,
            slivers: [
              // SliverAppBar with blur effect
              Obx(() => SliverAppBar(
                    expandedHeight: 0,
                    floating: false,
                    pinned: true,
                    toolbarHeight: kToolbarHeight,
                    collapsedHeight: kToolbarHeight,
                    backgroundColor: controller.isImportantIconPressed.value
                        ? Colors.grey.withOpacity(0.1)
                        : Colors.white,
                    elevation: 0,
                    surfaceTintColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    flexibleSpace: null,
                    leading: IconButton(
                      onPressed: () {
                        Get.back();
                      },
                      icon: Padding(
                        padding: const EdgeInsets.only(left: 10),
                        child: BackIcon(isInsideButton: true),
                      ),
                    ),
                    leadingWidth: 48,
                    title: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Flexible(
                          flex: 3,
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerLeft,
                            child: Text(
                              controller.interestName.value,
                              style: TextStyle(
                                fontSize: 50,
                                color: const Color(0xFFCC415D),
                                fontWeight: FontWeight.w300,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: ScreenUtils.width * 0.02),
                        Text(
                          "${controller.memberCount.value} members",
                          style: TextStyle(
                            fontSize: 10,
                            color: const Color(0xFF616161),
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(width: ScreenUtils.width * 0.02),
                        // Show a small badge if cross-category (news) results exist
                        Obx(() {
                          if (controller.hasCrossCategoryResults.value) {
                            return Container(
                              margin: EdgeInsets.only(left: 6),
                              padding: EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Color(0xFF714FC0),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons
                                        .article, // represents news-like content
                                    size: 12,
                                    color: Colors.white,
                                  ),
                                  SizedBox(width: 6),
                                  Text(
                                    'News',
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 12),
                                  ),
                                ],
                              ),
                            );
                          }

                          return const SizedBox.shrink();
                        }),
                      ],
                    ),
                    actions: [
                      Obx(() => controller.canSendMessages.value
                          ? Padding(
                              padding:
                                  const EdgeInsets.only(right: 20.0, top: 10),
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _showSearchOverlay = true;
                                  });
                                },
                                child: Container(
                                  width: 30,
                                  height: 30,
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                  ),
                                  child: CustomPaint(
                                    painter: _DottedCirclePainter(),
                                    child: const Center(
                                      child: Icon(
                                        Icons.add,
                                        size: 20,
                                        color: Color(0xFF714FC0),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            )
                          : const SizedBox.shrink()),
                      Obx(() => controller.canSendMessages.value
                          ? Padding(
                              padding:
                                  const EdgeInsets.only(right: 29.0, top: 10),
                              child: GestureDetector(
                                onTap: () {
                                  controller.toggleBlurEffect();
                                  setState(() {
                                    _showImportantMessage = true;
                                  });
                                },
                                child: Obx(() =>
                                    controller.isImportantIconPressed.value
                                        ? Container(
                                            padding: const EdgeInsets.all(4),
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.black
                                                      .withOpacity(0.1),
                                                  blurRadius: 4,
                                                  offset: const Offset(0, 2),
                                                ),
                                              ],
                                            ),
                                            child: Image.asset(
                                              KImages.importantIcon,
                                              height: 30,
                                            ),
                                          )
                                        : Image.asset(
                                            KImages.importantIcon,
                                            height: 30,
                                          )),
                              ),
                            )
                          : const SizedBox.shrink())
                    ],
                  )),

              // Divider
              SliverToBoxAdapter(
                child: const Divider(
                  endIndent: 20,
                  indent: 20,
                  color: Color(0xFF01B3B2),
                ),
              ),

              // Automatic loading indicator at the top for loading more messages
              SliverToBoxAdapter(
                child: Obx(
                    () => controller.hasNextPage && controller.isLoading.value
                        ? Container(
                            padding: const EdgeInsets.all(16),
                            child: Center(
                              child: Column(
                                children: [
                                  SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Color(0xFF714FC0),
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    'Loading older messages...',
                                    style: TextStyle(
                                      color: Color(0xFF9E9E9E),
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        : const SizedBox.shrink()),
              ),

              // Initial loading indicator (for first load)
              Obx(() =>
                  controller.isLoading.value && controller.messages.isEmpty
                      ? SliverToBoxAdapter(
                          child: Container(
                            padding: const EdgeInsets.all(20),
                            child: const Center(
                              child: CircularProgressIndicator(
                                color: Color(0xFF714FC0),
                              ),
                            ),
                          ),
                        )
                      : const SliverToBoxAdapter(child: SizedBox.shrink())),

              // Reply indicator
              SliverToBoxAdapter(
                child: Obx(() => controller.replyToMessage.value != null
                    ? _buildReplyIndicator()
                    : const SizedBox.shrink()),
              ),

              // Chat messages (efficient reactive list)
              Obx(() {
                final messages = controller.messages;
                return SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final message = messages[index];
                      if (message['isOwnMessage'] == true) {
                        return Padding(
                          padding: const EdgeInsets.only(
                            top: 8,
                            right: 16,
                            left: 16, // Minimal left margin
                          ),
                          child: _buildOwnMessage(message, index),
                        );
                      } else {
                        return Padding(
                          padding: const EdgeInsets.only(
                            left: 16,
                            right: 16, // Minimal right margin
                            top: 8,
                          ),
                          child: _buildMessageItem(message, index),
                        );
                      }
                    },
                    childCount: messages.length,
                  ),
                );
              }),
              // Typing indicator
              Obx(() => controller.typingUsersText.value.isNotEmpty
                  ? SliverToBoxAdapter(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 8,
                        ),
                        child: Row(
                          children: [
                            const SizedBox(width: 8),
                            Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: Color(0xFF9E9E9E),
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              controller.typingUsersText.value,
                              style: const TextStyle(
                                color: Color(0xFF9E9E9E),
                                fontSize: 14,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  : const SliverToBoxAdapter(child: SizedBox.shrink())),
            ],
          ),

          // Fixed Message Input Area at Bottom
          // Obx(
          //   () => controller.canSendMessages.value
          //       ? Positioned(
          //           bottom: 0,
          //           left: 0,
          //           right: 0,
          //           child: Container(
          //             color: Colors.white,
          //             padding: EdgeInsets.only(
          //               bottom: MediaQuery.of(context).padding.bottom,
          //               top: 8,
          //             ),
          //             child: Column(
          //               mainAxisSize: MainAxisSize.min,
          //               children: [
          //                 Divider(
          //                   color: Color(0xFF01B3B2).withOpacity(0.5),
          //                 ),
          //                 // Quick reply buttons above message input
          //                 Obx(() => _showQuickReplies.value
          //                     ? _buildQuickReplyButtons()
          //                     : const SizedBox.shrink()),
          //                 // Message input field
          //                 Padding(
          //                   padding: const EdgeInsets.only(left: 10, right: 10),
          //                   child: _buildMessageInput(),
          //                 ),
          //               ],
          //             ),
          //           ),
          //         )
          //       : const SizedBox.shrink(),
          // ),

          // // Important Message Overlay
          if (_showImportantMessage && controller.canSendMessages.value)
            Positioned.fill(
              child: Stack(
                children: [
                  // Blur overlay for entire background
                  Positioned.fill(
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 8.0, sigmaY: 8.0),
                      child: Container(
                        color: Colors.black.withValues(alpha: 0.3),
                      ),
                    ),
                  ),
                  // Important Message Overlay - Simple Input Popup
                  Positioned(
                    top: kToolbarHeight,
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: Stack(
                      children: [
                        // Full screen gesture detector to dismiss on outside tap
                        Positioned.fill(
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _showImportantMessage = false;
                                _importantMessageController.clear();
                                _showConfirmationOptions = false;
                              });
                              controller.disableBlurEffect();
                            },
                            behavior: HitTestBehavior.translucent,
                          ),
                        ),
                        Positioned(
                          top: 50,
                          right: 20,
                          child: Image.asset(
                            KImages.importantIcon,
                            height: 50,
                          ),
                        ),
                        // Popup content positioned on top
                        Positioned(
                          top: 100,
                          right: 50,
                          child: GestureDetector(
                            onTap: () {},
                            child: Container(
                              width: ScreenUtils.width * 0.7,
                              decoration: BoxDecoration(
                                color: Colors.transparent,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  // Header
                                  Container(
                                    height: ScreenUtils.height * 0.06,
                                    width: ScreenUtils.width * 0.7,
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFFFFFFF),
                                      borderRadius: const BorderRadius.only(
                                        topLeft: Radius.circular(16),
                                        topRight: Radius.circular(16),
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        const Text(
                                          'Important Message',
                                          style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.w300,
                                            color: Color(0xFF172B75),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(height: ScreenUtils.height * 0.005),

                                  // Message Input Field with Send Button Inside
                                  Container(
                                    constraints: BoxConstraints(
                                      minHeight: ScreenUtils.height * 0.02,
                                      maxHeight: ScreenUtils.height * 0.7,
                                    ),
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                        color: Color(0xFFD9D9D9),
                                        borderRadius: BorderRadius.circular(8)),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        // Simple TextField that works
                                        TextField(
                                          controller:
                                              _importantMessageController,
                                          autofocus: true,
                                          keyboardType: TextInputType.multiline,
                                          textInputAction:
                                              TextInputAction.newline,
                                          textAlignVertical:
                                              TextAlignVertical.top,
                                          maxLines: null,
                                          style: const TextStyle(
                                            color: Color(0xFF172B75),
                                            fontSize: 16,
                                            fontWeight: FontWeight.w400,
                                          ),
                                          cursorColor: Color(0xFF172B75),
                                          onChanged: (value) => setState(() {}),
                                          decoration: InputDecoration(
                                            hintText:
                                                "Write your message\n upto 100 words",
                                            hintStyle: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w400),
                                            border: InputBorder.none,
                                            contentPadding:
                                                const EdgeInsets.all(8),
                                            filled: false,
                                            // Send button
                                            suffixIcon: GestureDetector(
                                              onTap: () {
                                                final message =
                                                    _importantMessageController
                                                        .text
                                                        .trim();
                                                if (message.isNotEmpty) {
                                                  // Validate message length (100 words max as per hint)
                                                  final wordCount = message
                                                      .split(RegExp(r'\s+'))
                                                      .length;
                                                  if (wordCount > 100) {
                                                    Get.snackbar(
                                                      'Message Too Long',
                                                      'Please keep your message under 100 words',
                                                      backgroundColor:
                                                          Colors.orange,
                                                      colorText: Colors.white,
                                                      duration: const Duration(
                                                          seconds: 2),
                                                    );
                                                    return;
                                                  }

                                                  setState(() {
                                                    _showConfirmationOptions =
                                                        true;
                                                  });
                                                } else {
                                                  Get.snackbar(
                                                    'Empty Message',
                                                    'Please enter a message before sending',
                                                    backgroundColor:
                                                        Colors.orange,
                                                    colorText: Colors.white,
                                                    duration: const Duration(
                                                        seconds: 2),
                                                  );
                                                }
                                              },
                                              child: Container(
                                                height: 30,
                                                width: 30,
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                  border: Border.all(
                                                    color: Color(0xFF172B75),
                                                    width:
                                                        _importantMessageController
                                                                .text
                                                                .trim()
                                                                .isNotEmpty
                                                            ? 2
                                                            : 1,
                                                  ),
                                                ),
                                                child: const Icon(
                                                  Iconsax.arrow_up_3,
                                                  color: Color(0xFF172B75),
                                                  size: 20,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(height: 20),
                                  // Confirmation options below text field
                                  if (_showConfirmationOptions)
                                    Container(
                                      width: ScreenUtils.width * 0.7,
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 20, vertical: 10),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.only(
                                          topLeft: Radius.circular(16),
                                          topRight: Radius.circular(16),
                                        ),
                                        color: Color(0xFFFFFFFF),
                                      ),
                                      child: Align(
                                        alignment: Alignment.center,
                                        child: const Text(
                                          'not a regular update ?\nneed community attention ?',
                                          style: TextStyle(
                                              fontSize: 15,
                                              color: Color(0xFF3E9292),
                                              fontWeight: FontWeight.w300),
                                        ),
                                      ),
                                    ),
                                  SizedBox(height: 20),
                                  if (_showConfirmationOptions)
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        // Send as important message (Yes button)
                                        GestureDetector(
                                          onTap: () {
                                            final message =
                                                _importantMessageController.text
                                                    .trim();
                                            if (message.isNotEmpty) {
                                              // Final validation before sending
                                              final wordCount = message
                                                  .split(RegExp(r'\s+'))
                                                  .length;
                                              if (wordCount <= 100) {
                                                controller.sendImportantMessage(
                                                    message);
                                                setState(() {
                                                  _showImportantMessage = false;
                                                  _importantMessageController
                                                      .clear();
                                                  _showConfirmationOptions =
                                                      false;
                                                });
                                                controller.disableBlurEffect();
                                              } else {
                                                Get.snackbar(
                                                  'Message Too Long',
                                                  'Please keep your message under 100 words',
                                                  backgroundColor: Colors.red,
                                                  colorText: Colors.white,
                                                  duration: const Duration(
                                                      seconds: 2),
                                                );
                                              }
                                            }
                                          },
                                          child: Container(
                                            height: 52,
                                            width: ScreenUtils.width * 0.2,
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 8, horizontal: 12),
                                            decoration: BoxDecoration(
                                              color: Color(0xFFFFC746),
                                              borderRadius: BorderRadius.only(
                                                topLeft: Radius.circular(20),
                                                bottomLeft: Radius.circular(20),
                                                topRight: Radius.circular(0),
                                                bottomRight:
                                                    Radius.circular(20),
                                              ),
                                            ),
                                            child: Center(
                                              child: const Text(
                                                'yes',
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                  color: Color(0xFFFFFFFF),
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        SizedBox(
                                            width: ScreenUtils.width * 0.1),
                                        // Send as normal message (No button)
                                        GestureDetector(
                                          onTap: () {
                                            final message =
                                                _importantMessageController.text
                                                    .trim();
                                            if (message.isNotEmpty) {
                                              // Final validation before sending
                                              final wordCount = message
                                                  .split(RegExp(r'\s+'))
                                                  .length;
                                              if (wordCount <= 100) {
                                                controller
                                                    .sendNormalMessage(message);
                                                setState(() {
                                                  _showImportantMessage = false;
                                                  _importantMessageController
                                                      .clear();
                                                  _showConfirmationOptions =
                                                      false;
                                                });
                                                controller.disableBlurEffect();
                                              } else {
                                                Get.snackbar(
                                                  'Message Too Long',
                                                  'Please keep your message under 100 words',
                                                  backgroundColor: Colors.red,
                                                  colorText: Colors.white,
                                                  duration: const Duration(
                                                      seconds: 2),
                                                );
                                              }
                                            }
                                          },
                                          child: Container(
                                            height: 52,
                                            width: ScreenUtils.width * 0.2,
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 8, horizontal: 12),
                                            decoration: BoxDecoration(
                                              color: Color(0xFFFFFFFF),
                                              borderRadius: BorderRadius.only(
                                                topLeft: Radius.circular(0),
                                                bottomLeft: Radius.circular(20),
                                                topRight: Radius.circular(20),
                                                bottomRight:
                                                    Radius.circular(20),
                                              ),
                                            ),
                                            child: Center(
                                              child: const Text(
                                                'no',
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                  color: Color(0xFFFFC746),
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

          // Search Overlay for News Articles
          if (_showSearchOverlay)
            Positioned.fill(
              child: Stack(
                children: [
                  // Blur overlay for entire background
                  Positioned.fill(
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 8.0, sigmaY: 8.0),
                      child: Container(
                        color: Colors.black.withValues(alpha: 0.3),
                      ),
                    ),
                  ),
                  // Search Overlay Content
                  Positioned.fill(
                    child: Stack(
                      children: [
                        // Full screen gesture detector to dismiss on outside tap
                        Positioned(
                          top: 70,
                          right: 65,
                          child: Container(
                            width: ScreenUtils.width * 0.12,
                            height: ScreenUtils.height * 0.05,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                            ),
                            child: CustomPaint(
                              painter: _DottedCirclePainter(),
                              child: const Center(
                                child: Icon(
                                  Icons.add,
                                  size: 20,
                                  color: Color(0xFF714FC0),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          top: kToolbarHeight,
                          left: 0,
                          right: 0,
                          bottom: 0,
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _showSearchOverlay = false;
                                _searchController.clear();
                              });
                            },
                            behavior: HitTestBehavior.translucent,
                          ),
                        ),
                        // Search popup content
                        Positioned(
                          top: 100,
                          left: 20,
                          right: 20,
                          child: GestureDetector(
                            onTap: () {},
                            child: Container(
                              decoration: BoxDecoration(
                                // color: const Color(0xFFD9D9D9),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  // Header
                                  Container(
                                    height: 60,
                                    width: double.infinity,
                                    margin: EdgeInsets.only(
                                        left: 25, right: 24, top: 16),
                                    padding: const EdgeInsets.all(16),
                                    decoration: const BoxDecoration(
                                      color: Color(0xFFF7F7F7),
                                      borderRadius: BorderRadius.only(
                                        topLeft: Radius.circular(16),
                                        topRight: Radius.circular(16),
                                      ),
                                    ),
                                    child: Center(
                                      child: const Text(
                                        'highlighted content will be shared',
                                        style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w400,
                                          color: Color(0xFF172B75),
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 5),
                                  // Search Input
                                  Container(
                                    margin: EdgeInsets.only(
                                      left: 25,
                                      right: 24,
                                    ),
                                    padding: const EdgeInsets.all(5),
                                    decoration: const BoxDecoration(
                                      color: Color(0xFFD9D9D9),
                                      borderRadius: BorderRadius.only(
                                        topLeft: Radius.circular(16),
                                        topRight: Radius.circular(16),
                                      ),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Obx(() => TextField(
                                              controller: _searchController,
                                              autofocus: true,
                                              onChanged: (value) =>
                                                  _updateSearchText(value),
                                              decoration: InputDecoration(
                                                hintText:
                                                    'Try searching the relevant keyword',
                                                hintStyle: const TextStyle(
                                                    color: Color(0xFF797C7B),
                                                    fontSize: 14,
                                                    fontWeight:
                                                        FontWeight.w300),
                                                prefixIcon: controller
                                                        .isSearching.value
                                                    ? SizedBox(
                                                        width: 20,
                                                        height: 20,
                                                        child: Padding(
                                                          padding:
                                                              EdgeInsets.all(
                                                                  12),
                                                          child:
                                                              CircularProgressIndicator(
                                                            strokeWidth: 2,
                                                            valueColor:
                                                                AlwaysStoppedAnimation<
                                                                    Color>(
                                                              Color(0xFF172B75),
                                                            ),
                                                          ),
                                                        ),
                                                      )
                                                    : Image.asset(
                                                        KImages.searchIcon,
                                                        color:
                                                            Color(0xFF172B75),
                                                      ),
                                                suffixIcon: _searchController
                                                        .text.isNotEmpty
                                                    ? IconButton(
                                                        icon: Icon(
                                                          Icons.clear,
                                                          color:
                                                              Color(0xFF172B75),
                                                        ),
                                                        onPressed: () =>
                                                            _clearSearch(),
                                                      )
                                                    : null,
                                                border: InputBorder.none,
                                                contentPadding:
                                                    EdgeInsets.symmetric(
                                                        horizontal: 20,
                                                        vertical: 15),
                                              ),
                                            )),
                                      ],
                                    ),
                                  ),

                                  // Search Results
                                  if (_searchController.text.isNotEmpty)
                                    _buildSearchResults()
                                  else
                                    SizedBox()
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
      // Add bottomNavigationBar with message input
      bottomNavigationBar: Obx(() => controller.canSendMessages.value
          ? _buildMessageInputBottomBar()
          : const SizedBox.shrink()),
    );
  }

  Widget _buildReplyIndicator() {
    final replyMessage = controller.replyToMessage.value!;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(12),
        border: const Border(
          left: BorderSide(color: Color(0xFF2196F3), width: 4),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Replying to ${replyMessage['sender']}',
                  style: const TextStyle(
                    color: Color(0xFF2196F3),
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  replyMessage['message'],
                  style: const TextStyle(
                    color: Color(0xFFBDBDBD),
                    fontSize: 14,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: controller.cancelReply,
            icon: const Icon(Icons.close, color: Colors.white, size: 20),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageInputBottomBar() {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).padding.bottom,
        top: 8,
        left: 10,
        right: 10,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Divider(
            color: Color(0xFF01B3B2).withOpacity(0.5),
          ),
          // Quick reply buttons above message input
          Obx(() => _showQuickReplies.value
              ? _buildQuickReplyButtons()
              : const SizedBox.shrink()),
          // Message input field
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildMessageItem(Map<String, dynamic> message, int index) {
    final uniqueKey = GlobalKey();
    // Removed unused variables

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Only show avatar if it's the first message from this user
          if (index == 0 ||
              (index > 0 &&
                  controller.messages[index - 1]['sender'] !=
                      message['sender']))
            CircleAvatar(
              radius: 20,
              backgroundColor:
                  message['avatarColor'] ?? const Color(0xFF9E9E9E),
              child: Image.asset(
                KImages.profile2Icon,
                height: 17,
                width: 12,
                color: Color(0xFF172B75),
              ),
            )
          else
            // Add spacing to align with messages that have avatars
            SizedBox(
                width: ScreenUtils.width *
                    0.09), // Fixed width to match avatar diameter

          SizedBox(width: ScreenUtils.width * 0.02),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Show sender name only for first message from this user
                if (index == 0 ||
                    (index > 0 &&
                        controller.messages[index - 1]['sender'] !=
                            message['sender'])) ...[
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GestureDetector(
                        key: uniqueKey,
                        onLongPress: () async {
                          final RenderBox button = uniqueKey.currentContext!
                              .findRenderObject() as RenderBox;
                          final RenderBox overlay = Navigator.of(context)
                              .overlay!
                              .context
                              .findRenderObject() as RenderBox;
                          final RelativeRect position = RelativeRect.fromRect(
                            Rect.fromPoints(
                              button.localToGlobal(Offset.zero,
                                  ancestor: overlay),
                              button.localToGlobal(
                                  button.size.bottomRight(Offset.zero),
                                  ancestor: overlay),
                            ),
                            Offset.zero & overlay.size,
                          );

                          await showGeneralDialog(
                            context: context,
                            barrierColor: Colors.transparent,
                            barrierDismissible: true,
                            barrierLabel: "Filter",
                            pageBuilder: (context, anim1, anim2) {
                              return Stack(
                                children: [
                                  // Blur background
                                  Positioned.fromRect(
                                    rect: Rect.fromPoints(
                                      Offset(0, 0),
                                      Offset(ScreenUtils.width * 0.05,
                                          ScreenUtils.height * 0.05),
                                    ),
                                    child: BackdropFilter(
                                      filter: ImageFilter.blur(
                                          sigmaX: 6, sigmaY: 6),
                                      child: Container(),
                                    ),
                                  ),
                                  // The filter menu
                                  Positioned(
                                    left: 100,
                                    top: position.top,
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        Material(
                                          child: Text(
                                            "REPORT as..",
                                            style: TextStyle(
                                                fontSize: 15,
                                                color: Color(0xFF172B75),
                                                fontWeight: FontWeight.w500),
                                          ),
                                        ),
                                        Material(
                                          color: Colors.transparent,
                                          child: Container(
                                            height: ScreenUtils.height * 0.32,
                                            width: ScreenUtils.width * 0.35,
                                            decoration: BoxDecoration(
                                              color: Color(0xFF87706A)
                                                  .withOpacity(0.46),
                                              borderRadius:
                                                  BorderRadius.circular(30),
                                            ),
                                            padding: EdgeInsets.only(
                                                left: 30, top: 9),
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                _buildFilterChip(
                                                    context,
                                                    "irrelevant",
                                                    controller.selectedFilter
                                                            .value ==
                                                        "irrelevant", () {
                                                  controller.selectedFilter
                                                      .value = "irrelevant";
                                                  Navigator.of(context).pop();
                                                }),
                                                _buildFilterChip(
                                                    context,
                                                    "advertising",
                                                    controller.selectedFilter
                                                            .value ==
                                                        "advertising", () {
                                                  controller.selectedFilter
                                                      .value = "advertising";
                                                  Navigator.of(context).pop();
                                                }),
                                                _buildFilterChip(
                                                    context,
                                                    "selling",
                                                    controller.selectedFilter
                                                            .value ==
                                                        "selling", () {
                                                  controller.selectedFilter
                                                      .value = "selling";
                                                  Navigator.of(context).pop();
                                                }),
                                                _buildFilterChip(
                                                    context,
                                                    "suspicious",
                                                    controller.selectedFilter
                                                            .value ==
                                                        "suspicious", () {
                                                  controller.selectedFilter
                                                      .value = "suspicious";
                                                  Navigator.of(context).pop();
                                                }),
                                                _buildFilterChip(
                                                    context,
                                                    "offensive",
                                                    controller.selectedFilter
                                                            .value ==
                                                        "offensive", () {
                                                  controller.selectedFilter
                                                      .value = "offensive";
                                                  Navigator.of(context).pop();
                                                }),
                                                _buildFilterChip(
                                                    context,
                                                    "abusive",
                                                    controller.selectedFilter
                                                            .value ==
                                                        "abusive", () {
                                                  controller.selectedFilter
                                                      .value = "abusive";
                                                  Navigator.of(context).pop();
                                                }),
                                                _buildFilterChip(
                                                    context,
                                                    "false",
                                                    controller.selectedFilter
                                                            .value ==
                                                        "false", () {
                                                  controller.selectedFilter
                                                      .value = "false";
                                                  Navigator.of(context).pop();
                                                }),
                                                _buildFilterChip(
                                                    context,
                                                    "hate",
                                                    controller.selectedFilter
                                                            .value ==
                                                        "hate", () {
                                                  controller.selectedFilter
                                                      .value = "hate";
                                                  Navigator.of(context).pop();
                                                }),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                        child: Text(
                          message['sender'] ?? 'Unknown',
                          style: TextStyle(
                            color: Color(0xFF172B75),
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      SizedBox(
                        width: ScreenUtils.width * 0.02,
                      ),
                      Text("tag",
                          style: TextStyle(
                            color: Color(0xFF4A4A4A),
                            fontSize: 8,
                            fontWeight: FontWeight.w400,
                          ))
                    ],
                  ),
                  const SizedBox(height: 4),
                ],
                // Check if this is a reply to a shared article
                if (message['replyTo'] != null &&
                    message['replyTo']['isSharedArticle'] == true) ...[
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.reply,
                          size: 14,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            'Replying to: ${message['replyTo']['articleTitle']}',
                            style: TextStyle(
                              color: Colors.grey[700],
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                ],

                // Check if it's a shared article
                if (message['isSharedArticle'] == true)
                  _buildSharedArticle(message, index)
                else if (message['isHighlightedContent'] == true)
                  _buildHighlightedContent(message, index)
                else if (message['isSharedEntry'] == true)
                  _buildSharedEntry(message, index)
                else if (message['isImportantMessage'] == true)
                  _buildImportantMessage(message, index)
                else
                  Padding(
                    padding: const EdgeInsets.only(left: 16.0),
                    child: Container(
                      margin: EdgeInsets.only(right: 46),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      decoration: const BoxDecoration(
                          color: Color(0xFFF2F7FB),
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(0),
                            topRight: Radius.circular(20),
                            bottomLeft: Radius.circular(20),
                            bottomRight: Radius.circular(20),
                          )),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            message['message'] ?? '',
                            style: const TextStyle(
                              color: Color(0xFF1A1A1A),
                              fontSize: 16,
                            ),
                            softWrap: true,
                            overflow: TextOverflow.visible,
                            maxLines:
                                null, // Allow unlimited lines, wrap to next line automatically
                          ),
                          if (message['tags'] != null &&
                              message['tags'].isNotEmpty) ...[
                            const SizedBox(height: 8),
                            _buildMessageTags(message['tags']),
                          ],
                        ],
                      ),
                    ),
                  ),

                if (message['replied'] == true) ...[
                  const SizedBox(height: 4),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      'replied',
                      style: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 10,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSharedArticle(Map<String, dynamic> message, int index) {
    // Removed unused variables

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 40.0, bottom: 10),
          child: Text(
            'shared article',
            style: TextStyle(
                color: Colors.black, fontSize: 12, fontWeight: FontWeight.w400),
          ),
        ),
        Container(
          margin: EdgeInsets.only(right: 76, left: 23),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Color(0xFFEF2D56).withOpacity(0.1),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(0),
              topRight: Radius.circular(20),
              bottomLeft: Radius.circular(20),
              bottomRight: Radius.circular(20),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                message['articleTitle'] ?? 'Article Title',
                style: const TextStyle(
                  color: Color(0xFF172B75),
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Text(
                    'read..',
                    style: TextStyle(
                      color: Color(0xFF4A4A4A),
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    'reply',
                    style: TextStyle(
                      color: Color(0xFF4A4A4A),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              if (message['replied'] == true) ...[
                const SizedBox(height: 4),
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    'replied',
                    style: TextStyle(
                      color: Colors.grey[400],
                      fontSize: 10,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFilterChip(
      BuildContext context, String label, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 0, vertical: 8),
        child: Text(
          label,
          style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w300,
              fontSize: ScreenUtils.x(3.5),
              height: 1),
        ),
      ),
    );
  }

  Widget _buildMessageTags(List<String> tags) {
    return Wrap(
      spacing: 4,
      children: tags.map((tag) {
        return Text(
          '@$tag',
          style: const TextStyle(
            color: Color(0xFF1976D2),
            fontSize: 12,
          ),
          textAlign: TextAlign.center,
        );
      }).toList(),
    );
  }

  Widget _buildOwnMessage(Map<String, dynamic> message, int index) {
    // Removed unused variables

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end, // Push to right side
        children: [
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // Check if this is a reply to a shared article
                if (message['replyTo'] != null &&
                    message['replyTo']['isSharedArticle'] == true) ...[
                  _buildReplyToSharedArticle(message, index),
                  const SizedBox(height: 8),
                ],

                // Check if it's a shared article
                if (message['isSharedArticle'] == true)
                  _buildOwnSharedArticle(message, index)
                else if (message['isHighlightedContent'] == true)
                  _buildOwnHighlightedContent(message, index)
                else if (message['isSharedEntry'] == true)
                  _buildOwnSharedEntry(message, index)
                else if (message['isImportantMessage'] == true)
                  _buildOwnImportantMessage(message, index)
                else
                  Container(
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.75,
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                        color: message['quickReplyColor'] ??
                            const Color(0xFF007DB9),
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(18),
                          topRight: Radius.circular(4),
                          bottomLeft: Radius.circular(18),
                          bottomRight: Radius.circular(18),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 2,
                            offset: const Offset(0, 1),
                          ),
                        ]),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          message['message'] ?? '',
                          style: const TextStyle(
                              color: Colors.white, fontSize: 16),
                        ),
                        if (message['tags'] != null &&
                            message['tags'].isNotEmpty)
                          _buildOwnMessageTags(message['tags']),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOwnSharedArticle(Map<String, dynamic> message, int index) {
    // Removed unused variables

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Color(0xFFEF2D56).withOpacity(0.1),
        borderRadius: BorderRadius.all(Radius.circular(20)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            message['articleTitle'] ?? 'Article Title',
            style: const TextStyle(
              color: Color(0xFF172B75),
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.right,
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'read..',
                style: TextStyle(
                  color: Color(0xFF4A4A4A),
                  fontSize: 12,
                ),
              ),
              const SizedBox(width: 16),
              Text(
                'reply',
                style: TextStyle(
                  color: Color(0xFF4A4A4A),
                  fontSize: 12,
                ),
              ),
              if (message['replies'] != null &&
                  message['replies'].isNotEmpty) ...[
                const SizedBox(width: 16),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${message['replies'].length} replies',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSharedEntry(Map<String, dynamic> message, int index) {
    final sharedEntry = message['sharedEntry'] ?? {};
    final title = sharedEntry['title'] ?? 'Shared Entry';
    final body = sharedEntry['body'] ?? '';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 40.0, bottom: 10),
          child: Text(
            'shared entry',
            style: TextStyle(
                color: Colors.black, fontSize: 12, fontWeight: FontWeight.w400),
          ),
        ),
        Container(
          margin: EdgeInsets.only(right: 76, left: 23),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: const Color(0xFF714FC0).withOpacity(0.1),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(0),
              topRight: Radius.circular(20),
              bottomLeft: Radius.circular(20),
              bottomRight: Radius.circular(20),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Color(0xFF172B75),
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
              if (body.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  body,
                  style: const TextStyle(
                    color: Color(0xFF4A4A4A),
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              const SizedBox(height: 8),
              Row(
                children: [
                  Text(
                    'read..',
                    style: TextStyle(
                      color: Color(0xFF4A4A4A),
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    'reply',
                    style: TextStyle(
                      color: Color(0xFF4A4A4A),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildOwnImportantMessage(Map<String, dynamic> message, int index) {
    return Container(
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width * 0.75,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Important header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              color: Color(0xFFFFC746),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Center(
              child: const Text(
                'important',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ),
          // Message content
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF3F6F6),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
            ),
            child: Text(
              message['message'] ?? '',
              style: const TextStyle(
                color: Color(0xFF4A4A4A),
                fontSize: 12,
                height: 1,
                fontWeight: FontWeight.w400,
              ),
              softWrap: true,
              overflow: TextOverflow.visible,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOwnHighlightedContent(Map<String, dynamic> message, int index) {
    // Get shared entry data if available
    final sharedEntry = message['sharedEntry'] ?? {};
    final title =
        sharedEntry['title'] ?? message['highlightedTitle'] ?? 'Shared Content';
    final body = sharedEntry['body'] ?? message['highlightedSummary'] ?? '';

    return Container(
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width * 0.75,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Highlighted content header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: message['highlightedColor'] ?? const Color(0xFF714FC0),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Center(
              child: const Text(
                'highlighted content',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ),
          // Content
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Color(0xFFF3F6F6),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // Title
                Text(
                  title,
                  style: const TextStyle(
                    color: Color(0xFF172B75),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.right,
                  softWrap: true,
                  overflow: TextOverflow.visible,
                ),
                if (body.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  // Summary/Content
                  Text(
                    body,
                    style: const TextStyle(
                      color: Color(0xFF4A4A4A),
                      fontWeight: FontWeight.w400,
                      fontSize: 12,
                      height: 1.4,
                    ),
                    textAlign: TextAlign.right,
                    softWrap: true,
                    overflow: TextOverflow.visible,
                    maxLines: 5, // Limit to 5 lines to prevent excessive height
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOwnSharedEntry(Map<String, dynamic> message, int index) {
    final sharedEntry = message['sharedEntry'] ?? {};
    final title = sharedEntry['title'] ?? 'Shared Entry';
    final body = sharedEntry['body'] ?? '';

    return Container(
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width * 0.75,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF714FC0).withOpacity(0.1),
        borderRadius: BorderRadius.all(Radius.circular(20)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Color(0xFF172B75),
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.right,
          ),
          if (body.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              body,
              style: const TextStyle(
                color: Color(0xFF4A4A4A),
                fontSize: 12,
                fontWeight: FontWeight.w400,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.right,
            ),
          ],
          const SizedBox(height: 8),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'read..',
                style: TextStyle(
                  color: Color(0xFF4A4A4A),
                  fontSize: 12,
                ),
              ),
              const SizedBox(width: 16),
              Text(
                'reply',
                style: TextStyle(
                  color: Color(0xFF4A4A4A),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

// Add this new method after _buildOwnSharedArticle method
  Widget _buildReplyToSharedArticle(Map<String, dynamic> message, int index) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Color(0xFFEF2D56).withOpacity(0.5),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(0),
              topRight: Radius.circular(16),
              bottomLeft: Radius.circular(16),
              bottomRight: Radius.circular(16),
            ),
          ),
          child: Text(
            message['replyTo']['articleTitle'],
            style: TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w400,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(right: 15.0),
          child: Text("replied",
              style: TextStyle(
                color: Color(0xFF4A4A4A),
                fontSize: 12,
                fontWeight: FontWeight.w400,
              )),
        )
      ],
    );
  }

  Widget _buildOwnMessageTags(List<String> tags) {
    return Wrap(
      spacing: 4,
      children: tags.map((tag) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            '@$tag',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildQuickReplyButton(String text, Color color) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          controller.sendQuickReplyMessage(text, color);
        },
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 2),
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w400,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
    );
  }

  Widget _buildQuickReplyButtons() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 16),
      child: Column(
        children: [
          // Row 1
          Row(
            children: [
              _buildQuickReplyButton('yup', Color(0xFF0B85A5)),
              _buildQuickReplyButton('facts', Color(0xFFDE99AC)),
              _buildQuickReplyButton('same', Color(0xFFF9A068)),
              _buildQuickReplyButton('ofc', Color(0xFF6B5D7A)),
              _buildQuickReplyButton('true', Color(0xFF5C4A9B)),
              _buildQuickReplyButton('words', Color(0xFFCF455F)),
            ],
          ),
          const SizedBox(height: 8),
          // Row 2
          Row(
            children: [
              _buildQuickReplyButton('link ?', Color(0xFFFE9527)),
              _buildQuickReplyButton('sure ?', Color(0xFFFDB456)),
              _buildQuickReplyButton('chill', Color(0xFF19A699)),
              _buildQuickReplyButton('bruh', Color(0xFFF36E65)),
              _buildQuickReplyButton('skipp', Color(0xFF1873E1)),
              _buildQuickReplyButton('paas', Color(0xFF3E5E7A)),
            ],
          ),
          const SizedBox(height: 8),
          // Row 3
          Row(
            children: [
              _buildQuickReplyButton('okie', Color(0xFF4AAA7E)),
              _buildQuickReplyButton('wait', Color(0xFFD57851)),
              _buildQuickReplyButton('damn', Color(0xFF2D80CD)),
              _buildQuickReplyButton('oof', Color(0xFFDF8B97)),
              _buildQuickReplyButton('aye', Color(0xFF61C197)),
              _buildQuickReplyButton('wow', Color(0xFFDA7D53)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.only(left: 10, bottom: 20, top: 10, right: 10),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              _showQuickReplies.value = !_showQuickReplies.value;
            },
            child: Obx(() => Icon(
                  _showQuickReplies.value
                      ? Iconsax.arrow_down_1
                      : Iconsax.arrow_up_2,
                  color: _showQuickReplies.value
                      ? Color(0xFFFFA000)
                      : Color(0xFF172B75),
                  size: 30,
                )),
          ),
          SizedBox(width: ScreenUtils.width * 0.02),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Color(0xFFF3F6F6),
                borderRadius: BorderRadius.all(Radius.circular(12)),
              ),
              child: TextField(
                controller: controller.messageController,
                enabled: true,
                style: TextStyle(
                  color: Colors.black,
                ),
                maxLines: null,
                textInputAction: TextInputAction.newline,
                onChanged: (value) {
                  controller
                      .onTextChanged(value); // Add typing indicator support
                  // Removed setState to prevent screen refresh
                },
                decoration: InputDecoration(
                  hintText: "Write your message",
                  hintStyle: TextStyle(
                    color: Color(0xFF9E9E9E),
                  ),
                  border: InputBorder.none,
                  suffixIcon: GestureDetector(
                    onTap: () {
                      if (controller.messageController.text.trim().isNotEmpty) {
                        controller.sendMessage();
                      }
                    },
                    child: Container(
                      margin: const EdgeInsets.all(8),
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(0xFFFFA000),
                          width: 1,
                        ),
                      ),
                      child: const Align(
                        alignment: Alignment.center,
                        child: Icon(
                          Iconsax.arrow_up_3,
                          color: Color(0xFFFFA000),
                          size: 24,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImportantMessage(Map<String, dynamic> message, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16, right: 46),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF), // Yellow background like in the image
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Important header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              color: Color(0xFFFFC746),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Center(
              child: const Text(
                'important',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ),
          // Message content
          SizedBox(
            height: 10,
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Color(0xFFF3F6F6),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              message['message'] ?? '',
              style: const TextStyle(
                color: Color(0xFF4A4A4A), // Black text like in the image
                fontSize: 12,
                height: 1,
                fontWeight: FontWeight.w400,
              ),
              softWrap: true,
              overflow: TextOverflow.visible,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHighlightedContent(Map<String, dynamic> message, int index) {
    // Get shared entry data if available
    final sharedEntry = message['sharedEntry'] ?? {};
    final title =
        sharedEntry['title'] ?? message['highlightedTitle'] ?? 'Shared Content';
    final body = sharedEntry['body'] ?? message['highlightedSummary'] ?? '';

    return Container(
      margin: const EdgeInsets.only(bottom: 16, right: 46),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Highlighted content header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: message['highlightedColor'] ?? const Color(0xFF714FC0),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Center(
              child: const Text(
                'highlighted content',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ),
          SizedBox(
            height: 10,
          ),
          // Content
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF3F6F6),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                Text(
                  title,
                  style: const TextStyle(
                    color: Color(0xFF172B75),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                  softWrap: true,
                  overflow: TextOverflow.visible,
                ),
                if (body.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  // Summary/Content
                  Text(
                    body,
                    style: const TextStyle(
                      color: Color(0xFF4A4A4A),
                      fontWeight: FontWeight.w400,
                      fontSize: 12,
                      height: 1.4,
                    ),
                    softWrap: true,
                    overflow: TextOverflow.visible,
                    maxLines: 5, // Limit to 5 lines to prevent excessive height
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResults() {
    return Obx(() {
      final searchQuery = _searchController.text.trim().toLowerCase();

      // Use real search results from controller
      final filteredResults = controller.searchResults;

      // If no topic-scoped results, but cross-category results exist, show them
      if (filteredResults.isEmpty && controller.hasCrossCategoryResults.value) {
        final cross = controller.crossCategoryResults;
        return Container(
          margin: EdgeInsets.only(left: 25, right: 24),
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFFFFFFFF),
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(5),
              bottomRight: Radius.circular(5),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Row(
                  children: const [
                    Icon(Icons.article, size: 16, color: Color(0xFF714FC0)),
                    SizedBox(width: 8),
                    Text('News',
                        style: TextStyle(
                            color: Color(0xFF714FC0),
                            fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
              ...cross.map((result) {
                return GestureDetector(
                    onTap: () => _shareEntryContent(result),
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.only(
                          left: 28, top: 5, bottom: 5, right: 28),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFFFFF),
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(12),
                          bottomRight: Radius.circular(12),
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: RichText(
                              text: TextSpan(
                                style: const TextStyle(
                                  color: Color(0xFF797C7B),
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                                children: _buildHighlightedText(
                                  result['title'] ?? '',
                                  searchQuery,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ));
              }).toList(),
            ],
          ),
        );
      }

      // Default: show topic-scoped results (and optionally cross-category below)
      return Container(
        margin: EdgeInsets.only(left: 25, right: 24),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: const Color(0xFFFFFFFF),
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(5),
            bottomRight: Radius.circular(5),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ...filteredResults.map((result) {
              return GestureDetector(
                  onTap: () => _shareEntryContent(result),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.only(
                        left: 28, top: 5, bottom: 5, right: 28),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFFFFF),
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(12),
                        bottomRight: Radius.circular(12),
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: RichText(
                            text: TextSpan(
                              style: const TextStyle(
                                color: Color(0xFF797C7B),
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                              children: _buildHighlightedText(
                                result['title'] ?? '',
                                searchQuery,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ));
            }).toList(),
            if (controller.hasCrossCategoryResults.value) ...[
              const SizedBox(height: 6),
              const Divider(),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Row(
                  children: const [
                    Icon(Icons.article, size: 16, color: Color(0xFF714FC0)),
                    SizedBox(width: 8),
                    Text('News',
                        style: TextStyle(
                            color: Color(0xFF714FC0),
                            fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
              ...controller.crossCategoryResults.map((result) {
                return GestureDetector(
                    onTap: () => _shareEntryContent(result),
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.only(
                          left: 28, top: 5, bottom: 5, right: 28),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFFFFF),
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(12),
                          bottomRight: Radius.circular(12),
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: RichText(
                              text: TextSpan(
                                style: const TextStyle(
                                  color: Color(0xFF797C7B),
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                                children: _buildHighlightedText(
                                  result['title'] ?? '',
                                  searchQuery,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ));
              }).toList(),
            ]
          ],
        ),
      );
    });
  }

  List<TextSpan> _buildHighlightedText(String text, String highlight) {
    final List<TextSpan> spans = [];
    final String lowerText = text.toLowerCase();
    final String lowerHighlight = highlight.toLowerCase();

    int start = 0;
    while (true) {
      final int index = lowerText.indexOf(lowerHighlight, start);
      if (index == -1) {
        spans.add(TextSpan(
          text: text.substring(start),
          style: TextStyle(
            color: Color(0xFF797C7B),
            fontSize: 14,
            fontWeight: FontWeight.w300,
          ),
        ));
        break;
      }

      if (index > start) {
        spans.add(TextSpan(
          text: text.substring(start, index),
          style: TextStyle(
            color: Color(0xFF797C7B),
            fontSize: 14,
            fontWeight: FontWeight.w300,
          ),
        ));
      }

      spans.add(TextSpan(
        text: text.substring(index, index + highlight.length),
        style: TextStyle(
          color: Color(0xFF714FC0),
          fontSize: 14,
          fontWeight: FontWeight.w400,
        ),
      ));

      start = index + highlight.length;
    }

    return spans;
  }

  Future<void> _shareEntryContent(Map<String, dynamic> entry) async {
    final entryId = entry['_id'] ?? '';
    final title = entry['title'] ?? '';

    // Create a message with the entry title
    final message = 'Check this out: $title';

    // Share the entry
    // Ensure controller has the correct category/subcategory/topic IDs
    try {
      String? mainId = entry['mainCategoryId'] ??
          entry['parentMainCategoryId'] ??
          entry['categoryId'];
      String? subId = entry['subCategoryId'] ?? entry['parentSubCategoryId'];
      String? topicId = entry['topicId'] ?? entry['parentTopicId'];

      // If any of the required IDs are missing, try fetching entry content to retrieve parent IDs
      if ((mainId == null || mainId.toString().isEmpty) ||
          (subId == null || subId.toString().isEmpty) ||
          (topicId == null || topicId.toString().isEmpty)) {
        try {
          print(
              '🔎 [MESSAGE SCREEN] Missing parent IDs on selected entry, fetching full entry content for entryId=$entryId');
          final learnService = Get.find<LearnService>();
          final resp = await learnService.getEntryContent(entryId.toString());

          if (resp.success && resp.data != null) {
            final data = resp.data!;
            // Try multiple possible field names the backend may provide
            mainId = mainId ??
                data['parentMainCategoryId'] ??
                data['mainCategoryId'] ??
                data['mainCategory']?['_id'];
            subId = subId ??
                data['parentSubCategoryId'] ??
                data['subCategoryId'] ??
                data['subCategory']?['_id'];
            topicId = topicId ??
                data['parentTopicId'] ??
                data['topicId'] ??
                data['topic']?['_id'];
            print(
                '🔎 [MESSAGE SCREEN] Fetched parent IDs: main=$mainId, sub=$subId, topic=$topicId');
          } else {
            print(
                '⚠️ [MESSAGE SCREEN] getEntryContent returned no usable data for entryId=$entryId; message=${resp.message}');

            // Additional fallback: try to locate entry in NewsController in-memory articles
            try {
              NewsController newsController;
              try {
                newsController = Get.find<NewsController>();
                print(
                    '🔎 [MESSAGE SCREEN] Found existing NewsController for fallback lookup');
              } catch (_) {
                print(
                    '🔎 [MESSAGE SCREEN] Creating NewsController for fallback lookup');
                newsController =
                    Get.put(NewsController(), tag: 'share-fallback');
              }

              // Try to find by _id first
              Map<String, dynamic> matched = {};
              if (newsController.newsArticles.isNotEmpty) {
                matched = newsController.newsArticles.firstWhere(
                    (a) => (a['_id']?.toString() ?? '') == entryId.toString(),
                    orElse: () => <String, dynamic>{});
                if (matched.isEmpty) {
                  // Try title match as a fallback (loose)
                  final titleLower = title.toString().toLowerCase();
                  matched = newsController.newsArticles.firstWhere(
                      (a) => (a['title']?.toString().toLowerCase() ?? '')
                          .contains(titleLower),
                      orElse: () => <String, dynamic>{});
                }
              }

              if (matched.isNotEmpty) {
                print(
                    '🔎 [MESSAGE SCREEN] Matched entry in NewsController fallback: ${matched['title']}');
                mainId = mainId ??
                    matched['parentMainCategoryId'] ??
                    newsController.categoryId ??
                    matched['categoryId'];
                subId = subId ??
                    matched['parentSubCategoryId'] ??
                    newsController.subCategoryId ??
                    matched['subCategoryId'];
                topicId = topicId ??
                    matched['parentTopicId'] ??
                    newsController.topicId ??
                    matched['topicId'];
                print(
                    '🔎 [MESSAGE SCREEN] Inferred parent IDs from NewsController: main=$mainId, sub=$subId, topic=$topicId');
              } else {
                print(
                    '⚠️ [MESSAGE SCREEN] No matching entry found in NewsController for fallback');
              }
            } catch (e2) {
              print('⚠️ [MESSAGE SCREEN] NewsController fallback failed: $e2');
            }
          }
        } catch (e) {
          print('⚠️ [MESSAGE SCREEN] Failed to fetch entry content: $e');

          // Additional fallback: try to locate entry in NewsController in-memory articles
          try {
            NewsController newsController;
            try {
              newsController = Get.find<NewsController>();
              print(
                  '🔎 [MESSAGE SCREEN] Found existing NewsController for fallback lookup');
            } catch (_) {
              print(
                  '🔎 [MESSAGE SCREEN] Creating NewsController for fallback lookup');
              newsController = Get.put(NewsController(), tag: 'share-fallback');
            }

            // Try to find by _id first
            Map<String, dynamic> matched = {};
            if (newsController.newsArticles.isNotEmpty) {
              matched = newsController.newsArticles.firstWhere(
                  (a) => (a['_id']?.toString() ?? '') == entryId.toString(),
                  orElse: () => <String, dynamic>{});
              if (matched.isEmpty) {
                // Try title match as a fallback (loose)
                final titleLower = title.toString().toLowerCase();
                matched = newsController.newsArticles.firstWhere(
                    (a) => (a['title']?.toString().toLowerCase() ?? '')
                        .contains(titleLower),
                    orElse: () => <String, dynamic>{});
              }
            }

            if (matched.isNotEmpty) {
              print(
                  '🔎 [MESSAGE SCREEN] Matched entry in NewsController fallback: ${matched['title']}');
              mainId = mainId ??
                  matched['parentMainCategoryId'] ??
                  newsController.categoryId ??
                  matched['categoryId'];
              subId = subId ??
                  matched['parentSubCategoryId'] ??
                  newsController.subCategoryId ??
                  matched['subCategoryId'];
              topicId = topicId ??
                  matched['parentTopicId'] ??
                  newsController.topicId ??
                  matched['topicId'];
              print(
                  '🔎 [MESSAGE SCREEN] Inferred parent IDs from NewsController: main=$mainId, sub=$subId, topic=$topicId');
            } else {
              print(
                  '⚠️ [MESSAGE SCREEN] No matching entry found in NewsController for fallback');
            }
          } catch (e2) {
            print('⚠️ [MESSAGE SCREEN] NewsController fallback failed: $e2');
          }

          // Additional fallback: try cross-category search by title to locate parent IDs
          if ((mainId == null || mainId.toString().isEmpty) ||
              (subId == null || subId.toString().isEmpty) ||
              (topicId == null || topicId.toString().isEmpty)) {
            try {
              print(
                  '🔎 [MESSAGE SCREEN] Trying cross-category search fallback with title query: "$title"');
              final learnService2 = Get.find<LearnService>();
              final crossResp =
                  await learnService2.searchCrossCategory(title.toString());
              if (crossResp.success && crossResp.data != null) {
                final data = crossResp.data!;
                final results = (data['results'] as List<dynamic>?)
                        ?.cast<Map<String, dynamic>>() ??
                    [];
                print(
                    '🔎 [MESSAGE SCREEN] Cross-category search returned ${results.length} items');
                Map<String, dynamic> matchedCross = {};
                if (results.isNotEmpty) {
                  matchedCross = results.firstWhere(
                      (r) =>
                          (r['_id']?.toString() ?? '') == entryId.toString() ||
                          (r['title']?.toString() ?? '').toLowerCase() ==
                              title.toString().toLowerCase(),
                      orElse: () => <String, dynamic>{});
                }

                if (matchedCross.isNotEmpty) {
                  print(
                      '🔎 [MESSAGE SCREEN] Matched entry in cross-category results: ${matchedCross['title']}');
                  mainId = mainId ??
                      matchedCross['parentMainCategoryId'] ??
                      matchedCross['mainCategoryId'] ??
                      matchedCross['categoryId'];
                  subId = subId ??
                      matchedCross['parentSubCategoryId'] ??
                      matchedCross['subCategoryId'] ??
                      matchedCross['subcategoryId'] ??
                      matchedCross['subCategory']?['_id'];
                  topicId = topicId ??
                      matchedCross['parentTopicId'] ??
                      matchedCross['topicId'] ??
                      matchedCross['topic']?['_id'];
                  print(
                      '🔎 [MESSAGE SCREEN] Inferred parent IDs from cross-category: main=$mainId, sub=$subId, topic=$topicId');
                } else {
                  print(
                      '⚠️ [MESSAGE SCREEN] No match found in cross-category results for entryId=$entryId');
                }
              } else {
                print(
                    '⚠️ [MESSAGE SCREEN] Cross-category search returned no data for query: "$title"');
              }
            } catch (e3) {
              print('⚠️ [MESSAGE SCREEN] Cross-category fallback failed: $e3');
            }
          }
        }
      }

      // If still missing required IDs, abort and inform user
      if (mainId == null ||
          mainId.toString().isEmpty ||
          subId == null ||
          subId.toString().isEmpty ||
          topicId == null ||
          topicId.toString().isEmpty) {
        print(
            '❌ [MESSAGE SCREEN] Cannot share entry: missing category/topic metadata after fallbacks');
        Get.snackbar('Cannot share',
            'This item cannot be shared because category metadata is missing.',
            snackPosition: SnackPosition.TOP, backgroundColor: Colors.red);
        return;
      }

      if (mainId.toString().isNotEmpty) {
        controller.categoryId.value = mainId.toString();
      }
      if (subId.toString().isNotEmpty) {
        controller.subCategoryId.value = subId.toString();
      }
      if (topicId.toString().isNotEmpty) {
        controller.topicId.value = topicId.toString();
      }

      print(
          '🔁 [MESSAGE SCREEN] Set controller IDs from selected entry: main=${controller.categoryId.value}, sub=${controller.subCategoryId.value}, topic=${controller.topicId.value}');
    } catch (e) {
      print('⚠️ [MESSAGE SCREEN] Failed to set controller IDs from entry: $e');
    }

    // Now call shareEntry (it will validate IDs and show a user-friendly error if missing)
    await controller.shareEntry(
      message: message,
      entryId: entryId,
    );

    // Close the search overlay after sharing
    setState(() {
      _showSearchOverlay = false;
      _searchController.clear();
      controller.searchResults.clear();
    });
  }

  void _updateSearchText(String value) {
    controller.updateSearchText(value);
    setState(() {});
  }

  void _clearSearch() {
    _searchController.clear();
    controller.clearSearch();
  }

  // Add this method to calculate dynamic height in steps
}

class _DottedCirclePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF714FC0)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 1;

    // Draw long dashed circle
    for (int i = 0; i < 360; i += 30) {
      // Increased gap from 15 to 30
      final angle = i * (3.14159 / 180);
      final dashLength = 20 * (3.14159 / 180); // Longer dash length

      final startPoint = Offset(
        center.dx + radius * cos(angle),
        center.dy + radius * sin(angle),
      );
      final endPoint = Offset(
        center.dx + radius * cos(angle + dashLength),
        center.dy + radius * sin(angle + dashLength),
      );
      canvas.drawLine(startPoint, endPoint, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
