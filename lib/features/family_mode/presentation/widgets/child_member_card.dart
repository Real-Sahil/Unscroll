import 'package:flutter/material.dart';
import 'package:unscroll/features/family_mode/models/family_models.dart';
import 'package:unscroll/features/family_mode/presentation/screens/edit_child_screen.dart';

class ChildMemberCard extends StatelessWidget {
  final FamilyMember member;

  const ChildMemberCard({
    Key? key,
    required this.member,
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
            backgroundColor: const Color(0xFF00AA66).withOpacity(0.1),
            child: Text(
              member.name.isNotEmpty ? member.name[0].toUpperCase() : 'C',
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Color(0xFF00AA66),
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
                  member.name,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    if (member.isVerified)
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
                            'Pending Verification',
                            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                  color: Colors.orange,
                                  fontWeight: FontWeight.w600,
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
                value: 'edit',
                child: Row(
                  children: [
                    Icon(Icons.edit_outlined, size: 18),
                    SizedBox(width: 12),
                    Text('Edit Settings'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'view_summary',
                child: Row(
                  children: [
                    Icon(Icons.bar_chart_outlined, size: 18),
                    SizedBox(width: 12),
                    Text('View Summary'),
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
                case 'edit':
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EditChildScreen(
                        childId: member.memberId,
                        childName: member.name,
                        childEmail: member.email,
                      ),
                    ),
                  );
                  break;
                case 'view_summary':
                  Navigator.pushNamed(
                    context,
                    '/family-child-summary',
                    arguments: member.memberId,
                  );
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
        title: const Text('Remove Child'),
        content: Text(
          'Are you sure you want to remove ${member.name} from family protection?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // Remove family member
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
