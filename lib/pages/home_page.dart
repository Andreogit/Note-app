import 'dart:async';
import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:noteapp/cubit/auth/auth_cubit.dart';
import 'package:noteapp/cubit/folders_bloc/folders_cubit.dart';
import 'package:noteapp/cubit/notes/notes_cubit.dart';
import 'package:noteapp/cubit/page_cubit.dart';
import 'package:noteapp/model/folder.dart';
import 'package:noteapp/model/note.dart';
import 'package:noteapp/utils/colors.dart';
import 'package:noteapp/utils/routes.dart';
import 'package:noteapp/widgets/app_appbar.dart';
import 'package:noteapp/widgets/app_popup_menu_button.dart';
import 'package:noteapp/widgets/app_text.dart';
import 'package:relative_time/relative_time.dart';

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
    context.read<FoldersCubit>().loadFolders();
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
      drawer: const AppDrawer(),
      appBar: AppAppbar(
        backgroundColor: Colors.transparent,
        title: Row(
          children: [
            const SizedBox(width: 20),
            GestureDetector(
              onHorizontalDragUpdate: (details) {
                if (details.delta.dx > 10) {
                  if (_scaffoldKey.currentState?.isDrawerOpen == false) {
                    _scaffoldKey.currentState?.openDrawer();
                  }
                }
              },
              onTap: () {
                _scaffoldKey.currentState?.openDrawer();
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
            const Spacer(),
            const Padding(
              padding: EdgeInsets.all(12.0),
              child: AppPopupMenuButton(
                icon: Icon(
                  Icons.more_vert,
                  color: Colors.black,
                ),
                items: [
                  PopupMenuItem(
                    child: AppText("New note"),
                  ),
                  PopupMenuItem(
                    height: 1,
                    padding: EdgeInsets.zero,
                    child: PopupMenuDivider(
                      height: 1,
                    ),
                  ),
                  PopupMenuItem(
                    child: AppText("New note"),
                  ),
                  PopupMenuItem(
                    height: 1,
                    padding: EdgeInsets.zero,
                    child: PopupMenuDivider(
                      height: 1,
                    ),
                  ),
                  PopupMenuItem(
                    child: AppText("New note"),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 20),
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
          Placeholder(),
          Placeholder(),
          Placeholder(),
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

class BuildNotesPage extends StatefulWidget {
  const BuildNotesPage({
    super.key,
  });

  @override
  State<BuildNotesPage> createState() => _BuildNotesPageState();
}

class _BuildNotesPageState extends State<BuildNotesPage> {
  List<Note> listNotes = [];
  final GlobalKey<SliverAnimatedListState> _listKey = GlobalKey<SliverAnimatedListState>();
  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const AppText("Folders", size: 24, fw: FontWeight.bold),
                AppPopupMenuButton(
                  offset: const Offset(15, 26),
                  items: [
                    PopupMenuItem(
                      onTap: () {},
                      child: const AppText("Date"),
                    ),
                    const PopupMenuDivider(height: 1),
                    PopupMenuItem(
                      onTap: () {},
                      child: const AppText("Name"),
                    ),
                  ],
                  child: const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: AppText("Filter by", size: 15, fw: FontWeight.w500),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 30)),
        SliverToBoxAdapter(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: BlocBuilder<FoldersCubit, FoldersState>(
              builder: (context, state) {
                return Row(
                  children: [
                    const SizedBox(width: 35),
                    ...state.folders
                        .map(
                          (e) => FolderItem(e),
                        )
                        .toList(),
                    const AddFolderWidget(),
                    const SizedBox(width: 30),
                  ],
                );
              },
            ),
          ),
        ),
        const SliverPadding(
          padding: EdgeInsets.fromLTRB(30, 35, 30, 10),
          sliver: SliverToBoxAdapter(
            child: AppText(
              "Recent note",
              fw: FontWeight.w700,
              size: 25,
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          sliver: BlocBuilder<NotesCubit, NotesState>(
            builder: (context, state) {
              final stateNotes = state.notes.toList();
              for (var note in stateNotes) {
                if (!listNotes.contains(note)) {
                  final int index = stateNotes.indexOf(note);
                  listNotes.insert(index, note);
                  _listKey.currentState?.insertItem(index);
                }
              }
              for (var listNote in listNotes.toList()) {
                if (!stateNotes.contains(listNote)) {
                  final int index = listNotes.indexOf(listNote);
                  _listKey.currentState?.removeItem(
                      index,
                      (_, animation) => BuildNote(
                            note: listNote,
                            animation: animation,
                          ));
                  listNotes.removeAt(index);
                }
              }
              return SliverAnimatedList(
                key: _listKey,
                initialItemCount: state.notes.length,
                itemBuilder: (_, index, animation) {
                  final note = state.notes.elementAtOrNull(index);
                  return LongPressDraggable(
                    data: note,
                    delay: const Duration(milliseconds: 200),
                    maxSimultaneousDrags: 1,
                    feedback: Material(
                      color: Colors.transparent,
                      child: BuildNote(
                        note: note ?? Note.empty(),
                        animation: animation,
                      ),
                    ),
                    child: BuildNote(
                      note: note ?? Note.empty(),
                      animation: animation,
                    ),
                  );
                },
              );
            },
          ),
        ),
        const SliverPadding(padding: EdgeInsets.symmetric(vertical: 16)),
      ],
    );
  }
}

class BuildNote extends StatefulWidget {
  const BuildNote({
    super.key,
    required this.note,
    required this.animation,
  });

  final Note note;
  final Animation<double> animation;

  @override
  State<BuildNote> createState() => _BuildNoteState();
}

class _BuildNoteState extends State<BuildNote> {
  Timer? _everySecond;

  @override
  void dispose() {
    _everySecond?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: Tween<double>(
        begin: 0,
        end: 1,
      ).animate(widget.animation),
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, -0.1),
          end: Offset.zero,
        ).animate(widget.animation),
        child: Stack(
          children: [
            GestureDetector(
              onTap: () {
                if (widget.note.content.isNotEmpty || widget.note.audioPaths.isNotEmpty) {
                  context.push("${Routes.editNote}/${widget.note.uid}");
                } else {
                  context.read<NotesCubit>().deleteEmptyNotes();
                }
              },
              child: Container(
                padding: const EdgeInsets.all(10),
                margin: const EdgeInsets.only(bottom: 10),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black.withOpacity(0.1), width: 1),
                  color: Colors.white.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText(
                      widget.note.content.isEmpty ? "New note" : widget.note.content.trim(),
                      size: 15,
                      color: Colors.black.withOpacity(0.3),
                      fw: FontWeight.w600,
                    ),
                    const SizedBox(height: 5),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        StatefulBuilder(builder: (context, stateSetter) {
                          if (mounted) {
                            _everySecond ??= Timer.periodic(const Duration(seconds: 1), (timer) {
                              if (mounted) {
                                stateSetter(() {});
                              }
                            });
                          }

                          return AppText(
                            " ${widget.note.modified.relativeTime(context)}",
                            color: Colors.black.withOpacity(0.3),
                          );
                        }),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            widget.note.pinned
                ? Positioned(
                    right: 5,
                    top: 5,
                    child: Transform.rotate(
                      angle: pi / 4,
                      child: const Icon(
                        Icons.push_pin,
                        color: Colors.black,
                        size: 16,
                      ),
                    ),
                  )
                : Container(),
          ],
        ),
      ),
    );
  }
}

class AddFolderWidget extends StatelessWidget {
  const AddFolderWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return DragTarget(onAccept: (Note note) {
      context.read<FoldersCubit>().createFolder(notes: [note]);
    }, builder: (context, candidateData, rejectedData) {
      return GestureDetector(
        onTap: () {
          context.read<FoldersCubit>().createFolder();
        },
        child: Column(
          children: [
            Stack(
              children: [
                SizedBox(
                  width: 75,
                  child: ColorFiltered(
                    colorFilter:
                        ColorFilter.mode(candidateData.isEmpty ? const Color(0xFF33B737) : const Color(0xFF57DA52), BlendMode.srcATop),
                    child: Opacity(
                      opacity: 0.8,
                      child: Image.asset("assets/images/folder.png"),
                    ),
                  ),
                ),
                const Positioned(
                  top: 24,
                  left: 29,
                  child: AppText(
                    "+",
                    size: 30,
                    color: Colors.white,
                  ),
                )
              ],
            ),
            const SizedBox(height: 4),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 100),
              child: AppText(
                "Add folder",
                fw: FontWeight.bold,
                textAlign: TextAlign.center,
                size: 14,
                overflow: TextOverflow.ellipsis,
                color: Colors.black.withOpacity(0.77),
              ),
            )
          ],
        ),
      );
    });
  }
}

class FolderItem extends StatelessWidget {
  final Folder folder;
  const FolderItem(
    this.folder, {
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        context.push("${Routes.folder}/${folder.id}");
      },
      child: Padding(
        padding: const EdgeInsets.only(right: 15),
        child: Column(
          children: [
            DragTarget(onAccept: (Note note) {
              context.read<FoldersCubit>().addNoteToFolder(note, folder.id);
            }, builder: (context, candidateData, rejectedData) {
              return Stack(
                children: [
                  SizedBox(
                    width: 75,
                    child: ColorFiltered(
                        colorFilter: ColorFilter.mode(candidateData.isEmpty ? Colors.transparent : Colors.blue, BlendMode.screen),
                        child: Image.asset("assets/images/folder.png")),
                  ),
                  Positioned(
                    top: 25,
                    left: 7,
                    right: 7,
                    child: AppText(
                      folder.noteIds.length.toString(),
                      size: 14,
                      overflow: TextOverflow.ellipsis,
                      fw: FontWeight.w500,
                      letterSpacing: -0.5,
                      color: Colors.white70,
                    ),
                  )
                ],
              );
            }),
            const SizedBox(height: 4),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 100),
              child: AppText(
                folder.name,
                fw: FontWeight.bold,
                size: 14,
                overflow: TextOverflow.ellipsis,
                color: Colors.black.withOpacity(0.77),
              ),
            )
          ],
        ),
      ),
    );
  }
}

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

class AppDrawer extends StatelessWidget {
  const AppDrawer({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      elevation: 0,
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
        ),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 5),
              DottedBorder(
                strokeWidth: 4,
                dashPattern: const [89, 9, 114, 9, 121, 9],
                borderType: BorderType.Circle,
                color: Colors.black26,
                padding: const EdgeInsets.all(0),
                child: BlocBuilder<AuthCubit, AuthState>(
                  builder: (context, state) {
                    if (state.loading == true) {
                      return const SizedBox(
                        height: 120,
                        width: 120,
                        child: Padding(
                          padding: EdgeInsets.all(15.0),
                          child: CircularProgressIndicator(
                            strokeWidth: 5,
                            color: Colors.black26,
                          ),
                        ),
                      );
                    }
                    return InkWell(
                      borderRadius: BorderRadius.circular(9999),
                      onTap: () async {
                        await context.read<AuthCubit>().updateImage();
                      },
                      child: ClipRRect(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                          ),
                          padding: const EdgeInsets.all(5),
                          height: 120,
                          width: 120,
                          child: state.avatarUrl == ""
                              ? ClipRRect(borderRadius: BorderRadius.circular(9999), child: Image.asset("assets/images/profile.png"))
                              : ClipRRect(
                                  borderRadius: BorderRadius.circular(9999),
                                  child: CachedNetworkImage(
                                    imageUrl: state.avatarUrl,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              BlocBuilder<AuthCubit, AuthState>(
                builder: (context, state) {
                  return AppText(
                    state.email.contains("@") ? state.email.substring(0, state.email.indexOf("@")) : state.email,
                    fw: FontWeight.w500,
                    size: 30,
                  );
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}
