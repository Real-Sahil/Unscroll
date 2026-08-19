import 'package:flutter/material.dart';
import 'package:unscroll/features/accountability/models/accountability_models.dart';

class PartnerCard extends StatelessWidget {
  final AccountabilityPartner partner;

  const PartnerCard({
    Key? key,
    required this.partner,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: Colors.grey[300]!,
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: const Color(0xFF0066CC).withOpacity(0.1),
            child: Text(
              partner.partnerName.isNotEmpty
                  ? partner.partnerName[0].toUpperCase()
                  : 'P',
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Color(0xFF0066CC),
                fontSize: 18,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  partner.partnerName,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    if (partner.isVerified)
                      Row(
                        children: [
                          const Icon(
                            Icons.check_circle,
                            size: 14,
                            color: Color(0xFF00AA66),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Verified',
                            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                  color: const Color(0xFF00AA66),
                                  fontWeight: FontWeight.w600,
                                  fontSize: 11,
                            ),
                          ),
                        ],
                      )
                    else
                      Row(
                        children: [
                          const Icon(
                            Icons.pending,
                            size: 14,
                            color: Colors.orange,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Pending',
                            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                  color: Colors.orange,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    const SizedBox(width: 12),
                    if (partner.receivesWeeklySummary)
                      Row(
                        children: [
                          const Icon(
                            Icons.mail,
                            size: 14,
                            color: Colors.blue,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Weekly emails',
                            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                  color: Colors.blue,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ],
            ),
          ),
          PopupMenuButton(
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'view_summary',
                child: Row(
                  children: [
                    Icon(Icons.mail_outline, size: 18),
                    SizedBox(width: 12),
                    Text('View Summaries'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'toggle_weekly',
                child: Row(
                  children: [
                    const Icon(Icons.edit_notifications_outlined, size: 18),
                    const SizedBox(width: 12),
                    Text(partner.receivesWeeklySummary
                        ? 'Disable Weekly'
                        : 'Enable Weekly'),
                  ],
                ),
              ),
              const PopupMenuDivider(),
              const PopupMenuItem(
                value: 'remove',
                child: Row(
                  children: [
                    Icon(Icons.delete_outlined, size: 18, color: Colors.red),
                    SizedBox(width: 12),
                    Text('Remove', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
            onSelected: (value) {
              switch (value) {
                case 'view_summary':
                  Navigator.pushNamed(
                    context,
                    '/accountability-summary',
                    arguments: partner.partnerId,
                  );
                  break;
                case 'toggle_weekly':
                  // Toggle weekly summary
                  break;
                case 'remove':
                  _showRemoveDialog(context);
                  break;
              }
            },
          ),
        ],
      ),
    );
  }

  void _showRemoveDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove Partner'),
        content: Text(
          'Are you sure you want to remove ${partner.partnerName} as an accountability partner?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // Remove partner
            },
            child: const Text(
              'Remove',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}
