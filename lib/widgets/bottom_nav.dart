import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:noteapp/cubit/page_cubit.dart';

class BottomNavBar extends StatelessWidget {
  const BottomNavBar({
    super.key,
    required this.pageController,
  });

  final PageController pageController;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: SafeArea(
        child: SizedBox(
          height: 60,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const SizedBox(width: 15),
              BlocBuilder<PageCubit, int>(
                builder: (context, state) {
                  return BottomNavItem(
                    active: state == 0,
                    onTap: () {
                      pageController.animateToPage(0, duration: const Duration(milliseconds: 300), curve: Curves.ease);
                    },
                    asset: "assets/icons/doc.svg",
                  );
                },
              ),
              const SizedBox(width: 25),
              BlocBuilder<PageCubit, int>(
                builder: (context, state) {
                  return BottomNavItem(
                    active: state == 1,
                    onTap: () {
                      pageController.animateToPage(1, duration: const Duration(milliseconds: 300), curve: Curves.ease);
                    },
                    asset: "assets/icons/search.svg",
                  );
                },
              ),
              const Spacer(),
              BlocBuilder<PageCubit, int>(
                builder: (context, state) {
                  return BottomNavItem(
                    active: state == 2,
                    onTap: () {
                      pageController.animateToPage(2, duration: const Duration(milliseconds: 300), curve: Curves.ease);
                    },
                    asset: "assets/icons/calendar.svg",
                  );
                },
              ),
              const SizedBox(width: 25),
              BlocBuilder<PageCubit, int>(
                builder: (context, state) {
                  return BottomNavItem(
                    active: state == 3,
                    onTap: () {
                      pageController.animateToPage(3, duration: const Duration(milliseconds: 300), curve: Curves.ease);
                    },
                    asset: "assets/icons/person.svg",
                  );
                },
              ),
              const SizedBox(width: 15),
            ],
          ),
        ),
      ),
    );
  }
}

class BottomNavItem extends StatelessWidget {
  final VoidCallback onTap;
  final String asset;
  final bool active;
  const BottomNavItem({
    super.key,
    required this.onTap,
    required this.asset,
    required this.active,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      splashColor: Colors.transparent,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SvgPicture.asset(
          asset,
          color: active ? Colors.lightBlueAccent.shade400 : Colors.black.withOpacity(0.3),
        ),
      ),
    );
  }
}
