import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../state/farmer_state.dart';
import '../services/mock_api.dart';
import '../models/buyer.dart';

class BuyersScreen extends StatefulWidget {
  final String? initialCropFilter;
  const BuyersScreen({Key? key, this.initialCropFilter}) : super(key: key);

  @override
  _BuyersScreenState createState() => _BuyersScreenState();
}

class _BuyersScreenState extends State<BuyersScreen> {
  List<Buyer> _buyers = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadBuyers();
  }
  
  @override
  void didUpdateWidget(BuyersScreen oldWidget) {
    if (oldWidget.initialCropFilter != widget.initialCropFilter) {
      _loadBuyers();
    }
    super.didUpdateWidget(oldWidget);
  }

  Future<void> _loadBuyers() async {
    setState(() => _loading = true);
    final location = Provider.of<FarmerState>(context, listen: false).location;
    final buyers = await MockApi().fetchBuyers(widget.initialCropFilter, location);
    if (mounted) {
      setState(() {
        _buyers = buyers;
        _loading = false;
      });
    }
  }

  void _copyContact(String contact) {
    Clipboard.setData(ClipboardData(text: contact));
    final state = Provider.of<FarmerState>(context, listen: false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(state.get('contact_copied'))),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<FarmerState>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.initialCropFilter != null 
          ? '${state.get('buyers')} - ${widget.initialCropFilter}' 
          : state.get('buyers')),
        backgroundColor: const Color(0xFF2E7D32),
      ),
      body: _loading 
        ? const Center(child: CircularProgressIndicator())
        : _buyers.isEmpty
          ? Center(child: Text(state.get('no_buyers')))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _buyers.length,
              itemBuilder: (context, index) {
                final buyer = _buyers[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: const CircleAvatar(child: Icon(Icons.person)),
                    title: Text(buyer.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('${buyer.distanceKm} km away'),
                    trailing: IconButton(
                      icon: const Icon(Icons.phone, color: Color(0xFFE65100)),
                      onPressed: () => _copyContact(buyer.contact),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
