import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';

class ManualNagadScreen extends StatefulWidget {
  final int planPrice;
  final String planName;
  const ManualNagadScreen({required this.planPrice, required this.planName});

  @override
  State<ManualNagadScreen> createState() => _ManualNagadScreenState();
}

class _ManualNagadScreenState extends State<ManualNagadScreen> {
  final trxController = TextEditingController();
  XFile? screenshot;
  final String myNagadNumber = "01757128059";

  Future<void> submitProof() async {
    if(trxController.text.isEmpty || screenshot == null){
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('TrxID + Screenshot লাগবে')));
      return;
    }
    final fileName = 'nagad/${DateTime.now().millisecondsSinceEpoch}.jpg';
    await Supabase.instance.client.storage.from('payments').upload(fileName, await screenshot!.readAsBytes());
    final imageUrl = Supabase.instance.client.storage.from('payments').getPublicUrl(fileName);
    await Supabase.instance.client.from('manual_payments').insert({
      'user_id': Supabase.instance.client.auth.currentUser!.id,
      'amount': widget.planPrice, 'plan_name': widget.planName, 'method': 'nagad',
      'trx_id': trxController.text, 'screenshot_url': imageUrl, 'status': 'pending',
    });
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('সাবমিট হইছে ✅')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Nagad Payment')),
      body: Padding(padding: EdgeInsets.all(16), child: Column(children: [
        Text('Send Money করুন:', style: TextStyle(fontSize: 18)),
        SizedBox(height: 8),
        SelectableText("01757 128 059", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.orange)),
        Text('Amount: ${widget.planPrice} টাকা'),
        Divider(height: 32),
        TextField(controller: trxController, decoration: InputDecoration(hintText: 'Transaction ID লিখুন')),
        SizedBox(height: 16),
        ElevatedButton.icon(onPressed: () async => screenshot = await ImagePicker().pickImage(source: ImageSource.gallery),
          icon: Icon(Icons.upload), label: Text('Screenshot দিন')),
        if(screenshot!= null) Text('Selected: ${screenshot!.name}'),
        Spacer(),
        ElevatedButton(onPressed: submitProof, child: Text('Submit'), style: ElevatedButton.styleFrom(minimumSize: Size(double.infinity, 50))),
      ])),
    );
  }
}
