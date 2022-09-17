class ImageResults {
  external factory ImageResults({
    String className,
    num probability,
  });

  external String get className;
  external num get probability;

}

List<ImageResults> listOfImageResults(List<dynamic> _val) {
  final _listOfMap = <ImageResults>[];
  return _listOfMap;
}

Object imageClassifier() {
  final image = Object();
  return image;
}
