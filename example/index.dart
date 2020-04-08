import 'dart:html';

import 'example_lib.dart';

var example;

var featureDemoNames = [
  'geometry',
  'atlas',
  'batches',
  'fbo',
  'tilemap',
  'tweens',
  'audio',
  'font'
];
var featureDemoConstructors = [
  () => GeometryExample(),
  () => AtlasExample(),
  () => BatchExample(),
  () => FBOExample(),
  () => TilemapExample(),
  () => TweenExample(),
  () => AudioExample(),
  () => FontExample()
];

var advancedDemoNames = ['performance', 'shaders', 'particles', 'lighting'];
var advancedDemoConstructors = [
  () => PerformanceExample(),
  () => ShaderExample(),
  () => ParticlesExample(),
  () => LightingExample()
];

void main() {
  var featureList = querySelector('#features');
  for (var demo in featureDemoNames) {
    featureList.append(makeDemoLink(demo));
  }

  var advancedList = querySelector('#advanced');
  for (var demo in advancedDemoNames) {
    advancedList.append(makeDemoLink(demo));
  }

  example = featureDemoConstructors[0]();
}

Element makeDemoLink(String demo) {
  AnchorElement demoLink = AnchorElement()
    ..onClick.listen((e) => switchTo(demo))
    ..href = '#${demo}'
    ..text = demo;

  AnchorElement sourceLink = AnchorElement()
    ..href =
        'https://gitlab.com/ectucker/cobblestone/blob/master/example/${demo}/example_${demo}.dart'
    ..text = 'source';

  Element group = ParagraphElement()
    ..append(demoLink)
    ..appendText(' - ')
    ..append(sourceLink);

  Element li = Element.li()..append(group);

  return li;
}

void switchTo(String demo) {
  example.stop();
  if (featureDemoNames.contains(demo)) {
    example = featureDemoConstructors[featureDemoNames.indexOf(demo)]();
  } else {
    example = advancedDemoConstructors[advancedDemoNames.indexOf(demo)]();
  }
}
