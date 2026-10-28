/// The 50 background presets of `@nxgt/material`, by the same ids.
///
/// A preset is a name here: the app draws it (a `CustomPainter`, an image).
enum BackgroundPreset {
  /// `gradient`.
  gradient('gradient'),

  /// `mesh`.
  mesh('mesh'),

  /// `aurora`.
  aurora('aurora'),

  /// `spotlight`.
  spotlight('spotlight'),

  /// `bokeh`.
  bokeh('bokeh'),

  /// `rays`.
  rays('rays'),

  /// `halo`.
  halo('halo'),

  /// `plasma`.
  plasma('plasma'),

  /// `glass`.
  glass('glass'),

  /// `ripples`.
  ripples('ripples'),

  /// `blobs`.
  blobs('blobs'),

  /// `grain`.
  grain('grain'),

  /// `paper`.
  paper('paper'),

  /// `linen`.
  linen('linen'),

  /// `concrete`.
  concrete('concrete'),

  /// `marble`.
  marble('marble'),

  /// `isometric`.
  isometric('isometric'),

  /// `blueprint`.
  blueprint('blueprint'),

  /// `dots`.
  dots('dots'),

  /// `stripes`.
  stripes('stripes'),

  /// `low-poly`.
  lowPoly('low-poly'),

  /// `topography`.
  topography('topography'),

  /// `waves`.
  waves('waves'),

  /// `hexagons`.
  hexagons('hexagons'),

  /// `circuit`.
  circuit('circuit'),

  /// `graph-paper`.
  graphPaper('graph-paper'),

  /// `checker`.
  checker('checker'),

  /// `diagonal-checker`.
  diagonalChecker('diagonal-checker'),

  /// `chevrons`.
  chevrons('chevrons'),

  /// `shapes`.
  shapes('shapes'),

  /// `confetti-grid`.
  confettiGrid('confetti-grid'),

  /// `constellation`.
  constellation('constellation'),

  /// `halftone`.
  halftone('halftone'),

  /// `truchet`.
  truchet('truchet'),

  /// `floating`.
  floating('floating'),

  /// `scatter-icons`.
  scatterIcons('scatter-icons'),

  /// `school`.
  school('school'),

  /// `night-sky`.
  nightSky('night-sky'),

  /// `bubbles`.
  bubbles('bubbles'),

  /// `leaves`.
  leaves('leaves'),

  /// `science`.
  science('science'),

  /// `music`.
  music('music'),

  /// `travel`.
  travel('travel'),

  /// `sport`.
  sport('sport'),

  /// `moon`.
  moon('moon'),

  /// `icons`.
  icons('icons'),

  /// `eclipse`.
  eclipse('eclipse'),

  /// `meteor-shower`.
  meteorShower('meteor-shower'),

  /// `ringed-planet`.
  ringedPlanet('ringed-planet'),

  /// `northern-lights`.
  northernLights('northern-lights');

  new(this.id);

  /// The id shared with `@nxgt/material`, such as `low-poly`.
  final String id;
}
