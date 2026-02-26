import 'package:flutter/material.dart';
import '../models/crop.dart';
import 'trend_sparkline.dart';

class CropTile extends StatelessWidget {
  final Crop crop;

  const CropTile({Key? key, required this.crop}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isRising = crop.trend.last > crop.trend.first;
    final isHighDemand = crop.demandScore > 75 || (isRising && (crop.trend.last - crop.trend.first) > 5);

    return Container(
      width: 160,
      margin: const EdgeInsets.only(right: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  crop.name,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Icon(
                isRising ? Icons.trending_up : Icons.trending_down,
                color: isRising ? Colors.green : Colors.red,
                size: 20,
              )
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '₹${crop.avgPrice.toStringAsFixed(1)} / kg',
            style: const TextStyle(fontSize: 16, color: Color(0xFFE65100), fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          if (isHighDemand)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.green.shade100,
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text('High demand now', style: TextStyle(fontSize: 10, color: Colors.green)),
            ),
          const Spacer(),
          SizedBox(
            height: 40,
            width: double.infinity,
            child: TrendSparkline(
              data: crop.trend,
              lineColor: isRising ? Colors.green : Colors.red,
            ),
          )
        ],
      ),
    );
  }
}
