import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';
import '../urls/Urls.dart';

class BankAccountCreationScreen extends StatefulWidget {
  final Map<String, dynamic> bankDetails;
  final String userId;

  const BankAccountCreationScreen({
    Key? key,
    required this.bankDetails,
    required this.userId,
  }) : super(key: key);

  @override
  _BankAccountCreationScreenState createState() =>
      _BankAccountCreationScreenState();
}

class _BankAccountCreationScreenState extends State<BankAccountCreationScreen> {
  File? rectoCNI;
  File? versoCNI;
  bool isLoading = false;

  Future<void> _pickImage(bool isRecto) async {
    // Vérifier et demander la permission
    final status = await Permission.photos.request();
    if (status.isDenied) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Permission d\'accès à la galerie requise'),
        ),
      );
      return;
    }

    if (status.isPermanentlyDenied) {
      // Ouvrir les paramètres de l'application
      await openAppSettings();
      return;
    }

    final ImagePicker picker = ImagePicker();
    try {
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 70,
      );
      if (image != null) {
        setState(() {
          if (isRecto) {
            rectoCNI = File(image.path);
          } else {
            versoCNI = File(image.path);
          }
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Erreur lors de la sélection de l\'image'),
        ),
      );
    }
  }

  Future<void> _submitForm() async {
    if (rectoCNI == null || versoCNI == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Veuillez sélectionner les deux images CNI')),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final dio = Dio();
      final formData = FormData.fromMap({
        'userId': widget.userId,
        'bankId': widget.bankDetails['id'],
        'recto_cni': await MultipartFile.fromFile(rectoCNI!.path),
        'verso_cni': await MultipartFile.fromFile(versoCNI!.path),
      });

      final response = await dio.post(
        '${Urls.serviceDemand}/api/requests',
        data: formData,
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Demande envoyée avec succès')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erreur lors de l\'envoi de la demande')),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Création de compte bancaire'),
        backgroundColor: Colors.blue,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Informations de la banque',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    Text('Nom: ${widget.bankDetails['bank_name']}'),
                    const SizedBox(height: 8),
                    Text('Adresse: ${widget.bankDetails['address']}'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Documents requis',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildImageUploadSection(
                      'Recto CNI',
                      rectoCNI,
                      () => _pickImage(true),
                    ),
                    const SizedBox(height: 16),
                    _buildImageUploadSection(
                      'Verso CNI',
                      versoCNI,
                      () => _pickImage(false),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isLoading ? null : _submitForm,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Colors.blue,
                ),
                child: isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'Soumettre la demande',
                        style: TextStyle(fontSize: 16),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageUploadSection(
      String title, File? image, VoidCallback onTap) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        InkWell(
          onTap: onTap,
          child: Container(
            height: 120,
            width: double.infinity,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(8),
            ),
            child: image == null
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.add_photo_alternate, size: 40),
                      SizedBox(height: 8),
                      Text('Cliquez pour ajouter une image'),
                    ],
                  )
                : Image.file(image, fit: BoxFit.cover),
          ),
        ),
      ],
    );
  }
}
