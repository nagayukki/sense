# sense

色・長さ・面積・角度の「ちょっとした違い」を把握できるようにするアプリ。
あわせて色見本・長さ・面積を画面上に実寸で表示する。

詳細は [docs/spec.md](docs/spec.md)。

## 開発

Flutter 3.44.4 (fvm で固定)。

```
fvm flutter run
fvm flutter test
```

## 構成

- ホーム画面に機能一覧を表示し、タップで各機能を確認する形
- 機能の追加は `lib/features/feature.dart` の一覧に足す
