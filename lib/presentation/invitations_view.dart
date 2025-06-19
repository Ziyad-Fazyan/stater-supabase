import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class InvitationsView extends StatefulWidget {
  const InvitationsView({super.key});

  @override
  State<InvitationsView> createState() => _InvitationsViewState();
}

class _InvitationsViewState extends State<InvitationsView> {
  final supabase = Supabase.instance.client;
  bool loading = true;
  List invitations = [];

  @override
  void initState() {
    super.initState();
    loadInvitations();
  }

  Future<void> loadInvitations() async {
    setState(() {
      loading = true;
    });
    final response = await supabase.from('graduation_invitations').select().order('name');
    setState(() {
      invitations = response;
      loading = false;
    });
  }

  Future<void> deleteInvitation(String id) async {
    await supabase.from('graduation_invitations').delete().eq('id', id);
    await loadInvitations();
  }

  void showInvitationForm({Map<String, dynamic>? invitation}) {
    final isEditing = invitation != null;
    final nameController = TextEditingController(text: invitation?['name'] ?? '');
    final phoneController = TextEditingController(text: invitation?['phone'] ?? '');
    final addressController = TextEditingController(text: invitation?['address'] ?? '');
    final emailController = TextEditingController(text: invitation?['email'] ?? '');
    final invitationTypeController = TextEditingController(text: invitation?['invitation_type'] ?? '');
    final invitationStatusController = TextEditingController(text: invitation?['invitation_status'] ?? '');

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(isEditing ? 'Edit Invitation' : 'Add Invitation'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: 'Name',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                  ),
                ),
                SizedBox(height: 12),
                TextField(
                  controller: phoneController,
                  decoration: InputDecoration(
                    labelText: 'Phone',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                  ),
                  keyboardType: TextInputType.phone,
                ),
                SizedBox(height: 12),
                TextField(
                  controller: addressController,
                  decoration: InputDecoration(
                    labelText: 'Address',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                  ),
                ),
                SizedBox(height: 12),
                TextField(
                  controller: emailController,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
                SizedBox(height: 12),
                TextField(
                  controller: invitationTypeController,
                  decoration: InputDecoration(
                    labelText: 'Invitation Type',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                  ),
                ),
                SizedBox(height: 12),
                TextField(
                  controller: invitationStatusController,
                  decoration: InputDecoration(
                    labelText: 'Invitation Status',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final name = nameController.text.trim();
                final phone = phoneController.text.trim();
                final address = addressController.text.trim();
                final email = emailController.text.trim();
                final invitationType = invitationTypeController.text.trim();
                final invitationStatus = invitationStatusController.text.trim();

                if (name.isEmpty || phone.isEmpty || address.isEmpty || invitationType.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please fill all required fields')),
                  );
                  return;
                }

                if (isEditing) {
                  await supabase.from('graduation_invitations').update({
                    'name': name,
                    'phone': phone,
                    'address': address,
                    'email': email.isEmpty ? null : email,
                    'invitation_type': invitationType,
                    'invitation_status': invitationStatus.isEmpty ? 'sent' : invitationStatus,
                  }).eq('id', invitation!['id']);
                } else {
                  await supabase.from('graduation_invitations').insert({
                    'name': name,
                    'phone': phone,
                    'address': address,
                    'email': email.isEmpty ? null : email,
                    'invitation_type': invitationType,
                    'invitation_status': invitationStatus.isEmpty ? 'sent' : invitationStatus,
                  });
                }

                Navigator.pop(context);
                await loadInvitations();
              },
              child: Text(isEditing ? 'Update' : 'Add'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Invitations'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => showInvitationForm(),
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: invitations.length,
        itemBuilder: (context, index) {
          final invitation = invitations[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              leading: const Icon(Icons.mail_outline, color: Colors.blueAccent),
              title: Text(
                invitation['name'],
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(invitation['phone']),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.orange),
                    onPressed: () => showInvitationForm(invitation: invitation),
                    tooltip: 'Edit Invitation',
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Confirm Delete'),
                          content: Text('Delete invitation "${invitation['name']}"?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: const Text('Cancel'),
                            ),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                foregroundColor: Colors.white,
                              ),
                              onPressed: () => Navigator.pop(context, true),
                              child: const Text('Delete'),
                            ),
                          ],
                        ),
                      );
                      if (confirm == true) {
                        await deleteInvitation(invitation['id']);
                      }
                    },
                    tooltip: 'Delete Invitation',
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
