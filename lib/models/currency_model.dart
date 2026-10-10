/// A currency the user can keep their budget in. The picker on
/// "New Operation - Currency" lists these four.
class CurrencyModel {
  const CurrencyModel({
    required this.code,
    required this.name,
    required this.symbol,
    required this.flag,
  });

  final String code;
  final String name;
  final String symbol;

  /// Figma places a flag bitmap here; the emoji keeps it working before the
  /// image assets are exported.
  final String flag;

  static const CurrencyModel usd = CurrencyModel(
    code: 'USD',
    name: 'United States Dollar',
    symbol: r'$',
    flag: '🇺🇸',
  );

  static const List<CurrencyModel> all = <CurrencyModel>[
    usd,
    CurrencyModel(code: 'GBP', name: 'Pound (RGP £)', symbol: '£', flag: '🇬🇧'),
    CurrencyModel(code: 'EUR', name: 'Euro (EUR €)', symbol: '€', flag: '🇪🇺'),
    CurrencyModel(code: 'JPY', name: 'Yen (JPY ¥)', symbol: '¥', flag: '🇯🇵'),
  ];

  static CurrencyModel byCode(String code) =>
      all.firstWhere((c) => c.code == code, orElse: () => usd);

  factory CurrencyModel.fromJson(Map<String, dynamic> json) =>
      byCode(json['code'] as String? ?? 'USD');

  Map<String, dynamic> toJson() => <String, dynamic>{'code': code};
}
