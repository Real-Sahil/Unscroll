import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:unscroll/features/therapist/models/therapist_models.dart';
import 'package:unscroll/features/therapist/providers/therapist_provider.dart';

class TherapistClientDetailsScreen extends ConsumerStatefulWidget {
  final ClientSummary client;

  const TherapistClientDetailsScreen({
    Key? key,
    required this.client,
  }) : super(key: key);

  @override
  ConsumerState<TherapistClientDetailsScreen> createState() => _TherapistClientDetailsScreenState();
}

class _TherapistClientDetailsScreenState extends ConsumerState<TherapistClientDetailsScreen> {
  late TextEditingController _notesController;
  bool _isEditingNotes = false;

  @override
  void initState() {
    super.initState();
    _notesController = TextEditingController(text: widget.client.therapistNotes ?? '');
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  void _saveNotes() {
    ref.read(therapistClientsProvider.notifier).updateClientNotes(
          widget.client.clientId,
          _notesController.text,
        );
    setState(() => _isEditingNotes = false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Notes saved')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.client.clientName),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Client header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue[200]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.client.clientName,
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                          Text(
                            widget.client.clientEmail,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Colors.grey[600],
                                ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: widget.client.isCurrentlyProtected
                              ? const Color(0xFF00AA66).withOpacity(0.15)
                              : Colors.grey[200],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          widget.client.getStatusLabel(),
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                color: widget.client.isCurrentlyProtected
                                    ? const Color(0xFF00AA66)
                                    : Colors.grey[700],
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Connected since ${widget.client.connectedSince.toString().split(' ')[0]}',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Key metrics
            Text(
              'Recovery Metrics',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 12),
            _MetricRow(
              label: 'Total Days Protected',
              value: '${widget.client.totalDaysProtected} days',
              icon: Icons.shield_outlined,
              color: const Color(0xFF00AA66),
            ),
            _MetricRow(
              label: 'Current Streak',
              value: '${widget.client.currentStreak} days',
              icon: Icons.local_fire_department_outlined,
              color: const Color(0xFFFF8C00),
            ),
            _MetricRow(
              label: 'Longest Streak',
              value: '${widget.client.longestStreak} days',
              icon: Icons.trending_up,
              color: const Color(0xFF0066CC),
            ),
            _MetricRow(
              label: 'Adherence Rate',
              value: '${widget.client.adherencePercentage.toStringAsFixed(1)}%',
              icon: Icons.assessment_outlined,
              color: _getAdherenceColor(widget.client.adherencePercentage),
            ),
            const SizedBox(height: 24),

            // This month stats
            Text(
              'This Month Activity',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Column(
                children: [
                  _StatRow(
                    label: 'Relapse Attempts',
                    value: '${widget.client.totalRelapsesThisMonth}',
                    icon: Icons.block,
                    color: Colors.red,
                  ),
                  const Divider(height: 16),
                  _StatRow(
                    label: 'Panic Button Presses',
                    value: '${widget.client.panicButtonPressesThisMonth}',
                    icon: Icons.sos,
                    color: Colors.orange,
                  ),
                  const Divider(height: 16),
                  _StatRow(
                    label: 'Days w/ Protection',
                    value: '${widget.client.consecutiveDaysWithProtection}',
                    icon: Icons.check_circle,
                    color: const Color(0xFF00AA66),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Risk patterns
            if (widget.client.highRiskHour != null || widget.client.highRiskApp != null) ...[
              Text(
                'Risk Patterns',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.yellow[50],
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.yellow[200]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (widget.client.highRiskHour != null) ...[
                      Row(
                        children: [
                          Icon(Icons.access_time, color: Colors.yellow[700], size: 20),
                          const SizedBox(width: 12),
                          Text(
                            'High-risk hour: ${widget.client.highRiskHour}:00 (${widget.client.highRiskHour! < 12 ? 'AM' : 'PM'})',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Colors.yellow[900],
                                ),
                          ),
                        ],
                      ),
                    ],
                    if (widget.client.highRiskHour != null && widget.client.highRiskApp != null)
                      const SizedBox(height: 8),
                    if (widget.client.highRiskApp != null) ...[
                      Row(
                        children: [
                          Icon(Icons.apps, color: Colors.yellow[700], size: 20),
                          const SizedBox(width: 12),
                          Text(
                            'Most tempting: ${widget.client.highRiskApp}',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Colors.yellow[900],
                                ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],

            // Improving areas
            if (widget.client.improvingAreas.isNotEmpty) ...[
              Text(
                'Improvement Areas',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: widget.client.improvingAreas
                    .map((area) => Chip(
                          label: Text(area),
                          backgroundColor: Colors.blue[100],
                          labelStyle: Theme.of(context).textTheme.labelSmall?.copyWith(
                                color: Colors.blue[900],
                              ),
                        ))
                    .toList(),
              ),
              const SizedBox(height: 24),
            ],

            // Therapist notes
            Text(
              'Therapist Notes',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 12),
            if (!_isEditingNotes)
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (widget.client.therapistNotes != null && widget.client.therapistNotes!.isNotEmpty)
                      Text(
                        widget.client.therapistNotes!,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.grey[800],
                              height: 1.6,
                            ),
                      )
                    else
                      Text(
                        'No notes yet. Click edit to add notes about this client\'s progress.',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.grey[600],
                              fontStyle: FontStyle.italic,
                            ),
                      ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: () => setState(() => _isEditingNotes = true),
                        child: const Text('Edit Notes'),
                      ),
                    ),
                  ],
                ),
              )
            else
              Column(
                children: [
                  TextField(
                    controller: _notesController,
                    maxLines: 6,
                    decoration: InputDecoration(
                      hintText: 'Add observations, recommendations, and progress notes...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _saveNotes,
                          child: const Text('Save'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => setState(() => _isEditingNotes = false),
                          child: const Text('Cancel'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Color _getAdherenceColor(double adherence) {
    if (adherence >= 90) return const Color(0xFF00AA66);
    if (adherence >= 75) return const Color(0xFFFF8C00);
    return Colors.red;
  }
}

class _MetricRow extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _MetricRow({
    Key? key,
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                ),
                Text(
                  value,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatRow({
    Key? key,
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(width: 12),
            Text(
              label,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
            ),
          ],
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: color,
              ),
        ),
      ],
    );
  }
}
