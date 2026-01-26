enum Region {
  connacht('CO'),
  eastAnglia('EA'),
  eastMidlands('EM'),
  greatBritain('GB'),
  guernsey('GG'),
  isleOfMan('IM'),
  jersey('JE'),
  leinster('LE'),
  london('L'),
  munster('MU'),
  northEastEngland('NE'),
  northernIreland('NI'),
  northWestEngland('NW'),
  scotland('S'),
  southEastEngland('SE'),
  southWestEngland('SW'),
  ulster('UL'),
  wales('W'),
  westMidlands('WM'),
  yorkshire('Y');

  final String name;
  const Region(this.name);

  static Region fromString(String value) {
    return Region.values.firstWhere(
      (e) => e.name == value,
      orElse: () => throw ArgumentError('Invalid Region: $value'),
    );
  }
}

extension RegionNiceName on Region {
  String niceName() {
    switch (this) {
      case Region.connacht:
        return 'Connacht';
      case Region.eastAnglia:
        return 'East Anglia';
      case Region.eastMidlands:
        return 'East Midlands';
      case Region.greatBritain:
        return 'Great Britain';
      case Region.guernsey:
        return 'Guernsey';
      case Region.isleOfMan:
        return 'Isle of Man';
      case Region.jersey:
        return 'Jersey';
      case Region.leinster:
        return 'Leinster';
      case Region.london:
        return 'London';
      case Region.munster:
        return 'Munster';
      case Region.northEastEngland:
        return 'North East England';
      case Region.northernIreland:
        return 'Northern Ireland';
      case Region.northWestEngland:
        return 'North West England';
      case Region.scotland:
        return 'Scotland';
      case Region.southEastEngland:
        return 'South East England';
      case Region.southWestEngland:
        return 'South West England';
      case Region.ulster:
        return 'Ulster';
      case Region.wales:
        return 'Wales';
      case Region.westMidlands:
        return 'West Midlands';
      case Region.yorkshire:
        return 'Yorkshire';
    }
  }
}
