import 'package:flutter/material.dart';
import 'package:upi_pro_sdk/upi_pro_sdk.dart';

void main() {
  runApp(const ExampleApp());
}

class ExampleApp extends StatelessWidget {
  const ExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'UPI Pro SDK Example',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      home: const UpiDemoPage(),
    );
  }
}

class UpiDemoPage extends StatefulWidget {
  const UpiDemoPage({super.key});

  @override
  State<UpiDemoPage> createState() => _UpiDemoPageState();
}

class _UpiDemoPageState extends State<UpiDemoPage> {
  final UpiProSdk _sdk = UpiProSdk();
  final TextEditingController _upiIdController = TextEditingController(
    text: 'merchant@okaxis',
  );
  final TextEditingController _nameController = TextEditingController(
    text: 'Test Merchant',
  );
  final TextEditingController _amountController = TextEditingController(
    text: '1.00',
  );
  final TextEditingController _noteController = TextEditingController(
    text: 'SDK test payment',
  );

  bool _isBusy = false;
  List<UpiApp> _apps = const <UpiApp>[];
  String _log = 'Tap "Refresh Installed Apps" to begin.';

  @override
  void dispose() {
    _upiIdController.dispose();
    _nameController.dispose();
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _refreshApps() async {
    await _runGuarded(() async {
      final apps = await _sdk.getInstalledApps();
      setState(() {
        _apps = apps;
        _log = apps.isEmpty
            ? 'No verified UPI apps found.'
            : 'Found ${apps.length} verified app(s).';
      });
    });
  }

  Future<void> _payWithPicker() async {
    await _runGuarded(() async {
      final request = _buildRequest();
      final response = await _sdk.payWithAppPicker(context, request);
      setState(() {
        _log = _formatResponse(response);
      });
    });
  }

  Future<void> _payWithFirstInstalledApp() async {
    await _runGuarded(() async {
      final request = _buildRequest();
      final apps = _apps.isEmpty ? await _sdk.getInstalledApps() : _apps;
      if (apps.isEmpty) {
        throw const NoUpiAppFoundException();
      }
      final response = await _sdk.pay(request, app: apps.first);
      setState(() {
        _log = _formatResponse(response);
      });
    });
  }

  UpiPaymentRequest _buildRequest() {
    final amount = double.tryParse(_amountController.text.trim()) ?? 0;
    return UpiPaymentRequest(
      upiId: _upiIdController.text.trim(),
      name: _nameController.text.trim(),
      amount: amount,
      note: _noteController.text.trim().isEmpty
          ? null
          : _noteController.text.trim(),
    );
  }

  Future<void> _runGuarded(Future<void> Function() action) async {
    if (_isBusy) {
      return;
    }
    setState(() {
      _isBusy = true;
    });
    try {
      await action();
    } catch (e) {
      setState(() {
        _log = 'Error: $e';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isBusy = false;
        });
      }
    }
  }

  String _formatResponse(UpiResponse response) {
    final failureTypeName = response.failureType.name;
    return [
      'Status: ${response.status.name}',
      if (failureTypeName != 'none' && failureTypeName != 'unknown')
        'FailureType: $failureTypeName',
      if (response.txnId != null) 'TxnId: ${response.txnId}',
      if (response.responseCode != null)
        'ResponseCode: ${response.responseCode}',
      if (response.approvalRefNo != null)
        'ApprovalRefNo: ${response.approvalRefNo}',
      if (response.statusMessage != null)
        'StatusMessage: ${response.statusMessage}',
    ].join('\n');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('UPI Pro SDK Example')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _upiIdController,
                decoration: const InputDecoration(
                  labelText: 'Payee UPI ID',
                  hintText: 'merchant@okaxis',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Payee Name'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _amountController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(labelText: 'Amount (INR)'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _noteController,
                decoration: const InputDecoration(labelText: 'Note (Optional)'),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  ElevatedButton(
                    onPressed: _isBusy ? null : _refreshApps,
                    child: const Text('Refresh Installed Apps'),
                  ),
                  ElevatedButton(
                    onPressed: _isBusy ? null : _payWithPicker,
                    child: const Text('Pay With Picker'),
                  ),
                  OutlinedButton(
                    onPressed: _isBusy ? null : _payWithFirstInstalledApp,
                    child: const Text('Pay With First App'),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Text(
                'Installed Verified Apps (${_apps.length})',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              if (_apps.isEmpty)
                const Text('No app data loaded yet.')
              else
                ..._apps.map(
                  (app) => ListTile(
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    leading: app.icon != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: Image.memory(
                              app.icon!,
                              width: 28,
                              height: 28,
                              fit: BoxFit.cover,
                            ),
                          )
                        : const Icon(Icons.account_balance_wallet_outlined),
                    title: Text(app.name),
                    subtitle: Text(app.identifier),
                  ),
                ),
              const SizedBox(height: 16),
              Text('Logs', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(_log),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
