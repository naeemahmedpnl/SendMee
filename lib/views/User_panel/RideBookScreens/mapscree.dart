
// import 'package:flutter/material.dart';
// import 'package:geocoding/geocoding.dart';
// import 'package:easy_localization/easy_localization.dart';

// class GeocodeWidget extends StatefulWidget {
//   @override
//   _GeocodeWidgetState createState() => _GeocodeWidgetState();
// }

// class _GeocodeWidgetState extends State<GeocodeWidget> {
//   final TextEditingController _addressController = TextEditingController();
//   final TextEditingController _latitudeController = TextEditingController();
//   final TextEditingController _longitudeController = TextEditingController();
//   String _output = '';

//   @override
//   void initState() {
//     _addressController.text = 'Gronausestraat 710, Enschede';
//     _latitudeController.text = '52.2165157';
//     _longitudeController.text = '6.9437819';
//     super.initState();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         mainAxisAlignment: MainAxisAlignment.start,
//         children: <Widget>[
//           const Padding(
//             padding: EdgeInsets.only(top: 32),
//           ),
//           Row(
//             children: <Widget>[
//               Expanded(
//                 child: TextField(
//                   autocorrect: false,
//                   controller: _latitudeController,
//                   style: Theme.of(context).textTheme.bodyMedium,
//                   decoration: InputDecoration(
//                     hintText: 'geocode.latitude'.tr(),
//                   ),
//                   keyboardType: TextInputType.number,
//                 ),
//               ),
//               const SizedBox(
//                 width: 20,
//               ),
//               Expanded(
//                 child: TextField(
//                   autocorrect: false,
//                   controller: _longitudeController,
//                   style: Theme.of(context).textTheme.bodyMedium,
//                   decoration: InputDecoration(
//                     hintText: 'geocode.longitude'.tr(),
//                   ),
//                   keyboardType: TextInputType.number,
//                 ),
//               ),
//             ],
//           ),
//           const Padding(
//             padding: EdgeInsets.only(top: 8),
//           ),
//           Center(
//             child: ElevatedButton(
//               child: Text('geocode.look_up_address'.tr()),
//               onPressed: () {
//                 final latitude = double.parse(_latitudeController.text);
//                 final longitude = double.parse(_longitudeController.text);

//                 placemarkFromCoordinates(latitude, longitude).then((placemarks) {
//                   var output = 'geocode.no_results'.tr();
//                   if (placemarks.isNotEmpty) {
//                     output = placemarks[0].toString();
//                   }

//                   setState(() {
//                     _output = output;
//                   });
//                 });
//               },
//             ),
//           ),
//           const Padding(
//             padding: EdgeInsets.only(top: 32),
//           ),
//           TextField(
//             autocorrect: false,
//             controller: _addressController,
//             style: Theme.of(context).textTheme.bodyMedium,
//             decoration: InputDecoration(
//               hintText: 'geocode.address'.tr(),
//             ),
//             keyboardType: TextInputType.text,
//           ),
//           const Padding(
//             padding: EdgeInsets.only(top: 8),
//           ),
//           Center(
//             child: ElevatedButton(
//               child: Text('geocode.look_up_location'.tr()),
//               onPressed: () {
//                 locationFromAddress(_addressController.text).then((locations) {
//                   var output = 'geocode.no_results'.tr();
//                   if (locations.isNotEmpty) {
//                     output = locations[0].toString();
//                   }
//                   setState(() {
//                     _output = output;
//                   });
//                 });
//               },
//             ),
//           ),
//           const Padding(
//             padding: EdgeInsets.only(top: 8),
//           ),
//           Center(
//             child: ElevatedButton(
//               child: Text('geocode.is_present'.tr()),
//               onPressed: () {
//                 isPresent().then((isPresent) {
//                   var output = isPresent 
//                     ? 'geocode.is_present_true'.tr() 
//                     : 'geocode.is_present_false'.tr();
//                   setState(() {
//                     _output = output;
//                   });
//                 });
//               },
//             ),
//           ),
//           const Padding(
//             padding: EdgeInsets.only(top: 8),
//           ),
//           Center(
//             child: ElevatedButton(
//               child: Text('geocode.set_locale_en'.tr()),
//               onPressed: () {
//                 setLocaleIdentifier("en_US").then((_) {
//                   setState(() {});
//                 });
//               },
//             ),
//           ),
//           const Padding(
//             padding: EdgeInsets.only(top: 8),
//           ),
//           Center(
//             child: ElevatedButton(
//               child: Text('geocode.set_locale_nl'.tr()),
//               onPressed: () {
//                 setLocaleIdentifier("nl_NL").then((_) {
//                   setState(() {});
//                 });
//               },
//             ),
//           ),
//           const Padding(
//             padding: EdgeInsets.only(top: 8),
//           ),
//           Expanded(
//             child: SingleChildScrollView(
//               child: Container(
//                 width: MediaQuery.of(context).size.width,
//                 child: Text(_output),
//               ),
//             ),
//           )
//         ],
//       ),
//     );
//   }
// }