// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:noteapp/cubit/dashboard/dashboard_repository.dart';

class DashboardCubit extends Cubit<DashboardState> {
  final DashboardRepository repository;

  Future<void> updateDashboard() async {
    emit(state.copyWith(dashboard: await repository.getDashboard()));
  }

  DashboardCubit({required this.repository}) : super(const DashboardState());
}

class DashboardState extends Equatable {
  final Map<DateTime, int> dashboard;
  const DashboardState({this.dashboard = const {}});

  DashboardState copyWith({
    Map<DateTime, int>? dashboard,
  }) {
    return DashboardState(
      dashboard: dashboard ?? this.dashboard,
    );
  }

  @override
  List<Object?> get props => [dashboard];
}
