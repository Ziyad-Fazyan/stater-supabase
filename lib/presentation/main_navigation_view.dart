import 'package:flutter/material.dart';
import 'package:reusekit/core.dart';
import 'package:reusekit/presentation/home_view.dart';
import 'package:reusekit/presentation/profile_view.dart';
import 'package:reusekit/presentation/students_view.dart';
import 'package:reusekit/presentation/invitations_view.dart';

class MainNavigationView extends StatefulWidget {
  const MainNavigationView({super.key});

  @override
  State<MainNavigationView> createState() => _MainNavigationViewState();
}

class _MainNavigationViewState extends State<MainNavigationView> {
  @override
  Widget build(BuildContext context) {
    return QNavigation(
      mode: QNavigationMode.nav0,
      menus: [
        NavigationMenu(
          icon: Icons.dashboard,
          label: "Dashboard",
          view: const HomeView(),
        ),
        NavigationMenu(
          icon: Icons.school,
          label: "Students",
          view: const StudentsView(),
        ),
        NavigationMenu(
          icon: Icons.mail,
          label: "Invitations",
          view: const InvitationsView(),
        ),
        NavigationMenu(
          icon: Icons.person,
          label: "Profile",
          view: ProfileView(adminId: 'current-admin-id'),
        ),
      ],
    );
  }
}
