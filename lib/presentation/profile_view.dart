import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:reusekit/core.dart';
import 'package:reusekit/main.dart';
import 'package:reusekit/presentation/login_view.dart';
import 'package:reusekit/service/auth_service.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String? _name;
  String? _email;
  bool _isLoading = false;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    setState(() => _isLoading = true);
    try {
      // final user = await AuthService().getUserData();
      // _name = user['name'];
      // _email = user['email'];
    } catch (err) {
      se("Failed to load profile: $err");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _updateProfile() async {
    if (_formKey.currentState?.validate() != true) return;

    setState(() => _isLoading = true);
    try {
      // await AuthService().updateProfile(name: _name!, email: _email!);
      setState(() => _isEditing = false);
      ss("Profile updated successfully!");
    } on Exception catch (err) {
      se("Failed to update profile: $err");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _logout() async {
    try {
      await AuthService().logout();
      offAll(const LoginView());
    } catch (e) {
      se("Logout failed: $e");
    }
  }

  void _showLogoutConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Confirm Logout"),
        content: const Text("Are you sure you want to logout?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Navigator.pop(context);
              _logout();
            },
            child: const Text("Logout"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final lang = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(lang.profile),
        actions: [
          IconButton(
            icon: Icon(_isEditing ? Icons.close : Icons.edit),
            onPressed: () => setState(() => _isEditing = !_isEditing),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    // Profile Header
                    _buildProfileHeader(theme),
                    const SizedBox(height: 32),
                    
                    // Personal Information
                    _buildSectionTitle("Personal Information", theme),
                    const SizedBox(height: 16),
                    _buildProfileForm(theme),
                    
                    // Account Settings
                    const SizedBox(height: 32),
                    _buildSectionTitle("Account Settings", theme),
                    const SizedBox(height: 16),
                    _buildAccountSettings(theme, colors),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildProfileHeader(ThemeData theme) {
    return Column(
      children: [
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: theme.colorScheme.primary.withOpacity(0.2),
              width: 2,
            ),
            image: const DecorationImage(
              image: NetworkImage("https://i.ibb.co/PGv8ZzG/me.jpg"),
              fit: BoxFit.cover,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          _name ?? "User Name",
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          _email ?? "user@email.com",
          style: theme.textTheme.bodyMedium?.copyWith(
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title, ThemeData theme) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: theme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildProfileForm(ThemeData theme) {
    return Column(
      children: [
        QTextField(
          label: "Name",
          validator: Validator.required,
          prefixIcon: Icons.person,
          value: _name,
          enabled: _isEditing,
          onChanged: (value) => _name = value,
        ),
        const SizedBox(height: 16),
        QTextField(
          label: "Email",
          validator: Validator.email,
          prefixIcon: Icons.email,
          value: _email,
          enabled: _isEditing,
          onChanged: (value) => _email = value,
        ),
        if (_isEditing) ...[
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: _updateProfile,
              child: const Text("SAVE CHANGES"),
            ),
          ),
        ],
      ],
    );
  }

 Widget _buildAccountSettings(ThemeData theme, ColorScheme colors) {
  final mainAppState = GetIt.I<MainAppState>();
  
  return Card(
    elevation: 0,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
      side: BorderSide(
        color: colors.outline.withOpacity(0.2),
        width: 1,
      ),
    ),
    margin: const EdgeInsets.symmetric(horizontal: 4),
    child: ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Column(
        children: [
          _buildSettingItem(
            icon: Icons.lock_outline,
            title: "Change Password",
            subtitle: "Update your account security",
            color: colors.primary,
            onTap: () => sw("Feature coming soon!"),
            theme: theme,
          ),
          _buildDivider(colors),
          _buildSettingItem(
            icon: Icons.translate,
            title: "App Language",
            subtitle: "Current: ${mainAppState.currentLocale.toUpperCase()}",
            color: colors.primary,
            onTap: () {
              final newLocale = mainAppState.currentLocale == "en" 
                ? const Locale("ko")
                : mainAppState.currentLocale == "ko"
                  ? const Locale("id")
                  : const Locale("en");
              mainAppState.changeLocale(newLocale);
              setState(() {});
            },
            theme: theme,
          ),
          _buildDivider(colors),
          _buildSettingItem(
            icon: Icons.exit_to_app,
            title: "Sign Out",
            subtitle: "Log out from this device",
            color: colors.error,
            onTap: _showLogoutConfirmation,
            theme: theme,
            isDestructive: true,
          ),
        ],
      ),
    ),
  );
}

Widget _buildDivider(ColorScheme colors) {
  return Divider(
    height: 1,
    thickness: 1,
    indent: 16,
    endIndent: 16,
    color: colors.outline.withOpacity(0.1),
  );
}

Widget _buildSettingItem({
  required IconData icon,
  required String title,
  String? subtitle,
  required Color color,
  required VoidCallback onTap,
  required ThemeData theme,
  bool isDestructive = false,
}) {
  return Material(
    color: Colors.transparent,
    child: InkWell(
      onTap: onTap,
      splashColor: isDestructive 
          ? theme.colorScheme.error.withOpacity(0.1)
          : theme.colorScheme.primary.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: color,
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w500,
                      color: isDestructive 
                          ? theme.colorScheme.error 
                          : theme.textTheme.bodyLarge?.color,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: theme.colorScheme.onSurface.withOpacity(0.3),
              size: 20,
            ),
          ],
        ),
      ),
    ),
  );
}
}