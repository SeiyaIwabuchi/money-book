import "package:collection/collection.dart";
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter/rendering.dart';
import 'package:intl/intl.dart';

import 'package:fl_chart/fl_chart.dart';

import 'package:money_book/db_helper.dart';
import 'package:money_book/input_dialog.dart';
import 'package:money_book/item.dart';
import 'package:money_book/item_row.dart';

void main() {
  runApp(MyApp());
}

/// # MyApp クラス
///
/// ## アプリ本体
/// アプリのメイン画面を表示
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      // MaterialApp で日本語対応をサポート
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      // ロケールは日本を設定
      supportedLocales: [
        const Locale('ja'),
      ],
      home: MyHomePage(),
    );
  }
}

/// # メイン画面ウィジェット
///
/// ## お小遣い帳のメイン画面
/// タブ、項目一覧、月表示を表示
///
/// ```
/// home: MyHomePage()
/// ```
class MyHomePage extends StatefulWidget {
  const MyHomePage({Key key}) : super(key: key);
  @override
  _MyHomePageState createState() => new _MyHomePageState();
}

/// # [MyHomePage] ウィジェットから呼ばれる State(状態) クラス
///
/// TabBarView を使用するため SingleTickerProviderStateMixin を継承
class _MyHomePageState extends State<MyHomePage>
    with SingleTickerProviderStateMixin {
  // 表示するタブを保持
  final List<Tab> tabs = <Tab>[
    Tab(text: '一覧'),
    Tab(text: '月表示'),
  ];
  TabController _tabController;

  // DB ヘルパーのインスタンスを生成
  final _dbHelper = DbHelper.instance;

  // 各項目を保持するリスト
  List<Item> _listViewItems = <Item>[];

  // 月表示用リスト
  List<Item> _monthViewItems = <Item>[];

  // 月表示の合計金額を保持
  int _totalPrice = 0;

  // タブのインデックスを保持
  int _tabIndex = 0;

  // 表示月を保持
  DateTime _currentDate = DateTime.now();

  // DB から項目を読出して一覧に加える
  void _loadItems() {
    _listViewItems = <Item>[]; // リストを初期化
    _dbHelper.allRows().then((map) {
      // 読出時に一覧を再描画
      setState(() {
        _updateListView(map);
        _updateMonthView();
      });
    });
  }

  // 一覧を更新
  void _updateListView(List<Map<String, dynamic>> map) {
    map.forEach((item) {
      _listViewItems.add(Item.fromMap(item));
    });
  }

  // 表示月の一覧を更新
  void _updateMonthView() {
    // 月初日
    final firstOfMonth = DateTime(_currentDate.year, _currentDate.month, 1);
    // 月末日
    final lastOfMonth = DateTime(_currentDate.year, _currentDate.month + 1, 0);

    // 表示月の一覧を初期化
    _monthViewItems = <Item>[];
    // 月表示の合計金額を保持する変数
    _totalPrice = 0;

    // 表示月に該当する日付で項目を絞り込む
    _monthViewItems = _listViewItems.where((item) {
      final date = DateTime.parse(item.date);
      return date.compareTo(firstOfMonth) >= 0 &&
          date.compareTo(lastOfMonth) < 0;
    }).toList();

    // 表示月の合計金額を算出
    _monthViewItems.forEach((item) {
      _totalPrice += item.price;
    });
  }

  // 円グラフのセクション作成メソッド
  List<PieChartSectionData> showingSections() {
    // 描画する円の大きさ
    final radius = 80.0;

    // 項目名ごとにグループ化
    var groupItems = groupBy(_monthViewItems, (Item item) => item.name);

    // 各項目の項目名と合計金額を保持
    List<Map<String, int>> groupTotals = List<Map<String, int>>();
    List<String> keys = [];

    // 各項目ごとの金額を取得
    groupItems.forEach((name, items) {
      int total = 0;
      items.forEach((item) {
        total += item.price;
      });
      keys.add(name);
      groupTotals.add({name: total});
    });

    return List.generate(groupTotals.length, // グループ数
        (index) {
      return PieChartSectionData(
        color: const Color(0xff0293ee), // 円グラフの色を設定
        value: groupTotals[index][keys[index]].toDouble(), // 項目の金額を設定
        title:
            '${keys[index]}\n${groupTotals[index][keys[index]]}円', // 項目名と合計金額を表示
        radius: radius, // 円グラフの太さを設定
        // 円グラフに表示するテキストを設定
        titleStyle: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: const Color(0xffffffff)),
      );
    });
  }

  // ウィジェットが作成時に呼ばれるメソッド
  @override
  void initState() {
    super.initState();
    _tabController = TabController(vsync: this, length: tabs.length);

    // DB から既存の項目を読出
    _loadItems();
  }

  // ウィジェットが破棄時に呼ばれるメソッド
  @override
  void dispose() {
    super.dispose();
    _tabController.dispose();
  }

  // ウィジェットを構築するメソッド
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // キーボード表示時に、フローティングボタンが画面にせり上がらないように設定
      resizeToAvoidBottomInset: false,

      // AppBar を設定
      appBar: AppBar(
          // タブの UI を実装
          flexibleSpace: Padding(
              // ステータスバーに重ならないようにパディングを入れて位置を調整
              padding: EdgeInsets.only(top: 27),
              child: Column(children: <Widget>[
                Container(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      // 一覧ボタン
                      FlatButton(
                        // 選択された場合はボタンの背景色を白に変更する
                        color: _tabIndex == 0 ? Colors.white : Colors.blue,
                        // タブ [一覧] 押下時処理
                        onPressed: () {
                          _tabController.animateTo(0);
                          // インデックスを設定して再描画
                          setState(() {
                            _tabIndex = 0;
                          });
                        },
                        // ボタンに 「一覧」を表示
                        child: Text(tabs[0].text),
                      ),
                      // 月表示ボタン
                      FlatButton(
                        // 選択された場合はボタンの背景色を白に変更する
                        color: _tabIndex == 1 ? Colors.white : Colors.blue,
                        // タブ [月表示] 押下時処理
                        onPressed: () {
                          _tabController.animateTo(1);
                          // インデックスを設定して再描画
                          setState(() {
                            _tabIndex = 1;
                          });
                        },
                        // ボタンに 「月表示」を表示
                        child: Text(tabs[1].text),
                      )
                    ],
                  ),
                ),
              ]))),
      // [一覧][月表示] の UI を実装
      body: TabBarView(
        controller: _tabController,
        // タブのみでスクロールするように設定
        physics: const NeverScrollableScrollPhysics(),
        children: tabs.map((tab) {
          // 一覧表示の UI を配置
          if (tabs[0] == tab) {
            // 一覧表示
            return ListView.builder(itemBuilder: (context, index) {
              if (index >= _listViewItems.length) {
                return null;
              }

              return Padding(
                padding: EdgeInsets.all(1.0),
                // 項目表示行を配置
                child: ItemRow(
                  item: _listViewItems[index],
                  // 削除ボタン押下時の処理
                  onDeleteTapped: (id) {
                    setState(() {
                      // 選択した項目を削除
                      _dbHelper.delete(id);
                      _loadItems();
                    });
                  },
                  // 項目行の押下時の処理
                  onItemEdited: (item) {
                    setState(() {
                      // 選択した項目を更新
                      _dbHelper.update(item.id, item.toMap());
                      _loadItems();
                    });
                  },
                ),
              );
            });
          } else {
            // 月表示「< 2020年 08月 >」の UI を実装
            return Column(
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.all(10.0),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      // 左矢印ボタンを配置
                      IconButton(
                        onPressed: () {
                          // 押下時に表示する月を前の月に変更
                          setState(() {
                            final newDate = DateTime(_currentDate.year,
                                _currentDate.month - 1, _currentDate.day);
                            _currentDate = newDate;
                            _updateMonthView();
                          });
                        },
                        // 左矢印の画像を設定
                        icon: Image.asset(
                          'images/left_arrow.png',
                          color: Colors.black,
                          width: 20,
                          height: 20,
                        ),
                      ),
                      // 表示月を配置
                      Text(DateFormat('yyyy年 MM月').format(_currentDate),
                          style: TextStyle(
                            color: Colors.blueAccent,
                            fontSize: 20,
                          )),
                      // 右矢印ボタンを配置
                      IconButton(
                        onPressed: () {
                          // 押下時に表示する月を次の月に変更
                          setState(() {
                            final newDate = DateTime(_currentDate.year,
                                _currentDate.month + 1, _currentDate.day);
                            _currentDate = newDate;
                            _updateMonthView();
                          });
                        },
                        // 右矢印の画像を設定
                        icon: Image.asset(
                          'images/right_arrow.png',
                          color: Colors.black,
                          width: 20,
                          height: 20,
                        ),
                      ),
                    ],
                  ),
                ),

                // 円グラフの UI を配置
                PieChart(
                  PieChartData(
                    borderData: FlBorderData(
                      show: false, // グラフの境界線を非表示
                    ),
                    sectionsSpace: 3, // セクションの境界線の太さを設定
                    centerSpaceRadius: 40, // 円の大きさを設定
                    sections: showingSections(), // 円グラフに表示するセクションを設定
                  ),
                ),

                // 合計金額の UI を実装
                Padding(
                  padding: EdgeInsets.all(10.0),
                  child: Text(
                      // 合計金額
                      '¥${_totalPrice.toString()}',
                      style: TextStyle(
                        color: Colors.blueAccent,
                        fontSize: 20,
                      )),
                ),
                // 月ごとの一覧の UI を実装
                Flexible(
                  child: ListView.builder(itemBuilder: (context, index) {
                    if (index >= _monthViewItems.length) {
                      return null;
                    }

                    return Padding(
                      padding: EdgeInsets.all(1.0),
                      child: ItemRow(
                        item: _monthViewItems[index],
                        // 削除ボタン押下時の処理
                        onDeleteTapped: (id) {
                          setState(() {
                            // 選択した項目を削除
                            _dbHelper.delete(id);
                            _loadItems();
                          });
                        },
                        // 項目行の押下時の処理
                        onItemEdited: (item) {
                          setState(() {
                            // 選択して項目を更新
                            _dbHelper.update(item.id, item.toMap());
                            _loadItems();
                          });
                        },
                      ),
                    );
                  }),
                ),
              ],
            );
          }
        }).toList(),
      ),
      // フローティングボタン(新規項目追加) の UI を実装
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // 押下時に項目入力ダイアログを表示
          showDialog(
              barrierDismissible: false, // ダイアログの背景を押しても閉じないように設定
              context: context,
              builder: (_) {
                // 表示するダイアログを設定
                return InputDialog();
              }).then((item) {
            // 新規項目追加時に再描画
            setState(() {
              if (item != null) {
                // 新規項目を DB に保存
                _dbHelper.insert(item.toMap());

                // 一覧を更新
                _loadItems();
              }
            });
          });
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
