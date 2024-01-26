import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:noteapp/cubit/notes_bloc/notes_cubit.dart';
import 'package:noteapp/model/note.dart';
import 'package:noteapp/utils/routes.dart';
import 'package:noteapp/widgets/app_text.dart';
import 'package:relative_time/relative_time.dart';

class BuildNote extends StatefulWidget {
  const BuildNote({
    super.key,
    required this.note,
    this.animation,
  });

  final Note note;
  final Animation<double>? animation;

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
    if (widget.animation != null) {
      return FadeTransition(
        opacity: Tween<double>(
          begin: 0,
          end: 1,
        ).animate(widget.animation!),
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, -0.1),
            end: Offset.zero,
          ).animate(widget.animation!),
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
                        color: Colors.black.withOpacity(0.85),
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
    } else {
      return Stack(
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
                    color: Colors.black.withOpacity(0.85),
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
      );
    }
  }
}
