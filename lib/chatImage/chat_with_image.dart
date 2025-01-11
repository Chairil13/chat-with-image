import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_chat_google_ai/chatImage/api.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lottie/lottie.dart';

class ChatImage extends StatefulWidget {
  const ChatImage({super.key});

  @override
  State<ChatImage> createState() => _MainPageState();
}

class _MainPageState extends State<ChatImage> {
  TextEditingController textEditingController = TextEditingController();
  String answer = ''; // Menyimpan jawaban dari AI
  XFile? image; // Menyimpan gambar yang diambil
  bool isLoading = false; // Menyimpan status awal loading
  bool isAIResponding = false; // Menyimpan status awal respons AI

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text(
            'Chat Image',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          iconTheme: const IconThemeData(color: Colors.white),
          backgroundColor: Colors.blueGrey,
          centerTitle: true,
        ),
        body: Stack(
          children: [
            Column(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: ListView(
                      children: [
                        const SizedBox(height: 20),
                        Container(
                          width: double.infinity,
                          height: 200,
                          decoration: BoxDecoration(
                            color: image == null
                                ? Colors.grey.shade200
                                : null, // Warna latar belakang jika gambar tidak ada
                            borderRadius: BorderRadius.circular(10),
                            image: image != null
                                ? DecorationImage(
                                    image: FileImage(File(image!
                                        .path))) // Menampilkan gambar jika ada
                                : null,
                          ),
                        ),
                        const SizedBox(height: 20),
                        if (answer.isNotEmpty) ...[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.copy),
                                onPressed: () {
                                  Clipboard.setData(
                                      ClipboardData(text: answer));
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content:
                                          Text('Teks disalin ke clipboard'),
                                      backgroundColor:
                                          Color.fromARGB(255, 0, 166, 126),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                          MarkdownBody(
                            data: answer,
                            selectable: true,
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 18.0, vertical: 15.0),
                  child: TextField(
                    controller: textEditingController,
                    minLines: 1,
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: 'Tanyakan sesuatu...',
                      hintStyle: const TextStyle(color: Colors.black45),
                      filled: true,
                      fillColor: const Color.fromARGB(255, 168, 212, 250),
                      border: OutlineInputBorder(
                        borderSide: BorderSide.none,
                        gapPadding: 0,
                        borderRadius: BorderRadius.circular(26.0),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 18.0, vertical: 8.0),
                      prefixIcon: IconButton(
                        icon: const Icon(Icons.image),
                        onPressed: () {
                          ImagePicker()
                              .pickImage(source: ImageSource.gallery)
                              .then(
                            (value) {
                              setState(() {
                                image = value;
                              });
                            },
                          );
                        },
                      ),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.send),
                        onPressed: () {
                          if (image == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content:
                                    Text('Harap pilih gambar terlebih dahulu'),
                                backgroundColor: Colors.red,
                              ),
                            );
                            return;
                          }

                          setState(() {
                            isLoading = true;
                            isAIResponding = true;
                            answer = '';
                          });

                          debugPrint('Mengirim permintaan ke API...');
                          debugPrint('Teks: ${textEditingController.text}');
                          debugPrint('Gambar: ${image!.path}');

                          GenerativeModel model = GenerativeModel(
                              model: 'gemini-1.5-flash', apiKey: apiKey);

                          model.generateContent([
                            Content.multi([
                              TextPart(textEditingController.text),
                              DataPart('image/jpeg',
                                  File(image!.path).readAsBytesSync())
                            ])
                          ]).then((value) {
                            debugPrint('Menerima respons dari API:');
                            debugPrint(value.text.toString());

                            setState(() {
                              answer = value.text.toString();
                              isLoading = false;
                              isAIResponding = false;
                            });
                          }).catchError((error) {
                            debugPrint('Terjadi kesalahan: $error');
                            setState(() {
                              isLoading = false;
                              isAIResponding = false;
                            });
                          });
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),
            if (isLoading)
              Positioned.fill(
                child: Center(
                  child: Lottie.asset(
                    'assets/animation/loadingImage.json',
                    width: 200,
                    height: 200,
                  ),
                ),
              ),
          ],
        ));
  }
}
