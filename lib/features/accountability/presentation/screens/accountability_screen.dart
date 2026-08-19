import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:unscroll/features/accountability/providers/accountability_provider.dart';
import '../widgets/partner_card.dart';
import '../widgets/accountability_stats_card.dart';

class AccountabilityScreen extends ConsumerWidget {
  const AccountabilityScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final partners = ref.watch(accountabilityProvider);
    final pendingInvites = ref.watch(pendingPartnerInvitesProvider);
    final summaries = ref.watch(accountabilitySummaryProvider);

    final verifiedCount = partners.where((p) => p.isVerified).length;
    final totalSummaries = summaries.length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Accountability'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Stats card
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: AccountabilityStatsCard(
                partnerCount: partners.length,
                verifiedCount: verifiedCount,
                summariesCount: totalSummaries,
              ),
            ),

            // Pending invites section
            if (pendingInvites.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  'Pending Invitations',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              ...pendingInvites.map((invite) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: _PendingInviteCard(invite: invite),
                );
              }).toList(),
              const SizedBox(height: 24),
            ],

            // Partners section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'My Partners',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () {
                      Navigator.pushNamed(context, '/accountability-add-partner');
                    },
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('Add Partner'),
                  ),
                ],
              ),
            ),

            if (partners.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.grey[300]!,
                    ),
                  ),
                  child: Center(
                    child: Column(
                      children: [
                        Icon(
                          Icons.people_outline,
                          size: 48,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No partners added yet',
                          style:
                              Theme.of(context).textTheme.titleSmall?.copyWith(
                                    color: Colors.grey[700],
                                    fontWeight: FontWeight.w500,
                              ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Add an accountability partner to send weekly summaries',
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Colors.grey[600],
                              ),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            else
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  children: partners.map((partner) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: PartnerCard(partner: partner),
                    );
                  }).toList(),
                ),
              ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _PendingInviteCard extends StatelessWidget {
  final dynamic invite;

  const _PendingInviteCard({
    Key? key,
    required this.invite,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: Colors.blue[300]!,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.blue[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.mail_outline,
              color: Colors.blue,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Invitation Sent',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: Colors.blue[700],
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Awaiting response',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, size: 18),
            onPressed: () {
              // Cancel invite
            },
          ),
        ],
      ),
    );
  }
}
