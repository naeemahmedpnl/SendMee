
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapThemePopup extends StatelessWidget {
  const MapThemePopup({
    super.key,
    required Completer<GoogleMapController> controller,
  }) : _controller = controller;

  final Completer<GoogleMapController> _controller;

  @override
  Widget build(BuildContext context) {


    return PopupMenuButton(
      icon:const  Icon(Icons.map, color: Colors.amber), 
      itemBuilder: (context) => [
        PopupMenuItem(
          onTap: () {
            _controller.future.then((value) {
              DefaultAssetBundle.of(context)
                  .loadString('assets/map_theme/standard_theme.json')
                  .then((string) {
                value.setMapStyle(string);
              });
            });
          },
          child: const Text("Standard Mode"),
        ),
        PopupMenuItem(
          onTap: () {
            _controller.future.then((value) {
              DefaultAssetBundle.of(context)
                  .loadString('assets/map_theme/night_theme.json')
                  .then((string) {
                value.setMapStyle(string);
              });
            });
          },
          child: const Text("Night Mode"),
        ),
        PopupMenuItem(
          onTap: () {
            _controller.future.then((value) {
              DefaultAssetBundle.of(context)
                  .loadString('assets/map_theme/retro_theme.json')
                  .then((string) {
                value.setMapStyle(string);
              });
            });
          },
          child: const Text("Retro Mode"),
        ),
        PopupMenuItem(
          onTap: () {
            _controller.future.then((value) {
              DefaultAssetBundle.of(context)
                  .loadString('assets/map_theme/aubergine_theme.json')
                  .then((string) {
                value.setMapStyle(string);
              });
            });
          },
          child: const Text("Dark Blue Mode"),
        ),
      ],
    );
  }
}
