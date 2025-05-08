import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:kothayhisab/data/models/shop_model.dart';
import 'package:kothayhisab/presentation/common_widgets/app_bar.dart';
import 'package:kothayhisab/presentation/common_widgets/custom_bottom_app_bar.dart';
import 'package:kothayhisab/data/api/services/shops_service.dart';

class ShopUpdateScreen extends StatefulWidget {
  const ShopUpdateScreen({super.key, required this.shop});
  final Shop shop;

  @override
  State<ShopUpdateScreen> createState() => _ShopUpdateScreenState();
}

class _ShopUpdateScreenState extends State<ShopUpdateScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final ShopsService _shopsService = ShopsService();

  bool _isLoading = false;
  bool _isGPSLocationLoading = false;

  String? _errorMessage;
  Position? _currentPosition;

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.shop.name;
    _addressController.text = widget.shop.address;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _getCurrentLocation() async {
    setState(() {
      _isGPSLocationLoading = true;
      _errorMessage = null;
    });

    try {
      // Check location permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          print('লোকেশান পারমিশন দেওয়া হয়নি');
          setState(() {
            _isGPSLocationLoading = false;
            _errorMessage = 'লোকেশান পারমিশন দেওয়া হয়নি';
          });
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        print('লোকেশান পারমিশন স্থায়ীভাবে বন্ধ করা আছে');
        setState(() {
          _isGPSLocationLoading = false;
          _errorMessage = 'লোকেশান পারমিশন স্থায়ীভাবে বন্ধ করা আছে';
        });
        return;
      }

      // Get current position
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        _currentPosition = position;
        _isGPSLocationLoading = false;
      });
    } catch (e) {
      print('লোকেশান পেতে সমস্যা: ${e.toString()}');
      setState(() {
        _errorMessage = 'লোকেশান পেতে সমস্যা হয়েছে';
        _isGPSLocationLoading = false;
      });
    }
  }

  void _showSuccessToast(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 3,
      backgroundColor: Colors.green,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }

  void _showErrorToast(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 3,
      backgroundColor: Colors.red,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }

  Future<void> _saveShop() async {
    // Validate the form
    if (!_formKey.currentState!.validate()) {
      return; // Stop if validation fails
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      String gpsLocation =
          _currentPosition == null
              ? widget.shop.gpsLocation ?? ''
              : '{latitude: ${_currentPosition!.latitude}, longitude: ${_currentPosition!.longitude}}';

      String address = _addressController.text;

      // Create shop object with the shop id from the existing shop
      Shop updatedShop = Shop(
        id: widget.shop.id, // Keep the original ID
        name: _nameController.text,
        address: address,
        gpsLocation: gpsLocation,
      );

      // Call the service to update the shop
      final result = await _shopsService.updateShop(updatedShop);

      setState(() {
        _isLoading = false;
      });

      if (result) {
        // Show success toast
        _showSuccessToast('দোকান আপডেট সফল হয়েছে!');

        // Navigate back after a short delay to ensure toast is visible
        Future.delayed(Duration(milliseconds: 500), () {
          if (mounted) {
            Navigator.pushReplacementNamed(context, '/');
          }
        });
      } else {
        setState(() {
          _errorMessage = 'দোকান আপডেট করতে সমস্যা হয়েছে';
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'দোকান আপডেট করতে সমস্যা: ${e.toString()}';
      });
    }
  }

  void _showDeleteConfirmation() {
    TextEditingController confirmController = TextEditingController();
    bool canDelete = false;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('দোকান মুছে ফেলুন'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'আপনি কি নিশ্চিত এই দোকান মুছে ফেলতে চান?',
                    style: TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: confirmController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'নিশ্চিত করতে "yes" লিখুন',
                    ),
                    onChanged: (value) {
                      setDialogState(() {
                        canDelete = value.toLowerCase() == 'yes';
                      });
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('বাতিল করুন'),
                ),
                TextButton(
                  onPressed:
                      canDelete
                          ? () {
                            Navigator.pop(context);
                            Navigator.pop(context, 'deleted');
                          }
                          : null,
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.red,
                    disabledForegroundColor: Colors.grey,
                  ),
                  child: const Text('মুছে ফেলুন'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar('দোকানের তথ্য পরিবর্তন'),
      body: Stack(
        children: [
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Shop Name Input
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.store, color: Colors.grey),
                        labelText: 'দোকান নাম',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 12,
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'দোকান নাম দিতে হবে';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 16),

                    // Address Input
                    TextFormField(
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
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 12,
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'দোকান ঠিকানা দিতে হবে';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 24),

                    // GPS Location Status
                    Container(
                      height: 48,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4),
                        color: const Color.fromARGB(255, 185, 224, 247),
                      ),
                      child: Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (_isGPSLocationLoading)
                              const Padding(
                                padding: EdgeInsets.only(right: 10.0),
                                child: SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.0,
                                    color: Colors.blue,
                                  ),
                                ),
                              ),
                            Text(
                              _isGPSLocationLoading
                                  ? 'আপনার জিপিএস লোকেশান নেওয়া হচ্ছে....'
                                  : _currentPosition != null
                                  ? 'আপনার জিপিএস লোকেশান পাওয়া গেছে!'
                                  : widget.shop.gpsLocation != null &&
                                      widget.shop.gpsLocation!.isNotEmpty
                                  ? 'আগের জিপিএস লোকেশান আছে'
                                  : 'আপনার অবস্থান পাওয়া যায়নি',
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Get GPS Location Button
                    SizedBox(
                      height: 48,
                      child: ElevatedButton.icon(
                        onPressed: _isLoading ? null : _getCurrentLocation,
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.blue.shade800,
                          backgroundColor: Colors.blue.shade100,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        icon: const Icon(Icons.gps_fixed),
                        label: const Text(
                          'জিপিএস লোকেশান নিন',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
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
                                ? const CircularProgressIndicator(
                                  color: Colors.white,
                                )
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
                  ],
                ),
              ),
            ),
          ),

          // Loading overlay
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
      bottomNavigationBar: CustomBottomAppBar(),
    );
  }
}
