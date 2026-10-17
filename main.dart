enum ExpenseCategory { food, travel, shopping, bills, other }

class Expense {
  String title;
  int amount;
  String paidBy;
  ExpenseCategory category;
  List<String> participants;

  Expense(this.title, this.amount, this.paidBy,
      this.category, this.participants);

  int get share => amount ~/ participants.length;
}

class MemberBalance {
  int totalPaid = 0;
  int shareOwed = 0;

  int get netBalance => totalPaid - shareOwed;
}

class ExpenseGroup {
  final Set<String> _members = {};
  final List<Expense> _expenses = [];

  void addMember(String name) {
    name = name.trim();
    if (name.isEmpty) {
      throw ArgumentError('Member name cannot be empty.');
    }
    if (!_members.add(name)) {
      throw ArgumentError('Duplicate member: $name');
    }
    print('Added member: $name');
  }

  void addExpense({
    required String title,
    required int amount,
    required String paidBy,
    required String category,
    required List<String> splitBetween,
  }) {
    if (title.trim().isEmpty) {
      throw ArgumentError('Title cannot be empty.');
    }
    if (amount <= 0) {
      throw ArgumentError('Amount must be positive.');
    }
    if (!_members.contains(paidBy)) {
      throw ArgumentError('Unknown payer: $paidBy');
    }
    if (splitBetween.isEmpty) {
      throw ArgumentError('Participants cannot be empty.');
    }
    if (splitBetween.toSet().length != splitBetween.length) {
      throw ArgumentError('Duplicate participants.');
    }
    for (final name in splitBetween) {
      if (!_members.contains(name)) {
        throw ArgumentError('Unknown participant: $name');
      }
    }
    if (amount % splitBetween.length != 0) {
      throw ArgumentError('Amount must divide equally.');
    }

    final cat = ExpenseCategory.values.firstWhere(
      (c) => c.name == category.toLowerCase().trim(),
      orElse: () => throw ArgumentError('Invalid category: $category'),
    );

    _expenses.add(Expense(
      title.trim(), amount, paidBy, cat, List.from(splitBetween),
    ));
    print('Added expense: $title');
  }

  void listExpenses({String? member, String? category}) {
    final results = _expenses.where((e) {
      final matchesMember = member == null ||
          e.paidBy == member || e.participants.contains(member);
      final matchesCategory = category == null ||
          e.category.name == category.toLowerCase().trim();
      return matchesMember && matchesCategory;
    }).toList();

    print('\n--- EXPENSES ---');
    if (results.isEmpty) {
      print('No matching expenses.');
    }
    for (final e in results) {
      print('${e.title}: INR ${e.amount}, payer: ${e.paidBy}, '
          'category: ${e.category.name}, '
          'participants: ${e.participants.join(", ")}');
    }
  }

  Map<String, MemberBalance> calculateBalances() {
    final balances = <String, MemberBalance>{
      for (final name in _members) name: MemberBalance(),
    };

    for (final e in _expenses) {
      balances[e.paidBy]!.totalPaid += e.amount;
      for (final name in e.participants) {
        balances[name]!.shareOwed += e.share;
      }
    }
    return balances;
  }

  void printBalances() {
    print('\n--- MEMBER BALANCES ---');
    final balances = calculateBalances();

    for (final name in _members) {
      final b = balances[name]!;
      print('$name: paid INR ${b.totalPaid}, '
          'share INR ${b.shareOwed}, net INR ${b.netBalance}');

      if (b.netBalance > 0) {
        print('$name should receive INR ${b.netBalance}');
      } else if (b.netBalance < 0) {
        print('$name owes INR ${-b.netBalance}');
      } else {
        print('$name is settled.');
      }
    }
  }
}

void main() {
  final group = ExpenseGroup();

  try {
    group.addMember('Asha');
    group.addMember('Ravi');
    group.addMember('Neha');

    group.addExpense(
      title: 'Dinner',
      amount: 900,
      paidBy: 'Asha',
      category: 'food',
      splitBetween: ['Asha', 'Ravi', 'Neha'],
    );
