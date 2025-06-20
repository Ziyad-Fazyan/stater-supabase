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
  String searchQuery = "";
  final ScrollController _scrollController = ScrollController();

  List<Map<String, dynamic>> get filteredInvitations => searchQuery.isEmpty
      ? List<Map<String, dynamic>>.from(invitations)
      : List<Map<String, dynamic>>.from(invitations).where((invitation) =>
          invitation['name'].toString().toLowerCase().contains(searchQuery.toLowerCase()) ||
          invitation['phone'].toString().toLowerCase().contains(searchQuery.toLowerCase()) ||
          (invitation['email']?.toString().toLowerCase() ?? "").contains(searchQuery.toLowerCase())).toList();

  @override
  void initState() {
    super.initState();
    loadInvitations();
  }

  Future<void> loadInvitations() async {
    setState(() => loading = true);
    try {
      final response = await supabase.from('graduation_invitations').select().order('created_at', ascending: false);
      setState(() => invitations = response);
    } finally {
      setState(() => loading = false);
    }
  }

  Future<void> deleteInvitation(String id) async {
    await supabase.from('graduation_invitations').delete().eq('id', id);
    await loadInvitations();
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'sent':
        return Colors.blue;
      case 'confirmed':
        return Colors.green;
      case 'declined':
        return Colors.red;
      case 'pending':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  void showInvitationForm({Map<String, dynamic>? invitation}) {
    final isEditing = invitation != null;
    final nameController = TextEditingController(text: invitation?['name'] ?? '');
    final phoneController = TextEditingController(text: invitation?['phone'] ?? '');
    final addressController = TextEditingController(text: invitation?['address'] ?? '');
    final emailController = TextEditingController(text: invitation?['email'] ?? '');
    final invitationTypeController = TextEditingController(text: invitation?['invitation_type'] ?? 'guest');
    final invitationStatusController = TextEditingController(text: invitation?['invitation_status'] ?? 'pending');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        isEditing ? 'Edit Invitation' : 'Add New Invitation',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      DropdownButtonFormField<String>(
                        value: invitationTypeController.text,
                        decoration: const InputDecoration(
                          labelText: 'Invitation Type',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.type_specimen),
                        ),
                        items: ['guest', 'vip', 'speaker', 'sponsor', 'family']
                            .map((type) => DropdownMenuItem(
                                  value: type,
                                  child: Text(type.toUpperCase()),
                                ))
                            .toList(),
                        onChanged: (value) => invitationTypeController.text = value ?? 'guest',
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: nameController,
                        decoration: const InputDecoration(
                          labelText: 'Full Name',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.person),
                        ),
                        validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: phoneController,
                        decoration: const InputDecoration(
                          labelText: 'Phone Number',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.phone),
                        ),
                        keyboardType: TextInputType.phone,
                        validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: emailController,
                        decoration: const InputDecoration(
                          labelText: 'Email (Optional)',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.email),
                        ),
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: addressController,
                        decoration: const InputDecoration(
                          labelText: 'Address',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.location_on),
                        ),
                        maxLines: 2,
                        validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        value: invitationStatusController.text,
                        decoration: const InputDecoration(
                          labelText: 'Status',
                          border: OutlineInputBorder(),
                        ),
                        items: ['pending', 'sent', 'confirmed', 'declined']
                            .map((status) => DropdownMenuItem(
                                  value: status,
                                  child: Text(status.toUpperCase()),
                                ))
                            .toList(),
                        onChanged: (value) => invitationStatusController.text = value ?? 'pending',
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          onPressed: () async {
                            final name = nameController.text.trim();
                            final phone = phoneController.text.trim();
                            final address = addressController.text.trim();
                            final email = emailController.text.trim();
                            final type = invitationTypeController.text.trim();
                            final status = invitationStatusController.text.trim();

                            if (name.isEmpty || phone.isEmpty || address.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Please fill all required fields'),
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                              return;
                            }

                            if (isEditing) {
                              await supabase.from('graduation_invitations').update({
                                'name': name,
                                'phone': phone,
                                'address': address,
                                'email': email.isEmpty ? null : email,
                                'invitation_type': type,
                                'invitation_status': status,
                              }).eq('id', invitation!['id']);
                            } else {
                              await supabase.from('graduation_invitations').insert({
                                'name': name,
                                'phone': phone,
                                'address': address,
                                'email': email.isEmpty ? null : email,
                                'invitation_type': type,
                                'invitation_status': status,
                              });
                            }

                            Navigator.pop(context);
                            await loadInvitations();
                          },
                          child: Text(isEditing ? 'UPDATE INVITATION' : 'ADD INVITATION'),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Invitations'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              showSearch(
                context: context,
                delegate: InvitationSearchDelegate(invitations: invitations),
              );
            },
          ),
        ],
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: loadInvitations,
              child: invitations.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.mail_outline,
                            size: 80,
                            color: colors.primary.withOpacity(0.3),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No Invitations Yet',
                            style: theme.textTheme.titleLarge?.copyWith(
                              color: colors.onSurface.withOpacity(0.6),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Add your first invitation to get started',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: colors.onSurface.withOpacity(0.4),
                            ),
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton.icon(
                            icon: const Icon(Icons.add),
                            label: const Text('Add Invitation'),
                            onPressed: () => showInvitationForm(),
                          ),
                        ],
                      ),
                    )
                  : Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          child: TextField(
                            onChanged: (value) => setState(() => searchQuery = value.toLowerCase()),
                            decoration: InputDecoration(
                              hintText: 'Search invitations...',
                              prefixIcon: const Icon(Icons.search),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide.none,
                              ),
                              filled: true,
                              fillColor: colors.surfaceVariant.withOpacity(0.5),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                            ),
                          ),
                        ),
                        Expanded(
                          child: ListView.builder(
                            controller: _scrollController,
                            padding: const EdgeInsets.only(bottom: 80),
                            itemCount: filteredInvitations.length,
                            itemBuilder: (context, index) {
                              final invitation = filteredInvitations[index];
                              return Card(
                                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(12),
                                  onTap: () => showInvitationForm(invitation: invitation),
                                  child: Padding(
                                    padding: const EdgeInsets.all(12),
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 40,
                                          height: 40,
                                          decoration: BoxDecoration(
                                            color: _getStatusColor(invitation['invitation_status'] ?? 'pending')
                                                .withOpacity(0.2),
                                            shape: BoxShape.circle,
                                          ),
                                          child: Icon(
                                            Icons.mail,
                                            color: _getStatusColor(invitation['invitation_status'] ?? 'pending'),
                                            size: 20,
                                          ),
                                        ),
                                        const SizedBox(width: 16),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                invitation['name'],
                                                style: theme.textTheme.titleMedium?.copyWith(
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                invitation['phone'],
                                                style: theme.textTheme.bodySmall,
                                              ),
                                              const SizedBox(height: 4),
                                              Row(
                                                children: [
                                                  Container(
                                                    padding: const EdgeInsets.symmetric(
                                                        horizontal: 8, vertical: 2),
                                                    decoration: BoxDecoration(
                                                      color: _getStatusColor(
                                                              invitation['invitation_status'] ?? 'pending')
                                                          .withOpacity(0.1),
                                                      borderRadius: BorderRadius.circular(12),
                                                    ),
                                                    child: Text(
                                                      (invitation['invitation_status'] ?? 'pending')
                                                          .toUpperCase(),
                                                      style: theme.textTheme.labelSmall?.copyWith(
                                                        color: _getStatusColor(
                                                            invitation['invitation_status'] ?? 'pending'),
                                                        fontWeight: FontWeight.bold,
                                                      ),
                                                    ),
                                                  ),
                                                  const SizedBox(width: 8),
                                                  Container(
                                                    padding: const EdgeInsets.symmetric(
                                                        horizontal: 8, vertical: 2),
                                                    decoration: BoxDecoration(
                                                      color: colors.primary.withOpacity(0.1),
                                                      borderRadius: BorderRadius.circular(12),
                                                    ),
                                                    child: Text(
                                                      (invitation['invitation_type'] ?? 'guest')
                                                          .toUpperCase(),
                                                      style: theme.textTheme.labelSmall?.copyWith(
                                                        color: colors.primary,
                                                        fontWeight: FontWeight.bold,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.delete_outline),
                                          color: colors.error,
                                          onPressed: () async {
                                            final confirm = await showDialog<bool>(
                                              context: context,
                                              builder: (context) => AlertDialog(
                                                title: const Text('Confirm Delete'),
                                                content: Text(
                                                    'Delete invitation for ${invitation['name']}?'),
                                                actions: [
                                                  TextButton(
                                                    onPressed: () =>
                                                        Navigator.pop(context, false),
                                                    child: const Text('Cancel'),
                                                  ),
                                                  ElevatedButton(
                                                    style: ElevatedButton.styleFrom(
                                                      backgroundColor: colors.error,
                                                      foregroundColor: colors.onError,
                                                    ),
                                                    onPressed: () =>
                                                        Navigator.pop(context, true),
                                                    child: const Text('Delete'),
                                                  ),
                                                ],
                                              ),
                                            );
                                            if (confirm == true) {
                                              await deleteInvitation(invitation['id']);
                                            }
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showInvitationForm(),
        child: const Icon(Icons.add),
      ),
    );
  }
}

class InvitationSearchDelegate extends SearchDelegate {
  final List invitations;

  InvitationSearchDelegate({required this.invitations});

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    final results = invitations.where((invitation) =>
        invitation['name'].toString().toLowerCase().contains(query.toLowerCase()) ||
        invitation['phone'].toString().toLowerCase().contains(query.toLowerCase()) ||
        (invitation['email']?.toString().toLowerCase() ?? "").contains(query.toLowerCase()));

    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, index) {
        final invitation = results.elementAt(index);
        return ListTile(
          title: Text(invitation['name']),
          subtitle: Text(invitation['phone']),
          onTap: () {
            close(context, invitation);
          },
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final suggestions = query.isEmpty
        ? []
        : invitations.where((invitation) =>
            invitation['name'].toString().toLowerCase().contains(query.toLowerCase()) ||
            invitation['phone'].toString().toLowerCase().contains(query.toLowerCase()) ||
            (invitation['email']?.toString().toLowerCase() ?? "").contains(query.toLowerCase()));

    return ListView.builder(
      itemCount: suggestions.length,
      itemBuilder: (context, index) {
        final invitation = suggestions.elementAt(index);
        return ListTile(
          title: Text(invitation['name']),
          subtitle: Text(invitation['phone']),
          onTap: () {
            query = invitation['name'];
            showResults(context);
          },
        );
      },
    );
  }
}