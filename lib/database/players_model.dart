class Player {
  int ? id;
  String name;
  bool? isAvailable;
  int? mat;
  int? no;
  int? runs;
  String? avg;
  String? sr;
  int? wkts;
  String? bbm;
  String? eco;
  String? bowlingavg;

  Player({
    this.id,
    required this.name,
    this.isAvailable,
    this.mat,
    this.no,
    this.runs,
    this.avg,
    this.sr,
    this.wkts,
    this.bbm,
    this.eco,
    this.bowlingavg,
  });

  // Convert a Player into a Map. The keys must match the column names.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'isAvailable': isAvailable != null ? (isAvailable! ? 1 : 0) : null,
      'mat': mat,
      'no': no,
      'runs': runs,
      'avg': avg,
      'sr': sr,
      'wkts': wkts,
      'bbm': bbm,
      'eco': eco,
      'bowlingavg': bowlingavg,
    };
  }

  // Convert a Map into a Player
  factory Player.fromMap(Map<String, dynamic> map) {
    return Player(
      id: map['id'],
      name: map['name'],
      isAvailable: map['isAvailable'] == 1,
      mat: map['mat'],
      no: map['no'],
      runs: map['runs'],
      avg: map['avg'],
      sr: map['sr'],
      wkts: map['wkts'],
      bbm: map['bbm'],
      eco: map['eco'],
      bowlingavg: map['bowlingavg'],
    );
  }
}
