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
    if (!mounted) return; // Prevent setState if widget is disposed
    
    setState(() {
      loading = true;
    });

    try {
      // Load graduation events
      final eventsResponse = await supabase
          .from('graduation_events')
          .select()
          .order('graduation_date', ascending: true)
          .limit(5);
      
      if (!mounted) return; // Check again before updating state
      graduationEvents = eventsResponse ?? [];

      // Get statistics - Add null safety
      final studentsResponse = await supabase.from('students').select();
      final invitationsResponse = await supabase.from('graduation_invitations').select();
      final upcomingEventsResponse = await supabase
          .from('graduation_events')
          .select()
          .gte('graduation_date', DateTime.now().toIso8601String());
      final confirmedAttendeesResponse = await supabase
          .from('graduation_invitations')
          .select()
          .eq('invitation_status', 'confirmed');
      final parentsResponse = await supabase.from('parents').select();
      final studentGraduationsResponse = await supabase.from('student_graduations').select();
      final adminsResponse = await supabase.from('admins').select();

      if (!mounted) return; // Final check before updating state

      statistics = {
        'totalStudents': studentsResponse?.length ?? 0,
        'totalInvitations': invitationsResponse?.length ?? 0,
        'upcomingEvents': upcomingEventsResponse?.length ?? 0,
        'confirmedAttendees': confirmedAttendeesResponse?.length ?? 0,
        'totalParents': parentsResponse?.length ?? 0,
        'totalStudentGraduations': studentGraduationsResponse?.length ?? 0,
        'totalAdmins': adminsResponse?.length ?? 0,
      };
    } catch (e) {
      if (mounted) {
        se("Failed to load data: ${e.toString()}");
      }
    }

    if (mounted) {
      setState(() {
        loading = false;
      });
    }
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
                    statistics['totalStudents']?.toString() ?? '0',
                    Icons.people,
                    Colors.blue,
                  ),
                  _buildStatCard(
                    "Total Invitations",
                    statistics['totalInvitations']?.toString() ?? '0',
                    Icons.mail,
                    Colors.green,
                  ),
                  _buildStatCard(
                    "Upcoming Events",
                    statistics['upcomingEvents']?.toString() ?? '0',
                    Icons.event,
                    Colors.orange,
                  ),
                  _buildStatCard(
                    "Confirmed Attendees",
                    statistics['confirmedAttendees']?.toString() ?? '0',
                    Icons.check_circle,
                    Colors.purple,
                  ),
                  _buildStatCard(
                    "Total Parents",
                    statistics['totalParents']?.toString() ?? '0',
                    Icons.family_restroom,
                    Colors.teal,
                  ),
                  _buildStatCard(
                    "Student Graduations",
                    statistics['totalStudentGraduations']?.toString() ?? '0',
                    Icons.school,
                    Colors.indigo,
                  ),
                  _buildStatCard(
                    "Total Admins",
                    statistics['totalAdmins']?.toString() ?? '0',
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
              graduationEvents.isEmpty
                  ? const Center(
                      child: Padding(
                        padding: EdgeInsets.all(32.0),
                        child: Text(
                          "No upcoming graduation events",
                          style: TextStyle(
                            fontSize: 16.0,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    )
                  : ListView.builder(
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
                                  event['event_name']?.toString() ?? 'Unknown Event',
                                  style: Theme.of(context).textTheme.titleMedium,
                                ),
                                const SizedBox(height: 8.0),
                                Row(
                                  children: [
                                    const Icon(Icons.calendar_today, size: 16.0),
                                    const SizedBox(width: 8.0),
                                    Text(
                                      _formatDate(event['graduation_date']),
                                    ),
                                    const SizedBox(width: 16.0),
                                    const Icon(Icons.schedule, size: 16.0),
                                    const SizedBox(width: 8.0),
                                    Text(event['graduation_time']?.toString() ?? 'TBA'),
                                  ],
                                ),
                                const SizedBox(height: 8.0),
                                Row(
                                  children: [
                                    const Icon(Icons.location_on, size: 16.0),
                                    const SizedBox(width: 8.0),
                                    Expanded(
                                      child: Text(
                                        event['venue']?.toString() ?? 'TBA',
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
                                      "Capacity: ${event['current_registrations']?.toString() ?? '0'}/${event['total_capacity']?.toString() ?? '0'}",
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
                                        (event['event_status']?.toString() ?? 'UNKNOWN').toUpperCase(),
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

  String _formatDate(dynamic dateValue) {
    try {
      if (dateValue == null) return 'TBA';
      final date = DateTime.parse(dateValue.toString()).toLocal();
      return date.toString().split(' ')[0];
    } catch (e) {
      return 'Invalid Date';
    }
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

  Color _getStatusColor(dynamic status) {
    final statusStr = status?.toString().toLowerCase() ?? '';
    switch (statusStr) {
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