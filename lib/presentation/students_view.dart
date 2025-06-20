import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class StudentsView extends StatefulWidget {
  const StudentsView({super.key});

  @override
  State<StudentsView> createState() => _StudentsViewState();
}

class _StudentsViewState extends State<StudentsView> {
  final supabase = Supabase.instance.client;
  bool loading = true;
  List students = [];
  String searchQuery = "";
  final ScrollController _scrollController = ScrollController();

  List<Map<String, dynamic>> get filteredStudents => searchQuery.isEmpty
      ? List<Map<String, dynamic>>.from(students)
      : List<Map<String, dynamic>>.from(students)
          .where((student) =>
              student['name'].toString().toLowerCase().contains(searchQuery.toLowerCase()) ||
              (student['student_number']?.toString().toLowerCase() ?? "").contains(searchQuery.toLowerCase()))
          .toList();

  @override
  void initState() {
    super.initState();
    loadStudents();
  }

  Future<void> loadStudents() async {
    setState(() => loading = true);
    try {
      final response = await supabase.from('students').select().order('name');
      setState(() => students = response);
    } finally {
      setState(() => loading = false);
    }
  }

  Future<void> deleteStudent(String id) async {
    await supabase.from('students').delete().eq('id', id);
    await loadStudents();
  }

  String getInitials(String name) {
    if (name.isEmpty) return "";
    List<String> nameParts = name.split(" ");
    if (nameParts.length > 1) {
      return nameParts[0][0].toUpperCase() + nameParts[1][0].toUpperCase();
    }
    return name[0].toUpperCase();
  }

  void showDeleteConfirmationDialog(Map<String, dynamic> student) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Student"),
        content: Text("Are you sure you want to delete ${student['name']}?"),
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
            onPressed: () async {
              Navigator.pop(context);
              await deleteStudent(student['id']);
            },
            child: const Text("Delete"),
          ),
        ],
      ),
    );
  }

  void showStudentForm({Map<String, dynamic>? student}) {
    final isEditing = student != null;
    final nameController = TextEditingController(text: student?['name'] ?? '');
    final phoneController = TextEditingController(text: student?['phone'] ?? '');
    final addressController = TextEditingController(text: student?['address'] ?? '');
    final studentNumberController = TextEditingController(text: student?['student_number'] ?? '');

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
                        isEditing ? 'Edit Student' : 'Add Student',
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
                        controller: studentNumberController,
                        decoration: const InputDecoration(
                          labelText: 'Student ID (Optional)',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.badge),
                        ),
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
                            final studentNumber = studentNumberController.text.trim();

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
                              await supabase.from('students').update({
                                'name': name,
                                'phone': phone,
                                'address': address,
                                'student_number': studentNumber.isEmpty ? null : studentNumber,
                              }).eq('id', student!['id']);
                            } else {
                              await supabase.from('students').insert({
                                'name': name,
                                'phone': phone,
                                'address': address,
                                'student_number': studentNumber.isEmpty ? null : studentNumber,
                              });
                            }

                            Navigator.pop(context);
                            await loadStudents();
                          },
                          child: Text(isEditing ? 'UPDATE STUDENT' : 'ADD STUDENT'),
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
        title: const Text("Students"),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              showSearch(
                context: context,
                delegate: StudentSearchDelegate(students: students),
              );
            },
          ),
        ],
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: loadStudents,
              child: students.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.school_outlined,
                            size: 80,
                            color: colors.primary.withOpacity(0.3),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            "No Students Found",
                            style: theme.textTheme.titleLarge?.copyWith(
                              color: colors.onSurface.withOpacity(0.6),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "Add your first student to get started",
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: colors.onSurface.withOpacity(0.4),
                            ),
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton.icon(
                            icon: const Icon(Icons.add),
                            label: const Text("Add Student"),
                            onPressed: () => showStudentForm(),
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
                              hintText: "Search students...",
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
                            itemCount: filteredStudents.length,
                            itemBuilder: (context, index) {
                              final student = filteredStudents[index];
                              return Card(
                                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(12),
                                  onTap: () => showStudentForm(student: student),
                                  child: Padding(
                                    padding: const EdgeInsets.all(12),
                                    child: Row(
                                      children: [
                                        CircleAvatar(
                                          backgroundColor: colors.primary.withOpacity(0.1),
                                          child: Text(
                                            getInitials(student["name"]),
                                            style: TextStyle(
                                              color: colors.primary,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 16),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                student["name"],
                                                style: theme.textTheme.titleMedium?.copyWith(
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                student["student_number"] ?? "No ID",
                                                style: theme.textTheme.bodySmall?.copyWith(
                                                  color: colors.onSurface.withOpacity(0.6),
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                student["phone"],
                                                style: theme.textTheme.bodySmall,
                                              ),
                                            ],
                                          ),
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.delete_outline),
                                          color: colors.error,
                                          onPressed: () => showDeleteConfirmationDialog(student),
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
        onPressed: () => showStudentForm(),
        child: const Icon(Icons.add),
      ),
    );
  }
}

class StudentSearchDelegate extends SearchDelegate {
  final List students;

  StudentSearchDelegate({required this.students});

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
    final results = students.where((student) =>
        student['name'].toString().toLowerCase().contains(query.toLowerCase()) ||
        (student['student_number']?.toString().toLowerCase() ?? "").contains(query.toLowerCase()));

    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, index) {
        final student = results.elementAt(index);
        return ListTile(
          title: Text(student['name']),
          subtitle: Text(student['student_number'] ?? ''),
          onTap: () {
            // Handle student selection
            close(context, student);
          },
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final suggestions = query.isEmpty
        ? []
        : students.where((student) =>
            student['name'].toString().toLowerCase().contains(query.toLowerCase()) ||
            (student['student_number']?.toString().toLowerCase() ?? "").contains(query.toLowerCase()));

    return ListView.builder(
      itemCount: suggestions.length,
      itemBuilder: (context, index) {
        final student = suggestions.elementAt(index);
        return ListTile(
          title: Text(student['name']),
          subtitle: Text(student['student_number'] ?? ''),
          onTap: () {
            query = student['name'];
            showResults(context);
          },
        );
      },
    );
  }
}