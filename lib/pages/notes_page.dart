import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:noteapp/cubit/folders_bloc/folders_cubit.dart';
import 'package:noteapp/cubit/notes_bloc/notes_cubit.dart';
import 'package:noteapp/model/folder.dart';
import 'package:noteapp/model/note.dart';
import 'package:noteapp/utils/routes.dart';
import 'package:noteapp/widgets/app_popup_menu_button.dart';
import 'package:noteapp/widgets/app_text.dart';
import 'package:noteapp/widgets/note_widget.dart';

class BuildNotesPage extends StatefulWidget {
  const BuildNotesPage({
    super.key,
  });

  @override
  State<BuildNotesPage> createState() => _BuildNotesPageState();
}

class _BuildNotesPageState extends State<BuildNotesPage> {
  List<Note> listNotes = [];
  bool isDragging = false;
  final GlobalKey<SliverAnimatedListState> _listKey = GlobalKey<SliverAnimatedListState>();
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        CustomScrollView(
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
                          onTap: () {
                            context.read<FoldersCubit>().sortByDate();
                          },
                          child: const AppText("Date"),
                        ),
                        const PopupMenuDivider(height: 1),
                        PopupMenuItem(
                          onTap: () {
                            context.read<FoldersCubit>().sortByName();
                          },
                          child: const AppText("Name"),
                        ),
                      ],
                      child: const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: AppText("Sort by", size: 15, fw: FontWeight.w500),
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
                        ...state.folders.map((e) => FolderItem(e)).toList(),
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
                        onDragStarted: () {
                          setState(() {
                            isDragging = true;
                          });
                        },
                        onDragEnd: (details) {
                          setState(() {
                            isDragging = false;
                          });
                        },
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
        ),
        AnimatedPositioned(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
          bottom: isDragging ? 0 : -160,
          left: 15,
          right: 15,
          child: DragTarget<Note>(
            onAccept: (Note note) {
              context.read<FoldersCubit>().deleteNoteFromFolders(note.uid);
              context.read<NotesCubit>().deleteNote(note.uid);
            },
            builder: (context, candidateData, rejectedData) {
              return Container(
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                  color: Colors.black.withOpacity(candidateData.isNotEmpty ? .25 : .15),
                ),
                height: 160,
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 255, 109, 106).withOpacity(candidateData.isNotEmpty ? 1 : 0.7),
                        shape: BoxShape.circle),
                    child: const Icon(
                      Icons.delete_outline_outlined,
                      size: 40,
                      color: Colors.white,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
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
