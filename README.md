# Dango Stack

SwiftUI と SpriteKit で実装した、iPhone縦画面向けのカジュアルゲームです。v1.0は全21ステージで、3本の串すべてを `green → white → pink` の順に完成させるとクリアです。

## 画面構成

- `TitleView`：PLAY、STAGE SELECT、SETTINGS
- `StageSelectView`：7セクション×3ステージ、解放状態、Best Stars、PERFECT CLEAR
- `GameView` / `DangoGameScene`：SpriteKitのゲーム本体、Pause、FAILED
- `ResultView`：星、PERFECT / GOOD、PERFECT CLEAR、次の操作
- `SettingsView`：Sound、Haptics、Tutorial再実行、必要時のPrivacy Options

画面遷移とセッション状態は `AppState`、永続進捗は `SaveManager`、設定は `SettingsStore`、チュートリアル完了状態は `TutorialStore` が担当します。

## ステージ難易度

`DangoStack/StageConfig.swift` に基準値、A / B / Cの各Level、Stage 1〜21の組み合わせをまとめています。

- A：団子の横移動速度
- B：3本の串をまとめた左右移動
- C：串幅とPERFECT / GOOD判定幅

構成は A、B、C、A+B、A+C、B+C、A+B+C の7セクションで、各セクション内はLevel 1〜3です。タップ後の落下速度と着弾演出は全ステージ共通で、`DangoGameScene.swift` 冒頭の各Parametersにあります。

## 保存

UserDefaultsへ以下を保存します。

- `dangoStack.gameProgress`：解放ステージ、各ステージのBest Stars、PERFECT CLEAR
- `dangoStack.settings.soundEnabled`：Sound設定
- `dangoStack.settings.hapticsEnabled`：Haptics設定
- `dangoStack.hasSeenTutorial`：Stage 1チュートリアル完了状態

`SaveManager.resetProgressForDebug()` はDEBUGビルド限定で、画面上のリセットUIはありません。

## SE

音源がなくても安全に無音で動作します。SEを追加する場合は、次のbasenameで `wav`、`caf`、`m4a`、または `mp3` をアプリターゲットへ含めます。

- `tap`
- `perfect`
- `good`
- `wrong`
- `miss`
- `life_break`
- `dango_complete`
- `stage_clear`
- `perfect_clear`

## AdMob

Google Mobile Ads SDKはSwift Package Managerで導入しています。

- DEBUG：Google公式テストApp ID / Rewarded ID / Interstitial ID
- RELEASE：`DangoStack.xcodeproj/project.pbxproj` の `ADMOB_APP_ID` と `DangoStack/AdConfiguration.swift` の広告ユニットIDを本番値へ差し替える
- `DangoStack/Info.plist`：`GADApplicationIdentifier` と `SKAdNetworkItems`
- `ConsentManager`：UMP同意とPrivacy Options
- `AdManager`：事前ロード、Rewarded Continue、3クリア単位のInterstitial

Release用IDがプレースホルダーの間は広告処理を開始せず、ゲーム進行は継続します。

`DangoStack/PrivacyInfo.xcprivacy` は、アプリ自身のUserDefaults利用をCA92.1（アプリ内だけの読み書き）として宣言しています。広告SDKが収集するデータは、SDK同梱のPrivacy ManifestとApp Store Connect上の回答を合わせて確認してください。

## リリース前の実機確認

- Stage 1〜21の難易度とPERFECT / GOODの感触
- 小型・大型iPhoneでのNEXT、Pause、ライフ、Result、Stage Select
- 落下中・串移動中・チュートリアル中のPause / Resume
- FAILED後のRewarded Continueと、Result後のInterstitial
- Sound / Hapticsの実機動作
- アプリ再起動後の進捗・設定・チュートリアル状態
- Release用AdMob ID、署名、App Icon、表示名、Privacy情報
