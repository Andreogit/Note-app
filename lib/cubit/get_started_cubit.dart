import 'package:flutter_bloc/flutter_bloc.dart';

class GetStartedCubit extends Cubit<bool> {
  GetStartedCubit() : super(true);

  void setLogin() {
    emit(true);
  }

  void setRegister() {
    emit(false);
  }
}
