import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:noteapp/cubit/get_started_cubit.dart';
import 'package:noteapp/pages/auth/login_page.dart';
import 'package:noteapp/pages/auth/register_page.dart';
import 'package:noteapp/utils/colors.dart';

class GetStartedPage extends StatefulWidget {
  const GetStartedPage({Key? key}) : super(key: key);

  @override
  State<GetStartedPage> createState() => _GetStartedPageState();
}

class _GetStartedPageState extends State<GetStartedPage> {
  final PageController controller = PageController(initialPage: 0);
  final PageIndex pageIndex = PageIndex();
  @override
  void dispose() {
    controller.dispose();
    pageIndex.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F8EE),
      appBar: GetStartedAppBar(
        pageIndex: pageIndex,
        controller: controller,
      ),
      body: SafeArea(
        child: PageView(
          physics: const NeverScrollableScrollPhysics(),
          controller: controller,
          onPageChanged: (index) => pageIndex.setPageIndex(index),
          children: [
            WelcomeScreen(controller: controller),
            GetStarted(controller: controller),
            BlocBuilder<GetStartedCubit, bool>(
              builder: (context, state) {
                return SingleChildScrollView(
                  reverse: true,
                  child: Column(
                    children: [
                      state ? const LoginPage() : const RegisterPage(),
                    ],
                  ),
                );
              },
            )
          ],
        ),
      ),
    );
  }
}

class GetStarted extends StatelessWidget {
  final PageController controller;
  const GetStarted({Key? key, required this.controller}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        children: [
          const SizedBox(height: 30),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                "Make simple\nto do notes",
                textAlign: TextAlign.end,
                style: GoogleFonts.redHatDisplay(fontSize: 48, fontWeight: FontWeight.bold, height: 1.1),
              ),
            ],
          ),
          const SizedBox(height: 50),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              CachedNetworkImage(
                imageUrl: "https://media.tenor.com/inlnJtIOIJUAAAAi/clippy-put.gif",
                height: 200,
                fit: BoxFit.fitWidth,
              ),
            ],
          ),
          const Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                "Plan Your day\nwith ease",
                textAlign: TextAlign.end,
                style: GoogleFonts.redHatDisplay(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  height: 1.1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 55),
          Row(
            children: [
              Expanded(
                child: RoundButton(
                  "Log in",
                  bgColor: AppColors.loginButton,
                  onTap: () {
                    context.read<GetStartedCubit>().setLogin();
                    controller.animateToPage(2, duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
                  },
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: RoundButton(
                  "Register",
                  bgColor: AppColors.registerButton,
                  onTap: () {
                    context.read<GetStartedCubit>().setRegister();
                    controller.animateToPage(2, duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
                  },
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}

class PageIndex extends ChangeNotifier {
  int _pageIndex = 0;

  int get pageIndex => _pageIndex;

  void setPageIndex(int index) {
    _pageIndex = index;
    notifyListeners();
  }
}

class RoundButton extends StatelessWidget {
  final VoidCallback? onTap;
  final Color bgColor;
  final String text;
  final Widget? icon;
  final bool? loading;
  const RoundButton(this.text, {Key? key, required this.bgColor, this.onTap, this.icon, this.loading}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 50,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(99),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            icon != null ? const SizedBox(width: 20) : const SizedBox(),
            loading == true
                ? const SizedBox(
                    height: 27,
                    width: 27,
                    child: CircularProgressIndicator(strokeWidth: 3, color: AppColors.text),
                  )
                : Text(
                    text,
                    style: GoogleFonts.montserrat(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      color: AppColors.text,
                    ),
                  ),
            icon != null ? const SizedBox(width: 5) : const SizedBox(),
            icon ?? const SizedBox(),
          ],
        ),
      ),
    );
  }
}

class WelcomeScreen extends StatelessWidget {
  final PageController controller;
  const WelcomeScreen({Key? key, required this.controller}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 10),
          Text(
            "Good bye\nbook & pen",
            style: GoogleFonts.redHatDisplay(
              fontSize: 50,
              fontWeight: FontWeight.bold,
              letterSpacing: -.5,
              height: 1.1,
            ),
          ),
          const SizedBox(height: 10),
          Flexible(
            flex: 999,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Image.asset(
                  "assets/images/welcome.png",
                  colorBlendMode: BlendMode.darken,
                  color: const Color(0xFFF8F8ED),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Text(
            "Welcome to\nNotes App",
            style: GoogleFonts.redHatDisplay(
              fontSize: 50,
              fontWeight: FontWeight.bold,
              letterSpacing: -.5,
              height: 1.1,
            ),
          ),
          const SizedBox(height: 15),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(
                "Keep all your notes in one place",
                style: GoogleFonts.montserrat(
                  color: Colors.grey.shade500,
                  fontWeight: FontWeight.w500,
                  letterSpacing: -.3,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 40),
          Row(
            children: [
              Expanded(
                child: RoundButton(
                  "Get Started",
                  icon: Animate(
                    effects: const [
                      SlideEffect(
                        duration: Duration(milliseconds: 450),
                        curve: Curves.easeIn,
                        begin: Offset.zero,
                        end: Offset(.3, 0),
                      ),
                    ],
                    delay: const Duration(seconds: 3),
                    onComplete: (controller) {
                      controller
                          .animateBack(
                            0,
                            curve: Curves.easeIn,
                            duration: const Duration(
                              milliseconds: 350,
                            ),
                          )
                          .then(
                            (value) async => await Future.delayed(const Duration(seconds: 3), () {
                              try {
                                controller.forward();
                              } catch (e) {/**/}
                            }),
                          );
                    },
                    child: const Icon(Icons.arrow_forward_ios_rounded, size: 18),
                  ),
                  bgColor: AppColors.loginButton,
                  onTap: () {
                    controller.animateToPage(1, duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
                  },
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}

class GetStartedAppBar extends StatelessWidget implements PreferredSizeWidget {
  final PageController controller;
  final PageIndex pageIndex;
  const GetStartedAppBar({Key? key, required this.controller, required this.pageIndex}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: pageIndex,
      builder: (context, child) => AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Padding(
          padding: const EdgeInsets.only(top: 15.0),
          child: Stack(
            children: [
              GestureDetector(
                onTap: () {
                  if (pageIndex.pageIndex != 0) {
                    controller.animateToPage(pageIndex.pageIndex - 1, duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
                  }
                },
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(0, 8, 8, 8),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.arrow_back_ios_new,
                        color: pageIndex.pageIndex != 0 ? Colors.grey.shade600 : Colors.transparent,
                      ),
                      Text(
                        "Back",
                        style: GoogleFonts.poppins(
                            fontSize: 17, color: pageIndex.pageIndex != 0 ? Colors.grey.shade800 : Colors.transparent, letterSpacing: -1.2),
                      ),
                    ],
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: pageIndex.pageIndex == 0 ? AppColors.loginButton : Colors.grey.shade200,
                    ),
                    child: Text(
                      "1",
                      style: GoogleFonts.montserrat(
                          fontWeight: FontWeight.w600,
                          color: pageIndex.pageIndex == 0 ? Colors.black : AppColors.pageIndicatorInactive,
                          fontSize: 16),
                    ),
                  ),
                  const SizedBox(width: 15),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: pageIndex.pageIndex == 1 ? AppColors.loginButton : Colors.grey.shade200,
                    ),
                    child: Text(
                      "2",
                      style: GoogleFonts.montserrat(
                          fontWeight: FontWeight.w600,
                          color: pageIndex.pageIndex == 1 ? Colors.black : AppColors.pageIndicatorInactive,
                          fontSize: 16),
                    ),
                  ),
                  const SizedBox(width: 15),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: pageIndex.pageIndex == 2 ? AppColors.loginButton : Colors.grey.shade200,
                    ),
                    child: Text(
                      "3",
                      style: GoogleFonts.montserrat(
                          fontWeight: FontWeight.w600,
                          color: pageIndex.pageIndex == 2 ? Colors.black : AppColors.pageIndicatorInactive,
                          fontSize: 16),
                    ),
                  ),
                ],
              ),
              pageIndex.pageIndex != 0
                  ? const SizedBox()
                  : Row(
                      children: [
                        const Spacer(),
                        GestureDetector(
                          onTap: () {
                            if (pageIndex.pageIndex < 1) {
                              controller.animateToPage(2, duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
                            }
                          },
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(0, 8, 8, 8),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  "Skip",
                                  style: GoogleFonts.poppins(fontSize: 17, color: Colors.grey.shade800, letterSpacing: -1),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
