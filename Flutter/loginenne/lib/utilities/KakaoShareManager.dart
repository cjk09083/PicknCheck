

import 'dart:developer' as dev;

import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';
import 'package:loginenne/Widgets/CustomToast.dart';

class KakaoShareManager {

  static final KakaoShareManager _manager = KakaoShareManager._internal();

  factory KakaoShareManager() {
    return _manager;
  }

  KakaoShareManager._internal() {
    // 초기화 코드
  }

  void initializeKakaoSDK() {
    KakaoSdk.init(nativeAppKey: 'ef9450ecafdee177e81ec948d4908c8c');
  }

  Future<bool> isKakaotalkInstalled() async {
    bool installed = await isKakaoTalkInstalled();
    return installed;
  }

  Future<List<String>> shareMyCode(String uuid) async {
    List<String> receiverUuids = ["null"];
    try {
      var template = _getTemplate();
      Map<String, String> callback = {'uuid': uuid};
      print("카톡 defaultTemplate 생성");

      try {
        var uri = await LinkClient.instance.defaultTemplate(
            template: template, serverCallbackArgs: callback
        );
        await LinkClient.instance.launchKakaoTalk(uri);

        print("카톡 연동 Start");

      }catch(e){
        // 예외처리를 위한 코드
        print("카톡 연동 실패 : "+e.toString());
      }

      // keytool -exportcert -alias safetyhome -keystore /Users/cjk/AndroidStudioProjects/safetyhome-keystore.jks | openssl sha1 -binary | openssl base64

      // await TalkApi.instance.sendDefaultMessage(receiverUuids: receiverUuids, template: template);
      return receiverUuids;
    } catch (error) {
      dev.log(error.toString());
      return receiverUuids;
    }
  }

  DefaultTemplate _getTemplate() {
    String title = "얼굴성격검사";
    String description = "얼굴로 알아보는 동물성격유형";

    String webUrl = "http://pickncheck.com/animal/";
    String mobileWebUrl = "market://details?id=com.loginsoft.loginenne";

    Uri imageLink = Uri.parse("http://pickncheck.com/animal/app_logo.png");
    Link link = Link(
        webUrl: Uri.parse(webUrl),
        mobileWebUrl: Uri.parse(webUrl),
        androidExecutionParams : {},
        iosExecutionParams: {},
    );

    Content content = Content(
      description: description,
      title:title,
      imageUrl:imageLink,
      link:link,
    );

    FeedTemplate template = FeedTemplate(
      content:content,
      // social: Social(likeCount: 286, commentCount: 45, sharedCount: 845),
      buttons: [
        Button(title: "웹으로 보기",
            link: Link(
                mobileWebUrl: Uri.parse(webUrl),
                webUrl: Uri.parse(webUrl)
            )
        ),
        Button(title: "앱으로 보기",
            link: Link(
              androidExecutionParams : {},
              iosExecutionParams: {},
            )),
      ],
    );

    return template;
  }
}