/// Represents a citizen in the game world.
class Citizen {
  final String id;
  String name;
  double threatLevel;

  /// Initialize a new citizen.
  Citizen({required this.id, required this.name, this.threatLevel = 0.0});
}
