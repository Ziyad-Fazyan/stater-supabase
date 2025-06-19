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
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  String? name;
  String? email;
  bool isLoading = false;
  bool isEditing = false;

  @override
  void initState() {
    super.initState();
    loadUserData();
  }

  Future<void> loadUserData() async {
    setState(() {
      isLoading = true;
    });

    try {
      // final user = await getUserData();
    } catch (err) {
      se("Gagal memuat data profil: $err");
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  // Future<Map<String, dynamic>> getUserData() async {
  //   return await AuthService().getUserData();
  // }

  Future<void> updateProfile() async {
    bool isNotValid = formKey.currentState!.validate() == false;
    if (isNotValid) {
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      // await AuthService().updateProfile(
      //   name: name!,
      //   email: email!,
      // );

      setState(() {
        isEditing = false;
      });

      ss("Profil berhasil diperbarui!");
    } on Exception catch (err) {
      se("Gagal memperbarui profil: $err");
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> logout() async {
    try {
      await AuthService().logout();
      offAll(const LoginView());
    } catch (e) {
      se("Gagal logout: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    AppLocalizations lang = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(lang.profile),
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                if (isEditing) {
                  isEditing = false;
                } else {
                  isEditing = true;
                }
              });
            },
            icon: Icon(
              isEditing ? Icons.close : Icons.edit,
            ),
          ),
        ],
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Form(
                key: formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    Center(
                      child: Column(
                        children: [
                          Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              shape: BoxShape.circle,
                              image: const DecorationImage(
                                image: NetworkImage(
                                  "https://i.ibb.co/PGv8ZzG/me.jpg",
                                ),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            name ?? "User Name",
                            style: Theme.of(context)
                                .textTheme
                                .headlineSmall
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          Text(
                            email ?? "user@email.com",
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  color: Colors.grey[600],
                                ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 40),
                    Text(
                      "Personal Information",
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 20),
                    QTextField(
                      label: "Name",
                      validator: Validator.required,
                      suffixIcon: Icons.person,
                      value: name,
                      enabled: isEditing,
                      onChanged: (value) {
                        name = value;
                      },
                    ),
                    QTextField(
                      label: "Email",
                      validator: Validator.email,
                      suffixIcon: Icons.email,
                      value: email,
                      enabled: isEditing,
                      onChanged: (value) {
                        email = value;
                      },
                    ),
                    const SizedBox(height: 30),
                    if (isEditing)
                      QButton(
                        label: "Save Changes",
                        onPressed: () => updateProfile(),
                      ),
                    const SizedBox(height: 40),
                    Text(
                      "Account Settings",
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 20),
                    Card(
                      child: Column(
                        children: [
                          InkWell(
                            onTap: () {
                              // Change password functionality would go here
                              sw("Feature coming soon!");
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(15.0),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.security,
                                    color: Theme.of(context).primaryColor,
                                  ),
                                  const SizedBox(width: 15),
                                  Text(
                                    "Change Password",
                                    style:
                                        Theme.of(context).textTheme.bodyLarge,
                                  ),
                                  const Spacer(),
                                  const Icon(
                                    Icons.chevron_right,
                                    color: Colors.grey,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const Divider(height: 1),
                          Builder(builder: (context) {
                            var mainAppState = GetIt.I<MainAppState>();
                            return InkWell(
                              onTap: () {
                                // Change password functionality would go here
                                if (mainAppState.currentLocale == "en") {
                                  mainAppState.changeLocale(const Locale("ko"));
                                } else if (mainAppState.currentLocale == "ko") {
                                  mainAppState.changeLocale(const Locale("id"));
                                } else {
                                  mainAppState.changeLocale(const Locale("en"));
                                }

                                setState(() {});
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(15.0),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.language,
                                      color: Theme.of(context).primaryColor,
                                    ),
                                    const SizedBox(width: 15),
                                    Text(
                                      "Change language (${mainAppState.currentLocale})",
                                      style:
                                          Theme.of(context).textTheme.bodyLarge,
                                    ),
                                    const Spacer(),
                                    const Icon(
                                      Icons.chevron_right,
                                      color: Colors.grey,
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }),
                          const Divider(height: 1),
                          InkWell(
                            onTap: () {
                              showConfirmationDialog();
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(15.0),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.logout,
                                    color: Colors.red,
                                  ),
                                  const SizedBox(width: 15),
                                  Text(
                                    "Logout",
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyLarge
                                        ?.copyWith(
                                          color: Colors.red,
                                        ),
                                  ),
                                  const Spacer(),
                                  const Icon(
                                    Icons.chevron_right,
                                    color: Colors.grey,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  void showConfirmationDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Logout Confirmation"),
        content: const Text("Are you sure you want to logout?"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text("Cancel"),
          ),
          QButton(
            label: "Logout",
            color: Colors.red,
            onPressed: () {
              Navigator.pop(context);
              logout();
            },
          ),
        ],
      ),
    );
  }
}
