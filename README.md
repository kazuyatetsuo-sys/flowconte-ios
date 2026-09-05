# FlowConte (iOS / iPadOS ネイティブ版)

コンテンツとプロジェクトを整理するための個人用ツールのネイティブアプリ版。SwiftUI + SwiftDataで構築し、データは端末内にのみ保存する(CloudKit同期は将来対応)。

Web版(Next.js + Supabase, [flowconte](https://github.com/kazuyatetsuo-sys/flowconte))と機能仕様・配色は共通だが、実装は独立している。

## 技術構成

- SwiftUI + SwiftData(ローカル永続化のみ)
- Universal app: iPad / iPhone 両対応、`NavigationSplitView`
- 最低対応OS: iOS 17 / iPadOS 17
- Bundle ID: `com.oaksand.flowconte`
- プロジェクトファイルは [XcodeGen](https://github.com/yonaskolb/XcodeGen) の `project.yml` から生成(`FlowConte.xcodeproj` もコミット済みなのでXcodeで開くだけで使える)

## セットアップ

```bash
git clone https://github.com/kazuyatetsuo-sys/flowconte-ios.git
cd flowconte-ios
open FlowConte.xcodeproj
```

`project.yml` を変更した場合は再生成する:

```bash
brew install xcodegen  # 未導入の場合
xcodegen generate
```

### ビルド(コマンドライン)

この環境では `xcode-select` がCommand Line Toolsを指している場合があるため、必要に応じて `DEVELOPER_DIR` を明示する:

```bash
env DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer \
  xcodebuild -project FlowConte.xcodeproj -scheme FlowConte \
  -destination 'generic/platform=iOS Simulator' build
```

### テスト

`FlowConteUITests` に主要フローのUIテストがある(新規作成→編集→タグ付け→リリース判定→保存、プロジェクトのAND/OR絞り込み)。SwiftDataは `-UITest_ResetStore` 起動引数を渡すとインメモリストアで起動し、実データに影響を与えずに毎回まっさらな状態でテストできる。

```bash
env DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer \
  xcodebuild -project FlowConte.xcodeproj -scheme FlowConte \
  -destination 'id=<シミュレータのUDID>' test
```

## 操作(外部キーボード)

- `⌘+Return`: 編集開始 / 保存のトグル
- `⌃⌘+Return`: 新規コンテンツを作成し、即編集モードで開く
- `↑` / `↓`: コンテンツリストの選択移動(編集中は無効)

キーボードショートカットはSimulator上のXCUITestでは確実に再現できないことがあるため、実機の外部キーボードでの動作確認を推奨する。

## 写真の扱い

- 本文中は `![キャプション](ファイル名)` のマークダウン記法でインライン写真を扱う
- 圧縮版(長辺1600px・JPEG)はアプリのDocumentsディレクトリに保存し、ファイル名を `ContentItem.photoFileName` / 本文中に保持する
- オリジナルは `PHPhotoLibrary` 経由で「写真」アプリに保存する(iCloud写真の同期はユーザー側の設定に委ねる。アプリ側では同期を管理しない)

## 既知の制約 / 今後の対応

- CloudKit/iCloud同期は未対応(データモデルはString/Bool/Date/[String]のみで構成し、将来の移行を想定)
- AppIconはプレースホルダー(1024pxスロットのみ)。配布前に実際のアイコン画像を用意する必要がある
- 実機配布時はXcodeでDevelopment Teamの設定が必要(現状はシミュレータ向けの自己署名のみ)
