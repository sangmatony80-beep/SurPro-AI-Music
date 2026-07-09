import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ManualPaymentApprove extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Manual Payments')),
      body: StreamBuilder(
        stream: Supabase.instance.client.from('manual_payments').stream(primaryKey: ['id']).eq('status', 'pending'),
        builder: (context, snapshot) {
          if(!snapshot.hasData) return Center(child: CircularProgressIndicator());
          final payments = snapshot.data!;
          if(payments.isEmpty) return Center(child: Text('কোনো পেমেন্ট নাই'));
          return ListView.builder(
            itemCount: payments.length,
            itemBuilder: (context, i) {
              final p = payments[i];
              return Card(child: ListTile(
                leading: Image.network(p['screenshot_url'], width: 50, height: 50),
                title: Text('${p['amount']} টাকা - ${p['plan_name']}'),
                subtitle: Text('TrxID: ${p['trx_id']}'),
                trailing: ElevatedButton(onPressed: () async {
                  await Supabase.instance.client.from('manual_payments').update({'status': 'approved'}).eq('id', p['id']);
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Approved ✅')));
                }, child: Text('Approve')),
              ));
            },
          );
        },
      ),
    );
  }
}
