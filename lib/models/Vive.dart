class Vive {
  final String? id;
  final double? latitude;
  final double? longitude;
  final double? temperature;
  final int? population;
  final double? batteryLevel;

  Vive({this.id, this.latitude, this.longitude, this.temperature, this.batteryLevel, this.population});


}

final List<Vive> vives = [
  Vive(
    id: "1",
    latitude: -4.065076,
    longitude: 39.689850,
    temperature: 20.6,
    population: 123,
    batteryLevel: 0.75,
  ),
  Vive(
    id: "2",
    latitude: -4.071069,
    longitude: 39.687876,
    temperature: 21.7,
    population: 523,
    batteryLevel: 0.67,
  ),
  Vive(
    id: "3",
    latitude: -4.063021,
    longitude: 39.684057,
    temperature: 22.8,
    population: 764,
    batteryLevel: 0.23,
  ),
  Vive(
    id: "4",
    latitude: -4.061652,
    longitude: 39.701738,
    temperature: 24.2,
    population: 455,
    batteryLevel: 0.49,
  ),
  Vive(
    id: "5",
    latitude: -4.075393,
    longitude: 39.701094,
    temperature: 25.1,
    population: 853,
    batteryLevel: 0.16,
  ),
  Vive(
    id: "6",
    latitude: -4.070470,
    longitude: 39.712166,
    temperature: 27.5,
    population: 921,
    batteryLevel: 0.87,
  ),
];