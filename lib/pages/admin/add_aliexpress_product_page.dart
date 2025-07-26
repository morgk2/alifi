import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';

class AddAliexpressProductPage extends StatefulWidget {
  const AddAliexpressProductPage({super.key});

  @override
  State<AddAliexpressProductPage> createState() => _AddAliexpressProductPageState();
}

class _AddAliexpressProductPageState extends State<AddAliexpressProductPage> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  final List<String> _photos = [];

  // Form fields
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _affiliateUrlController = TextEditingController();
  final _categoryController = TextEditingController();
  final _priceController = TextEditingController();
  final _originalPriceController = TextEditingController();
  final _ordersController = TextEditingController();
  final _ratingController = TextEditingController();
  final _shippingTimeController = TextEditingController();
  bool _isFreeShipping = false;

  // Photo URL controller
  final _photoUrlController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _affiliateUrlController.dispose();
    _categoryController.dispose();
    _priceController.dispose();
    _originalPriceController.dispose();
    _ordersController.dispose();
    _ratingController.dispose();
    _shippingTimeController.dispose();
    _photoUrlController.dispose();
    super.dispose();
  }

  Future<void> _addProduct() async {
    if (!_formKey.currentState!.validate()) return;
    if (_photos.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add at least one photo')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Check if user is admin
      final authService = context.read<AuthService>();
      if (!authService.currentUser!.isAdmin) {
        throw 'Unauthorized: Admin access required';
      }

      // Create product data
      final productData = {
        'title': _titleController.text.trim(),
        'description': _descriptionController.text.trim(),
        'affiliateUrl': _affiliateUrlController.text.trim(),
        'category': _categoryController.text.trim(),
        'price': double.parse(_priceController.text),
        'originalPrice': double.parse(_originalPriceController.text),
        'orders': int.parse(_ordersController.text),
        'rating': double.parse(_ratingController.text),
        'shippingTime': _shippingTimeController.text.trim(),
        'isFreeShipping': _isFreeShipping,
        'photos': _photos,
        'createdAt': FieldValue.serverTimestamp(),
        'lastUpdatedAt': FieldValue.serverTimestamp(),
        'isActive': true,
      };

      // Add to Firestore
      await FirebaseFirestore.instance
          .collection('aliexpresslistings')
          .add(productData);

      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Product added successfully')),
      );

      // Clear form
      _formKey.currentState!.reset();
      _photos.clear();
      setState(() {});

    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _addPhoto() {
    final url = _photoUrlController.text.trim();
    if (url.isEmpty) return;

    setState(() {
      _photos.add(url);
      _photoUrlController.clear();
    });
  }

  void _removePhoto(int index) {
    setState(() {
      _photos.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add AliExpress Product'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Title
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Description
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a description';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Affiliate URL
              TextFormField(
                controller: _affiliateUrlController,
                decoration: const InputDecoration(
                  labelText: 'Affiliate URL',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter an affiliate URL';
                  }
                  if (!value.startsWith('https://')) {
                    return 'Please enter a valid HTTPS URL';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Category
              TextFormField(
                controller: _categoryController,
                decoration: const InputDecoration(
                  labelText: 'Category',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a category';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Price and Original Price
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _priceController,
                      decoration: const InputDecoration(
                        labelText: 'Price',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Required';
                        }
                        if (double.tryParse(value) == null) {
                          return 'Invalid number';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _originalPriceController,
                      decoration: const InputDecoration(
                        labelText: 'Original Price',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Required';
                        }
                        if (double.tryParse(value) == null) {
                          return 'Invalid number';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Orders and Rating
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _ordersController,
                      decoration: const InputDecoration(
                        labelText: 'Orders',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Required';
                        }
                        if (int.tryParse(value) == null) {
                          return 'Invalid number';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _ratingController,
                      decoration: const InputDecoration(
                        labelText: 'Rating',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Required';
                        }
                        final rating = double.tryParse(value);
                        if (rating == null || rating < 0 || rating > 5) {
                          return 'Invalid rating';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Shipping Time
              TextFormField(
                controller: _shippingTimeController,
                decoration: const InputDecoration(
                  labelText: 'Shipping Time',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter shipping time';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Free Shipping Switch
              SwitchListTile(
                title: const Text('Free Shipping'),
                value: _isFreeShipping,
                onChanged: (value) {
                  setState(() {
                    _isFreeShipping = value;
                  });
                },
              ),
              const SizedBox(height: 16),

              // Photos Section
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        'Photos',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _photoUrlController,
                              decoration: const InputDecoration(
                                labelText: 'Photo URL',
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          ElevatedButton(
                            onPressed: _addPhoto,
                            child: const Text('Add Photo'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      if (_photos.isNotEmpty) ...[
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: List.generate(_photos.length, (index) {
                            return Stack(
                              children: [
                                Container(
                                  width: 100,
                                  height: 100,
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.grey),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.network(
                                      _photos[index],
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) {
                                        return const Center(
                                          child: Icon(Icons.error),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                                Positioned(
                                  right: 0,
                                  top: 0,
                                  child: IconButton(
                                    icon: const Icon(Icons.remove_circle),
                                    color: Colors.red,
                                    onPressed: () => _removePhoto(index),
                                  ),
                                ),
                              ],
                            );
                          }),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Submit Button
              ElevatedButton(
                onPressed: _isLoading ? null : _addProduct,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator()
                    : const Text('Add Product'),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 