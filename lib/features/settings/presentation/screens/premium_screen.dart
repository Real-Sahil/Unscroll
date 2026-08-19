import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:unscroll/features/profile/providers/profile_provider.dart';

class PremiumScreen extends ConsumerWidget {
  const PremiumScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(profileProvider);
    final isPremiumActive = profile?.isPremiumActive ?? false;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Premium Subscription'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Hero section
            if (!isPremiumActive)
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      const Color(0xFFFF8C00).withOpacity(0.1),
                      const Color(0xFFFF6B35).withOpacity(0.1),
                    ],
                  ),
                ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF8C00).withOpacity(0.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.diamond,
                        size: 56,
                        color: Color(0xFFFF8C00),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Unlock Premium',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Get advanced features to support your recovery',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              )
            else
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      const Color(0xFF00AA66).withOpacity(0.1),
                      const Color(0xFF00D686).withOpacity(0.1),
                    ],
                  ),
                ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: const Color(0xFF00AA66).withOpacity(0.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.verified,
                        size: 56,
                        color: Color(0xFF00AA66),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Premium Active',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF00AA66),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Expires ${profile?.premiumExpiresAt?.toString().split(' ')[0] ?? 'N/A'}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 32),

            // Features section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Premium Features',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _FeatureTile(
                    icon: Icons.people,
                    title: 'Family Mode',
                    description: 'Manage protection for up to 5 children',
                    included: true,
                  ),
                  _FeatureTile(
                    icon: Icons.bar_chart,
                    title: 'Advanced Analytics',
                    description: 'Deep insights into your recovery patterns',
                    included: true,
                  ),
                  _FeatureTile(
                    icon: Icons.therapy_sessions,
                    title: 'Therapist Dashboard',
                    description: 'Share aggregated data with your coach',
                    included: true,
                  ),
                  _FeatureTile(
                    icon: Icons.clock_loader_10,
                    title: 'Custom Friction Levels',
                    description: 'Fine-tune protection settings to your needs',
                    included: true,
                  ),
                  _FeatureTile(
                    icon: Icons.notifications_active,
                    title: 'Advanced Notifications',
                    description: 'Custom time-based alerts and reminders',
                    included: true,
                  ),
                  _FeatureTile(
                    icon: Icons.cloud_download,
                    title: 'Data Export',
                    description: 'Export all your recovery data anytime',
                    included: false,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Pricing section
            if (!isPremiumActive)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Pricing Plans',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _PricingCard(
                      plan: '1 Month',
                      price: '\$4.99',
                      description: 'Perfect for trying premium',
                      onTap: () {
                        // Show purchase dialog
                      },
                    ),
                    _PricingCard(
                      plan: '1 Year',
                      price: '\$39.99',
                      description: 'Save 33% annually',
                      featured: true,
                      onTap: () {
                        // Show purchase dialog
                      },
                    ),
                    _PricingCard(
                      plan: 'Lifetime',
                      price: '\$99.99',
                      description: 'One-time payment, forever access',
                      onTap: () {
                        // Show purchase dialog
                      },
                    ),
                  ],
                ),
              )
            else
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Subscription Settings',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _SettingItem(
                            icon: Icons.calendar_today,
                            label: 'Renewal Date',
                            value: profile?.premiumExpiresAt?.toString().split(' ')[0] ?? 'N/A',
                          ),
                          const Divider(height: 16),
                          _SettingItem(
                            icon: Icons.credit_card,
                            label: 'Payment Method',
                            value: 'Credit Card ending in 4242',
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          // Manage subscription
                        },
                        child: const Text('Manage Subscription'),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: () {
                          // Show cancel dialog
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red,
                        ),
                        child: const Text('Cancel Subscription'),
                      ),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 32),

            // FAQ section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Frequently Asked Questions',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _FAQItem(
                    question: 'Can I cancel anytime?',
                    answer:
                        'Yes, you can cancel your subscription at any time. You\'ll retain access until your billing period ends.',
                  ),
                  _FAQItem(
                    question: 'What payment methods do you accept?',
                    answer:
                        'We accept all major credit cards through a secure payment processor.',
                  ),
                  _FAQItem(
                    question: 'Is there a free trial?',
                    answer:
                        'Yes, all users get 7 days of premium features free. No credit card required to start.',
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

class _FeatureTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final bool included;

  const _FeatureTile({
    Key? key,
    required this.icon,
    required this.title,
    required this.description,
    required this.included,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: included ? Colors.green[50] : Colors.grey[100],
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: included ? Colors.green[200]! : Colors.grey[300]!,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: included ? Colors.green[100] : Colors.grey[300],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: included ? Colors.green[700] : Colors.grey[600],
                size: 18,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    description,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            if (included)
              Icon(
                Icons.check_circle,
                color: Colors.green[700],
                size: 20,
              ),
          ],
        ),
      ),
    );
  }
}

class _PricingCard extends StatelessWidget {
  final String plan;
  final String price;
  final String description;
  final VoidCallback onTap;
  final bool featured;

  const _PricingCard({
    Key? key,
    required this.plan,
    required this.price,
    required this.description,
    required this.onTap,
    this.featured = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: featured ? const Color(0xFFFF8C00).withOpacity(0.05) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: featured ? const Color(0xFFFF8C00) : Colors.grey[300]!,
          width: featured ? 2 : 1,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  plan,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  price,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: featured ? const Color(0xFFFF8C00) : null,
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: onTap,
            style: ElevatedButton.styleFrom(
              backgroundColor: featured ? const Color(0xFFFF8C00) : null,
            ),
            child: const Text('Choose'),
          ),
        ],
      ),
    );
  }
}

class _SettingItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _SettingItem({
    Key? key,
    required this.icon,
    required this.label,
    required this.value,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.grey[600]),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                value,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _FAQItem extends StatefulWidget {
  final String question;
  final String answer;

  const _FAQItem({
    Key? key,
    required this.question,
    required this.answer,
  }) : super(key: key);

  @override
  State<_FAQItem> createState() => _FAQItemState();
}

class _FAQItemState extends State<_FAQItem> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: Colors.grey[300]!,
        ),
      ),
      child: ExpansionTile(
        title: Text(
          widget.question,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              widget.answer,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[700],
                    height: 1.6,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
