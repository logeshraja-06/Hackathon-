import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../state/farmer_state.dart';

class SchemesScreen extends StatelessWidget {
  const SchemesScreen({Key? key}) : super(key: key);

  Future<void> _launchUrl(String urlStr, BuildContext context) async {
    final Uri url = Uri.parse(urlStr);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      if (context.mounted) {
         ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Could not launch $urlStr')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<FarmerState>(context);
    
    final List<Map<String, String>> schemes = [
      {
        'title': 'TN AGRISNET',
        'subtitle': "Tamil Nadu Agriculture Department Farmer Services Portal",
        'desc': "Official Government of Tamil Nadu agriculture portal providing scheme details, farmer registration, crop insurance status, subsidies, and agricultural information services.",
        'url': "https://www.tnagrisnet.tn.gov.in",
        'icon': "agriculture"
      },
      {
        'title': 'KAVIADP',
        'subtitle': "Kalaignar's All Village Integrated Agriculture Development Programme",
        'desc': 'State-sponsored initiative to bring fallow lands into cultivation and augment water resources in village panchayats.',
        'url': 'https://www.tn.gov.in', // Main hub since specific KAVIADP portal varies
        'icon': 'water_drop'
      },
      {
        'title': 'PM-KISAN SAMMAN NIDHI',
        'subtitle': 'Central Government Income Support',
        'desc': '₹6,000 per year in three equal installments provided directly to the bank accounts of landholding farmers.',
        'url': 'https://pmkisan.gov.in/',
        'icon': 'account_balance'
      },
      {
        'title': 'PMFBY',
        'subtitle': 'Crop Insurance Scheme',
        'desc': 'Pradhan Mantri Fasal Bima Yojana provides insurance coverage and financial support in the event of failure of any notified crop.',
        'url': 'https://pmfby.gov.in/',
        'icon': 'shield'
      }
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(state.get('schemes')),
        backgroundColor: const Color(0xFF2E7D32),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: schemes.length,
        itemBuilder: (context, index) {
          final scheme = schemes[index];
          IconData iconData = Icons.article;
          if (scheme['icon'] == 'security') iconData = Icons.security;
          if (scheme['icon'] == 'water_drop') iconData = Icons.water_drop;
          if (scheme['icon'] == 'account_balance') iconData = Icons.account_balance;
          if (scheme['icon'] == 'shield') iconData = Icons.shield;

          return Card(
            elevation: 3,
            margin: const EdgeInsets.only(bottom: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: Colors.green.shade100,
                        child: Icon(iconData, color: Colors.green.shade800),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(scheme['title']!, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1B5E20))),
                            Text(scheme['subtitle']!, style: const TextStyle(fontSize: 14, color: Colors.grey)),
                          ],
                        ),
                      )
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(scheme['desc']!, style: const TextStyle(fontSize: 15)),
                  const SizedBox(height: 16),
                  Align(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.open_in_new, size: 18),
                      label: const Text('View Details'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE65100),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      onPressed: () => _launchUrl(scheme['url']!, context),
                    ),
                  )
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
