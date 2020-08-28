お小遣い帳 Flutter アプリ
===

# 環境

- Flutter 1.20.2
- Dart 2.9.1
- SQLite

## 導入ライブラリ
- [path 1.6.4](https://pub.dev/packages/path)
- [path_provider 1.6.11](https://pub.dev/packages/path_provider)
- [sqflite 1.3.1](https://pub.dev/packages/sqflite)

## ライブラリインストール
- pubspec.yaml ファイルの dependencies: のセクションに使用するライブラリを追加

- 以下、記述例
    ```
    dependencies:
        sqflite: ^1.3.1
    ```

# 機能
- 収支の記録
- 貯金目標を設定できる
- 使用金額に応じて文字色が変化する
## メイン画面
- ナビゲーションバーにより3画面を切り替える。

### 「つかったおかね」＆「もらったおかね」画面
- 入力で項目を入力できます。

### 「もくひょう」画面
- 目標金額を長押しすると、目標金額を設定できます。
- プレゼントボックスのゲージの変化を確認できます。

### 項目入力ダイアログ
- 日付、項目名、金額の入力が可能
- OK ボタンで項目を登録
