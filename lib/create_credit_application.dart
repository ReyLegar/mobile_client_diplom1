import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class CreateCreditApplicationScreen extends StatefulWidget {
  final String accessToken;

  const CreateCreditApplicationScreen({Key? key, required this.accessToken})
      : super(key: key);

  @override
  _CreateCreditApplicationScreenState createState() =>
      _CreateCreditApplicationScreenState();
}

class _CreateCreditApplicationScreenState
    extends State<CreateCreditApplicationScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _amountController;

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController();
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _createCreditApplication() async {
    final response = await http.post(
      Uri.parse('https://localhost/api/credit_applications_create/'),
      headers: {
        'Authorization': 'Bearer ${widget.accessToken}',
        'Content-Type': 'application/json; charset=utf-8',
      },
      body: jsonEncode({
        'amount': double.parse(_amountController.text),
      }),
    );

    if (response.statusCode == 201) {
      // Заявка создана успешно, перейти на другой экран
    } else {
      throw Exception('Failed to create credit application');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Создать заявку на кредит'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Сумма заявки',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Введите сумму заявки';
                  }
                  final amount = double.tryParse(value);
                  if (amount == null || amount <= 0) {
                    return 'Введите корректную сумму заявки';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        _createCreditApplication();
                      }
                    },
                    child: Text('Создать заявку'),
                  ),
                  SizedBox(width: 16),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text('Отмена'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
