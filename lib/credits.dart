import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:url_launcher/url_launcher.dart';
import 'dart:html' as html;



class Credit {
  final int id;
  final double amount;
  final List<String> paymentDates;

  Credit({required this.id, required this.amount, required this.paymentDates});

  factory Credit.fromJson(Map<String, dynamic> json) {
    List<dynamic> paymentDatesJson = json['payment_dates'];
    List<String> paymentDates = paymentDatesJson.cast<String>();
    return Credit(
      id: json['id'],
      amount: json['amount'].toDouble(),
      paymentDates: paymentDates,
    );
  }
}

class CreditsPage extends StatefulWidget {
  final String accessToken;

  const CreditsPage({Key? key, required this.accessToken}) : super(key: key);

  @override
  _CreditsPageState createState() => _CreditsPageState();
}

class _CreditsPageState extends State<CreditsPage> {
  late Future<List<Credit>> _futureCredits;

  Future<List<Credit>> _fetchCredits() async {
    final response = await http.get(
      Uri.parse('http://localhost/api/credits/'),
      headers: {
        'Authorization': 'Bearer ${widget.accessToken}',
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );
    if (response.statusCode == 200) {
      List<dynamic> creditsJson = json.decode(response.body);
      List<Credit> credits = [];
      for (var creditJson in creditsJson) {
        Credit credit = Credit.fromJson(creditJson);
        credits.add(credit);
      }
      return credits;
    } else {
      throw Exception('Failed to load credits');
    }
  }

  @override
  void initState() {
    super.initState();
    _futureCredits = _fetchCredits();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Кредиты'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Center(
        child: FutureBuilder<List<Credit>>(
          future: _futureCredits,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return ListView.builder(
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) {
                  Credit credit = snapshot.data![index];
                  return ExpansionTile(
                    title: Text('ID Кредита: ${credit.id}'),
                    subtitle: Text('Сумма: ${credit.amount}'),
                    children: [
                      for (var i = 0; i < credit.paymentDates.length; i++)
                        ListTile(
                          title: Text('Дата ${i + 1}: ${credit.paymentDates[i]}'),
                        ),
                      ElevatedButton(
                        onPressed: () {
                          _generatePDF(context, credit);
                        },
                        child: Text('Генерация квитанции'),
                      ),
                    ],
                  );
                },
              );
            } else if (snapshot.hasError) {
              return Text("${snapshot.error}");
            }
            return CircularProgressIndicator();
          },
        ),
      ),
    );
  }

  void _generatePDF(BuildContext context, Credit credit) async {
    final url = Uri.parse('http://localhost:8000/api/generate_pdf/');
    final headers = {
      'Content-Type': 'application/json; charset=UTF-8',
    };
    final body = jsonEncode({
      'id': credit.id,
      'amount': credit.amount,
      'payment_dates': credit.paymentDates,
    });

    final response = await http.post(url, headers: headers, body: body);
    if (response.statusCode == 200) {
      // Сохранение PDF в файл
      final blob = html.Blob([response.bodyBytes], 'application/pdf');
      final url = html.Url.createObjectUrlFromBlob(blob);
      html.window.open(url, '_blank');
      html.Url.revokeObjectUrl(url);
    } else {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Error'),
          content: Text('Failed to generate the PDF.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        ),
      );
    }
  }

}
