import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/utils/image_picker_utils.dart';
import '../blocs/image_detection/image_detection_bloc.dart';
import '../blocs/image_detection/image_detection_state.dart';


class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Detection de mask',
          style: GoogleFonts.roboto(),
        ),
      ),
      body: BlocBuilder<ImageDetectionBloc, ImageDetectionState>(
        builder: (context, state) {
          return Container(
            child: Column(
              children: [
                Container(
                  height: 150,
                  width: 150,
                  padding: EdgeInsets.all(10),
                  child: Image.asset('assets/mask.png'),
                ),
                Container(
                  child: Text(
                    'Mask Detector',
                    style: GoogleFonts.roboto(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(height: 50),
                Container(
                  child: Column(
                    children: [
                      Container(
                        padding: EdgeInsets.only(left: 10, right: 10),
                        height: 50,
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            primary: Colors.teal[800],
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          onPressed: () {
                            pickImageCamera(context);
                          },
                          child: Text(
                            'Capture',
                            style: GoogleFonts.roboto(fontSize: 18),
                          ),
                        ),
                      ),
                      SizedBox(height: 10),
                      Container(
                        padding: EdgeInsets.only(left: 10, right: 10),
                        height: 50,
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            primary: Colors.teal[800],
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          onPressed: () {
                            pickImageGallery(context);
                          },
                          child: Text(
                            'Gallery',
                            style: GoogleFonts.roboto(fontSize: 18),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                if (!state.loading && state.image != null)
                  Container(
                    child: Column(
                      children: [
                        Container(
                          height: 220,
                          padding: EdgeInsets.all(15),
                          child: Image.file(state.image!),
                        ),
                        SizedBox(height: 10),
                        if (state.output != null && state.output!.isNotEmpty)
                          Text(
                            'Prediction: ${state.output![0]['label']}',
                            style: GoogleFonts.roboto(fontSize: 18),
                          ),
                        if (state.output != null && state.output!.isNotEmpty)
                          Text(
                            'Confidence: ${state.output![0]['confidence']}',
                            style: GoogleFonts.roboto(fontSize: 18),
                          ),
                      ],
                    ),
                  )
                else
                  Container(),
              ],
            ),
          );
        },
      ),
    );
  }
}