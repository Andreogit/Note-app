import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:noteapp/cubit/notes_bloc/notes_cubit.dart';
import 'package:noteapp/widgets/app_appbar.dart';
import 'package:noteapp/widgets/app_back_button.dart';
import 'package:noteapp/widgets/app_scaffold.dart';
import 'package:noteapp/widgets/app_text.dart';
import 'package:noteapp/widgets/profile_card.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: const AppAppbar(
        title: AppText(
          "Settings",
          fw: FontWeight.w500,
        ),
        leading: AppBackButton(),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300, width: 1.5),
                borderRadius: BorderRadius.circular(14),
              ),
              child: ProfileCard(
                text: "Font size",
                icon: Icons.text_fields_rounded,
                actions: Row(
                  children: [
                    IconButton(
                      constraints: BoxConstraints.loose(const Size(40, 40)),
                      icon: const Icon(Icons.arrow_drop_down, color: Colors.grey),
                      onPressed: () {
                        context.read<NotesCubit>().decrementFontSize();
                      },
                      splashRadius: 15,
                      splashColor: Colors.transparent,
                      padding: EdgeInsets.zero,
                      iconSize: 25,
                    ),
                    const SizedBox(width: 5),
                    BlocBuilder<NotesCubit, NotesState>(
                      builder: (context, state) {
                        return AppText(state.fontSize.ceil().toString(), size: 20, color: Colors.grey);
                      },
                    ),
                    const SizedBox(width: 5),
                    IconButton(
                      constraints: BoxConstraints.loose(const Size(40, 40)),
                      icon: const Icon(Icons.arrow_drop_up, color: Colors.grey),
                      onPressed: () {
                        context.read<NotesCubit>().incrementFontSize();
                      },
                      splashRadius: 15,
                      splashColor: Colors.transparent,
                      padding: EdgeInsets.zero,
                      iconSize: 25,
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 8),
              child: Row(
                children: [
                  Flexible(
                    child: BlocBuilder<NotesCubit, NotesState>(
                      builder: (context, state) {
                        return AppText(
                          "Example text to preview size",
                          size: state.fontSize,
                          color: Colors.grey,
                        );
                      },
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
