import 'package:cached_network_image/cached_network_image.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:noteapp/cubit/auth/auth_cubit.dart';
import 'package:noteapp/utils/routes.dart';
import 'package:noteapp/widgets/app_text.dart';
import 'package:noteapp/widgets/profile_card.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black26),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
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
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.1),
                                ),
                                padding: const EdgeInsets.all(5),
                                height: 120,
                                width: 120,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(9999),
                                  child: state.avatarUrl == ""
                                      ? Image.asset(
                                          "assets/images/profile.png",
                                          fit: BoxFit.cover,
                                        )
                                      : CachedNetworkImage(
                                          imageUrl: state.avatarUrl,
                                          fit: BoxFit.cover,
                                          placeholder: (context, url) => const CircularProgressIndicator(
                                                strokeWidth: 3,
                                                color: Colors.black26,
                                              ),
                                          errorWidget: (context, url, error) => Image.asset(
                                                "assets/images/profile.png",
                                                fit: BoxFit.cover,
                                              )),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 10),
                      BlocBuilder<AuthCubit, AuthState>(
                        builder: (context, state) {
                          return AppText(
                            state.email.contains("@") ? state.email.substring(0, state.email.indexOf("@")) : state.email,
                            fw: FontWeight.w500,
                            size: 30,
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 30),
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300, width: 1.5),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              children: [
                ProfileCard(
                    onTap: () {
                      context.push(Routes.settings);
                    },
                    text: "Settings",
                    icon: Icons.settings),
                const Divider(
                  height: 0,
                  thickness: 1.5,
                ),
                ProfileCard(
                    icon: Icons.logout,
                    onTap: () async {
                      await context.read<AuthCubit>().logout().then((value) {
                        if (context.canPop()) context.pop();
                      });
                    },
                    text: "Logout")
              ],
            ),
          ),
        ],
      ),
    );
  }
}
