import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:unscroll/features/family_mode/providers/family_provider.dart';
import '../widgets/child_member_card.dart';
import '../widgets/family_stats_card.dart';

class FamilyDashboardScreen extends ConsumerWidget {
  const FamilyDashboardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final familyMembers = ref.watch(familyMembersProvider);
    final pendingInvites = ref.watch(pendingFamilyInvitesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Family Shield'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {
              // Navigate to family settings
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Family stats
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: FamilyStatsCard(
                childCount: familyMembers.length,
                protectedDevices: familyMembers.fold<int>(
                  0,
                  (sum, member) => sum + (member.isVerified ? 1 : 0),
                ),
              ),
            ),

            // Pending invites
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
                  child: PendingInviteCard(invite: invite),
                );
              }).toList(),
              const SizedBox(height: 24),
            ],

            // Children section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Protected Children',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () {
                      // Navigate to add child
                      Navigator.pushNamed(context, '/family-add-child');
                    },
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('Add Child'),
                  ),
                ],
              ),
            ),

            if (familyMembers.isEmpty)
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
                          'No children added yet',
                          style:
                              Theme.of(context).textTheme.titleSmall?.copyWith(
                                    color: Colors.grey[700],
                                    fontWeight: FontWeight.w500,
                              ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Add children to manage their protection',
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
                  children: familyMembers.map((member) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: ChildMemberCard(member: member),
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

class PendingInviteCard extends StatelessWidget {
  final dynamic invite;

  const PendingInviteCard({
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
