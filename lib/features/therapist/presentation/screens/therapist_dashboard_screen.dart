import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:unscroll/features/therapist/providers/therapist_provider.dart';
import 'package:unscroll/features/therapist/models/therapist_models.dart';

class TherapistDashboardScreen extends ConsumerStatefulWidget {
  const TherapistDashboardScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<TherapistDashboardScreen> createState() => _TherapistDashboardScreenState();
}

class _TherapistDashboardScreenState extends ConsumerState<TherapistDashboardScreen> {
  String _sortBy = 'adherence'; // adherence, risk, lastActive
  String _filterBy = 'all'; // all, protected, unprotected, highRisk
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _initializeTherapist();
  }

  void _initializeTherapist() {
    final notifier = ref.read(therapistProvider.notifier);
    notifier.initializeProfile(
      TherapistProfile(
        id: 'therapist_001',
        email: 'dr.smith@example.com',
        displayName: 'Dr. Smith',
        licenseNumber: 'PHD-12345',
        specialty: 'Addiction Psychology',
        clientCount: 0,
        createdAt: DateTime.now(),
      ),
    );

    final clientsNotifier = ref.read(therapistClientsProvider.notifier);
    clientsNotifier.setClients(_generateSampleClients());
  }

  List<ClientSummary> _generateSampleClients() {
    return [
      ClientSummary(
        clientId: 'client_001',
        clientName: 'Alex Johnson',
        clientEmail: 'alex@example.com',
        connectedSince: DateTime.now().subtract(const Duration(days: 45)),
        totalDaysProtected: 42,
        currentStreak: 18,
        longestStreak: 42,
        totalRelapsesThisMonth: 2,
        panicButtonPressesThisMonth: 3,
        adherencePercentage: 92.5,
        consecutiveDaysWithProtection: 18,
        highRiskHour: 22,
        highRiskApp: 'TikTok',
        improvingAreas: ['Late-night usage', 'Weekend patterns'],
        lastActiveAt: DateTime.now().subtract(const Duration(hours: 2)),
        isCurrentlyProtected: true,
        therapistNotes: 'Excellent progress, consistent adherence.',
        lastNotesUpdated: DateTime.now().subtract(const Duration(days: 3)),
      ),
      ClientSummary(
        clientId: 'client_002',
        clientName: 'Jordan Davis',
        clientEmail: 'jordan@example.com',
        connectedSince: DateTime.now().subtract(const Duration(days: 30)),
        totalDaysProtected: 22,
        currentStreak: 8,
        longestStreak: 15,
        totalRelapsesThisMonth: 5,
        panicButtonPressesThisMonth: 7,
        adherencePercentage: 68.0,
        consecutiveDaysWithProtection: 8,
        highRiskHour: 20,
        highRiskApp: 'Instagram',
        improvingAreas: ['Evenings', 'Social triggers'],
        lastActiveAt: DateTime.now().subtract(const Duration(hours: 6)),
        isCurrentlyProtected: false,
        therapistNotes: 'Working through evening triggers. Recommended additional support.',
        lastNotesUpdated: DateTime.now().subtract(const Duration(days: 1)),
      ),
      ClientSummary(
        clientId: 'client_003',
        clientName: 'Morgan Lee',
        clientEmail: 'morgan@example.com',
        connectedSince: DateTime.now().subtract(const Duration(days: 60)),
        totalDaysProtected: 58,
        currentStreak: 35,
        longestStreak: 58,
        totalRelapsesThisMonth: 0,
        panicButtonPressesThisMonth: 1,
        adherencePercentage: 97.0,
        consecutiveDaysWithProtection: 35,
        highRiskHour: null,
        highRiskApp: null,
        improvingAreas: [],
        lastActiveAt: DateTime.now(),
        isCurrentlyProtected: true,
        therapistNotes: 'Outstanding recovery. Zero relapses this month.',
        lastNotesUpdated: DateTime.now().subtract(const Duration(days: 5)),
      ),
      ClientSummary(
        clientId: 'client_004',
        clientName: 'Casey Wilson',
        clientEmail: 'casey@example.com',
        connectedSince: DateTime.now().subtract(const Duration(days: 15)),
        totalDaysProtected: 10,
        currentStreak: 3,
        longestStreak: 7,
        totalRelapsesThisMonth: 8,
        panicButtonPressesThisMonth: 12,
        adherencePercentage: 35.0,
        consecutiveDaysWithProtection: 3,
        highRiskHour: 19,
        highRiskApp: 'YouTube',
        improvingAreas: ['Impulse control', 'Afternoon patterns', 'Work stress triggers'],
        lastActiveAt: DateTime.now().subtract(const Duration(days: 1)),
        isCurrentlyProtected: false,
        therapistNotes: 'Early stage. Frequent relapses. Recommend intensive support program.',
        lastNotesUpdated: DateTime.now().subtract(const Duration(hours: 12)),
      ),
    ];
  }

  List<ClientSummary> _getFilteredAndSortedClients() {
    var clients = ref.watch(therapistClientsProvider);

    if (_searchQuery.isNotEmpty) {
      clients = ref.read(therapistClientsProvider.notifier).searchByName(_searchQuery);
    }

    switch (_filterBy) {
      case 'protected':
        clients = clients.where((c) => c.isCurrentlyProtected).toList();
        break;
      case 'unprotected':
        clients = clients.where((c) => !c.isCurrentlyProtected).toList();
        break;
      case 'highRisk':
        clients = clients.where((c) => c.adherencePercentage < 50).toList();
        break;
      default:
        break;
    }

    switch (_sortBy) {
      case 'adherence':
        clients.sort((a, b) => b.adherencePercentage.compareTo(a.adherencePercentage));
        break;
      case 'risk':
        clients.sort((a, b) => a.adherencePercentage.compareTo(b.adherencePercentage));
        break;
      case 'lastActive':
        clients.sort((a, b) {
          final aTime = a.lastActiveAt ?? DateTime(2000);
          final bTime = b.lastActiveAt ?? DateTime(2000);
          return bTime.compareTo(aTime);
        });
        break;
      default:
        break;
    }

    return clients;
  }

  @override
  Widget build(BuildContext context) {
    final stats = ref.watch(therapistStatsProvider);
    final filteredClients = _getFilteredAndSortedClients();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Therapist Dashboard'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Client Overview',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const SizedBox(height: 16),
                  GridView.count(
                    crossAxisCount: 3,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 1.1,
                    children: [
                      _StatCard(
                        label: 'Total Clients',
                        value: '${stats.totalClients}',
                        icon: Icons.people,
                        color: const Color(0xFF0066CC),
                      ),
                      _StatCard(
                        label: 'Protected',
                        value: '${stats.activeClients}',
                        icon: Icons.shield,
                        color: const Color(0xFF00AA66),
                      ),
                      _StatCard(
                        label: 'Avg Adherence',
                        value: '${stats.avgAdherence.toStringAsFixed(0)}%',
                        icon: Icons.trending_up,
                        color: const Color(0xFFFF8C00),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Divider(),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Clients',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    onChanged: (value) {
                      setState(() => _searchQuery = value);
                    },
                    decoration: InputDecoration(
                      hintText: 'Search by name or email',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _FilterButton(
                          label: 'Sort',
                          value: _sortBy,
                          options: const {
                            'adherence': 'Adherence (High)',
                            'risk': 'Risk (High)',
                            'lastActive': 'Last Active',
                          },
                          onChanged: (value) => setState(() => _sortBy = value),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _FilterButton(
                          label: 'Filter',
                          value: _filterBy,
                          options: const {
                            'all': 'All',
                            'protected': 'Protected',
                            'unprotected': 'Unprotected',
                            'highRisk': 'High Risk',
                          },
                          onChanged: (value) => setState(() => _filterBy = value),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (filteredClients.isEmpty)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 32),
                        child: Column(
                          children: [
                            Icon(
                              Icons.people_outline,
                              size: 64,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No clients found',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    Column(
                      children: filteredClients.map((client) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _ClientCard(client: client),
                        );
                      }).toList(),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    Key? key,
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 24, color: color),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: color,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: Colors.grey[600],
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterButton extends StatelessWidget {
  final String label;
  final String value;
  final Map<String, String> options;
  final ValueChanged<String> onChanged;

  const _FilterButton({
    Key? key,
    required this.label,
    required this.value,
    required this.options,
    required this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      onSelected: onChanged,
      itemBuilder: (context) => options.entries
          .map((e) => PopupMenuItem(value: e.key, child: Text(e.value)))
          .toList(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: Theme.of(context).textTheme.labelSmall),
            const SizedBox(width: 4),
            const Icon(Icons.arrow_drop_down, size: 18),
          ],
        ),
      ),
    );
  }
}

class _ClientCard extends StatelessWidget {
  final ClientSummary client;

  const _ClientCard({
    Key? key,
    required this.client,
  }) : super(key: key);

  Color _getAdherenceColor(double adherence) {
    if (adherence >= 90) return const Color(0xFF00AA66);
    if (adherence >= 75) return const Color(0xFFFF8C00);
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        client.clientName,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                      Text(
                        client.clientEmail,
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: Colors.grey[600],
                            ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: client.isCurrentlyProtected
                        ? const Color(0xFF00AA66).withOpacity(0.15)
                        : Colors.grey[200],
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    client.getStatusLabel(),
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: client.isCurrentlyProtected
                              ? const Color(0xFF00AA66)
                              : Colors.grey[700],
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            GridView.count(
              crossAxisCount: 4,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              childAspectRatio: 2.2,
              children: [
                _MetricTile(
                  label: 'Adherence',
                  value: '${client.adherencePercentage.toStringAsFixed(0)}%',
                  color: _getAdherenceColor(client.adherencePercentage),
                ),
                _MetricTile(
                  label: 'Streak',
                  value: '${client.currentStreak}d',
                  color: const Color(0xFF0066CC),
                ),
                _MetricTile(
                  label: 'This Month',
                  value: '${client.totalRelapsesThisMonth} ↓',
                  color: Colors.red,
                ),
                _MetricTile(
                  label: 'Protected',
                  value: '${client.totalDaysProtected}d',
                  color: const Color(0xFF00AA66),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (client.therapistNotes != null) ...[
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Notes',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: Colors.blue[700],
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      client.therapistNotes!,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.blue[900],
                          ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _MetricTile extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _MetricTile({
    Key? key,
    required this.label,
    required this.value,
    required this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Padding(
        padding: const EdgeInsets.all(6),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              value,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: color,
                    fontSize: 12,
                  ),
            ),
            Text(
              label,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: Colors.grey[600],
                    fontSize: 9,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
