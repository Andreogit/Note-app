// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:noteapp/cubit/auth/auth_repository.dart';

import 'package:noteapp/utils/get_error_text.dart';
import 'package:noteapp/utils/toast.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit({required this.repository}) : super(const AuthState());
  final AuthRepository repository;

  Future<void> updateImage() async {
    emit(state.copyWith(loading: true));
    try {
      final String newAvatarUrl = await repository.getAvatarUrl();
      if (newAvatarUrl != "") {
        emit(state.copyWith(avatarUrl: newAvatarUrl));
        AppToast.showToast("Profile image updated");
      }
    } on FirebaseAuthException catch (e) {
      print(e);
      emit(state.copyWith(errorText: getMessageFromErrorCode(e.code)));
      AppToast.showToast(getMessageFromErrorCode(e.code), long: true);
    } catch (e) {
      print(e);
      emit(state.copyWith(errorText: e.toString()));
      AppToast.showToast(e.toString(), long: true);
    }

    emit(state.copyWith(loading: false));
  }

  Future<void> init() async {
    final snapshot = await FirebaseFirestore.instance.collection("users").doc(FirebaseAuth.instance.currentUser?.uid).get();
    final data = snapshot.data();
    if (data == null || data.isEmpty) {
      await FirebaseFirestore.instance.collection("users").doc(FirebaseAuth.instance.currentUser?.uid).set({
        "email": FirebaseAuth.instance.currentUser?.email,
      });
    }
    emit(
      state.copyWith(
        email: FirebaseAuth.instance.currentUser?.email,
        avatarUrl: data?["avatarUrl"] ?? FirebaseAuth.instance.currentUser?.photoURL ?? "",
      ),
    );
  }

  void changePassword(str) {
    clearError();
    emit(state.copyWith(password: str));
  }

  void clearError() {
    emit(state.copyWith(errorText: ""));
  }

  Future<void> signInWithEmail() async {
    if (state.loading != true) {
      emit(state.copyWith(loading: true));
      try {
        await FirebaseAuth.instance.signInWithEmailAndPassword(email: state.email, password: state.password);
      } on FirebaseAuthException catch (e) {
        emit(state.copyWith(errorText: getMessageFromErrorCode(e.code)));
      } catch (e) {
        emit(state.copyWith(errorText: e.toString()));
      }
      emit(state.copyWith(loading: false));
    }
  }

  void changeEmail(str) {
    clearError();
    emit(state.copyWith(email: str));
  }

  Future<void> register() async {
    if (state.loading != true) {
      emit(state.copyWith(loading: true));
      try {
        await repository.register(state.email, state.password);
      } on FirebaseAuthException catch (e) {
        emit(state.copyWith(errorText: getMessageFromErrorCode(e.code)));
      } catch (e) {
        emit(state.copyWith(errorText: e.toString()));
      }
      emit(state.copyWith(loading: false));
    }
  }

  Future<void> signInWithGoogle() async {
    if (state.loading != true) {
      emit(state.copyWith(loading: true));
      final GoogleSignIn googleSignIn = GoogleSignIn();

      await googleSignIn.disconnect();

      final GoogleSignInAccount? googleSignInAccount = await googleSignIn.signIn();

      if (googleSignInAccount != null) {
        final GoogleSignInAuthentication googleAuth = await googleSignInAccount.authentication;

        final AuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );
        try {
          await FirebaseAuth.instance.signInWithCredential(credential);
        } on FirebaseAuthException catch (e) {
          print(e);
          emit(state.copyWith(errorText: getMessageFromErrorCode(e.code)));
        } catch (e) {
          print(e);
          emit(state.copyWith(errorText: e.toString()));
        }
      }
      emit(state.copyWith(loading: false));
    }
  }
}

class AuthState extends Equatable {
  final String errorText;
  final String password;
  final bool loading;
  final String email;
  final String avatarUrl;
  const AuthState({
    this.errorText = "",
    this.password = "",
    this.loading = false,
    this.email = "",
    this.avatarUrl = "",
  });

  @override
  List<Object?> get props => [errorText, password, loading, email, avatarUrl];

  AuthState copyWith({
    String? errorText,
    String? password,
    bool? loading,
    String? email,
    String? avatarUrl,
  }) {
    return AuthState(
      errorText: errorText ?? this.errorText,
      password: password ?? this.password,
      loading: loading ?? this.loading,
      email: email ?? this.email,
      avatarUrl: avatarUrl ?? this.avatarUrl,
    );
  }
}
