import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path/path.dart' as path;
import '../../models/store_product.dart';
import '../../services/auth_service.dart';
import '../../services/database_service.dart';
import '../../services/storage_service.dart';
import '../../widgets/spinning_loader.dart';

class AddStoreProductPage extends StatefulWidget {
  final StoreProduct? product;  // If editing existing product

  const AddStoreProductPage({super.key, this.product});

  @override
  State<AddStoreProductPage> createState() => _AddStoreProductPageState();
}

class _AddStoreProductPageState extends State<AddStoreProductPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _shippingTimeController = TextEditingController();
  final _stockQuantityController = TextEditingController();
  
  String _selectedCategory = 'Food';
  bool _isFreeShipping = false;
  List<File> _selectedImages = [];
  bool _isLoading = false;
  String _loadingMessage = '';
  
  final List<String> _categories = [
    'Food',
    'Toys',
    'Health',
    'Beds',
    'Hygiene',
    'Other',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.product != null) {
      _nameController.text = widget.product!.name;
      _descriptionController.text = widget.product!.description;
      _priceController.text = widget.product!.price.toString();
      _shippingTimeController.text = widget.product!.shippingTime;
      _stockQuantityController.text = widget.product!.stockQuantity.toString();
      _selectedCategory = widget.product!.category;
      _isFreeShipping = widget.product!.isFreeShipping;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _shippingTimeController.dispose();
    _stockQuantityController.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    try {
      final ImagePicker picker = ImagePicker();
      final List<XFile> images = await picker.pickMultiImage();
      
      if (images.isNotEmpty) {
        // Process each image
        for (var image in images) {
          // Get original file size
          final originalBytes = await image.readAsBytes();
          final originalSize = originalBytes.length;
          
          // Compress the image
          final File originalFile = File(image.path);
          final String dir = path.dirname(image.path);
          final String newPath = path.join(dir, 'compressed_${path.basename(image.path)}');
          
          final compressedFile = await FlutterImageCompress.compressAndGetFile(
            originalFile.path,
            newPath,
            quality: 60,  // Same compression quality as pet photos
            minWidth: 800,  // Same dimensions as pet photos
            minHeight: 800,
            rotate: 0,
          );
          
          if (compressedFile != null) {
            setState(() {
              _selectedImages.add(File(compressedFile.path));
            });
            
            final compressedSize = File(compressedFile.path).lengthSync();
            final compressionRatio = (1 - (compressedSize / originalSize)) * 100;
            
            print('Image compressed successfully:');
            print('- Original size: ${(originalSize / 1024).toStringAsFixed(2)} KB');
            print('- Compressed size: ${(compressedSize / 1024).toStringAsFixed(2)} KB');
            print('- Compression ratio: ${compressionRatio.toStringAsFixed(1)}%');
          }
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking images: $e')),
      );
    }
  }

  Future<void> _saveProduct() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedImages.isEmpty && widget.product?.imageUrls.isEmpty != false) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one image')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _loadingMessage = 'Uploading images...';
    });

    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final storageService = Provider.of<StorageService>(context, listen: false);
      final dbService = DatabaseService();
      
      if (authService.currentUser == null) {
        throw Exception('No user logged in');
      }

      // Upload images
      List<String> imageUrls = widget.product?.imageUrls ?? [];
      for (var image in _selectedImages) {
        final url = await storageService.uploadPetPhoto(image);
        imageUrls.add(url);
      }

      setState(() {
        _loadingMessage = 'Saving product...';
      });

      final product = StoreProduct(
        id: widget.product?.id ?? '',
        name: _nameController.text,
        description: _descriptionController.text,
        price: double.parse(_priceController.text),
        currency: 'USD',  // Hardcoded for now
        imageUrls: imageUrls,
        category: _selectedCategory,
        isFreeShipping: _isFreeShipping,
        shippingTime: _shippingTimeController.text,
        stockQuantity: int.parse(_stockQuantityController.text),
        storeId: authService.currentUser!.id,
        rating: widget.product?.rating ?? 0.0,
        totalOrders: widget.product?.totalOrders ?? 0,
        createdAt: widget.product?.createdAt ?? DateTime.now(),
        lastUpdatedAt: DateTime.now(),
      );

      if (widget.product != null) {
        await dbService.updateStoreProduct(product);
      } else {
        await dbService.createStoreProduct(product);
      }

      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving product: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.product != null ? 'Edit Product' : 'Add Product'),
      ),
      body: Stack(
        children: [
          Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Product Name',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a product name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a description';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _priceController,
                        decoration: const InputDecoration(
                          labelText: 'Price (USD)',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a price';
                          }
                          if (double.tryParse(value) == null) {
                            return 'Please enter a valid number';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        controller: _stockQuantityController,
                        decoration: const InputDecoration(
                          labelText: 'Stock Quantity',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter quantity';
                          }
                          if (int.tryParse(value) == null) {
                            return 'Please enter a valid number';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _selectedCategory,
                  decoration: const InputDecoration(
                    labelText: 'Category',
                    border: OutlineInputBorder(),
                  ),
                  items: _categories.map((category) {
                    return DropdownMenuItem(
                      value: category,
                      child: Text(category),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedCategory = value!;
                    });
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _shippingTimeController,
                  decoration: const InputDecoration(
                    labelText: 'Shipping Time (e.g., "3-5 days")',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter shipping time';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                SwitchListTile(
                  title: const Text('Free Shipping'),
                  value: _isFreeShipping,
                  onChanged: (bool value) {
                    setState(() {
                      _isFreeShipping = value;
                    });
                  },
                ),
                const SizedBox(height: 16),
                const Text(
                  'Product Images',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                if (widget.product != null) ...[
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: widget.product!.imageUrls.map((url) {
                      return Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(8),
                          image: DecorationImage(
                            image: NetworkImage(url),
                            fit: BoxFit.cover,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                ],
                if (_selectedImages.isNotEmpty)
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _selectedImages.map((image) {
                      return Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(8),
                          image: DecorationImage(
                            image: FileImage(image),
                            fit: BoxFit.cover,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: _pickImages,
                  icon: const Icon(Icons.add_photo_alternate),
                  label: const Text('Add Images'),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 48),
                  ),
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: _isLoading ? null : _saveProduct,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 48),
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                  ),
                  child: Text(
                    widget.product != null ? 'Update Product' : 'Add Product',
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
          ),
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SpinningLoader(size: 50),
                    const SizedBox(height: 16),
                    Text(
                      _loadingMessage,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
} 