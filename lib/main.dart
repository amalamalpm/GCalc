import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter/services.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  // Ensure you have 'uses-material-design: true' in your pubspec.yaml for icons to work in deployed builds.
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gold Rate Calculator',
      theme: ThemeData(
        primarySwatch: Colors.amber,
        scaffoldBackgroundColor: Colors.white,
        // Use default icon theme to ensure Material icons are loaded
        iconTheme: const IconThemeData.fallback(),
      ),
      home: const MainMenu(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MainMenu extends StatefulWidget {
  const MainMenu({super.key});

  @override
  State<MainMenu> createState() => _MainMenuState();
}

class _MainMenuState extends State<MainMenu> {
  int _selectedIndex = 0;

  static final List<Widget> _pages = <Widget>[
    HomePage(),
    CalculatePage(),
    AboutUsPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    Color _iconColor(int index) =>
        _selectedIndex == index ? Colors.amber[800]! : const Color(0xFF757575);

    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: SvgPicture.string(
              '''
              <svg width="24" height="24" viewBox="0 0 24 24">
                <path fill="${_iconColor(0).value.toRadixString(16).padLeft(8, '0').replaceFirst('ff', '#')}" d="M10.19 2.62a2 2 0 0 1 2.62 0l7.5 6.6A1 1 0 0 1 20 11h-1v7a2 2 0 0 1-2 2h-2v-5h-4v5H7a2 2 0 0 1-2-2v-7H4a1 1 0 0 1-.31-1.78l7.5-6.6z"/>
              </svg>
              ''',
              width: 24,
              height: 24,
            ),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: SvgPicture.string(
              '''
              <svg width="24" height="24" viewBox="0 0 24 24">
                <rect x="3" y="3" width="18" height="18" rx="2" fill="${_iconColor(1).value.toRadixString(16).padLeft(8, '0').replaceFirst('ff', '#')}"/>
                <rect x="7" y="7" width="2" height="2" fill="#fff"/>
                <rect x="11" y="7" width="2" height="2" fill="#fff"/>
                <rect x="15" y="7" width="2" height="2" fill="#fff"/>
                <rect x="7" y="11" width="2" height="2" fill="#fff"/>
                <rect x="11" y="11" width="2" height="2" fill="#fff"/>
                <rect x="15" y="11" width="2" height="2" fill="#fff"/>
                <rect x="7" y="15" width="10" height="2" fill="#fff"/>
              </svg>
              ''',
              width: 24,
              height: 24,
            ),
            label: 'Gold Price Calculator',
          ),
          BottomNavigationBarItem(
            icon: SvgPicture.string(
              '''
              <svg width="24" height="24" viewBox="0 0 24 24">
                <circle cx="12" cy="12" r="10" fill="${_iconColor(2).value.toRadixString(16).padLeft(8, '0').replaceFirst('ff', '#')}"/>
                <rect x="11" y="10" width="2" height="6" fill="#fff"/>
                <rect x="11" y="7" width="2" height="2" fill="#fff"/>
              </svg>
              ''',
              width: 24,
              height: 24,
            ),
            label: 'About Us',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.amber[800],
        onTap: _onItemTapped,
      ),
    );
  }
}

class GoldPriceCalculatorWidget extends StatefulWidget {
  final bool showAppBar;
  final double? goldRate22kt;
  const GoldPriceCalculatorWidget({super.key, this.showAppBar = false, this.goldRate22kt});

  @override
  State<GoldPriceCalculatorWidget> createState() => _GoldPriceCalculatorWidgetState();
}

class _GoldPriceCalculatorWidgetState extends State<GoldPriceCalculatorWidget> {
  final _formKey = GlobalKey<FormState>();
  final _weightController = TextEditingController(text: '1');
  late final double goldRate = (widget.goldRate22kt ?? 0) * 24 / 22;
  double? _result;
  String _type = 'coin';
  String _ktType = '22';
  static const double gstPercent = 3.0;
  final List<double> makingOptionsCoin = [2.0, 3.0, 5.0, 7.0, 9.0];
  final List<double> makingOptionsOrnament = [8.0, 10.0, 12.0, 15.0];
  double _makingPercent = 3.0;
  double? _basePrice;
  double? _makingCharge;
  double? _gstAmount;
  double? _customGoldRate22kt;
  final scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _makingPercent = _type == 'coin' ? 3.0 : 10.0;
    _weightController.addListener(_instantCalculate);
  }

  @override
  void dispose() {
    _weightController.dispose();
    super.dispose();
  }

  void _instantCalculate() {
    final weight = double.tryParse(_weightController.text) ?? 0;
    double ratePerGram = _customGoldRate22kt ?? goldRate;
    if (_ktType == '22') {
      ratePerGram = _customGoldRate22kt ?? widget.goldRate22kt ?? 0;
    } else if (_ktType == '18') {
      ratePerGram = ratePerGram * 18 / 24;
    } else if (_ktType == '14') {
      ratePerGram = ratePerGram * 14 / 24;
    } else if (_ktType == '12') {
      ratePerGram = ratePerGram * 12 / 24;
    } else if (_ktType == '10') {
      ratePerGram = ratePerGram * 10 / 24;
    }
    if (weight <= 0) {
      setState(() {
        _result = null;
        _basePrice = null;
        _makingCharge = null;
        _gstAmount = null;
      });
      return;
    }
    _basePrice = weight * ratePerGram;
    _makingCharge = _basePrice! * _makingPercent / 100;
    final subtotal = _basePrice! + _makingCharge!;
    _gstAmount = subtotal * gstPercent / 100;
    final total = subtotal + _gstAmount!;
    setState(() {
      _result = total;
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_result != null && scrollController.hasClients) {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Widget _buildBreakup() {
    if (_basePrice == null || _makingCharge == null || _gstAmount == null) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        const Text('Price Breakup:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        Table(
          columnWidths: const {
            0: FlexColumnWidth(2),
            1: FlexColumnWidth(2),
          },
          children: [
            TableRow(
              children: [
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 4),
                  child: Text('Base Price:', style: TextStyle(fontSize: 15)),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Text(
                    '\u20B9${_basePrice!.toStringAsFixed(2)}',
                    textAlign: TextAlign.right,
                    style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 15),
                  ),
                ),
              ],
            ),
            TableRow(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Text(
                    'Making Charge (${_makingPercent.toStringAsFixed(1)}%):',
                    style: const TextStyle(fontSize: 15),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Text(
                    '\u20B9${_makingCharge!.toStringAsFixed(2)}',
                    textAlign: TextAlign.right,
                    style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 15),
                  ),
                ),
              ],
            ),
            TableRow(
              children: [
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 4),
                  child: Text('GST (3%):', style: TextStyle(fontSize: 15)),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Text(
                    '\u20B9${_gstAmount!.toStringAsFixed(2)}',
                    textAlign: TextAlign.right,
                    style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 15),
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final makingOptions = _type == 'coin' ? makingOptionsCoin : makingOptionsOrnament;
    final maxSlider = 35.0;
    final inputBox = Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Wrap(
                spacing: 8,
                runSpacing: 8,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  SizedBox(
                    width: 110,
                    child: RadioListTile<String>(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Gold Coin', style: TextStyle(fontSize: 13)),
                      value: 'coin',
                      groupValue: _type,
                      onChanged: (val) {
                        setState(() => _type = val!);
                        _instantCalculate();
                      },
                    ),
                  ),
                  SizedBox(
                    width: 110,
                    child: RadioListTile<String>(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Ornament', style: TextStyle(fontSize: 13)),
                      value: 'ornament',
                      groupValue: _type,
                      onChanged: (val) {
                        setState(() => _type = val!);
                        _instantCalculate();
                      },
                    ),
                  ),
                  SizedBox(
                    width: 120,
                    child: TextFormField(
                      textAlign: TextAlign.right,
                      initialValue: (widget.goldRate22kt ?? 0).toStringAsFixed(2),
                      keyboardType: TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(
                        labelText: '22k ₹/g',
                        border: OutlineInputBorder(),
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                      ),
                      onChanged: (val) {
                        final v = double.tryParse(val);
                        if (v != null) {
                          setState(() {
                            _customGoldRate22kt = v;
                          });
                          _instantCalculate();
                        }
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              TextFormField(
                key: const Key('weightField'),
                controller: _weightController,
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,3}')),
                ],
                decoration: const InputDecoration(
                  labelText: 'Enter weight (grams)',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter weight';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Enter a valid number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Purity: '),
                  Row(
                    children: [
                      Radio<String>(
                        value: '24',
                        groupValue: _ktType,
                        onChanged: (val) {
                          setState(() => _ktType = val!);
                          _instantCalculate();
                        },
                      ),
                      const Text('24kt'),
                      Radio<String>(
                        value: '22',
                        groupValue: _ktType,
                        onChanged: (val) {
                          setState(() => _ktType = val!);
                          _instantCalculate();
                        },
                      ),
                      const Text('22kt'),
                      Radio<String>(
                        value: '18',
                        groupValue: _ktType,
                        onChanged: (val) {
                          setState(() => _ktType = val!);
                          _instantCalculate();
                        },
                      ),
                      const Text('18kt'),
                      Radio<String>(
                        value: '14',
                        groupValue: _ktType,
                        onChanged: (val) {
                          setState(() => _ktType = val!);
                          _instantCalculate();
                        },
                      ),
                      const Text('14kt'),
                      Radio<String>(
                        value: '12',
                        groupValue: _ktType,
                        onChanged: (val) {
                          setState(() => _ktType = val!);
                          _instantCalculate();
                        },
                      ),
                      const Text('12kt'),
                      Radio<String>(
                        value: '10',
                        groupValue: _ktType,
                        onChanged: (val) {
                          setState(() => _ktType = val!);
                          _instantCalculate();
                        },
                      ),
                      const Text('10kt'),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: makingOptions.map((percent) => ChoiceChip(
                  label: Text('${percent.toStringAsFixed(0)}%'),
                  selected: _makingPercent == percent,
                  onSelected: (selected) {
                    setState(() {
                      _makingPercent = percent;
                    });
                    _instantCalculate();
                  },
                )).toList(),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Text('Custom Making %:'),
                  Expanded(
                    child: Slider(
                      min: 0,
                      max: maxSlider,
                      divisions: maxSlider.toInt(),
                      value: _makingPercent,
                      label: _makingPercent.toStringAsFixed(1),
                      onChanged: (val) {
                        setState(() {
                          _makingPercent = val;
                        });
                        _instantCalculate();
                      },
                    ),
                  ),
                  SizedBox(
                    width: 40,
                    child: Text('${_makingPercent.toStringAsFixed(1)}%'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    final outputBox = (_result != null)
        ? Card(
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Total Price: \u20B9${_result!.round()}',
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.green),
                  ),
                  _buildBreakup(),
                  const SizedBox(height: 8),
                  const Text(
                    '(Includes making charge and 3% GST)',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ],
              ),
            ),
          )
        : const SizedBox.shrink();

    if (widget.showAppBar) {
      return Scaffold(
        appBar: AppBar(title: const Text('Calculate total gold Price')),
        body: Padding(
          padding: const EdgeInsets.all(24.0),
          child: SingleChildScrollView(
            controller: scrollController,
            child: Column(
              children: [inputBox, const SizedBox(height: 16),
                if (_result != null)
                  SizedBox(width: double.infinity, child: outputBox)
                else
                  outputBox
              ],
            ),
          ),
        ),
      );
    } else {
      return SingleChildScrollView(
        controller: scrollController,
        child: Column(
          children: [inputBox, const SizedBox(height: 16),
            if (_result != null)
              SizedBox(width: double.infinity, child: outputBox)
            else
              outputBox
          ],
        ),
      );
    }
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final today = DateFormat('MMMM d, yyyy').format(DateTime.now());
    return FutureBuilder<double>(
      future: fetchGoldRate22kt(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final goldRate22kt = (snapshot.data ?? 0.0).roundToDouble();
        final goldRate = (goldRate22kt * 24 / 22).roundToDouble();
        final price1Pavan22kt = (goldRate22kt * 8).roundToDouble();
        final price1Pavan = (goldRate * 8).roundToDouble();
        return Scaffold(
          appBar: AppBar(
            title: const Text('Gold Rate Today'),
            centerTitle: true,
            elevation: 0,
          ),
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    today,
                    style: const TextStyle(fontSize: 20, color: Colors.grey),
                  ),
                  const SizedBox(height: 16),
                  Card(
                    elevation: 6,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
                      child: Column(
                        children: [
                          const Text('Gold Rate', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Column(
                                children: [
                                  const Text('22kt', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                                  Text('₹${goldRate22kt.toStringAsFixed(0)} /gm', style: const TextStyle(fontSize: 20, color: Colors.orange, fontWeight: FontWeight.bold)),
                                ],
                              ),
                              Column(
                                children: [
                                  const Text('24kt', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                                  Text('₹${goldRate.toStringAsFixed(0)} /gm', style: const TextStyle(fontSize: 20, color: Colors.amber, fontWeight: FontWeight.bold)),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Column(
                                children: [
                                  const Text('1 Pavan (22kt)', style: TextStyle(fontSize: 14)),
                                  Text('₹${price1Pavan22kt.toStringAsFixed(0)}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                                ],
                              ),
                              Column(
                                children: [
                                  const Text('1 Pavan (24kt)', style: TextStyle(fontSize: 14)),
                                  Text('₹${price1Pavan.toStringAsFixed(0)}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  const Text('Quick Gold Price Calculator', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  GoldPriceCalculatorWidget(goldRate22kt: goldRate22kt),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class CalculatePage extends StatelessWidget {
  const CalculatePage({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<double>(
      future: fetchGoldRate22kt(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final goldRate22kt = snapshot.data ?? 15.0;
        return GoldPriceCalculatorWidget(showAppBar: true, goldRate22kt: goldRate22kt);
      },
    );
  }
}

class AboutUsPage extends StatefulWidget {
  const AboutUsPage({super.key});

  @override
  State<AboutUsPage> createState() => _AboutUsPageState();
}

class _AboutUsPageState extends State<AboutUsPage> {
  int _tapCount = 0;
  DateTime? _lastTapTime;

  void _handleHeaderTap() async {
    final now = DateTime.now();
    if (_lastTapTime == null || now.difference(_lastTapTime!) > const Duration(seconds: 2)) {
      _tapCount = 1;
    } else {
      _tapCount++;
    }
    _lastTapTime = now;
    if (_tapCount == 3) {
      _tapCount = 0;
      final controller = TextEditingController();
      final result = await showDialog<double>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Insert Gold Price'),
          content: TextField(
            controller: controller,
            keyboardType: TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(labelText: 'Enter new price'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                final value = double.tryParse(controller.text);
                Navigator.pop(context, value);
              },
              child: const Text('Insert'),
            ),
          ],
        ),
      );
      if (result != null) {
        await FirebaseFirestore.instance.collection('gprice').add({
          'price': result,
          'updated_time': Timestamp.now(),
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Inserted price: ₹${result.toStringAsFixed(0)}')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: GestureDetector(
          onTap: _handleHeaderTap,
          child: const Text('About Us', key: Key('aboutUsAppBarTitle')),
        ),
      ),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(24.0),
          child: Text(
            'GoldCalc is your trusted gold price calculator.\n\nDeveloped for easy and accurate gold price calculations.\n\nContact: techandreality@gmail.com\n\nVersion: 1.0.0',
            style: TextStyle(fontSize: 18),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}

// Helper to fetch gold price from Firestore
Future<double> fetchGoldRate22kt() async {
  final query = await FirebaseFirestore.instance
      .collection('gprice')
      .orderBy('updated_time', descending: true)
      .limit(1)
      .get();
  if (query.docs.isNotEmpty && query.docs.first.data().containsKey('price')) {
    return (query.docs.first['price'] as num).toDouble();
  }
  return 10.0;
}
