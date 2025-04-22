import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:kothayhisab/presentation/common_widgets/app_bar.dart';
import 'package:kothayhisab/presentation/common_widgets/custom_bottom_app_bar.dart';
import 'package:kothayhisab/data/api/services/shops_service.dart';
import 'package:kothayhisab/data/models/shop_model.dart';
import 'package:kothayhisab/core/constants/app_routes.dart';

class ShopCreationScreen extends StatefulWidget {
  const ShopCreationScreen({super.key});

  @override
  State<ShopCreationScreen> createState() => _ShopCreationScreenState();
}

class _ShopCreationScreenState extends State<ShopCreationScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final ShopsService _shopsService = ShopsService();

  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;

  Position? _currentPosition;
  String? _currentAddress;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _getCurrentLocation() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Check location permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Location permissions are denied');
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw Exception('Location permissions are permanently denied');
      }

      // Get current position
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        _currentPosition = position;
      });

      // Get address from coordinates
      await _getAddressFromLatLng(position);
    } catch (e) {
      setState(() {
        _errorMessage = 'Error getting location: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _getAddressFromLatLng(Position position) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        String address =
            '${place.street}, ${place.subLocality}, ${place.locality}, ${place.postalCode}';

        setState(() {
          _currentAddress = address;
          _addressController.text = address;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error getting address: ${e.toString()}';
      });
    }
  }

  Future<void> _saveShop() async {
    if (_nameController.text.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter shop name';
      });
      return;
    }

    if (_currentPosition == null) {
      setState(() {
        _errorMessage = 'Location data not available';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _successMessage = null;
    });

    try {
      String gpsLocation =
          '{latitude: ${_currentPosition!.latitude}, longitude: ${_currentPosition!.longitude}}';
      String address =
          _addressController.text.isNotEmpty
              ? _addressController.text
              : 'Unknown Address';

      // Create shop object
      Shop shop = Shop(
        name: _nameController.text,
        address: address,
        gpsLocation: gpsLocation,
      );

      // Call the service to create the shop
      final result = await _shopsService.createShop(shop);

      if (result) {
        // Clear form after successful submission
        _nameController.clear();

        // Show success dialog with Go to Home button
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('সফল!'),
              content: const Text('দোকান সফলভাবে যোগ করা হয়েছে!'),
              actions: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: const Color(0xFF0069A5),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop(); // Close dialog
                    Navigator.of(context).pushReplacementNamed(
                      AppRoutes.homePage,
                    ); // Navigate to home
                  },
                  child: const Text('হোম পেজে যান'),
                ),
              ],
            );
          },
        );
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error creating shop: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar('দোকান যোগ করুন'),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Shop Name Input
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.store, color: Colors.grey),
                      labelText: 'দোকান নাম',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Address Input with Location Icon
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: _addressController,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(
                        Icons.location_on,
                        color: Colors.grey,
                      ),
                      labelText: 'দোকান ঠিকানা',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Save Button
              SizedBox(
                height: 48,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveShop,
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: const Color(0xFF0069A5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  child:
                      _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                            'সেভ করুন',
                            style: TextStyle(fontSize: 16),
                          ),
                ),
              ),

              const SizedBox(height: 16),

              // Error message
              if (_errorMessage != null)
                Container(
                  padding: const EdgeInsets.all(8),
                  color: Colors.red[100],
                  child: Text(
                    _errorMessage!,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),

              // Success message
              if (_successMessage != null)
                Container(
                  padding: const EdgeInsets.all(8),
                  color: Colors.green[100],
                  child: Text(
                    _successMessage!,
                    style: const TextStyle(color: Colors.green),
                  ),
                ),

              // Location info
              // if (_currentPosition != null)
              //   Padding(
              //     padding: const EdgeInsets.only(top: 16.0),
              //     child: Text(
              //       'GPS: ${_currentPosition!.latitude}, ${_currentPosition!.longitude}',
              //       style: const TextStyle(fontSize: 12, color: Colors.grey),
              //     ),
              //   ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: CustomBottomAppBar(),
    );
  }
}
