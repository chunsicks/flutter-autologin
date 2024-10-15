import 'package:dio/dio.dart';
import 'package:flutter_blog/_core/utils/my_http.dart';

class UserRepository {
  //정확한거는 assess토큰 유효한지 서버쪽에서 찾겠다는 거임
  Future<Map<String, dynamic>> autoLogin(String accessToken) async {
    final response = await dio.post(
      "/auto/login",
      options: Options(
        headers: {"Authorization": "Bearer $accessToken"}
      ),
    );


    //one에 응답됨  왜 리턴해야하냐면 세션정보 갱신?
    Map<String, dynamic> body = response.data;
    return body;
  }

  Future<(Map<String, dynamic>,String)> login(String username, String password) async {
    final response = await dio.post(
      "/login",
      data: {
        "username":username,
        "password":password
      }
    );
    String accessToken = response.headers["Authorization"]![0];
    //one에 응답됨  왜 리턴해야하냐면 세션정보 갱신?
    Map<String, dynamic> body = response.data;
    return (body,accessToken);
  }
}