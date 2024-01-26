import 'package:cached_network_image/cached_network_image.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:noteapp/cubit/auth/auth_cubit.dart';
import 'package:noteapp/cubit/dashboard/dashboard_cubit.dart';
import 'package:noteapp/cubit/folders_bloc/folders_cubit.dart';
import 'package:noteapp/cubit/notes_bloc/notes_cubit.dart';
import 'package:noteapp/cubit/page_cubit.dart';
import 'package:noteapp/pages/dashboard_page.dart';
import 'package:noteapp/pages/notes_page.dart';
import 'package:noteapp/pages/profile_page.dart';
import 'package:noteapp/pages/search_page.dart';
import 'package:noteapp/utils/colors.dart';
import 'package:noteapp/utils/routes.dart';
import 'package:noteapp/widgets/app_appbar.dart';
import 'package:noteapp/widgets/app_popup_menu_button.dart';
import 'package:noteapp/widgets/app_text.dart';
import 'package:noteapp/widgets/bottom_nav.dart';

import '../widgets/app_scaffold.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final PageController pageController = PageController(initialPage: 0);

  @override
  void initState() {
    context.read<AuthCubit>().init();
    context.read<NotesCubit>().init();
    context.read<FoldersCubit>().loadFolders();
    context.read<DashboardCubit>().updateDashboard();
    super.initState();
  }

  @override
  void dispose() {
    pageController.dispose();
    _scaffoldKey.currentState?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      floatingActionButton: const FAB(),
      bgColor: AppColors.bg,
      bottomNavigationBar: BottomNavBar(pageController: pageController),
      scaffoldKey: _scaffoldKey,
      appBar: AppAppbar(
        backgroundColor: Colors.transparent,
        title: Row(
          children: [
            const SizedBox(width: 20),
            BlocBuilder<PageCubit, int>(
              builder: (context, state) {
                return AnimatedOpacity(
                  curve: Curves.easeOut,
                  duration: const Duration(milliseconds: 300),
                  opacity: state == 3 ? 0 : 1,
                  child: GestureDetector(
                    onTap: () {
                      pageController.animateToPage(3, duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(3.0),
                      child: DottedBorder(
                        strokeWidth: 2.5,
                        dashPattern: const [34.45, 3, 44, 3, 45.7, 3],
                        borderType: BorderType.Circle,
                        color: Colors.black.withOpacity(0.2),
                        padding: const EdgeInsets.all(3),
                        child: BlocBuilder<AuthCubit, AuthState>(
                          buildWhen: (previous, current) => previous.avatarUrl != current.avatarUrl,
                          builder: (context, state) {
                            return state.avatarUrl == ""
                                ? const CircleAvatar(
                                    radius: 20,
                                    backgroundColor: Colors.grey,
                                    child: Icon(
                                      Icons.person,
                                      color: Colors.white,
                                      size: 34,
                                    ),
                                  )
                                : CircleAvatar(
                                    radius: 20,
                                    backgroundColor: Colors.transparent,
                                    backgroundImage: CachedNetworkImageProvider(
                                      state.avatarUrl,
                                    ),
                                  );
                          },
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: AppPopupMenuButton(
                icon: const Icon(
                  Icons.more_vert,
                  color: Colors.black,
                ),
                items: [
                  PopupMenuItem(
                    onTap: () {
                      context.push("${Routes.editNote}/${context.read<NotesCubit>().createNoteAndGetUid()}");
                    },
                    child: const AppText("New note"),
                  ),
                  const PopupMenuDivider(
                    height: 1,
                  ),
                  PopupMenuItem(
                    onTap: () {
                      context.read<FoldersCubit>().createFolder();
                    },
                    child: const AppText("New folder"),
                  ),
                  BlocBuilder<PageCubit, int>(
                    builder: (context, state) {
                      if (state == 3) return const SizedBox();
                      return Column(
                        children: [
                          const PopupMenuDivider(
                            height: 1,
                          ),
                          PopupMenuItem(
                            onTap: () {
                              pageController.animateToPage(3, duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
                            },
                            child: const AppText("Settings"),
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: PageView(
        controller: pageController,
        onPageChanged: (value) {
          context.read<PageCubit>().setCurrentPage(value);
        },
        children: const [
          BuildNotesPage(),
          SearchPage(),
          DashboardPage(),
          ProfilePage(),
        ],
      ),
    );
  }
}

class FAB extends StatelessWidget {
  const FAB({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      borderRadius: BorderRadius.circular(999),
      elevation: 16,
      color: Colors.black,
      child: IconButton(
        iconSize: 45,
        highlightColor: Colors.white.withOpacity(0.2),
        splashColor: Colors.transparent,
        onPressed: () {
          final String newNoteId = context.read<NotesCubit>().createNoteAndGetUid();
          context.push("${Routes.editNote}/$newNoteId");
        },
        color: Colors.white,
        icon: const Icon(Icons.add, size: 25),
      ),
    );
  }
}
