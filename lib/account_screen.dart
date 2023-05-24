import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'create_credit_application.dart';
import 'credits.dart';

class UserInfoScreen extends StatefulWidget {
  final String accessToken;

  const UserInfoScreen({Key? key, required this.accessToken}) : super(key: key);

  @override
  _UserInfoScreenState createState() => _UserInfoScreenState();
}

class _UserInfoScreenState extends State<UserInfoScreen> {
  late Future<Map<String, dynamic>> _userData;

  @override
  void initState() {
    super.initState();
    _userData = _getUserData();
  }

  Future<Map<String, dynamic>> _getUserData() async {
    final response = await http.get(
      Uri.parse('https://localhost/api/get_user/'),
      headers: {
        'Authorization': 'Bearer ${widget.accessToken}',
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(utf8.decode(response.bodyBytes));
    } else {
      throw Exception('Failed to load user data');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Профиль'),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _userData,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final userData = snapshot.data!;
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 16.0),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Имя: ${userData['first_name']}',
                            style: Theme
                                .of(context)
                                .textTheme
                                .subtitle1,
                          ),
                          SizedBox(height: 8.0),
                          Text(
                            'Фамилия: ${userData['last_name']}',
                            style: Theme
                                .of(context)
                                .textTheme
                                .subtitle1,
                          ),
                          SizedBox(height: 8.0),
                          Text(
                            'Отчество: ${userData['patronymic']}',
                            style: Theme
                                .of(context)
                                .textTheme
                                .subtitle1,
                          ),
                          SizedBox(height: 8.0),
                          Text(
                            'Баланс: ${userData['balance']}',
                            style: Theme
                                .of(context)
                                .textTheme
                                .subtitle1,
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 16.0),
                  Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    CreateCreditApplicationScreen(
                                      accessToken: widget.accessToken,
                                    ),
                              ),
                            );
                          },
                          child: Text('Создать заявку на кредит'),
                        ),
                      ),
                      SizedBox(height: 16.0),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    CreditsPage(
                                      accessToken: widget.accessToken,
                                    ),
                              ),
                            );
                          },
                          child: Text('Кредит'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text('${snapshot.error}'),
            );
          } else {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      ),
    );
  }
}