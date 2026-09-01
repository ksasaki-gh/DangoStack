Task 1を完了しました。
変更ファイル：
- [GameView.swift](/Users/evergreen/Program/xcode/DangoStack/DangoStack/GameView.swift)
  - SwiftUIのSpriteViewからDangoGameSceneを全画面表示
- [DangoGameScene.swift](/Users/evergreen/Program/xcode/DangoStack/DangoStack/DangoGameScene.swift)
  - ゲームロジックなしの最小SKScene
  - 背景色のみ設定
- [DangoStackApp.swift](/Users/evergreen/Program/xcode/DangoStack/DangoStack/DangoStackApp.swift)
  - 起動時の画面を暫定的にGameViewへ変更
- [project.pbxproj](/Users/evergreen/Program/xcode/DangoStack/DangoStack.xcodeproj/project.pbxproj)
  - iPhoneの画面方向を縦向きに限定
確認結果：
- iPhone Simulator向けDebugビルド成功
- iPhone 17 Pro Simulatorへのインストール・起動成功
- SpriteKitの背景色がSwiftUI内で全画面表示されることを目視確認済みです。
