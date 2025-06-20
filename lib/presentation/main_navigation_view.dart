import 'package:flutter/material.dart';
import 'package:reusekit/core.dart';
import 'package:reusekit/presentation/home_view.dart';
import 'package:reusekit/presentation/profile_view.dart';
import 'package:reusekit/presentation/students_view.dart';
import 'package:reusekit/presentation/invitations_view.dart';
// import 'package:reusekit/service/auth_service.dart';

class MainNavigationView extends StatefulWidget {
  const MainNavigationView({super.key});

  @override
  State<MainNavigationView> createState() => _MainNavigationViewState();
}

class _MainNavigationViewState extends State<MainNavigationView> {
  String? _adminId;

  @override
  void initState() {
    super.initState();
    _loadAdminId();
  }

  Future<void> _loadAdminId() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _adminId = prefs.getString('adminId') ?? '';
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_adminId == null || _adminId!.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
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
          view: ProfileView(adminId: _adminId!),
        ),
      ],
    );
  }
}
