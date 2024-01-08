import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:noteapp/cubit/folders_bloc/folders_cubit.dart';
import 'package:noteapp/cubit/notes/notes_cubit.dart';
import 'package:noteapp/model/folder.dart';
import 'package:noteapp/model/note.dart';
import 'package:noteapp/utils/colors.dart';
import 'package:noteapp/utils/routes.dart';
import 'package:noteapp/widgets/app_appbar.dart';
import 'package:noteapp/widgets/app_back_button.dart';
import 'package:noteapp/widgets/app_popup_menu_button.dart';
import 'package:noteapp/widgets/app_scaffold.dart';
import 'package:noteapp/widgets/app_text.dart';
import 'package:relative_time/relative_time.dart';

class FolderPage extends StatefulWidget {
  final String folderId;
  const FolderPage(this.folderId, {Key? key}) : super(key: key);

  @override
  State<FolderPage> createState() => _FolderPageState();
}

class _FolderPageState extends State<FolderPage> {
  final GlobalKey<SliverAnimatedListState> _listKey = GlobalKey<SliverAnimatedListState>();
  List<Note> listNotes = [];
  final TextEditingController textFieldController = TextEditingController();
  final focusNode = FocusNode();

  @override
  void initState() {
    textFieldController.text = context.read<FoldersCubit>().state.folders.firstWhere((element) => element.id == widget.folderId).name;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: AppAppbar(
        title: Row(
          children: [
            const SizedBox(width: 5),
            const AppBackButton(),
            const SizedBox(width: 10),
            const Icon(
              Icons.folder_outlined,
              color: AppColors.darkGrey,
              size: 20,
            ),
            const SizedBox(width: 5),
            Flexible(
              child: TextField(
                textInputAction: TextInputAction.done,
                onTapOutside: (event) => FocusScope.of(context).unfocus(),
                textAlign: TextAlign.start,
                controller: textFieldController,
                maxLines: 1,
                cursorColor: AppColors.cursor,
                style: GoogleFonts.montserrat(
                  fontWeight: FontWeight.w500,
                ),
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: "Name",
                  hintStyle: GoogleFonts.montserrat(
                    fontWeight: FontWeight.w500,
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 0),
                ),
                onChanged: (value) {
                  context.read<FoldersCubit>().changeFolderName(widget.folderId, value);
                },
              ),
            ),
            AppPopupMenuButton(
              items: [
                PopupMenuItem(
                  onTap: () => context.read<FoldersCubit>().deleteFolder(widget.folderId),
                  child: const AppText(
                    "Delete folder",
                  ),
                ),
              ],
              icon: const Icon(
                Icons.more_vert,
                color: Colors.black,
              ),
            ),
            const SizedBox(width: 5),
          ],
        ),
      ),
      body: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            sliver: BlocBuilder<NotesCubit, NotesState>(
              builder: (context, notesState) {
                return BlocBuilder<FoldersCubit, FoldersState>(
                  builder: (context, state) {
                    final folder = state.folders.firstWhere(
                      (element) => element.id == widget.folderId,
                      orElse: () => Folder.empty(),
                    );
                    for (var noteId in folder.noteIds.toList()) {
                      if (!listNotes.any((note) => note.uid == noteId)) {
                        if (notesState.notes.any((note) => note.uid == noteId)) {
                          final int index = folder.noteIds.indexOf(noteId);
                          listNotes.insert(
                            index,
                            notesState.notes.firstWhere((element) => element.uid == noteId, orElse: () => Note.empty()),
                          );
                          _listKey.currentState?.insertItem(index);
                        }
                      }
                    }
                    for (var listNote in listNotes.toList()) {
                      if (!folder.noteIds.contains(listNote.uid)) {
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
                      initialItemCount: folder.noteIds.length,
                      itemBuilder: (_, index, animation) {
                        final note = notesState.notes.firstWhere(
                          (element) => element.uid == folder.noteIds[index],
                          orElse: () => Note.empty(),
                        );
                        return LongPressDraggable(
                          data: note,
                          delay: const Duration(milliseconds: 200),
                          maxSimultaneousDrags: 1,
                          feedback: Material(
                            color: Colors.transparent,
                            child: BuildNote(
                              note: note,
                              animation: animation,
                            ),
                          ),
                          child: BuildNote(
                            note: note,
                            animation: animation,
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
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
                if (widget.note.content.isNotEmpty) {
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
