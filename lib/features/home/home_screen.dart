// import 'package:flutter/material.dart';
// import 'package:nvidiaapp/core/services/paypal_service.dart';

// class HomeScreen extends StatefulWidget {
//   const HomeScreen({super.key});

//   @override
//   State<HomeScreen> createState() => _HomeScreenState();
// }

// class _HomeScreenState extends State<HomeScreen> {
// final PaypalService paypalService = PaypalService();

//   bool isLoading = false;
//   String message = 'Belum dites';
//   bool? isConnected;

//   Future<void> checkConnection() async {
//     setState(() {
//       isLoading = true;
//       message = 'Menghubungkan ke PayPal Sandbox...';
//       isConnected = null;
//     });

//     try {
//       final result = await paypalService.testConnection();

//       setState(() {
//         isConnected = true;
//         message =
//             '${result['message']}\n'
//             'App ID: ${result['app_id']}\n'
//             'Token Type: ${result['token_type']}\n'
//             'Expires In: ${result['expires_in']} seconds';
//       });
//     } catch (e) {
//       setState(() {
//         isConnected = false;
//         message = e.toString();
//       });
//     } finally {
//       setState(() => isLoading = false);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('PayPal Connection Test')),
//       body: Padding(
//         padding: const EdgeInsets.all(20),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(
//               isConnected == true
//                   ? Icons.check_circle
//                   : isConnected == false
//                       ? Icons.error
//                       : Icons.account_balance_wallet,
//               size: 65,
//               color: isConnected == true
//                   ? Colors.green
//                   : isConnected == false
//                       ? Colors.red
//                       : Colors.blue,
//             ),
//             const SizedBox(height: 20),
//             const Text(
//               'PayPal Sandbox',
//               style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
//             ),
//             const SizedBox(height: 15),
//             Text(message, textAlign: TextAlign.center),
//             const SizedBox(height: 25),
//             SizedBox(
//               width: double.infinity,
//               child: ElevatedButton(
//                 onPressed: isLoading ? null : checkConnection,
//                 child: isLoading
//                     ? const CircularProgressIndicator()
//                     : const Text('TEST CONNECTION'),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }