import 'dart:async';
import 'dart:convert';
import 'dart:developer' as dev;
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart' show kIsWeb, kReleaseMode;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:image_picker/image_picker.dart';
import 'package:loginenne/Widgets/CircularBar.dart';
import 'package:loginenne/Widgets/DescriptionList.dart';
import 'package:loginenne/Widgets/confidenceBar.dart';
import 'package:loginenne/face_detector_views/face_detector_painter.dart';
import 'package:loginenne/main.dart';
import 'package:path_provider/path_provider.dart';
import 'package:tflite/tflite.dart';
import 'package:universal_html/html.dart' as html;
import 'package:universal_html/js_util.dart' as jsutil;
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;

// Mobile(Android, Ios)와 Web에서의 Import를 다르게 구현
import 'package:loginenne/Widgets/AdsViewMobile.dart'
  if (dart.library.js) 'package:loginenne/Widgets/AdsViewWeb.dart';
import 'package:loginenne/utilities/linear_ml_mobile.dart'
  if (dart.library.js) 'package:loginenne/utilities/linear_ml.dart';
import 'package:loginenne/Widgets/kakaoLinkMobile.dart'
  if (dart.library.js) 'package:loginenne/Widgets/kakaoLinkWeb.dart';


import 'Widgets/CustomToast.dart';

const Map<String, String> UNIT_ID = kReleaseMode
    ? {
  'ios': 'SECRET',
  'android': 'SECRET',
}
    : {
  'ios': 'ca-app-pub-3940256099942544/2934735716',
  'android': 'ca-app-pub-3940256099942544/6300978111',
};

class PicknCheck extends StatefulWidget {
  const PicknCheck({Key? key}) : super(key: key);

  @override
  PicknCheckState createState() => PicknCheckState();
}

class PicknCheckState extends State<PicknCheck>
    with TickerProviderStateMixin {

  File? _image;
  final picker = ImagePicker();
  List? _outputs = [];
  List<double> perList = [0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5];
  List<String> labelList = [
    "황소",
    "강아지",
    "독수리",
    "고양이",
    "부엉이",
    "사슴",
    "원숭이",
    "호랑이",
    "코끼리",
  ];

  final List<Color> _colorList = [
    Colors.red,
    Colors.green,
    Colors.blue,
    Colors.orange,
    Colors.purple,
    Colors.indigo,
    Colors.brown,
    Colors.grey,
    Colors.blueGrey,
  ];

  List _items = [];
  List _contents = [];
  List<String> _discList = [], _discList1 = [], _discList2 = [], _discList3 = [], _discList4 = [];
  Color _setColor = Colors.black;
  List<ImageResults>? _listOfMap = <ImageResults>[];
  int _predictIdx = 0;
  final double _webWidth = 500;
  bool _loading = false, isBusy = false;
  late AnimationController circleController;
  final String _title = "얼굴로 알아보는 동물성격유형";
  String picGallery = "사진을 선택해주세요.\nSelect a picture";
  var banner;
  static bool viewText = true;
  final String _askText = "추가 설명을 확인하려면 \n친구에게 공유해주세요.";
  String _uid = "";
  var _timer;
  var isTimerNeed = true;
  int _timerCnt = 0;
  bool isDarkMode = false;
  Color textColor = Colors.black;
  Color bgColor = Colors.white;
  String _deviceInfo = "";
  String _darkAlert = "다크모드 사용시 클릭.";
  bool _init = false;
  int startTime = DateTime.now().millisecondsSinceEpoch;
  CustomPaint? customPaint;
  final FToast ftoast = FToast();
  late ToastNotification toast;
  PicknCheckState? stateObject;

  double minImageSize = 300.0;

  double imageHeight = 300.0;
  double imageWidth = 300.0;

  // Fetch content from the json file
  Future<void> readJson() async {
    final String response = await rootBundle.loadString('assets/contents.json');
    final data = await json.decode(response);
    setState(() {
      _contents = data["items"];
      // dev.log(_items.toString());
    });
  }

  loadModel() async {
    await Tflite.loadModel(
      model: "assets/model_unquant.tflite",
      labels: "assets/labels.txt",
    ).then((value) {
      setState(() {});
    });
  }

  @override
  void initState() {
    super.initState();
    _uid = setUid();

    // var brightness = MediaQuery.of(context).platformBrightness;
    // var isDarkMode = brightness == Brightness.dark;
    // if(isDarkMode){textColor = Colors.white;}

    dev.log("kIsWeb:"+kIsWeb.toString());
    if (!kIsWeb) {

      banner = BannerAd(
        adUnitId: UNIT_ID[Platform.isIOS ? 'ios' : 'android']!,
        size: AdSize.banner,
        request: const AdRequest(),
        listener: BannerAdListener(
          onAdOpened: (data){
            dev.log("onAdOpened:"+data.toString());
            setState(() { viewText = true; });
          },
          onAdClicked: (data){
            dev.log("onAdClicked:"+data.toString());
            setState(() { viewText = true; });
          },
        ),
      )..load();

      loadModel().then((value) {
        setState(() {
          readJson();
        });
      });
    } else {
      readJson();
    }
    getDeviceInfo();
    toast = ToastNotification(ftoast.init(context));

    circleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..addListener(() {
        setState(() {});
      });
    circleController.repeat(reverse: true);
    _init = true;
  }

  @override
  void dispose() {
    imageCache!.clear();
    Tflite.close();
    circleController.dispose();
    if(!kIsWeb && banner != null) { banner.dispose(); }
    super.dispose();
  }

  Future<File> getImageFileFromAssets(String path) async {
    final byteData = await rootBundle.load('assets/$path');

    final file = File('${(await getTemporaryDirectory()).path}/$path');
    await file.writeAsBytes(byteData.buffer.asUint8List(byteData.offsetInBytes, byteData.lengthInBytes));

    return file;
  }

  // 비동기 처리를 통해 카메라와 갤러리에서 이미지를 가져온다.
  Future getImage(ImageSource imageSource) async {
    bool cropped = false;
    dev.log("getImage:" + imageSource.name);
    _darkAlert = "";
    if(!kIsWeb) {
      Future.delayed(const Duration(milliseconds: 200), () {
        setState(() {_loading = true;});
      });
    }
    dev.log("pickImages");
    final image = await picker.pickImage(source: imageSource);
    // final image = await getImageFileFromAssets('test_image.jpeg');

    dev.log("image: "+image.toString());
    if(image.toString()=="null"||image.toString().isEmpty){
      setState(() {
        _image = null;
        _loading = false;
      });
    }else {

      _image = File(image!.path); // 가져온 이미지를 _image에 저장
      dev.log("origin image path: "+image.path);
      int imageSize = await image.length();
      dev.log("origin image size: "+imageSize.toString());

      if(!kIsWeb) {
        // 10MB 이상이면 분석전에 압축
        if(imageSize > 10*1000*1000){
          dev.log("Need Crop Image");
          picGallery = "[고용량 이미지 감지] \n분석을 위해 이미지를 압축중입니다.";
          toast = ToastNotification(ftoast.init(context));
          toast.warn(picGallery);

          final decodedImage = await decodeImageFromList(
              _image!.readAsBytesSync());
          imageHeight = decodedImage.height.toDouble();
          imageWidth = decodedImage.width.toDouble();

          _image = await cropImage(_image!, imageWidth, imageHeight);
          int imageSize = await _image!.length();
          dev.log("croppedImage size: "+imageSize.toString());
          cropped = true;
          // return;
        }else{

          final decodedImage = await decodeImageFromList(
              _image!.readAsBytesSync());
          imageHeight = decodedImage.height.toDouble();
          imageWidth = decodedImage.width.toDouble();

          if(Platform.isIOS) {
            dev.log("convert heic to jpg (IOS)");
            _image = await saveJpg(_image!, imageWidth, imageHeight);
          }
        }


        final inputImage = InputImage.fromFilePath(_image!.path);
        if (!await processImage(inputImage)) {
          dev.log("얼굴이 인식되지 않습니다. 다른 사진으로 시도해주세요.");
          picGallery = "얼굴이 인식되지 않습니다. \n다른 사진으로 시도해주세요.\n(No faces found)";
          toast = ToastNotification(ftoast.init(context));
          toast.error(picGallery);
          // _image = null;
          _loading = false;
          isBusy = false;
          customPaint = null;
          return;
        }
      }

      setState(() {
        _outputs = [];
        _loading = true;
      });
      (kIsWeb)
          ? await classifyImageWeb(File(image.path))
          : await classifyImage(
          File(image.path), cropped); // 가져온 이미지를 분류 하기 위해 await을 사용
    }
  }

  Future<File> saveJpg(File imageFile, double width, double height) async {
    File? jpgImage;
    Directory tempDir = await getTemporaryDirectory();
    String tempPath = path.join(tempDir.path, "temp_"+path.basename(imageFile.path));
    dev.log("imageFile absolute: "+imageFile.absolute.path);
    dev.log("croppedImage tempPath: "+tempPath);

    jpgImage = await FlutterImageCompress.compressAndGetFile(
      imageFile.absolute.path,
      tempPath,
      // minWidth: width.toInt(),
      // minHeight: height.toInt(),
      quality: 100,
      // rotate: 90,
    );

    return jpgImage!;
  }

  Future<File> cropImage(File imageFile, double width, double height) async {
    File? croppedImage;
    Directory tempDir = await getTemporaryDirectory();
    String tempPath = path.join(tempDir.path, "temp_"+path.basename(imageFile.path));
    dev.log("imageFile absolute: "+imageFile.absolute.path);
    dev.log("croppedImage tempPath: "+tempPath);

    double ratio = height / width;
    int minHeight = (1080 * ratio).toInt();
    dev.log("croppedImage size: "+minHeight.toString()+", 1080");

    croppedImage = await FlutterImageCompress.compressAndGetFile(
      imageFile.absolute.path,
      tempPath,
      minWidth: 1080,
      minHeight: minHeight,
      quality: 100,
      // rotate: 90,
    );

    return croppedImage!;
  }

  Future<String> fetchPost(String uuid) async {
    final _url = 'http://pickncheck.com/animal/process/get_uid.php?uuid='+uuid;
    dev.log(_url);
    try{
      dev.log("start http");
      http.Response response = await http.get(Uri.parse(_url),);
      dev.log('Response status: ${response.statusCode}');
      Map<String, dynamic> data = jsonDecode(response.body);
      dev.log('Response body: $data');
      // debugPrint("data: "+data.toString());
      String success = data['success'].toString();
      // debugPrint("success: "+success);

      if (success == 'true'){
        viewText = true;
        // dev.log("stop timer");
        // _timer?.cancel();
        // _timer = null;
        // setState(() {
        //   viewText = true;
        // });
      }
    } catch (e){
      dev.log(e.toString());
      _timer?.cancel();
      viewText = true;
    }

    return _url;
  }

  // 이미지 분류 (Web)
  Future classifyImageWeb(File image) async {
    dev.log(image.toString());
    var input = html.document.getElementById('__image_picker_web-file-input');
    var img = html.document.getElementsByTagName('input');
    dev.log(img[0].toString());
    html.Element? box = html.document.getElementById('box');

    // dart(flutter)에서 html에 이미지를 바로 삽입할경우 아래와 같이 allow 해주어야 링크가 허용된다.
    box?.setInnerHtml(image.path + '<img id="img" src="' + image.path + '">',
        validator: html.NodeValidatorBuilder()
          ..allowHtml5()
          ..allowElement('a', attributes: ['href'])
          ..allowElement('img',
              attributes: ['src'], uriPolicy: DefaultUriPolicy()));

    final _val = await jsutil.promiseToFuture<List<dynamic>>(imageClassifier());
    setState(() => _listOfMap = listOfImageResults(_val));

    dev.log("List_of_Map: " + _listOfMap.toString());

    int maxIdx = 0, currentIdx = 0;
    num maxProb = 0;
    for (var _item in _listOfMap!) {
      if (_item.probability > maxProb) {
        maxProb = _item.probability;
        maxIdx = currentIdx;
      }
      dev.log(_item.className.toString() +
          " : " +
          (_item.probability).toStringAsFixed(4));
      perList[currentIdx] = double.parse(_item.probability.toStringAsFixed(4));
      currentIdx++;
    }
    dev.log(perList.toString());

    _predictIdx = maxIdx;
    dev.log("predictIdx : " + _predictIdx.toString());
    _items.clear();
    dev.log(_contents[_predictIdx].toString());
    _items.add(_contents[_predictIdx]);
    dev.log(_items.toString());
    String discripts = _items[0]['description'];
    String discript1 = _items[0]['description1'];
    String discript2 = _items[0]['description2'];
    String discript3 = _items[0]['description3'];
    String discript4 = _items[0]['description4'];

    _discList = (discripts.split("."));
    _discList1 = (discript1.split("."));
    _discList2 = (discript2.split("."));
    _discList3 = (discript3.split("."));
    _discList4 = (discript4.split("."));

    _setColor = _colorList[_predictIdx];
    _uid = setUid();
    dev.log("web uid:"+_uid);
    setState(() {
      _loading = false;
      _outputs = _listOfMap;
    });

    // startTimer();
  }

  // 이미지 분류 (Mobile)
  Future classifyImage(File image, bool cropped) async {
    dev.log("Image path : $image");
    perList = [0, 0, 0, 0, 0, 0, 0, 0, 0];
    try {
      var output = await Tflite.runModelOnImage(
        path: image.path,
        numResults: 9,
        threshold: 0.01,
        asynch: true,
        // imageMean: 127.5,
        imageStd: 127.5,
        // imageMean: 0,
        // imageStd: 255,
      );
      _predictIdx = output![0]['index'];
      dev.log(output.toString());
      _items.clear();
      dev.log(_contents[_predictIdx].toString());
      _items.add(_contents[_predictIdx]);
      dev.log(_items.toString());
      String discripts = _items[0]['description'];
      String discript1 = _items[0]['description1'];
      String discript2 = _items[0]['description2'];
      String discript3 = _items[0]['description3'];
      String discript4 = _items[0]['description4'];

      _discList = (discripts.split("."));
      _discList1 = (discript1.split("."));
      _discList2 = (discript2.split("."));
      _discList3 = (discript3.split("."));
      _discList4 = (discript4.split("."));
      _setColor = _colorList[_predictIdx];

      //startTimer();

      setState(() {
        _loading = false;
        _outputs = output;
        if (_outputs!.isNotEmpty) {
          for (var data in _outputs!) {
            dev.log(data.toString());
            perList[data['index']] = data['confidence'];
          }
        }
        dev.log(perList.toString());
      });
    } catch (e) {
      dev.log("Error:" + e.toString());
    }
  }

  void nullCallback(){}

  void startTimer() {
     if (!viewText && isTimerNeed){
        // viewText = true;
        _timerCnt = 0;
        isTimerNeed = false;
        _timer?.cancel();
        dev.log("startTimer " + _timerCnt.toString());
        _timer = Timer.periodic(const Duration(milliseconds: 1000),
            (timer){
            _timerCnt++;
            dev.log(_timerCnt.toString()+" get method uid:"+_uid);

            if(!kIsWeb) {
              try {
                fetchPost(_uid);
              } catch (e) {
                dev.log(e.toString());
                _timer?.cancel();
              }
            }

            if (_timerCnt > 60||viewText){
              _timer?.cancel();
              _timer = null;
              dev.log("stop timer cnt:"+_timerCnt.toString()+", VT:"+viewText.toString());
              // setState(() { });
              setState(() {
                viewText = true;
              });
            }
          }
      );
    }
  }

  // 이미지를 보여주는 위젯
  Widget showImage() {
    return GestureDetector(
      onTap: () async {
        await getImage(ImageSource.gallery);
        //recycleDiadev.log();
      },
      child: Container(
          color:
              _image == null ? const Color(0xffd0cece) : const Color(0x00000000),
          margin: const EdgeInsets.only(left: 35, right: 35),
          constraints: const BoxConstraints(minHeight: 250, minWidth: 300),
          // width: MediaQuery.of(context).size.width,
          // height: MediaQuery.of(context).size.width,
          child: Center(
            child: _image == null
              ? const Padding(
                padding: EdgeInsets.all(50.0),
                child: Image(image: AssetImage('assets/face-detection.png')),
              )

              : (kIsWeb)
                  ? Image.network(_image!.path)
                  : Container(
                      height: (imageWidth<imageHeight)? minImageSize: minImageSize * imageHeight / imageWidth ,
                      alignment: Alignment.center,
                      child: Container(

                          height: (imageWidth<imageHeight)? minImageSize: minImageSize * imageHeight / imageWidth ,
                          width: (imageWidth<imageHeight)? minImageSize * imageWidth / imageHeight :minImageSize,

                          child: Stack(
                          fit: StackFit.expand,
                          alignment: Alignment.center,
                          children: <Widget>[
                            Image.file(_image!),
                            if (customPaint != null) customPaint!,
                          ],
                        ),
                        ),
                      ),

          )
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // 화면 세로 고정
    SystemChrome.setPreferredOrientations(
        [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);

    return SafeArea(
      child: Scaffold(
        backgroundColor: bgColor,
        body: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              children: [
                SingleChildScrollView(
                  child: Container(
                    // color: const Color(0xffaaaaaa),
                    constraints: BoxConstraints(
                      maxWidth: (!kIsWeb)?
                          MediaQuery.of(context).size.width:
                          (MediaQuery.of(context).size.width > _webWidth)?
                          _webWidth:MediaQuery.of(context).size.width,
                      minHeight: MediaQuery.of(context).size.height,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        const SizedBox(height: 40.0),
                        Text(
                          _title,
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 25,
                              color: textColor),
                        ),
                        GestureDetector(
                          onTap: () => changeToDark(),
                          child: Text(_darkAlert, style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18, color: Colors.white), ),
                        ),

                        const SizedBox(height: 15.0),
                        Row(
                          mainAxisAlignment: kIsWeb
                              ? MainAxisAlignment.center
                              : MainAxisAlignment.spaceEvenly,
                          children: <Widget>[
                            // 카메라 촬영 버튼
                            Visibility(
                              child: FloatingActionButton(
                                backgroundColor: Colors.orange,
                                child: const Icon(Icons.add_a_photo),
                                tooltip: 'get Image',
                                onPressed: () async {
                                  await getImage(ImageSource.camera);
                                  //recycleDiadev.log();
                                },
                              ),
                              visible: !kIsWeb,
                            ),

                            // 갤러리에서 이미지를 가져오는 버튼
                            FloatingActionButton(
                              backgroundColor: Colors.blue,
                              child: const Icon(Icons.wallpaper),
                              tooltip: 'pick Image',
                              onPressed: () async {
                                await getImage(ImageSource.gallery);
                                //recycleDiadev.log();
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 30.0),
                        showImage(),
                        const SizedBox(height: 15.0),
                        GestureDetector(
                          onTap: (){
                            dev.log("광고 배너 터치");
                            setState(() { viewText = true;});},
                          child: bottomAdsView(banner, context)
                        ),
                        GestureDetector(
                          onTap: () => changeToDark(),
                          child: Text(_darkAlert, style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18, color: Colors.white), ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 15.0,right: 15),
                          child: _outputs!.isNotEmpty
                              ? Column(
                                  children: [
                                    // const SizedBox(height: 25.0),
                                    Text(
                                      _items[0]['name'].toString(),
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: textColor,
                                          fontSize: 25),
                                    ),
                                    const SizedBox(height: 15.0),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Text(
                                          _items[0]['keyword'].toString(),
                                          style: TextStyle(
                                              color: textColor,
                                              fontSize: 20),
                                        ),
                                        const SizedBox(width: 5.0),
                                        Text(
                                          _items[0]['title'].toString(),
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: _setColor,
                                              fontSize: 20),
                                        ),
                                      ],
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(top:10,
                                          left: 15,right: 15,bottom: 10),
                                      child: Stack(
                                        alignment: Alignment.center,
                                        children: [
                                                Column(
                                                  children: [
                                                    TextDataBuilder(data: _discList1,
                                                      viewText:true, descriptIndex: 1,
                                                      textColor: textColor,),
                                                    TextDataBuilder(data: _discList2,
                                                      viewText:viewText, descriptIndex: 2,
                                                      textColor: textColor,),
                                                    TextDataBuilder(data: _discList3,
                                                      viewText:viewText, descriptIndex: 3,
                                                      textColor: textColor,),
                                                    TextDataBuilder(data: _discList4,
                                                      viewText:viewText, descriptIndex: 4,
                                                      textColor: textColor,),
                                                  ],
                                                ),
                                                viewText?
                                                const SizedBox():
                                                Column(
                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                  crossAxisAlignment: CrossAxisAlignment.center,
                                                  children: [
                                                    Text(_askText,
                                                      textAlign: TextAlign.center,
                                                      style: TextStyle(fontWeight: FontWeight.bold,
                                                        color: textColor, fontSize: 20, height: 1.5),),
                                                    GestureDetector(
                                                        onTap: (){
                                                            dev.log("공유하기 터치");
                                                            setState(() { viewText = true;});
                                                          },
                                                        child: kakaoLink(_uid, context, startTimer)
                                                    ),
                                                  ],
                                                ),
                                            ],
                                      ),
                                    ),
                                    const SizedBox(height: 5.0),
                                    (viewText)?kakaoLink(_uid, context, startTimer):const SizedBox(),
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          left: 35,right: 35),
                                      child: Align(
                                        alignment: Alignment.centerLeft,
                                        child: Text(
                                              '연애스타일 : '+
                                            _items[0]['love'].toString(),
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14,
                                              color: textColor),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 15.0),
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          left: 35,right: 35),
                                      child: Align(
                                        alignment: Alignment.centerLeft,
                                        child: Text(
                                          _items[0]['name'].toString()+
                                              ' 유형 연예인: '+
                                              _items[0]['star'].toString(),
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14,
                                              color: textColor),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 25.0),

                                    Column(
                                      children: [
                                        ConfidenceBar(
                                            textColor: textColor,
                                            content: labelList[0],
                                            barColor: _colorList[0],
                                            progress: perList[0]),
                                        ConfidenceBar(
                                            textColor: textColor,
                                            content: labelList[1],
                                            barColor: _colorList[1],
                                            progress: perList[1]),
                                        ConfidenceBar(
                                            textColor: textColor,
                                            content: labelList[2],
                                            barColor: _colorList[2],
                                            progress: perList[2]),
                                        ConfidenceBar(
                                            textColor: textColor,
                                            content: labelList[3],
                                            barColor: _colorList[3],
                                            progress: perList[3]),
                                        ConfidenceBar(
                                            textColor: textColor,
                                            content: labelList[4],
                                            barColor: _colorList[4],
                                            progress: perList[4]),
                                        ConfidenceBar(
                                            textColor: textColor,
                                            content: labelList[5],
                                            barColor: _colorList[5],
                                            progress: perList[5]),
                                        ConfidenceBar(
                                            textColor: textColor,
                                            content: labelList[6],
                                            barColor: _colorList[6],
                                            progress: perList[6]),
                                        ConfidenceBar(
                                            textColor: textColor,
                                            content: labelList[7],
                                            barColor: _colorList[7],
                                            progress: perList[7]),
                                        ConfidenceBar(
                                            textColor: textColor,
                                            content: labelList[8],
                                            barColor: _colorList[8],
                                            progress: perList[8]),
                                      ],
                                    ),
                                  ],
                                )
                              : const SizedBox(),
                        ),
                        const SizedBox(height: 20.0),
                        // bottomAdsView(banner),
                      ],
                    ),
                  ),
                ),

                (_loading) ? Container(
                        width: (!kIsWeb)?
                          MediaQuery.of(context).size.width:
                          (MediaQuery.of(context).size.width > _webWidth)?
                          _webWidth:MediaQuery.of(context).size.width,
                        height: MediaQuery.of(context).size.height,
                        decoration:
                            const BoxDecoration(color: Color(0xccffffff)),
                        child: CircleBar(
                          controller: circleController,
                          size: 120,
                          msg: "분석중..",
                        ))
                    : const SizedBox(),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> getDeviceInfo() async {

    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    if(!kIsWeb) {
      if(Platform.isAndroid) {
        AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
        dev.log('Running on ${androidInfo.model}'); // e.g. "Moto G (4)"
        _deviceInfo = androidInfo.model.toString();
      }else {
        IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
        dev.log('Running on ${iosInfo.utsname.machine}'); // e.g. "iPod7,1"
        _deviceInfo = iosInfo.utsname.machine.toString();
      }
    }else {
      WebBrowserInfo webBrowserInfo = await deviceInfo.webBrowserInfo;
      dev.log('Running on ${webBrowserInfo
          .userAgent}'); // e.g. "Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:61.0) Gecko/20100101 Firefox/61.0"
      _deviceInfo = webBrowserInfo.userAgent.toString();
      // _title = _deviceInfo;
      var brightness = MediaQuery.of(context).platformBrightness;
      bool isDarkMode = brightness == Brightness.dark;
      // _title = isDarkMode.toString();
      // if (_deviceInfo.contains("SamsungBrowser") && isDarkMode){
      //   textColor = Colors.white;
      //   bgColor = Colors.black87;
      //   _darkAlert = "";
      // }
    }
  }

  changeToDark() {
    int now = DateTime.now().millisecondsSinceEpoch;

    int diff = now - startTime;

    startTime = now;

    if(_deviceInfo.contains("SamsungBrowser")&& _darkAlert != ""){
      setState(() {
        textColor = Colors.white;
        bgColor = Colors.black87;
        _darkAlert = "";
      });
    }
  }

  Future<bool> processImage(InputImage inputImage) async {
    if (isBusy) return false;
    isBusy = true;
    FaceDetector faceDetector =
    GoogleMlKit.vision.faceDetector(const FaceDetectorOptions(
      minFaceSize: 0.01,
      enableContours: true,
      enableClassification: true,
    ));

    final faces = await faceDetector.processImage(inputImage);
    dev.log('Found ${faces.length} faces');
    if(faces.isNotEmpty){
      print('face top:${faces[0].boundingBox.top} ');
      print('face bottom:${faces[0].boundingBox.bottom} ');
      print('face left:${faces[0].boundingBox.left} ');
      print('face right:${faces[0].boundingBox.right} ');
      dev.log('face box:${faces[0].boundingBox.size} ');
    }else{
      return false;
    }
    if (inputImage.inputImageData?.size != null &&
        inputImage.inputImageData?.imageRotation != null) {
      dev.log('Live painter');
      dev.log('face size: ${inputImage.inputImageData?.size} ');
      dev.log('face imageRotation: ${inputImage.inputImageData?.imageRotation} ');
      final painter = FaceDetectorPainter(
          faces,
          inputImage.inputImageData!.size,
          inputImage.inputImageData!.imageRotation);
      customPaint = CustomPaint(painter: painter);
    } else {
      if(faces.isNotEmpty ) {
        final String path = inputImage.filePath!;
        dev.log('Gallery painter path : ${inputImage.filePath}');

        File imageFile = File(path);
        // print('File path : ${imageFile.path}');
        int fileLength = await imageFile.length();
        // print('File length : ${fileLength}');

        final decodedImage = await decodeImageFromList(imageFile.readAsBytesSync());
        // final Size size = Size(decodedImage.height.toDouble(), decodedImage.width.toDouble());
        double wRatio = decodedImage.width / 300;
        double hRatio = decodedImage.height / 300;

        final Size size = Size(decodedImage.width.toDouble(),
            decodedImage.height.toDouble());

        print('image size : $size');
        // print('imageRotation: ${InputImageRotation.Rotation_0deg} ');
        final painter = FaceDetectorPainter(
            faces,
            size,
            InputImageRotation.Rotation_0deg);
        customPaint = CustomPaint(painter: painter);
      }else{
        customPaint = null;
      }
    }
    isBusy = false;
    if (mounted) {
      setState(() {});
    }
    return true;
  }

}

class DefaultUriPolicy implements html.UriPolicy {
  DefaultUriPolicy();

  bool allowsUri(String uri) {
    // Return true/false based on uri comparison
    return true;
  }
}
