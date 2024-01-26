import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_heatmap_calendar/flutter_heatmap_calendar.dart';
import 'package:intl/intl.dart';
import 'package:noteapp/cubit/dashboard/dashboard_cubit.dart';
import 'package:noteapp/utils/toast.dart';
import 'package:noteapp/widgets/app_scaffold.dart';
import 'package:noteapp/widgets/app_text.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      body: Padding(
        padding: const EdgeInsets.only(top: 12.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(),
            const AppText(
              "Dashboard",
              size: 22,
              fw: FontWeight.w500,
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: BlocBuilder<DashboardCubit, DashboardState>(
                builder: (context, state) {
                  return HeatMap(
                    borderRadius: 6,
                    size: 30,
                    defaultColor: const Color(0xFFE9E9E9),
                    colorMode: ColorMode.color,
                    datasets: state.dashboard,
                    colorTipCount: 0,
                    colorTipHelper: const [SizedBox(), SizedBox()],
                    scrollable: true,
                    onClick: (p0) {
                      AppToast.showToast("You made ${state.dashboard.entries.firstWhere(
                            (element) => element.key == p0,
                            orElse: () => MapEntry<DateTime, int>(DateTime.now(), 0),
                          ).value} actions on ${DateFormat("MMM d").format(p0)}");
                    },
                    colorsets: {
                      1: Colors.green.shade100,
                      2: Colors.green.shade300,
                      4: Colors.green.shade400,
                      6: Colors.green.shade500,
                      9: Colors.green.shade600,
                    },
                  );
                },
              ),
            ),
            const Spacer(flex: 2),
          ],
        ),
      ),
    );
  }
}
