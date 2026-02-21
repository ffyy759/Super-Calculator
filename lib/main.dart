import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

void main() {
  runApp(const SuperCalculatorApp());
}

class SuperCalculatorApp extends StatelessWidget {
  const SuperCalculatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Super Calculator',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6C63FF),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = const [
    FinanceScreen(),
    ConverterScreen(),
    DateScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (i) => setState(() => _selectedIndex = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.currency_rupee), label: 'Finance'),
          NavigationDestination(icon: Icon(Icons.swap_horiz), label: 'Converter'),
          NavigationDestination(icon: Icon(Icons.calendar_today), label: 'Date & Age'),
        ],
      ),
    );
  }
}

double myPow(double base, double exp) {
  double result = 1;
  for (int i = 0; i < exp.toInt(); i++) result *= base;
  return result;
}

class FinanceScreen extends StatefulWidget {
  const FinanceScreen({super.key});

  @override
  State<FinanceScreen> createState() => _FinanceScreenState();
}

class _FinanceScreenState extends State<FinanceScreen> {
  int _selectedTool = 0;
  final List<String> tools = ['EMI', 'GST', 'Salary', 'Interest', 'Discount', 'Profit/Loss'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Finance Calculator', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: Column(
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.all(12),
            child: Row(
              children: tools.asMap().entries.map((e) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(e.value),
                    selected: _selectedTool == e.key,
                    onSelected: (_) => setState(() => _selectedTool = e.key),
                  ),
                );
              }).toList(),
            ),
          ),
          Expanded(
            child: [
              const EMICalculator(),
              const GSTCalculator(),
              const SalaryCalculator(),
              const InterestCalculator(),
              const DiscountCalculator(),
              const ProfitLossCalculator(),
            ][_selectedTool],
          ),
        ],
      ),
    );
  }
}

class EMICalculator extends StatefulWidget {
  const EMICalculator({super.key});

  @override
  State<EMICalculator> createState() => _EMICalculatorState();
}

class _EMICalculatorState extends State<EMICalculator> {
  final _principal = TextEditingController();
  final _rate = TextEditingController();
  final _tenure = TextEditingController();
  double? emi, totalAmount, totalInterest;

  void _calculate() {
    final p = double.tryParse(_principal.text) ?? 0;
    final r = (double.tryParse(_rate.text) ?? 0) / 12 / 100;
    final n = double.tryParse(_tenure.text) ?? 0;
    if (p > 0 && r > 0 && n > 0) {
      final powered = myPow(1 + r, n);
      final e = p * r * powered / (powered - 1);
      setState(() {
        emi = e;
        totalAmount = e * n;
        totalInterest = e * n - p;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _InputField(_principal, 'Loan Amount (Rs)', Icons.currency_rupee),
          _InputField(_rate, 'Interest Rate (% per year)', Icons.percent),
          _InputField(_tenure, 'Tenure (months)', Icons.calendar_month),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _calculate,
            icon: const Icon(Icons.calculate),
            label: const Text('Calculate EMI'),
            style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
          ),
          if (emi != null) ...[
            const SizedBox(height: 20),
            _ResultCard('Monthly EMI', 'Rs ${emi!.toStringAsFixed(2)}', Colors.purple),
            _ResultCard('Total Amount', 'Rs ${totalAmount!.toStringAsFixed(2)}', Colors.blue),
            _ResultCard('Total Interest', 'Rs ${totalInterest!.toStringAsFixed(2)}', Colors.orange),
          ],
        ],
      ),
    );
  }
}

class GSTCalculator extends StatefulWidget {
  const GSTCalculator({super.key});

  @override
  State<GSTCalculator> createState() => _GSTCalculatorState();
}

class _GSTCalculatorState extends State<GSTCalculator> {
  final _amount = TextEditingController();
  double _gstRate = 18;
  double? gstAmount, totalAmount, originalAmount;
  bool _addMode = true;

  void _calculate() {
    final a = double.tryParse(_amount.text) ?? 0;
    if (a > 0) {
      setState(() {
        if (_addMode) {
          gstAmount = a * _gstRate / 100;
          totalAmount = a + gstAmount!;
          originalAmount = a;
        } else {
          originalAmount = a * 100 / (100 + _gstRate);
          gstAmount = a - originalAmount!;
          totalAmount = a;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: RadioListTile(
                  title: const Text('Add GST'),
                  value: true,
                  groupValue: _addMode,
                  onChanged: (v) => setState(() => _addMode = v!),
                ),
              ),
              Expanded(
                child: RadioListTile(
                  title: const Text('Remove GST'),
                  value: false,
                  groupValue: _addMode,
                  onChanged: (v) => setState(() => _addMode = v!),
                ),
              ),
            ],
          ),
          _InputField(_amount, _addMode ? 'Original Amount (Rs)' : 'Amount with GST (Rs)', Icons.currency_rupee),
          const SizedBox(height: 12),
          const Text('GST Rate:'),
          Wrap(
            spacing: 8,
            children: [5, 12, 18, 28].map((rate) {
              return ChoiceChip(
                label: Text('$rate%'),
                selected: _gstRate == rate,
                onSelected: (_) => setState(() => _gstRate = rate.toDouble()),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _calculate,
            icon: const Icon(Icons.calculate),
            label: const Text('Calculate GST'),
            style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
          ),
          if (gstAmount != null) ...[
            const SizedBox(height: 20),
            _ResultCard('Original Amount', 'Rs ${originalAmount!.toStringAsFixed(2)}', Colors.blue),
            _ResultCard('GST (${_gstRate.toInt()}%)', 'Rs ${gstAmount!.toStringAsFixed(2)}', Colors.orange),
            _ResultCard('Total Amount', 'Rs ${totalAmount!.toStringAsFixed(2)}', Colors.green),
          ],
        ],
      ),
    );
  }
}

class SalaryCalculator extends StatefulWidget {
  const SalaryCalculator({super.key});

  @override
  State<SalaryCalculator> createState() => _SalaryCalculatorState();
}

class _SalaryCalculatorState extends State<SalaryCalculator> {
  final _ctc = TextEditingController();
  double? basic, hra, pf, tax, inHand;

  void _calculate() {
    final ctc = double.tryParse(_ctc.text) ?? 0;
    if (ctc > 0) {
      final monthly = ctc / 12;
      setState(() {
        basic = monthly * 0.5;
        hra = monthly * 0.2;
        pf = basic! * 0.12;
        tax = ctc > 500000 ? monthly * 0.1 : 0;
        inHand = monthly - pf! - tax!;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _InputField(_ctc, 'Annual CTC (Rs)', Icons.work),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _calculate,
            icon: const Icon(Icons.calculate),
            label: const Text('Calculate Salary'),
            style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
          ),
          if (inHand != null) ...[
            const SizedBox(height: 20),
            _ResultCard('Monthly In-Hand', 'Rs ${inHand!.toStringAsFixed(2)}', Colors.green),
            _ResultCard('Basic Salary', 'Rs ${basic!.toStringAsFixed(2)}', Colors.blue),
            _ResultCard('HRA', 'Rs ${hra!.toStringAsFixed(2)}', Colors.purple),
            _ResultCard('PF Deduction', 'Rs ${pf!.toStringAsFixed(2)}', Colors.orange),
            _ResultCard('Tax Deduction', 'Rs ${tax!.toStringAsFixed(2)}', Colors.red),
          ],
        ],
      ),
    );
  }
}

class InterestCalculator extends StatefulWidget {
  const InterestCalculator({super.key});

  @override
  State<InterestCalculator> createState() => _InterestCalculatorState();
}

class _InterestCalculatorState extends State<InterestCalculator> {
  final _principal = TextEditingController();
  final _rate = TextEditingController();
  final _time = TextEditingController();
  bool _isCompound = false;
  double? interest, totalAmount;

  void _calculate() {
    final p = double.tryParse(_principal.text) ?? 0;
    final r = double.tryParse(_rate.text) ?? 0;
    final t = double.tryParse(_time.text) ?? 0;
    if (p > 0 && r > 0 && t > 0) {
      setState(() {
        if (_isCompound) {
          totalAmount = p * myPow(1 + r / 100, t);
          interest = totalAmount! - p;
        } else {
          interest = p * r * t / 100;
          totalAmount = p + interest!;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: RadioListTile(
                  title: const Text('Simple'),
                  value: false,
                  groupValue: _isCompound,
                  onChanged: (v) => setState(() => _isCompound = v!),
                ),
              ),
              Expanded(
                child: RadioListTile(
                  title: const Text('Compound'),
                  value: true,
                  groupValue: _isCompound,
                  onChanged: (v) => setState(() => _isCompound = v!),
                ),
              ),
            ],
          ),
          _InputField(_principal, 'Principal Amount (Rs)', Icons.currency_rupee),
          _InputField(_rate, 'Rate of Interest (%)', Icons.percent),
          _InputField(_time, 'Time (years)', Icons.timer),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _calculate,
            icon: const Icon(Icons.calculate),
            label: const Text('Calculate Interest'),
            style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
          ),
          if (interest != null) ...[
            const SizedBox(height: 20),
            _ResultCard('Interest Amount', 'Rs ${interest!.toStringAsFixed(2)}', Colors.orange),
            _ResultCard('Total Amount', 'Rs ${totalAmount!.toStringAsFixed(2)}', Colors.green),
          ],
        ],
      ),
    );
  }
}

class DiscountCalculator extends StatefulWidget {
  const DiscountCalculator({super.key});

  @override
  State<DiscountCalculator> createState() => _DiscountCalculatorState();
}

class _DiscountCalculatorState extends State<DiscountCalculator> {
  final _price = TextEditingController();
  final _discount = TextEditingController();
  double? discountAmount, finalPrice;

  void _calculate() {
    final p = double.tryParse(_price.text) ?? 0;
    final d = double.tryParse(_discount.text) ?? 0;
    if (p > 0 && d > 0) {
      setState(() {
        discountAmount = p * d / 100;
        finalPrice = p - discountAmount!;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _InputField(_price, 'Original Price (Rs)', Icons.currency_rupee),
          _InputField(_discount, 'Discount (%)', Icons.percent),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _calculate,
            icon: const Icon(Icons.calculate),
            label: const Text('Calculate Discount'),
            style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
          ),
          if (finalPrice != null) ...[
            const SizedBox(height: 20),
            _ResultCard('Final Price', 'Rs ${finalPrice!.toStringAsFixed(2)}', Colors.green),
            _ResultCard('You Save', 'Rs ${discountAmount!.toStringAsFixed(2)}', Colors.orange),
          ],
        ],
      ),
    );
  }
}

class ProfitLossCalculator extends StatefulWidget {
  const ProfitLossCalculator({super.key});

  @override
  State<ProfitLossCalculator> createState() => _ProfitLossCalculatorState();
}

class _ProfitLossCalculatorState extends State<ProfitLossCalculator> {
  final _cost = TextEditingController();
  final _selling = TextEditingController();
  double? profitLoss, percentage;
  bool isProfit = true;

  void _calculate() {
    final cp = double.tryParse(_cost.text) ?? 0;
    final sp = double.tryParse(_selling.text) ?? 0;
    if (cp > 0 && sp > 0) {
      setState(() {
        isProfit = sp >= cp;
        profitLoss = (sp - cp).abs();
        percentage = profitLoss! / cp * 100;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _InputField(_cost, 'Cost Price (Rs)', Icons.currency_rupee),
          _InputField(_selling, 'Selling Price (Rs)', Icons.sell),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _calculate,
            icon: const Icon(Icons.calculate),
            label: const Text('Calculate'),
            style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
          ),
          if (profitLoss != null) ...[
            const SizedBox(height: 20),
            _ResultCard(
              isProfit ? 'PROFIT' : 'LOSS',
              'Rs ${profitLoss!.toStringAsFixed(2)}',
              isProfit ? Colors.green : Colors.red,
            ),
            _ResultCard(
              isProfit ? 'Profit %' : 'Loss %',
              '${percentage!.toStringAsFixed(2)}%',
              isProfit ? Colors.green : Colors.red,
            ),
          ],
        ],
      ),
    );
  }
}

class ConverterScreen extends StatefulWidget {
  const ConverterScreen({super.key});

  @override
  State<ConverterScreen> createState() => _ConverterScreenState();
}

class _ConverterScreenState extends State<ConverterScreen> {
  int _selectedTool = 0;
  final tools = ['Weight', 'Length', 'Temperature', 'Area'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Unit Converter', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: Column(
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.all(12),
            child: Row(
              children: tools.asMap().entries.map((e) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(e.value),
                    selected: _selectedTool == e.key,
                    onSelected: (_) => setState(() => _selectedTool = e.key),
                  ),
                );
              }).toList(),
            ),
          ),
          Expanded(
            child: [
              const WeightConverter(),
              const LengthConverter(),
              const TempConverter(),
              const AreaConverter(),
            ][_selectedTool],
          ),
        ],
      ),
    );
  }
}

class WeightConverter extends StatefulWidget {
  const WeightConverter({super.key});

  @override
  State<WeightConverter> createState() => _WeightConverterState();
}

class _WeightConverterState extends State<WeightConverter> {
  final _input = TextEditingController();
  String _from = 'kg';
  String _to = 'pound';
  double? result;

  final units = ['kg', 'gram', 'pound', 'ounce', 'ton'];
  final toKg = {
    'kg': 1.0, 'gram': 0.001, 'pound': 0.453592,
    'ounce': 0.0283495, 'ton': 1000.0,
  };

  void _convert() {
    final val = double.tryParse(_input.text) ?? 0;
    if (val > 0) {
      final inKg = val * toKg[_from]!;
      setState(() => result = inKg / toKg[_to]!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _InputField(_input, 'Enter Value', Icons.scale),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField(
                  value: _from,
                  decoration: const InputDecoration(labelText: 'From', border: OutlineInputBorder()),
                  items: units.map((u) => DropdownMenuItem(value: u, child: Text(u))).toList(),
                  onChanged: (v) => setState(() => _from = v!),
                ),
              ),
              const Padding(padding: EdgeInsets.all(8), child: Icon(Icons.arrow_forward)),
              Expanded(
                child: DropdownButtonFormField(
                  value: _to,
                  decoration: const InputDecoration(labelText: 'To', border: OutlineInputBorder()),
                  items: units.map((u) => DropdownMenuItem(value: u, child: Text(u))).toList(),
                  onChanged: (v) => setState(() => _to = v!),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _convert,
            icon: const Icon(Icons.swap_horiz),
            label: const Text('Convert'),
            style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
          ),
          if (result != null)
            _ResultCard('Result', '${result!.toStringAsFixed(4)} $_to', Colors.purple),
        ],
      ),
    );
  }
}

class LengthConverter extends StatefulWidget {
  const LengthConverter({super.key});

  @override
  State<LengthConverter> createState() => _LengthConverterState();
}

class _LengthConverterState extends State<LengthConverter> {
  final _input = TextEditingController();
  String _from = 'meter';
  String _to = 'feet';
  double? result;

  final units = ['meter', 'km', 'cm', 'mm', 'feet', 'inch', 'mile'];
  final toMeter = {
    'meter': 1.0, 'km': 1000.0, 'cm': 0.01,
    'mm': 0.001, 'feet': 0.3048, 'inch': 0.0254, 'mile': 1609.34,
  };

  void _convert() {
    final val = double.tryParse(_input.text) ?? 0;
    if (val > 0) {
      final inMeter = val * toMeter[_from]!;
      setState(() => result = inMeter / toMeter[_to]!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _InputField(_input, 'Enter Value', Icons.straighten),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField(
                  value: _from,
                  decoration: const InputDecoration(labelText: 'From', border: OutlineInputBorder()),
                  items: units.map((u) => DropdownMenuItem(value: u, child: Text(u))).toList(),
                  onChanged: (v) => setState(() => _from = v!),
                ),
              ),
              const Padding(padding: EdgeInsets.all(8), child: Icon(Icons.arrow_forward)),
              Expanded(
                child: DropdownButtonFormField(
                  value: _to,
                  decoration: const InputDecoration(labelText: 'To', border: OutlineInputBorder()),
                  items: units.map((u) => DropdownMenuItem(value: u, child: Text(u))).toList(),
                  onChanged: (v) => setState(() => _to = v!),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _convert,
            icon: const Icon(Icons.swap_horiz),
            label: const Text('Convert'),
            style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
          ),
          if (result != null)
            _ResultCard('Result', '${result!.toStringAsFixed(4)} $_to', Colors.blue),
        ],
      ),
    );
  }
}

class TempConverter extends StatefulWidget {
  const TempConverter({super.key});

  @override
  State<TempConverter> createState() => _TempConverterState();
}

class _TempConverterState extends State<TempConverter> {
  final _input = TextEditingController();
  String _from = 'Celsius';
  String _to = 'Fahrenheit';
  double? result;

  final units = ['Celsius', 'Fahrenheit', 'Kelvin'];

  double _convert(double val, String from, String to) {
    double celsius;
    switch (from) {
      case 'Fahrenheit': celsius = (val - 32) * 5 / 9; break;
      case 'Kelvin': celsius = val - 273.15; break;
      default: celsius = val;
    }
    switch (to) {
      case 'Fahrenheit': return celsius * 9 / 5 + 32;
      case 'Kelvin': return celsius + 273.15;
      default: return celsius;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _InputField(_input, 'Enter Temperature', Icons.thermostat),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField(
                  value: _from,
                  decoration: const InputDecoration(labelText: 'From', border: OutlineInputBorder()),
                  items: units.map((u) => DropdownMenuItem(value: u, child: Text(u))).toList(),
                  onChanged: (v) => setState(() => _from = v!),
                ),
              ),
              const Padding(padding: EdgeInsets.all(8), child: Icon(Icons.arrow_forward)),
              Expanded(
                child: DropdownButtonFormField(
                  value: _to,
                  decoration: const InputDecoration(labelText: 'To', border: OutlineInputBorder()),
                  items: units.map((u) => DropdownMenuItem(value: u, child: Text(u))).toList(),
                  onChanged: (v) => setState(() => _to = v!),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () {
              final val = double.tryParse(_input.text) ?? 0;
              setState(() => result = _convert(val, _from, _to));
            },
            icon: const Icon(Icons.swap_horiz),
            label: const Text('Convert'),
            style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
          ),
          if (result != null)
            _ResultCard('Result', '${result!.toStringAsFixed(2)} $_to', Colors.orange),
        ],
      ),
    );
  }
}

class AreaConverter extends StatefulWidget {
  const AreaConverter({super.key});

  @override
  State<AreaConverter> createState() => _AreaConverterState();
}

class _AreaConverterState extends State<AreaConverter> {
  final _input = TextEditingController();
  String _from = 'sqmeter';
  String _to = 'sqfeet';
  double? result;

  final units = ['sqmeter', 'sqfeet', 'sqkm', 'acre', 'hectare'];
  final labels = {
    'sqmeter': 'Sq Meter', 'sqfeet': 'Sq Feet',
    'sqkm': 'Sq KM', 'acre': 'Acre', 'hectare': 'Hectare'
  };
  final toSqMeter = {
    'sqmeter': 1.0, 'sqfeet': 0.092903,
    'sqkm': 1000000.0, 'acre': 4046.86, 'hectare': 10000.0,
  };

  void _convert() {
    final val = double.tryParse(_input.text) ?? 0;
    if (val > 0) {
      final inSqM = val * toSqMeter[_from]!;
      setState(() => result = inSqM / toSqMeter[_to]!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _InputField(_input, 'Enter Area', Icons.crop_square),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField(
                  value: _from,
                  decoration: const InputDecoration(labelText: 'From', border: OutlineInputBorder()),
                  items: units.map((u) => DropdownMenuItem(value: u, child: Text(labels[u]!))).toList(),
                  onChanged: (v) => setState(() => _from = v!),
                ),
              ),
              const Padding(padding: EdgeInsets.all(8), child: Icon(Icons.arrow_forward)),
              Expanded(
                child: DropdownButtonFormField(
                  value: _to,
                  decoration: const InputDecoration(labelText: 'To', border: OutlineInputBorder()),
                  items: units.map((u) => DropdownMenuItem(value: u, child: Text(labels[u]!))).toList(),
                  onChanged: (v) => setState(() => _to = v!),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _convert,
            icon: const Icon(Icons.swap_horiz),
            label: const Text('Convert'),
            style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
          ),
          if (result != null)
            _ResultCard('Result', '${result!.toStringAsFixed(4)} ${labels[_to]}', Colors.green),
        ],
      ),
    );
  }
}

class DateScreen extends StatefulWidget {
  const DateScreen({super.key});

  @override
  State<DateScreen> createState() => _DateScreenState();
}

class _DateScreenState extends State<DateScreen> {
  int _selectedTool = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Date & Age Calculator', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: FilterChip(
                    label: const Text('Age Calculator'),
                    selected: _selectedTool == 0,
                    onSelected: (_) => setState(() => _selectedTool = 0),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: FilterChip(
                    label: const Text('Date Difference'),
                    selected: _selectedTool == 1,
                    onSelected: (_) => setState(() => _selectedTool = 1),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: _selectedTool == 0 ? const AgeCalculator() : const DateDiffCalculator(),
          ),
        ],
      ),
    );
  }
}

class AgeCalculator extends StatefulWidget {
  const AgeCalculator({super.key});

  @override
  State<AgeCalculator> createState() => _AgeCalculatorState();
}

class _AgeCalculatorState extends State<AgeCalculator> {
  DateTime? _dob;
  int? years, months, days;

  void _calculate() {
    if (_dob != null) {
      final now = DateTime.now();
      int y = now.year - _dob!.year;
      int m = now.month - _dob!.month;
      int d = now.day - _dob!.day;
      if (d < 0) { m--; d += 30; }
      if (m < 0) { y--; m += 12; }
      setState(() { years = y; months = m; days = d; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Card(
            child: ListTile(
              leading: const Icon(Icons.cake, color: Colors.purple),
              title: const Text('Date of Birth'),
              subtitle: Text(_dob == null ? 'Tap to select' : DateFormat('dd MMM yyyy').format(_dob!)),
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: DateTime(2000),
                  firstDate: DateTime(1900),
                  lastDate: DateTime.now(),
                );
                if (date != null) setState(() => _dob = date);
              },
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _calculate,
            icon: const Icon(Icons.calculate),
            label: const Text('Calculate Age'),
            style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
          ),
          if (years != null) ...[
            const SizedBox(height: 20),
            _ResultCard('Years', '$years Years', Colors.purple),
            _ResultCard('Months', '$months Months', Colors.blue),
            _ResultCard('Days', '$days Days', Colors.orange),
          ],
        ],
      ),
    );
  }
}

class DateDiffCalculator extends StatefulWidget {
  const DateDiffCalculator({super.key});

  @override
  State<DateDiffCalculator> createState() => _DateDiffCalculatorState();
}

class _DateDiffCalculatorState extends State<DateDiffCalculator> {
  DateTime? _date1, _date2;
  int? diffDays, diffWeeks, diffMonths;

  void _calculate() {
    if (_date1 != null && _date2 != null) {
      final diff = _date2!.difference(_date1!).inDays.abs();
      setState(() {
        diffDays = diff;
        diffWeeks = diff ~/ 7;
        diffMonths = diff ~/ 30;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Card(
            child: ListTile(
              leading: const Icon(Icons.date_range, color: Colors.blue),
              title: const Text('Start Date'),
              subtitle: Text(_date1 == null ? 'Tap to select' : DateFormat('dd MMM yyyy').format(_date1!)),
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(1900),
                  lastDate: DateTime(2100),
                );
                if (date != null) setState(() => _date1 = date);
              },
            ),
          ),
          const SizedBox(height: 8),
          Card(
            child: ListTile(
              leading: const Icon(Icons.date_range, color: Colors.green),
              title: const Text('End Date'),
              subtitle: Text(_date2 == null ? 'Tap to select' : DateFormat('dd MMM yyyy').format(_date2!)),
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(1900),
                  lastDate: DateTime(2100),
                );
                if (date != null) setState(() => _date2 = date);
              },
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _calculate,
            icon: const Icon(Icons.calculate),
            label: const Text('Calculate Difference'),
            style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
          ),
          if (diffDays != null) ...[
            const SizedBox(height: 20),
            _ResultCard('Days', '$diffDays Days', Colors.blue),
            _ResultCard('Weeks', '$diffWeeks Weeks', Colors.purple),
            _ResultCard('Months', '$diffMonths Months', Colors.green),
          ],
        ],
      ),
    );
  }
}

class _InputField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;

  const _InputField(this.controller, this.label, this.icon);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          border: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(12))),
        ),
      ),
    );
  }
}

class _ResultCard extends StatelessWidget {
  final String title;
  final String value;
  final Color color;

  const _ResultCard(this.title, this.value, this.color);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: const TextStyle(color: Colors.grey, fontSize: 16)),
            Text(value, style: TextStyle(color: color, fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
