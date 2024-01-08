import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:noteapp/cubit/folders_bloc/folders_cubit.dart';
import 'package:noteapp/cubit/notes/notes_cubit.dart';
import 'package:noteapp/model/note.dart';
import 'package:noteapp/widgets/app_scaffold.dart';
import 'package:noteapp/widgets/app_text.dart';

class EditNote extends StatefulWidget {
  final String noteId;
  const EditNote(
    this.noteId, {
    Key? key,
  }) : super(key: key);

  @override
  State<EditNote> createState() => _EditNoteState();
}

class _EditNoteState extends State<EditNote> {
  bool loading = false;
  final TextEditingController textFieldController = TextEditingController();

  @override
  void initState() {
    // path = "${appDirectory.path}/recording.m4a";
    textFieldController.text = context.read<NotesCubit>().state.notes.firstWhere((element) => element.uid == widget.noteId).content;
    textFieldController.selection = TextSelection.fromPosition(TextPosition(offset: textFieldController.text.length));
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        AppScaffold(
          floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
          bgColor: Colors.white,
          body: CustomScrollView(
            slivers: [
              SliverAppBar(
                backgroundColor: Colors.white,
                elevation: 0,
                pinned: true,
                leadingWidth: 0,
                title: Stack(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GestureDetector(
                          onTap: () {
                            if (!loading) {
                              context.pop(context);
                            }
                          },
                          child: Row(
                            children: [
                              Icon(
                                Icons.arrow_back_ios,
                                color: Colors.black.withOpacity(0.6),
                                size: 24,
                              ),
                              AppText(
                                "Back",
                                letterSpacing: -1.2,
                                fw: FontWeight.w500,
                                color: Colors.black.withOpacity(0.6),
                              ),
                            ],
                          ),
                        ),
                        Row(
                          children: [
                            IconButton(
                              highlightColor: Colors.transparent,
                              splashRadius: 22,
                              splashColor: Colors.transparent,
                              onPressed: () {
                                if (!loading) {
                                  context.read<NotesCubit>().togglePin(widget.noteId);
                                }
                              },
                              icon: Transform.rotate(
                                angle: pi / 4,
                                child: BlocBuilder<NotesCubit, NotesState>(
                                  buildWhen: (previous, current) =>
                                      previous.notes
                                          .firstWhere((element) => element.uid == widget.noteId, orElse: () => Note.empty())
                                          .pinned !=
                                      current.notes
                                          .firstWhere((element) => element.uid == widget.noteId, orElse: () => Note.empty())
                                          .pinned,
                                  builder: (context, state) {
                                    final note =
                                        state.notes.firstWhere((element) => element.uid == widget.noteId, orElse: () => Note.empty());
                                    return Stack(
                                      children: [
                                        note.pinned
                                            ? const Icon(
                                                Icons.push_pin,
                                                color: Colors.lightBlue,
                                                size: 28,
                                              )
                                            : const SizedBox(),
                                        const Icon(
                                          Icons.push_pin_outlined,
                                          color: Colors.black,
                                          size: 28,
                                        )
                                      ],
                                    );
                                  },
                                ),
                              ),
                            ),
                            PopupMenuButton(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                icon: const Icon(
                                  Icons.more_vert,
                                  color: Colors.black,
                                ),
                                splashRadius: 22,
                                tooltip: "",
                                elevation: 0,
                                padding: EdgeInsets.zero,
                                offset: const Offset(20, 35),
                                color: Colors.transparent,
                                itemBuilder: (context) {
                                  return [
                                    PopupMenuItem(
                                      padding: EdgeInsets.zero,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(vertical: 4),
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(10),
                                          color: Colors.white,
                                          border: Border.all(
                                            color: Colors.black.withOpacity(0.1),
                                          ),
                                        ),
                                        child: Column(
                                          children: [
                                            const PopupMenuItem(
                                              child: AppText("Add to folder"),
                                            ),
                                            const PopupMenuItem(
                                              height: 1,
                                              padding: EdgeInsets.zero,
                                              child: PopupMenuDivider(
                                                height: 1,
                                              ),
                                            ),
                                            PopupMenuItem(
                                              onTap: () async {
                                                if (!loading) {
                                                  setState(() {
                                                    loading = true;
                                                  });
                                                  await context.read<NotesCubit>().deleteNote(widget.noteId);
                                                  if (context.mounted) {
                                                    context.read<FoldersCubit>().updateFolderNotesCount();
                                                    context.pop();
                                                  }
                                                }
                                              },
                                              child: const AppText("Delete note"),
                                            ),
                                            const PopupMenuItem(
                                              height: 1,
                                              padding: EdgeInsets.zero,
                                              child: PopupMenuDivider(
                                                height: 1,
                                              ),
                                            ),
                                            const PopupMenuItem(
                                              child: AppText("Share"),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ];
                                })
                          ],
                        ),
                      ],
                    ),
                    Positioned(
                      top: 6,
                      left: 0,
                      right: 0,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          BlocBuilder<NotesCubit, NotesState>(
                            builder: (context, state) {
                              final note = state.notes.firstWhere((element) => element.uid == widget.noteId, orElse: () => Note.empty());
                              return InkWell(
                                customBorder: const CircleBorder(),
                                splashColor: Colors.transparent,
                                onTap: () {
                                  if (!loading) {
                                    if (note.undos.isNotEmpty) {
                                      final String newText = note.undos.last;
                                      textFieldController.value = textFieldController.value.copyWith(
                                        text: newText,
                                        selection: TextSelection.fromPosition(
                                          TextPosition(offset: newText.length),
                                        ),
                                      );
                                      context.read<NotesCubit>().undoPressed(widget.noteId);
                                      context.read<NotesCubit>().updateNoteContent(widget.noteId, newText);
                                    }
                                  }
                                },
                                child: RotatedBox(
                                  quarterTurns: 2,
                                  child: Padding(
                                    padding: const EdgeInsets.all(4.0),
                                    child: Icon(
                                      Icons.subdirectory_arrow_right_rounded,
                                      color: note.undos.isNotEmpty ? Colors.black : Colors.grey,
                                      size: 34,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                          const SizedBox(width: 5),
                          BlocBuilder<NotesCubit, NotesState>(
                            builder: (context, state) {
                              final note = state.notes.firstWhere((element) => element.uid == widget.noteId, orElse: () => Note.empty());
                              return InkWell(
                                onTap: () {
                                  if (!loading) {
                                    if (note.redos.isNotEmpty) {
                                      final String newText = note.redos.last;
                                      textFieldController.value = textFieldController.value.copyWith(
                                        text: newText,
                                        selection: TextSelection.fromPosition(
                                          TextPosition(offset: newText.length),
                                        ),
                                      );
                                      context.read<NotesCubit>().redoPressed(widget.noteId);
                                      context.read<NotesCubit>().updateNoteContent(widget.noteId, newText);
                                    }
                                  }
                                },
                                customBorder: const CircleBorder(),
                                splashColor: Colors.transparent,
                                child: Padding(
                                  padding: const EdgeInsets.all(4.0),
                                  child: RotatedBox(
                                    quarterTurns: 2,
                                    child: Icon(
                                      Icons.subdirectory_arrow_left_rounded,
                                      color: note.redos.isNotEmpty ? Colors.black : Colors.grey,
                                      size: 34,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  child: TextField(
                    controller: textFieldController,
                    onChanged: (value) {
                      if (!loading) {
                        context.read<NotesCubit>().changeNoteContent(noteUid: widget.noteId, content: value);
                      }
                    },
                    maxLines: null,
                    minLines: 1,
                    cursorColor: Colors.blueGrey,
                    cursorWidth: 1.5,
                    keyboardType: TextInputType.multiline,
                    onTap: () => FocusScope.of(context).unfocus(),
                    autofocus: true,
                    style: GoogleFonts.roboto(
                      fontSize: 17,
                    ),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        loading
            ? Container(
                height: 100,
                width: 100,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: Colors.black.withOpacity(0.2),
                    width: 1.3,
                  ),
                  color: Colors.white,
                ),
                child: const Stack(
                  alignment: Alignment.center,
                  children: [
                    CircularProgressIndicator(
                      color: Color.fromARGB(255, 87, 157, 255),
                      strokeWidth: 3,
                      value: 1,
                    ),
                    CircularProgressIndicator(color: Color.fromARGB(255, 194, 217, 255), strokeWidth: 3),
                  ],
                ),
              )
            : const SizedBox(),
      ],
    );
  }
}
