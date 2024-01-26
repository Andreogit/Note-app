import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:noteapp/cubit/notes_bloc/notes_cubit.dart';
import 'package:noteapp/widgets/note_widget.dart';

class SearchPage extends StatelessWidget {
  const SearchPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: Colors.grey.shade400, width: 1.2),
            ),
            child: TextField(
              onChanged: (query) {
                context.read<NotesCubit>().changeSearchQuery(query.toLowerCase());
              },
              cursorColor: Colors.grey.shade600,
              decoration: InputDecoration(
                prefixIcon: Icon(
                  Icons.search,
                  color: Colors.grey.shade500,
                  size: 28,
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
                hintText: "Search",
                hintStyle: GoogleFonts.roboto(color: Colors.grey),
              ),
            ),
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            child: BlocBuilder<NotesCubit, NotesState>(
              buildWhen: (previous, current) => previous.searchQuery != current.searchQuery || previous.notes != current.notes,
              builder: (context, state) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
                  child: Column(
                    children: [
                      ...state.notes.where((e) => e.content.toLowerCase().contains(state.searchQuery)).map((e) => BuildNote(note: e)),
                      const SizedBox(height: 20),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}
