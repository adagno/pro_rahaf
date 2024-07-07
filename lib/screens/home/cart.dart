import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:home_maintenance/constants/colors.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:home_maintenance/languages/ar.dart';

class Cart extends StatefulWidget {
  const Cart({super.key});

  @override
  _CartState createState() => _CartState();
}

class _CartState extends State<Cart> with SingleTickerProviderStateMixin {
  late Database database;
  List<Map<String, dynamic>> cartItems = [];
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initDatabase().then((_) {
      _fetchCartItems();
    });

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 0.5),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    database.close();
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _initDatabase() async {
    database = await openDatabase(
      join(await getDatabasesPath(), 'cart_database.db'),
      onCreate: (db, version) {
        return db.execute(
          'CREATE TABLE cart(id INTEGER PRIMARY KEY, name TEXT, price REAL)',
        );
      },
      version: 1,
    );
  }

  Future<void> _fetchCartItems() async {
    final List<Map<String, dynamic>> items = await database.query('cart');
    setState(() {
      cartItems = items;
    });
  }

  Future<void> _deleteCartItem(int id) async {
    await database.delete(
      'cart',
      where: 'id = ?',
      whereArgs: [id],
    );
    _fetchCartItems();
  }

  void _showCheckoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: Text(
            Ar.checkout,
            style: GoogleFonts.cairo(),
          ),
          content: SizedBox(
            width: MediaQuery.of(context).size.width / 1.5,
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: _nameController,
                    style: GoogleFonts.cairo(),
                    decoration: InputDecoration(
                      labelStyle: GoogleFonts.cairo(),
                      labelText: Ar.enterName,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(color: Colors.white),
                      ),
                      filled: true,
                      fillColor: const Color.fromARGB(255, 255, 255, 255)
                          .withOpacity(0.5),
                    ),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return Ar.requiredFailed;
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _phoneController,
                    style: GoogleFonts.cairo(),
                    decoration: InputDecoration(
                      labelStyle: GoogleFonts.cairo(),
                      labelText: Ar.enterPhone,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(color: Colors.white),
                      ),
                      filled: true,
                      fillColor: const Color.fromARGB(255, 255, 255, 255)
                          .withOpacity(0.5),
                    ),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return Ar.requiredFailed;
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _addressController,
                    style: GoogleFonts.cairo(),
                    decoration: InputDecoration(
                      labelStyle: GoogleFonts.cairo(),
                      labelText: Ar.enterAddress,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(color: Colors.white),
                      ),
                      filled: true,
                      fillColor: const Color.fromARGB(255, 255, 255, 255)
                          .withOpacity(0.5),
                    ),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return Ar.requiredFailed;
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: [
            Center(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 255, 51, 0),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 50,
                        vertical: 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text(
                      Ar.cancel,
                      style: GoogleFonts.cairo(),
                    ),
                  ),
                  const SizedBox(width: 20),
                  ElevatedButton(
                    onPressed: cartItems.isEmpty
                        ? null
                        : () {
                            if (_formKey.currentState!.validate()) {
                              String name = _nameController.text;
                              String phone = _phoneController.text;
                              String address = _addressController.text;

                              if (kDebugMode) {
                                print(
                                    'Name: $name, Phone: $phone, Address: $address');
                              }

                              // Show success snackbar
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(Ar.checkoutSuccess),
                                  duration: Duration(seconds: 2),
                                ),
                              );

                              // Delete items from cart after successful checkout
                              for (var item in cartItems) {
                                _deleteCartItem(item['id'] as int);
                              }

                              Navigator.pop(context);
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4CAF50),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 50,
                        vertical: 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Text(
                      Ar.checkout,
                      style: GoogleFonts.cairo(),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final totalPrice =
        cartItems.fold(0.0, (sum, item) => sum + item['price'] as double);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: backgroundColor,
        appBar: AppBar(
          title: const Text(Ar.cart),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: cartItems.length,
                  itemBuilder: (context, index) {
                    final item = cartItems[index];
                    return FadeTransition(
                      opacity: _fadeAnimation,
                      child: SlideTransition(
                        position: _slideAnimation,
                        child: Dismissible(
                          key: Key(item['id'].toString()),
                          direction: DismissDirection.endToStart,
                          background: Container(
                            color: Colors.red,
                            alignment: Alignment.centerRight,
                            padding:
                                const EdgeInsets.symmetric(horizontal: 16.0),
                            child:
                                const Icon(Icons.delete, color: Colors.white),
                          ),
                          onDismissed: (direction) {
                            _deleteCartItem(item['id'] as int);
                          },
                          child: Card(
                            color: const Color(0xFF2C2C2C),
                            elevation: 4,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: ListTile(
                              title: Text(
                                item['name'] as String,
                                style: GoogleFonts.cairo(color: Colors.white),
                              ),
                              subtitle: Text(
                                '\$${item['price']}',
                                style: GoogleFonts.cairo(color: Colors.white),
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              Text(
                'Total: \$${totalPrice.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: cartItems.isEmpty
                    ? null
                    : () {
                        _showCheckoutDialog(context);
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4CAF50),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 50,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Text(
                  Ar.checkout,
                  style: GoogleFonts.cairo(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
