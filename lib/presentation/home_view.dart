import 'package:flutter/material.dart';
import 'package:reusekit/core.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  final supabase = Supabase.instance.client;
  bool loading = true;
  List graduationEvents = [];
  Map<String, dynamic> statistics = {
    'totalStudents': 0,
    'totalInvitations': 0,
    'upcomingEvents': 0,
    'confirmedAttendees': 0,
    'totalParents': 0,
    'totalStudentGraduations': 0,
    'totalAdmins': 0,
  };

  @override

  void initState() {
    super.initState();
    loadData();
  }

  loadData() async {
    loading = true;
    setState(() {});    try {
      // Load graduation events
      final eventsResponse = await supabase
          .from('graduation_events')
          .select()
          .order('graduation_date', ascending: true)
          .limit(5);
      graduationEvents = eventsResponse;

      // Get statistics
      List students = await supabase.from('students').select();
      List invitations = await supabase.from('graduation_invitations').select();
      List upcomingEvents = await supabase
          .from('graduation_events')
          .select()
          .gte('graduation_date', DateTime.now().toIso8601String());
      List confirmedAttendees = await supabase
          .from('graduation_invitations')
          .select()
          .eq('invitation_status', 'confirmed');
      List parents = await supabase.from('parents').select();
      List studentGraduations = await supabase.from('student_graduations').select();
      List admins = await supabase.from('admins').select();

      statistics = {
        'totalStudents': students.length,
        'totalInvitations': invitations.length,
        'upcomingEvents': upcomingEvents.length,
        'confirmedAttendees': confirmedAttendees.length,
        'totalParents': parents.length,
        'totalStudentGraduations': studentGraduations.length,
        'totalAdmins': admins.length,
      };
    } catch (e) {
      se("Failed to load data");
    }

    loading = false;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.school,
                    size: 32.0,
                  ),
                  const SizedBox(width: 8.0),
                  Text(
                    "Graduation Dashboard",
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                ],
              ),
              const SizedBox(height: 20.0),
              // Statistics Cards
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 16.0,
                crossAxisSpacing: 16.0,
                childAspectRatio: 1.5,
                children: [
                  _buildStatCard(
                    "Total Students",
                    statistics['totalStudents'].toString(),
                    Icons.people,
                    Colors.blue,
                  ),
                  _buildStatCard(
                    "Total Invitations",
                    statistics['totalInvitations'].toString(),
                    Icons.mail,
                    Colors.green,
                  ),
                  _buildStatCard(
                    "Upcoming Events",
                    statistics['upcomingEvents'].toString(),
                    Icons.event,
                    Colors.orange,
                  ),
                  _buildStatCard(
                    "Confirmed Attendees",
                    statistics['confirmedAttendees'].toString(),
                    Icons.check_circle,
                    Colors.purple,
                  ),
                  _buildStatCard(
                    "Total Parents",
                    statistics['totalParents'].toString(),
                    Icons.family_restroom,
                    Colors.teal,
                  ),
                  _buildStatCard(
                    "Student Graduations",
                    statistics['totalStudentGraduations'].toString(),
                    Icons.school,
                    Colors.indigo,
                  ),
                  _buildStatCard(
                    "Total Admins",
                    statistics['totalAdmins'].toString(),
                    Icons.admin_panel_settings,
                    Colors.brown,
                  ),
                ],
              ),
              const SizedBox(height: 24.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Upcoming Graduation Events",
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  QButton(
                    label: "View All",
                    onPressed: () {},
                  ),
                ],
              ),
              const SizedBox(height: 16.0),
              // Upcoming Events List
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: graduationEvents.length,
                itemBuilder: (context, index) {
                  final event = graduationEvents[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12.0),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            event['event_name'],
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 8.0),
                          Row(
                            children: [
                              const Icon(Icons.calendar_today, size: 16.0),
                              const SizedBox(width: 8.0),
                              Text(
                                DateTime.parse(event['graduation_date'])
                                    .toLocal()
                                    .toString()
                                    .split(' ')[0],
                              ),
                              const SizedBox(width: 16.0),
                              const Icon(Icons.schedule, size: 16.0),
                              const SizedBox(width: 8.0),
                              Text(event['graduation_time']),
                            ],
                          ),
                          const SizedBox(height: 8.0),
                          Row(
                            children: [
                              const Icon(Icons.location_on, size: 16.0),
                              const SizedBox(width: 8.0),
                              Expanded(
                                child: Text(
                                  event['venue'],
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8.0),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Capacity: ${event['current_registrations']}/${event['total_capacity']}",
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8.0,
                                  vertical: 4.0,
                                ),
                                decoration: BoxDecoration(
                                  color: _getStatusColor(event['event_status'])
                                      .withAlpha(30),
                                  borderRadius: BorderRadius.circular(12.0),
                                ),
                                child: Text(
                                  event['event_status'].toUpperCase(),
                                  style: TextStyle(
                                    color: _getStatusColor(event['event_status']),
                                    fontSize: 12.0,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: color.withAlpha(30),
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 32.0,
            color: color,
          ),
          const SizedBox(height: 8.0),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 4.0),
          Text(
            title,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: color,
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'planning':
        return Colors.blue;
      case 'open':
        return Colors.green;
      case 'closed':
        return Colors.red;
      case 'completed':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }
}
