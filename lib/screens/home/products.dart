import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:home_maintenance/languages/ar.dart';
import 'package:home_maintenance/screens/home/home.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class Products extends StatefulWidget {
  const Products({Key? key}) : super(key: key);

  @override
  _ProductsState createState() => _ProductsState();
}

class _ProductsState extends State<Products>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;
  late Database database;

  final TextEditingController _searchController = TextEditingController();
  final GlobalKey _cartIconKey = GlobalKey();
  final Map<Map<String, dynamic>, GlobalKey> _productCardKeys = {};

  int _cartItemCount = 0;
  List<Map<String, dynamic>> _allProducts = [];
  List<Map<String, dynamic>> _filteredProducts = [];

  @override
  void initState() {
    super.initState();
    _initDatabase();
    _initializeAnimations();
    _initializeProductList();
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

  void _initializeAnimations() {
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 0.5),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeIn,
      ),
    );
    _animationController.forward();
  }

  void _initializeProductList() {
    _allProducts = [
      {'name': "صيانة " + 'الغسالات', 'price': 10.0},
      {'name': "صيانة " + 'المكيفات', 'price': 15.0},
      {'name': "صيانة " + 'الثلاجات', 'price': 20.0},
      {'name': "صيانة " + 'أفران الميكروويف', 'price': 25.0},
      {'name': "صيانة " + 'الشاشات', 'price': 30.0},
      {'name': "صيانة " + 'الهواتف', 'price': 35.0},
      {'name': "صيانة " + 'الخلاطات', 'price': 40.0},
      {'name': "صيانة " + 'السخانات', 'price': 45.0},
      {'name': "صيانة " + 'المراوح', 'price': 50.0},
      {'name': "صيانة " + 'المواتير', 'price': 55.0},
      {'name': "صيانة " + 'الشفاطات', 'price': 60.0},
      {'name': "صيانة " + 'الدفايات', 'price': 65.0},
    ];
    _filteredProducts = _allProducts;
  }

  @override
  void dispose() {
    _searchController.dispose();
    _animationController.dispose();
    database.close();
    super.dispose();
  }

  void _addToCart(BuildContext context, Map<String, dynamic> product) async {
    await database.insert(
      'cart',
      product,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    final count = Sqflite.firstIntValue(
      await database.rawQuery('SELECT COUNT(*) FROM cart'),
    );
    setState(() {
      _cartItemCount = count!;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${product['name']} added to cart'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _filterProducts(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredProducts = _allProducts;
      } else {
        _filteredProducts = _allProducts
            .where((product) =>
                product['name'].toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: Text(
          Ar.products,
          style: GoogleFonts.cairo(
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          _buildCartButton(context),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: Ar.search,
                hintStyle: GoogleFonts.cairo(),
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20.0),
                ),
              ),
              onChanged: _filterProducts,
            ),
            const SizedBox(height: 16.0),
            Expanded(
              child: SlideTransition(
                position: _slideAnimation,
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: ListView(
                    children: [
                      _buildServiceSection(),
                      const SizedBox(height: 16.0),
                      _buildProductGrid(),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildServiceSection() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildServiceCard('التوصيل', Icons.local_shipping, Colors.blue),
        _buildServiceCard('الإعادة', Icons.undo, Colors.green),
        _buildServiceCard('الدعم', Icons.headset_mic, Colors.orange),
      ],
    );
  }

  Widget _buildServiceCard(String title, IconData icon, Color color) {
    return Card(
      elevation: 4.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: InkWell(
        onTap: () {},
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 32.0, color: color),
              const SizedBox(height: 8.0),
              Text(title,
                  style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProductGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.75,
        crossAxisSpacing: 16.0,
        mainAxisSpacing: 16.0,
      ),
      itemCount: _filteredProducts.length,
      itemBuilder: (context, index) {
        final product = _filteredProducts[index];
        _productCardKeys[product] = GlobalKey();
        return _buildProductCard(context, product, index);
      },
    );
  }

  Widget _buildProductCard(
      BuildContext context, Map<String, dynamic> product, int index) {
    IconData iconData;
    Color iconColor;
    String productName;

    switch (index) {
      case 0:
        iconData = Icons.wash;
        iconColor = Colors.blue;
        productName = 'الغسالات';
        break;
      case 1:
        iconData = FontAwesomeIcons.snowflake;
        iconColor = Colors.green;
        productName = 'المكيفات';
        break;
      case 2:
        iconData = Icons.kitchen;
        iconColor = Colors.orange;
        productName = 'الثلاجات';
        break;
      case 3:
        iconData = Icons.microwave;
        iconColor = Colors.purple;
        productName = 'أفران الميكروويف';
        break;
      case 4:
        iconData = FontAwesomeIcons.tv;
        iconColor = Colors.red;
        productName = 'الشاشات';
        break;
      case 5:
        iconData = FontAwesomeIcons.mobileScreenButton;
        iconColor = Colors.pink;
        productName = 'الهواتف';
        break;
      case 6:
        iconData = FontAwesomeIcons.blender;
        iconColor = Colors.teal;
        productName = 'الخلاطات';
        break;
      case 7:
        iconData = FontAwesomeIcons.fire;
        iconColor = Colors.indigo;
        productName = 'السخانات';
        break;
      case 8:
        iconData = FontAwesomeIcons.fan;
        iconColor = Colors.lime;
        productName = 'المراوح';
        break;
      case 9:
        iconData = Icons.heat_pump;
        iconColor = Colors.deepOrange;
        productName = 'المواتير';
        break;
      case 10:
        iconData = Icons.cleaning_services;
        iconColor = Colors.cyan;
        productName = 'الشفاطات';
        break;
      case 11:
        iconData = Icons.fireplace;
        iconColor = Colors.amber;
        productName = 'الدفايات';
        break;
      default:
        iconData = Icons.fireplace;
        iconColor = Colors.blue;
        productName = 'Product';
        break;
    }

    return GestureDetector(
      onTap: () async {
        _addToCart(context, product);
      },
      child: Card(
        elevation: 12.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
        ),
        color: Colors.transparent,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16.0),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white,
                Colors.grey[200]!,
              ],
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Center(
                  child: FaIcon(iconData, size: 64.0, color: iconColor),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      productName,
                      style: GoogleFonts.cairo(
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6.0),
                    Text(
                      '\$${product['price']?.toStringAsFixed(2) ?? '0.00'}', // Format price
                      style: TextStyle(
                        fontSize: 16.0,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCartButton(BuildContext context) {
    return Stack(
      key: _cartIconKey,
      alignment: Alignment.topRight,
      children: [
        IconButton(
          icon: const Icon(Icons.shopping_cart),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => const Home(
                        page_index: 1,
                      )),
            );
          },
        ),
        if (_cartItemCount > 0)
          Positioned(
            right: 7,
            top: 7,
            child: Container(
              padding: const EdgeInsets.all(4.0),
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
              child: Text(
                '$_cartItemCount',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
