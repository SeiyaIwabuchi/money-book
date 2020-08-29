
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:intl/intl.dart';

import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Data{
  static int nowPageIndex = 0;
  static bool doneLoad = false;
}

class aRecord{
  int price;
  String name;
  DateTime date;
  aRecord(this.price,this.name,this.date);
}

List<aRecord> recordsIN = [];  //収入用
List<aRecord> recordsOUT = []; //支出用

class Record{
  static int key = 0;
  static int mokuhyo = 100;
  static void saveRecords() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    for (int i=0;i<recordsIN.length;i++){
      await pref.setString("IN." + i.toString() + ".price", recordsIN[i].price.toString());
      await pref.setString("IN." +i.toString() + ".name", recordsIN[i].name.toString());
      await pref.setString("IN." +i.toString() + ".date", recordsIN[i].date.toString());
    }
      await pref.setString("IN.recordLength", recordsIN.length.toString());

    for (int i=0;i<recordsOUT.length;i++){
      await pref.setString("OUT." + i.toString() + ".price", recordsOUT[i].price.toString());
      await pref.setString("OUT." +i.toString() + ".name", recordsOUT[i].name.toString());
      await pref.setString("OUT." +i.toString() + ".date", recordsOUT[i].date.toString());
    }
      await pref.setString("OUT.recordLength", recordsOUT.length.toString());
  }
  static void addRecord(int price,String name,DateTime date,String dir){
    if(dir == "IN"){
      recordsIN.add(new aRecord(price,name,date));
    }else if(dir == "OUT"){
      recordsOUT.add(new aRecord(price,name,date));
    }
    saveRecords();
  }
  static void roadRecords() async {
    Data.doneLoad = false;
    SharedPreferences pref = await SharedPreferences.getInstance();
    int recordLengthIN = int.parse(pref.get("IN.recordLength"));
    int recordLengthOUT = int.parse(pref.get("OUT.recordLength"));
    for(int i=0;i<recordLengthIN;i++){
      int price = int.parse(pref.get("IN." + (i.toString()) + ".price"));
      String name = pref.get("IN." + i.toString() + ".name");
      DateTime date = DateTime.parse(pref.get("IN." + i.toString() + ".date"));
      recordsIN.add(new aRecord(price,name,date));
    }
    for(int i=0;i<recordLengthOUT;i++){
      int price =  int.parse(pref.get("OUT." + i.toString() + ".price"));
      String name = pref.get("OUT." + i.toString() + ".name");
      DateTime date = DateTime.parse(pref.get("OUT." + i.toString() + ".date"));
      recordsOUT.add(new aRecord(price,name,date));
    }
    try{
      mokuhyo = int.parse(pref.get("mokuhyo"));
    }on ArgumentError{
      mokuhyo = 100;
    }
    Data.doneLoad = true;
  }
  static int getTotal(String dir){
    int tmp = 0;
    List<aRecord> tList;
    if(dir == "OUT"){
      tList = recordsOUT;
    }else{
      tList = recordsIN;
    }
    tList.forEach((r) { tmp += r.price; });
    return tmp;
  }
  static void saveMokuhyo(int price) async{
    SharedPreferences pref = await SharedPreferences.getInstance();
    await pref.setString("mokuhyo",price.toString());
    mokuhyo = price;
  }
}
List<String> pageName = [
  "つかったおかね",
  "もらったおかね",
  "もくひょう"
  ];

final formatter = NumberFormat("#,###");

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try{
    await Record.roadRecords();
  }on ArgumentError{

  }
  runApp(new MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Generated App',
      theme: new ThemeData(
        primarySwatch: Colors.blue,
        primaryColor: const Color(0xFF2196f3),
        accentColor: const Color(0xFF2196f3),
        canvasColor: const Color(0xFFfafafa),
      ),
      home: new HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  HomePage({Key key}) : super(key: key); //親クラス(StatefulWidget)のコンストラクタを呼び出し、継承
  @override
  //_HomePageState createState() => new _HomePageState();
  _HomePageState createState(){
    return new _HomePageState();
  }
}

class MokuhyouPage extends StatefulWidget {
  MokuhyouPage({Key key}) : super(key: key);
  @override
  _MokuhyouPageState createState() => new _MokuhyouPageState();
}

class SisyutuPage extends StatefulWidget {
  SisyutuPage({Key key}) : super(key: key);
  @override
  _SisyutuPageState createState() => new _SisyutuPageState();
}

class GoalDialog extends StatefulWidget{
  GoalDialog({Key key}) : super(key : key);
  @override
  _GoalDialogState createState() => new _GoalDialogState();
}


class _HomePageState extends State<HomePage>{
  int _selectedIndex = 0;
  static List<Widget> _pageList = [
    SisyutuPage(),
    SisyutuPage(),
    MokuhyouPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      Data.nowPageIndex = index;
    });
  }
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return new Scaffold(
      appBar: new AppBar(
        title: new Text(
          pageName[this._selectedIndex],
          style: TextStyle(
            color:Color(0xFF000000)
          ),
          ),
        backgroundColor: Color(0xFFbbefff),
      ),
      body: _pageList[_selectedIndex],
      bottomNavigationBar: new BottomNavigationBar(
        items: [
          new BottomNavigationBarItem(
            icon: const Icon(Icons.arrow_upward),
            title: new Text(pageName[0]),
          ),

          new BottomNavigationBarItem(
            icon: const Icon(Icons.arrow_downward),
            title: new Text(pageName[1]),
          ),

          new BottomNavigationBarItem(
            icon: const Icon(Icons.attach_money),
            title: new Text(pageName[2]),
          )
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        backgroundColor: Color(0xFFe1edfa),
      ),
    );
  }
}


Widget getRowView(String name, int value){
  return Container(
    color: Color(0xFF000000).withOpacity(1).withBlue((255*getClNum(value/Record.getTotal("OUT"))).floor()).withGreen(0x00).withRed((255*getClNum(value/Record.getTotal("OUT") - 255).floor())).withOpacity(0.3),
    child:
      new Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          new Padding(
            child:
            new Text(
              name,
              style: new TextStyle(fontSize:20.0,
                  color: const Color(0xFF000000),
                  fontWeight: FontWeight.w200,
                  fontFamily: "Roboto"),
            ),

            padding: const EdgeInsets.fromLTRB(24.0, 0.0, 24.0, 24.0),
          ),

          new Padding(
            child:
            new Text(
              "￥" + formatter.format(value),
              style: new TextStyle(fontSize:20.0,
                  color: const Color(0xFF000000),
                  fontWeight: FontWeight.w200,
                  fontFamily: "Roboto"),
            ),

            padding: const EdgeInsets.fromLTRB(24.0, 0.0, 24.0, 24.0),
          )
        ]

    )
  );
}
Widget getDateRowView(DateTime date){
  debugPrint(date.toString());
  return new Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.max,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        new Padding(
          child:
          new Text(
            date.month.toString() + "月" + date.day.toString() + "日",
            style: new TextStyle(fontSize:18.0,
                color: const Color(0xFF000000),
                fontWeight: FontWeight.w200,
                fontFamily: "Roboto"),
          ),
          padding: const EdgeInsets.all(10.0),
        )
      ]
  );
}


class _SisyutuPageState extends State<SisyutuPage>{
  String name = "";
  int price = 0;
  DateTime date = DateTime.now();
  TextEditingController _textEditingController;
  @override
  void initState() {
    super.initState();
    _textEditingController = new TextEditingController(text: ''); // <- こんな感じ
  }
  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    int pageIndex = Data.nowPageIndex;
    // TODO: implement build
    return new Scaffold(
      body:
       new Stack(
           children: <Widget>[
             new Image.asset('images/flutter背景でかい.png',
               fit:BoxFit.fitHeight,
             ),
              new Column(
                mainAxisAlignment: MainAxisAlignment.start,
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                        new Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            mainAxisSize: MainAxisSize.max,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              new Padding(
                                child:
                                new Text(
                                  "ごうけい",
                                  style: new TextStyle(fontSize:20.0,
                                      color: const Color(0xFF000000),
                                      fontWeight: FontWeight.w200,
                                      fontFamily: "Roboto"),
                                ),

                                padding: const EdgeInsets.fromLTRB(24.0, 24.0, 24.0, 24.0),
                              ),

                              new Padding(
                                child:
                                new Text(
                                  "￥" + formatter.format(Record.getTotal(Data.nowPageIndex==0?"OUT":"IN")),
                                  style: new TextStyle(fontSize:20.0,
                                      color: const Color(0xFF000000),
                                      fontWeight: FontWeight.w200,
                                      fontFamily: "Roboto"),
                                ),

                                padding: const EdgeInsets.fromLTRB(24.0, 24.0, 24.0, 24.0),
                              )
                            ]

                        ),
                        getList(),
                        new SizedBox(
                          width: size.width-100,
                          height: size.height/14,
                          child: new RaisedButton(
                            child: Text(
                              "にゅうりょく",
                              style: new TextStyle(
                              fontSize: 20.0
                              ),
                            ),
                            onPressed: nyuryoku,
                            shape: StadiumBorder(),
                            color: Color(0xFFe1edfa),
                    ),
                  ),
                ]
            ),
        ],
           fit: StackFit.expand
       )
    );
  }
  void nyuryoku(){
    showDialog(
      context: context,
      builder: (BuildContext context) {
            return SimpleDialog(
              title: Text('にゅうりょく'),
              children: <Widget>[
                new Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  mainAxisSize: MainAxisSize.max,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    new Padding(
                      padding: const EdgeInsets.fromLTRB(24.0, 0, 24.0, 0.0),
                      child: new Text("ひづけ"),
                    ),
                    new Padding(
                      padding: EdgeInsets.fromLTRB(24.0, 0, 24.0, 24.0),
                      child: new TextField(
                      onTap: () => selectDate(context),
                      controller: _textEditingController,
                      )
                    ),
                    new Padding(
                      padding: const EdgeInsets.fromLTRB(24.0, 0, 24.0, 0.0),
                      child: new Text("ことがら"),
                    ),
                    new Padding(
                      padding: EdgeInsets.fromLTRB(24.0, 0, 24.0, 24.0),
                      child: new TextField(
                        maxLines:1 ,
                        onChanged: handleTextName,
                      )
                    ),
                    new Padding(
                      padding: const EdgeInsets.fromLTRB(24.0, 0, 24.0, 0.0),
                      child: new Text("きんがく"),
                    ),
                    new Padding(
                      padding: EdgeInsets.fromLTRB(24.0, 0, 24.0, 24.0),
                      child: new TextField(
                        maxLines:1 ,
                        inputFormatters: <TextInputFormatter> [
                          WhitelistingTextInputFormatter.digitsOnly,
                        ],
                        onChanged: handleTextPrice,
                      )
                    ),
                    new Padding(
                      padding: EdgeInsets.fromLTRB(24.0, 0, 24.0, 24.0),
                      child: new RaisedButton(
                        child: new Text(
                          "OK"
                        ),
                      onPressed: nyurokuOK,
                      )
                    )
                  ]
                )
              ],
            );
          },
    );
  }
  void nyurokuOK(){
    if(price != null && name != null && date != null){
      setState(() {
        _textEditingController.text = "";
      });
      String dir = Data.nowPageIndex == 0 ? "OUT" : "IN";
      Record.addRecord(price, name, date, dir);
      price = null;
      name = null;
      date = null;
      Navigator.pop(context);
    }
  }
  void handleTextName(String e) => this.name = e;
  void handleTextPrice(String e) => this.price = int.parse(e);
  void handleDate(DateTime e) => this.date = e;

  Future<void> selectDate(BuildContext context) async {
    final DateTime selected = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2015),
      lastDate: DateTime.now(),
    );
    if (selected != null) {
      setState(() {
        date = selected;
        _textEditingController.text = date.month.toString() + "月" + date.day.toString() + "日";
      });
    }
  }
  Widget getList(){
    List<Widget> _myList = [];
    List<aRecord> tlist = Data.nowPageIndex == 0 ? recordsOUT : recordsIN;
    DateTime tDate;
    try{
      tDate = tlist[0].date;
      _myList.add(getDateRowView(tDate));
    }on RangeError{
      tDate = DateTime.now();
    }
    for(aRecord r in tlist){
      if(tDate.difference(r.date) != Duration()){
        _myList.add(getDateRowView(r.date));
        tDate = r.date;
      }
      _myList.add(getRowView(r.name,r.price));
    }
    return Container(
      color: Color(0x00FFFFFFFF).withOpacity(0.5),
      height:410,
      child:
          Scrollbar(
            child:
              SingleChildScrollView(
                child:
                new Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    mainAxisSize: MainAxisSize.max,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: _myList
                )
                ,
              )
          )
    );
  }
}

class _MokuhyouPageState extends State<MokuhyouPage>{
  int InTotal = Record.getTotal("IN");
  int OutTotal = Record.getTotal("OUT");
  int price;

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    //debugPrint((0xFF000000 + ((((InTotal - OutTotal)/Record.mokuhyo)*0xFF).floor() << 0x0f)).toRadixString(16));
    //debugPrint((((((InTotal - OutTotal)/Record.mokuhyo)*0xFF).floor() << 0x10)).toRadixString(16));
    debugPrint((Record.getTotal("IN") - Record.getTotal("OUT") >= Record.mokuhyo).toString());
    return new Scaffold(
      body:
      new Stack(
          children: <Widget>[
            new Image.asset('images/flutter背景でかい.png',
                fit:BoxFit.fitHeight,
            ),
            new Column(
                mainAxisAlignment: MainAxisAlignment.start,
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  new Padding(
                    child:
                    new Stack(
                      children: <Widget>[
                        new Image.asset(
                          'images/simple_present_red下地.png',
                          fit:BoxFit.fill,
                          width: (size.height/2)-(size.width/4),
                          height: size.height/2-(size.width/4),
                        ),
                        new Image.asset(
                          'images/simple_present_red中地.png',
                          fit:BoxFit.fill,
                          width: (size.height/2)-(size.width/4),
                          height: 250 - (((InTotal - OutTotal)/Record.mokuhyo)*250),
                        ),
                        new Image.asset(
                          'images/simple_present_red上地.png',
                          fit:BoxFit.fill,
                          width: (size.height/2)-(size.width/4),
                          height: size.height/2-(size.width/4),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(24.0),
                  ),

                  new Padding(
                    child:
                    new Text(
                      "たまったおかね",
                      style: new TextStyle(fontSize:25.0,
                          fontWeight: FontWeight.w200,
                          fontFamily: "Roboto"),
                    ),

                    padding: const EdgeInsets.fromLTRB(24.0, 19.0, 24.0, 4.0),
                  ),

                  new Padding(
                    child:
                    new Text(
                      "￥" + formatter.format(InTotal - OutTotal),
                      style: new TextStyle(fontSize:25.0,
                          //const Color(0xFF000000 + ((((InTotal - OutTotal)/Record.mokuhyo)*0xFF) << 0x10) + 0xFF - (((InTotal - OutTotal)/Record.mokuhyo)*0xFF))
                          color: Color(0xFF000000).withOpacity(1).withBlue((255*getClNum((InTotal - OutTotal)/Record.mokuhyo) - 255).floor()).withGreen(0x00).withRed((255*getClNum((InTotal - OutTotal)/Record.mokuhyo)).floor()),
                          fontWeight: FontWeight.w900,
                          fontFamily: "Roboto"),
                    ),

                    padding: const EdgeInsets.fromLTRB(24.0, 4.0, 24.0, 4.0),
                  ),

                  new Padding(
                    child:
                    new Text(
                      "ひつようなおかね",
                      style: new TextStyle(fontSize:25.0,
                          color: const Color(0xFF000000),
                          fontWeight: FontWeight.w200,
                          fontFamily: "Roboto"),
                    ),

                    padding: const EdgeInsets.fromLTRB(24.0, 4.0, 24.0, 4.0),
                  ),
                  new Stack(
                    children:<Widget>[
                        new FlatButton(
                        child: 
                        new Padding(
                        child:
                        new Text(
                          '￥' + formatter.format(Record.mokuhyo),
                          style: new TextStyle(fontSize:25.0,
                              color: const Color(0xFF000000),
                              fontWeight: FontWeight.w200,
                              fontFamily: "Roboto"),
                          ),

                          padding: const EdgeInsets.fromLTRB(24.0, 4.0, 24.0, 0.0),
                        ),
                        onLongPress: nyuryoku,
                        highlightColor: Color(0x0).withOpacity(0),
                      ),
                    ]
                  ),
                ]
            ),
            new GoalDialog(),
          ],
          fit: StackFit.expand
      ),
    );
  }
  void nyuryoku(){
    showDialog(
      context: context,
      builder: (BuildContext context) {
            return SimpleDialog(
              title: Text('にゅうりょく'),
              children: <Widget>[
                new Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  mainAxisSize: MainAxisSize.max,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    new Padding(
                      padding: const EdgeInsets.fromLTRB(24.0, 0, 24.0, 0.0),
                      child: new Text("ひつようなおかね"),
                    ),
                    new Padding(
                      padding: EdgeInsets.fromLTRB(24.0, 0, 24.0, 24.0),
                      child: new TextField(
                        maxLines:1 ,
                        inputFormatters: <TextInputFormatter> [
                          WhitelistingTextInputFormatter.digitsOnly,
                        ],
                        onChanged: handleTextPrice,
                      )
                    ),
                    new Padding(
                      padding: EdgeInsets.fromLTRB(24.0, 0, 24.0, 24.0),
                      child: new RaisedButton(
                        child: new Text(
                          "OK"
                        ),
                      onPressed: nyurokuOK,
                      )
                    )
                  ]
                )
              ],
            );
          },
    );
  }
  void nyurokuOK(){
    setState(() {
      if(price != null){
        Record.saveMokuhyo(price);
        price = null;
        Navigator.pop(context);
      }
    });
  }
  void handleTextPrice(String e) => this.price = int.parse(e);

  /*void goalDialog(){
    Record.saveMokuhyo(Record.mokuhyo*2);
    showDialog(
      context: context,
      builder: (context){
        return SimpleDialog(
        title: Text('☆もくひょうたっせい☆'),
        children: <Widget>[
          new Column(
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              new Padding(
                padding: const EdgeInsets.fromLTRB(24.0, 0, 24.0, 0.0),
                child: new Text("もくひょうたっせいしました！おめでとうございます！"),
              ),
              new Padding(
                padding: EdgeInsets.fromLTRB(24.0, 0, 24.0, 24.0),
                child: new RaisedButton(
                  child: new Text(
                    "OK"
                  ),
                onPressed: () => Navigator.pop(context)
                )
              )
            ]
          )
        ],
      );
      }
    );
  }*/

}

  double getClNum(double value) {
    if(value > 1) return 1;
    else if(value < 0) return 0;
    else return value;
  }

class _GoalDialogState extends State<GoalDialog> {
  @override
  Widget build(BuildContext context) {
    if (Record.getTotal("IN") - Record.getTotal("OUT") >= Record.mokuhyo){
      Record.saveMokuhyo(Record.mokuhyo*2);
      return new SimpleDialog(
        title: Text('☆もくひょうたっせい☆'),
        children: <Widget>[
          new Column(
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              new Padding(
                padding: const EdgeInsets.fromLTRB(24.0, 0, 24.0, 0.0),
                child: new Text("もくひょうたっせいしました！\nおめでとうございます！\n次の目標額を設定してみましょう！"),
              ),
              new Padding(
                padding: EdgeInsets.fromLTRB(24.0, 0, 24.0, 24.0),
                child: new RaisedButton(
                  child: new Text(
                    "OK"
                  ),
                onPressed: (){
                  setState(() {
                    Data.nowPageIndex = 2;
                  });
                }
                )
              )
            ]
          )
        ],
      );
    }else{
      return new Padding(padding: EdgeInsets.all(0),);
    }
  }
}