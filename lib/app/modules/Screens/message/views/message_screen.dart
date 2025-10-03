import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:vropay_final/Components/back_icon.dart';
import 'package:vropay_final/Utilities/constants/KImages.dart';
import 'package:vropay_final/Utilities/screen_utils.dart';
import 'package:vropay_final/app/modules/Screens/message/controllers/message_controller.dart';
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
  bool _showQuickReplies = false;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    controller.setScrollCallback(() {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _importantMessageController.dispose();
    _searchController.dispose(); // Add this
    _scrollController.dispose();
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
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            controller.interestName.value,
                            style: TextStyle(
                              fontSize: 22,
                              color: const Color(0xFFCC415D),
                              fontWeight: FontWeight.w300,
                            ),
                          ),
                          SizedBox(width: ScreenUtils.width * 0.02),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "\n${controller.memberCount.value} members",
                                style: TextStyle(
                                  fontSize: 10,
                                  color: const Color(0xFF616161),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              // Connection status indicator (can be hidden in production)
                              if (controller.isRealTimeActive)
                                Text(
                                  "● Live",
                                  style: TextStyle(
                                    fontSize: 8,
                                    color: const Color(0xFF4CAF50),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              // Permission status indicator
                              Container(
                                margin: EdgeInsets.only(top: 2),
                                padding: EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 1),
                                decoration: BoxDecoration(
                                  color: Color(0xFF4CAF50).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: Color(0xFF4CAF50),
                                    width: 0.5,
                                  ),
                                ),
                                child: Text(
                                  "Open chat",
                                  style: TextStyle(
                                    fontSize: 7,
                                    color: Color(0xFF4CAF50),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                      actions: [
                        Obx(() => controller.canSendMessages.value
                            ? Padding(
                                padding:
                                    const EdgeInsets.only(right: 20.0, top: 15),
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
                                    const EdgeInsets.only(right: 29.0, top: 15),
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
                // Loading indicator
                Obx(() => controller.isLoading.value
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

                // Chat messages
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final message = controller.messages[index];
                      if (message['isOwnMessage'] == true) {
                        return Padding(
                          padding: EdgeInsets.only(
                            top: 10,
                            right: 20,
                          ),
                          child: _buildOwnMessage(message, index),
                        );
                      } else {
                        return Padding(
                          padding: EdgeInsets.only(
                            left: 20,
                          ),
                          child: _buildMessageItem(message, index),
                        );
                      }
                    },
                    childCount: controller.messages.length,
                  ),
                ),
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
                // Load more button
                SliverToBoxAdapter(
                  child: Obx(() => controller.hasNextPage
                      ? Container(
                          padding: const EdgeInsets.all(16),
                          child: Center(
                            child: ElevatedButton(
                              onPressed: () => controller.loadMoreMessages(),
                              child: const Text('Load More Messages'),
                            ),
                          ),
                        )
                      : const SizedBox.shrink()),
                ),
              ],
            ),

            // Fixed Message Input Area at Bottom
            Obx(
              () => controller.canSendMessages.value
                  ? Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        color: Colors.white,
                        padding: EdgeInsets.only(
                          bottom: MediaQuery.of(context).padding.bottom,
                          top: 8,
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Divider(
                              color: Color(0xFF01B3B2).withOpacity(0.5),
                            ),
                            // Quick reply buttons above message input
                            if (_showQuickReplies) _buildQuickReplyButtons(),
                            // Message input field
                            Padding(
                              padding:
                                  const EdgeInsets.only(left: 10, right: 10),
                              child: _buildMessageInput(),
                            ),
                          ],
                        ),
                      ),
                    )
                  : const SizedBox.shrink(),
            ),

            // Important Message Overlay
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
                                    SizedBox(
                                        height: ScreenUtils.height * 0.005),

                                    // Message Input Field with Send Button Inside
                                    Container(
                                      constraints: BoxConstraints(
                                        minHeight: ScreenUtils.height * 0.02,
                                        maxHeight: ScreenUtils.height * 0.7,
                                      ),
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                          color: Color(0xFFD9D9D9),
                                          borderRadius:
                                              BorderRadius.circular(8)),
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
                                            keyboardType:
                                                TextInputType.multiline,
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
                                            onChanged: (value) =>
                                                setState(() {}),
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
                                                  if (_importantMessageController
                                                      .text
                                                      .trim()
                                                      .isNotEmpty) {
                                                    setState(() {
                                                      _showConfirmationOptions =
                                                          true;
                                                    });
                                                  }
                                                },
                                                child: Container(
                                                  height: 30,
                                                  width: 30,
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8),
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
                                          // // Hint text below the TextField
                                          // if (_importantMessageController
                                          //     .text.isEmpty)
                                          //   Padding(
                                          //     padding:
                                          //         const EdgeInsets.only(top: 8),
                                          //     child: RichText(
                                          //       text: TextSpan(
                                          //         children: [
                                          //           TextSpan(
                                          //             text:
                                          //                 'Write your message\n',
                                          //             style: TextStyle(
                                          //               color:
                                          //                   Color(0xFF797C7B),
                                          //               fontSize: 12,
                                          //               fontWeight:
                                          //                   FontWeight.w400,
                                          //             ),
                                          //           ),
                                          //           TextSpan(
                                          //             text: 'upto 100 words',
                                          //             style: TextStyle(
                                          //               color:
                                          //                   Color(0xFFFFA000),
                                          //               fontSize: 10,
                                          //               fontWeight:
                                          //                   FontWeight.w400,
                                          //             ),
                                          //           ),
                                          //         ],
                                          //       ),
                                          //     ),
                                          //   ),
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
                                              controller.sendImportantMessage(
                                                _importantMessageController.text
                                                    .trim(),
                                              );
                                              setState(() {
                                                _showImportantMessage = false;
                                                _importantMessageController
                                                    .clear();
                                                _showConfirmationOptions =
                                                    false;
                                              });
                                              controller.disableBlurEffect();
                                            },
                                            child: Container(
                                              height: 52,
                                              width: ScreenUtils.width * 0.2,
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 8,
                                                      horizontal: 12),
                                              decoration: BoxDecoration(
                                                color: Color(0xFFFFC746),
                                                borderRadius: BorderRadius.only(
                                                  topLeft: Radius.circular(20),
                                                  bottomLeft:
                                                      Radius.circular(20),
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
                                              controller.sendNormalMessage(
                                                _importantMessageController.text
                                                    .trim(),
                                              );
                                              setState(() {
                                                _showImportantMessage = false;
                                                _importantMessageController
                                                    .clear();
                                                _showConfirmationOptions =
                                                    false;
                                              });
                                              controller.disableBlurEffect();
                                            },
                                            child: Container(
                                              height: 52,
                                              width: ScreenUtils.width * 0.2,
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 8,
                                                      horizontal: 12),
                                              decoration: BoxDecoration(
                                                color: Color(0xFFFFFFFF),
                                                borderRadius: BorderRadius.only(
                                                  topLeft: Radius.circular(0),
                                                  bottomLeft:
                                                      Radius.circular(20),
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
                                          TextField(
                                            controller: _searchController,
                                            autofocus: true,
                                            decoration: InputDecoration(
                                              hintText:
                                                  'Try searching the relevant keyword',
                                              hintStyle: const TextStyle(
                                                  color: Color(0xFF797C7B),
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w300),
                                              prefixIcon: Image.asset(
                                                  KImages.searchIcon),
                                              border: InputBorder.none,
                                              contentPadding:
                                                  EdgeInsets.symmetric(
                                                      horizontal: 20,
                                                      vertical: 15),
                                            ),
                                            onChanged: (value) {
                                              setState(() {});
                                            },
                                            onSubmitted: (_) =>
                                                _performSearch(),
                                          ),
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
        ));
  }

  int _calculateMaxLines(String text) {
    // Count actual lines (including line breaks from Enter key)
    int actualLines = text.split('\n').length;

    // Set minimum and maximum bounds
    if (actualLines < 2) return 2;
    if (actualLines > 6) return 6;
    if (actualLines > 8) return 8;
    if (actualLines > 10) return 10;
    if (actualLines > 12) return 12;
    return actualLines;
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

  Widget _buildTaggedUsers() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Wrap(
        spacing: 8,
        children: controller.taggedUsers.map((username) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: const BoxDecoration(
              color: Color(0xFF2196F3),
              borderRadius: BorderRadius.all(Radius.circular(12)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '@$username',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(width: 4),
                GestureDetector(
                  onTap: () => controller.removeTag(username),
                  child: const Icon(
                    Icons.close,
                    color: Colors.white,
                    size: 14,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildMessageItem(Map<String, dynamic> message, int index) {
    final uniqueKey = GlobalKey();
    final messages = controller.messages;
    final isFirstMessage = index == 0;
    final isPreviousFromSameUser =
        !isFirstMessage && messages[index - 1]['sender'] == message['sender'];

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Only show avatar if it's the first message from this user
          if (!isPreviousFromSameUser)
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
                if (!isPreviousFromSameUser) ...[
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
                else if (message['isImportantMessage'] == true)
                  _buildImportantMessage(message, index)
                else if (message['isHighlightedContent'] == true)
                  _buildHighlightedContent(message, index)
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
    final messages = controller.messages;
    final isFirstMessage = index == 0;
    final isPreviousFromSameUser =
        !isFirstMessage && messages[index - 1]['sender'] == message['sender'];

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

  Widget _buildRepliesIndicator(Map<String, dynamic> message) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.reply,
                size: 16,
                color: Colors.grey[600],
              ),
              const SizedBox(width: 6),
              Text(
                '${message['replies'].length} replies',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          if (message['isSharedArticle'] == true) ...[
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.article,
                    size: 14,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      '${message['sender']} shared: ${message['articleTitle']}',
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
          ],
        ],
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
    final messages = controller.messages;
    final isFirstMessage = index == 0;
    final isPreviousFromSameUser =
        !isFirstMessage && messages[index - 1]['sender'] == message['sender'];

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Align(
        alignment: Alignment.centerRight,
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
            else
              Container(
                margin: EdgeInsets.only(left: 154),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                    color:
                        message['quickReplyColor'] ?? const Color(0xFF007DB9),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(0),
                      bottomLeft: Radius.circular(20),
                      bottomRight: Radius.circular(20),
                    )),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      message['message'] ?? '',
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                    ),
                    if (message['tags'] != null && message['tags'].isNotEmpty)
                      _buildOwnMessageTags(message['tags']),
                  ],
                ),
              ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _buildOwnSharedArticle(Map<String, dynamic> message, int index) {
    final messages = controller.messages;
    final isFirstMessage = index == 0;
    final isPreviousFromSameUser =
        !isFirstMessage && messages[index - 1]['sender'] == message['sender'];

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

  String _formatTimestamp(DateTime? timestamp) {
    if (timestamp == null) return '';
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
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
              setState(() {
                _showQuickReplies = !_showQuickReplies;
              });
            },
            child: Icon(
              _showQuickReplies ? Iconsax.arrow_down_1 : Iconsax.arrow_up_2,
              color: _showQuickReplies ? Color(0xFFFFA000) : Color(0xFF172B75),
              size: 30,
            ),
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
                  setState(() {}); // Update UI state
                },
                decoration: InputDecoration(
                  hintText: "Write your message",
                  hintStyle: TextStyle(
                    color: Color(0xFF9E9E9E),
                  ),
                  border: InputBorder.none,
                  suffixIcon: GestureDetector(
                    onTap: controller.messageController.text.trim().isNotEmpty
                        ? controller.sendMessage
                        : null,
                    child: Container(
                      margin: const EdgeInsets.all(8),
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: controller.messageController.text
                                  .trim()
                                  .isNotEmpty
                              ? const Color(0xFFFFA000)
                              : Color(0xFF9E9E9E),
                          width: 1,
                        ),
                      ),
                      child: Align(
                        alignment: Alignment.center,
                        child: Icon(
                          Iconsax.arrow_up_3,
                          color: controller.messageController.text
                                  .trim()
                                  .isNotEmpty
                              ? const Color(0xFFFFA000)
                              : Color(0xFF9E9E9E),
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
                  message['highlightedTitle'] ?? '',
                  style: const TextStyle(
                    color: Color(0xFF172B75),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                  softWrap: true,
                  overflow: TextOverflow.visible,
                ),
                const SizedBox(height: 12),
                // Summary
                Text(
                  message['highlightedSummary'] ?? '',
                  style: const TextStyle(
                    color: Color(0xFF4A4A4A),
                    fontWeight: FontWeight.w400,
                    fontSize: 12,
                    height: 1,
                  ),
                  softWrap: true,
                  overflow: TextOverflow.visible,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResults() {
    final searchQuery = _searchController.text.trim().toLowerCase();

    // Mock search results - in real app, this would come from API
    final List<Map<String, String>> mockResults = [
      {
        'title': 'Trump Vows Revenge in 2024 Run',
        'highlight': 'Trump',
      },
      {
        'title': 'Court Delays Trump Sentencing Again',
        'highlight': 'Trump',
      },
      {
        'title': 'Trump Slams Biden on Economy',
        'highlight': 'Trump',
      },
      {
        'title': 'Biden Announces New Economic Policy',
        'highlight': 'Biden',
      },
      {
        'title': 'Biden Meets with World Leaders',
        'highlight': 'Biden',
      },
      {
        'title': 'Stock Market Reaches New Highs',
        'highlight': 'Stock',
      },
      {
        'title': 'Stock Trading Volume Increases',
        'highlight': 'Stock',
      },
      {
        'title': 'Technology Stocks Lead Market Rally',
        'highlight': 'Technology',
      },
    ];

    // Filter results based on search query
    final filteredResults = mockResults
        .where((result) => result['title']!.toLowerCase().contains(searchQuery))
        .toList();

    if (filteredResults.isEmpty) {
      return Container(
        margin: EdgeInsets.only(left: 25, right: 24),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(12),
            bottomRight: Radius.circular(12),
          ),
        ),
        child: const Column(
          children: [
            Icon(
              Icons.search_off,
              size: 48,
              color: Color(0xFF797C7B),
            ),
            SizedBox(height: 12),
            Text(
              'No results found',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFF797C7B),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

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
        children: filteredResults.map((result) {
          return GestureDetector(
              onTap: () => _shareContent(result['title']!),
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
                            result['title']!,
                            searchQuery,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ));
        }).toList(),
      ),
    );
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

  void _shareContent(String content) {
    // TODO: Implement actual sharing functionality
    // This could integrate with native sharing, social media APIs, etc.
    Get.snackbar(
      'Share',
      'Sharing: $content',
      backgroundColor: const Color(0xFF714FC0),
      colorText: Colors.white,
      duration: const Duration(seconds: 2),
    );

    // Close the search overlay after sharing
    setState(() {
      _showSearchOverlay = false;
      _searchController.clear();
    });
  }

  void _performSearch() {
    final searchQuery = _searchController.text.trim();
    if (searchQuery.isNotEmpty) {
      // TODO: Implement actual news article search
      // This is where you would connect to your news API or database
      Get.snackbar(
        'Search',
        'Searching for: $searchQuery',
        backgroundColor: const Color(0xFF714FC0),
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );

      // For now, just show a placeholder
      // In the future, you would:
      // 1. Call your news API
      // 2. Display results
      // 3. Allow users to select and share articles
    }
  }

  // Add this method to calculate dynamic height in steps
  double _calculateDynamicHeight(String text) {
    if (text.isEmpty) return ScreenUtils.height * 0.08;

    // Count lines and characters
    int lines = text.split('\n').length;
    int characters = text.length;

    // Base height
    double baseHeight = ScreenUtils.height * 0.08;

    // Add height based on lines (small steps)
    if (lines > 1) {
      baseHeight += (lines - 1) * 20.0; // 20px per additional line
    }

    // Add height based on characters (very small steps)
    if (characters > 50) {
      baseHeight += (characters - 50) * 0.5; // 0.5px per character after 50
    }

    // Cap the maximum height
    double maxHeight = ScreenUtils.height * 0.6;
    return baseHeight.clamp(ScreenUtils.height * 0.05, maxHeight);
  }
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
