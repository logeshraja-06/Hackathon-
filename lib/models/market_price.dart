class MarketPrice {
  final String priceDate;
  final String districtName;
  final String marketName;
  final String commodityGroup;
  final String commodity;
  final String variety;
  final String season;
  final double arrivalVolumeTonnes;
  final double modalPriceRsQuintal;

  MarketPrice({
    required this.priceDate,
    required this.districtName,
    required this.marketName,
    required this.commodityGroup,
    required this.commodity,
    required this.variety,
    required this.season,
    required this.arrivalVolumeTonnes,
    required this.modalPriceRsQuintal,
  });

  factory MarketPrice.fromJson(Map<String, dynamic> json) {
    return MarketPrice(
      priceDate: json['priceDate'] ?? '',
      districtName: json['districtName'] ?? '',
      marketName: json['marketName'] ?? '',
      commodityGroup: json['commodityGroup'] ?? '',
      commodity: json['commodity'] ?? '',
      variety: json['variety'] ?? '',
      season: json['season'] ?? '',
      arrivalVolumeTonnes: (json['arrivalVolumeTonnes'] ?? 0.0).toDouble(),
      modalPriceRsQuintal: (json['modalPriceRsQuintal'] ?? 0).toDouble(),
    );
  }
}
