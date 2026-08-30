# sense 開発メモ

## フェーズ方針

現在は速さと検証を重視するフェーズ。作って触って判断するサイクルを優先する。

## テスト方針

- テストは「コアロジックで変更が少ない部分」のみ書く (例: 色空間の状態計算、閾値・スコア計算)
- UI・画面のウィジェットテストは書かない (画面は頻繁に変わるため)
- 検証は `fvm flutter analyze` + コアロジックの `fvm flutter test`

## 基本

- Flutter は fvm で固定。コマンドは `fvm flutter ...`
- 機能追加は `lib/features/feature.dart` の一覧に足すとホームに並ぶ
- 仕様は docs/spec.md、機能ごとの検討は GitHub Issue (#1〜#5)
