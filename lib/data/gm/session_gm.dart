import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blog/_core/utils/my_http.dart';
import 'package:flutter_blog/data/repository/user_repository.dart';
import 'package:flutter_blog/main.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';

//창고겸(데이터)
class SessionGM {
  int? id;
  String? username;
  String? accessToken;
  bool isLogin;

  SessionGM({this.id, this.username, this.accessToken, this.isLogin = false});

  final mContext = navigatorKey.currentContext!;

  Future<void> login(String username, String password) async {
    //1. 통신 //body안에 {success:머시기, statue:머시기 errorMessage:머시기, response:오브젝트
    var (body, accessToken) = await UserRepository().login(username, password);

    Logger().d("세션창고의 login() 메서드 실행됨 ${body}, ${accessToken}");

    //2. 성공 or 실패 처리
    if (body["success"]) {
      Logger().d("로그인 성공");
      //(1) sessionGM 값 변경   session이라 생각하면 된다
      this.id = body["response"]["id"];
      this.username = body["response"]["username"];
      this.accessToken = accessToken;
      //true했다고 상태 변경 안됨
      this.isLogin = true;

      //(2) 휴대폰 하드 저장
      await secureStorage.write(key: "accessToken", value: accessToken);

      //(3) dio에 토큰 세팅
      //accessToken하고 베이어 토큰 둘다 넣어야한다
      dio.options.headers["Authorization"] = accessToken;

      //(4) 화면 이동
      Navigator.pushNamed(mContext, "/post/list");
    } else {
      Logger().d("로그인 실패");
      ScaffoldMessenger.of(mContext).showSnackBar(
        SnackBar(content: Text("${body["errorMessage"]}")),
      );
    }
  }

  Future<void> join() async {}

  Future<void> logout() async {
    await secureStorage.delete(key: "accessToken");
    this.id = null;
    this.username = null;
    this.accessToken = null;
    this.isLogin = false;
    //this.id 이런곳에 왜 await안 붙여도될까 cpu가 되니까 그냥 빨리됨
    Navigator.popAndPushNamed(mContext, "/login");
  }

  Future<void> autoLogin() async {
    //1. 시큐어 스토리지에서 accessToken꺼내기
    //꺼냈을 때 null이면 로그인페이지로 꺼내면 던지기
    String? accessToken = await secureStorage.read(key: "accessToken");
    Logger().d("로그인 토큰 : ${accessToken}");
    if (accessToken == null) {
      Navigator.popAndPushNamed(mContext, "/login");
      Logger().d("로그인 실패 오토");
    } else {
      Logger().d("로그인 성공 오토");
      //2. api 호출
      Map<String, dynamic> body = await UserRepository().autoLogin(accessToken);
      //3. 세션값 갱신 트루 이런거 넣어주는 것
      this.id = body["response"]["id"];
      this.username = body["response"]["username"];
      this.accessToken = accessToken;
      this.isLogin = true;
      //4. 정상이면 post/list로 이동(pop and pushNamed)
      Navigator.popAndPushNamed(mContext, "/post/list");
    }

    // Future.delayed(
    //   Duration(seconds: 3),
    //   () {
    //     Navigator.popAndPushNamed(mContext, "/post/list");
    //   },
    // );
  }
}

final sessionProvider = StateProvider<SessionGM>((ref) {
  return SessionGM();
});
