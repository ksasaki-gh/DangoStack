Task 9を実装しました。Bag方式による生成と、画面右上のNEXT表示が動作します。
変更ファイル：
- [DangoQueue.swift (line 6)](/Users/evergreen/Program/xcode/DangoStack/DangoStack/DangoQueue.swift:6)
  - green / white / pinkを各3個追加した9個のBagを生成。
  - Bag生成時にシャッフル。
  - 空になると次のBagを自動生成。
- [DangoGameScene.swift (line 80)](/Users/evergreen/Program/xcode/DangoStack/DangoStack/DangoGameScene.swift:80)
  - currentDangoColorとnextDangoColorを管理。
  - 右上にNEXTラベルと直径28ptのプレビュー円を追加。
  - NEXTの位置やサイズはNextDisplayParametersで調整可能。
Current／Nextの更新は[finishCurrentDango() (line 532)](/Users/evergreen/Program/xcode/DangoStack/DangoStack/DangoGameScene.swift:532)へ共通化しました。
- 正しく刺さったアニメーション完了後
- DISCARDで画面外へ落ちた後
- MISSで画面下へ落ちた後
のいずれでも、nextをcurrentへ移し、Queueから新しいnextを取得して表示を更新します。
確認結果：
- 100個のBagを検証し、各Bagが常に3色×3個になることを確認
- iOS Simulator向けDebugビルド成功
- Simulatorへのインストール・起動成功
- NEXT表示をSimulator画面で確認済み

Task 8を実装しました。色違い・完成済みの串への着弾が正式にDISCARDとして処理されます。
変更ファイル：
- [DangoGameScene.swift (line 68)](/Users/evergreen/Program/xcode/DangoStack/DangoStack/DangoGameScene.swift:68)
  - discarding状態を追加。
  - 団子を少し横・上へ弾いたあと、画面外へ落とすアニメーションを追加。
  - 着弾位置にDISCARDを表示し、上昇しながらフェードアウト。
  - 色違いと完成済みの串を同じDISCARD処理へ接続。
  - アニメーション値はDiscardAnimationParametersで調整可能。
MISSとDISCARDの区別：
- [HitJudge.swift (line 19)](/Users/evergreen/Program/xcode/DangoStack/DangoStack/HitJudge.swift:19)が横位置のみを判定し、着弾範囲外ならMISS。
- [DangoGameScene.swift (line 271)](/Users/evergreen/Program/xcode/DangoStack/DangoStack/DangoGameScene.swift:271)で、位置判定がPERFECT/GOODの場合だけ色を確認。
- 色違いまたは完成済みならDISCARD、正しい色なら従来どおり串へ刺します。
確認結果：
- iOS Simulator向けDebugビルド成功
- Simulatorへのインストール・起動成功
- スコア・MISS回数・コンボ処理は追加していません。

Task 7を実装しました。3本の串が独立して進行し、次に必要な色だけ刺さります。
変更ファイル：
- [DangoColor.swift (line 6)](/Users/evergreen/Program/xcode/DangoStack/DangoStack/DangoColor.swift:6)
  - 積み上げ順を green → white → pink として定義。
  - デバッグ表示用に色名を文字列化。
- [DangoGameScene.swift (line 256)](/Users/evergreen/Program/xcode/DangoStack/DangoStack/DangoGameScene.swift:256)
  - 落下中の団子色を保持。
  - 位置判定後、対象の串が必要としている色と一致する場合のみ、既存の位置補正・ぷにっ演出で追加。
  - 色違いまたは完成済みの場合は刺さらず、そのまま画面下へ落下。
  - PERFECT / GOOD LEFT / GOOD RIGHT / MISS判定は維持。
各串の次の色は、[SkewerState.swift (line 18)](/Users/evergreen/Program/xcode/DangoStack/DangoStack/SkewerState.swift:18)で、現在の団子数を stackOrder の添字として判断しています。3個刺さると nilになり、追加できません。3本それぞれが別のSkewerStateを持つため、進行状態も独立しています。
確認結果：
- iOS Simulator向けDebugビルド成功
- Simulatorへのインストール・起動成功
- 3本の串の独立状態とgreen → white → pinkの遷移を確認済み

Task 6を完了しました。
変更ファイル：
- [DangoColor.swift](/Users/evergreen/Program/xcode/DangoStack/DangoStack/DangoColor.swift)
  - green、white、pinkと生成順を定義
- [SkewerState.swift](/Users/evergreen/Program/xcode/DangoStack/DangoStack/SkewerState.swift)
  - 各串の団子数、次に必要な色、刺さったノード、満杯状態を管理
  - 最大3個に制限
- [DangoGameScene.swift](/Users/evergreen/Program/xcode/DangoStack/DangoStack/DangoGameScene.swift)
  - green → white → pinkの順で生成
  - 成功後に次の団子を生成
  - 3段の固定位置へスナップ
  - 直下の団子だけを軽く縦方向へ変形
  - PERFECT／GOOD補正とMISS処理を維持
- [HitJudge.swift](/Users/evergreen/Program/xcode/DangoStack/DangoStack/HitJudge.swift)
  - 対象となる最近傍の串インデックスを取得可能に変更
調整箇所：
- 串の状態・最大数
  [SkewerState.swift (line 8)](/Users/evergreen/Program/xcode/DangoStack/DangoStack/SkewerState.swift:8)
- 各段のY座標・団子間隔
  [StackLayoutParameters (line 64)](/Users/evergreen/Program/xcode/DangoStack/DangoStack/DangoGameScene.swift:64)のdangoVerticalSpacing
  - 1段目：串先端 − 104pt
  - 2段目：串先端 − 52pt
  - 3段目：串先端
  - 現在の中心間隔は52ptで、直径56ptの団子が約4pt重なります。
- 直下の団子の変形量
  [LandingAnimationParameters (line 49)](/Users/evergreen/Program/xcode/DangoStack/DangoStack/DangoGameScene.swift:49)
  - underlyingSquashScaleY = 0.94
  - underlyingSquashDuration
  - underlyingRestoreDuration
確認結果：
- Simulator向けDebugビルド成功
- iPhone 17 Pro Simulatorで起動成功
- 初期団子がgreenで表示されることを確認
- green → white → pink、3個で満杯、4個目拒否の状態チェックに成功

Task 5を完了しました。
変更ファイル：
- [DangoGameScene.swift](/Users/evergreen/Program/xcode/DangoStack/DangoStack/DangoGameScene.swift)
  - PERFECTは串中央へスナップ
  - GOOD LEFT／RIGHTは串中央から固定量ずらしてスナップ
  - 成功時は落下を停止して串上へ固定
  - 吸着と同時に横へ広がり、縦へ縮んでから戻る「ぷにっ」演出を追加
  - MISSは従来どおり落下・再生成
- [HitJudge.swift](/Users/evergreen/Program/xcode/DangoStack/DangoStack/HitJudge.swift)
  - 最寄りの串中心を表示補正でも利用できるよう整理
調整値は[LandingAnimationParameters (line 49)](/Users/evergreen/Program/xcode/DangoStack/DangoStack/DangoGameScene.swift:49)にまとめています。
- スナップ位置
  - goodHorizontalOffset：GOODの左右固定ズレ
  - stuckCenterYOffset：串先端に対する縦位置
- スナップ時間
  - snapDuration
- ぷにっ変形量
  - squashScaleX
  - squashScaleY
- アニメーション時間
  - squashDuration
  - restoreDuration
現在値はスナップ0.08秒、横1.10倍、縦0.85倍、変形・復元合計0.13秒です。
確認結果：
- iPhone Simulator向けDebugビルド成功
- iPhone 17 Pro Simulatorで起動成功
- Task 4までの団子移動・串表示を維持しています。

Task 4を完了しました。
変更ファイル：
- [HitJudge.swift](/Users/evergreen/Program/xcode/DangoStack/DangoStack/HitJudge.swift)
  - perfect、goodLeft、goodRight、missを定義
  - 最も近い串を選択して横方向の距離を判定
- [DangoGameScene.swift (line 224)](/Users/evergreen/Program/xcode/DangoStack/DangoStack/DangoGameScene.swift:224)
  - 団子が串先端へ到達した時に1回だけ判定
  - XcodeコンソールへPERFECT、GOOD LEFT、GOOD RIGHT、MISSを出力
  - 判定後も団子は固定せず、従来どおり画面下まで落下
判定幅は[HitJudge.swift (line 16)](/Users/evergreen/Program/xcode/DangoStack/DangoStack/HitJudge.swift:16)の次の値で調整できます。
- perfectThresholdRatio = 0.20
- goodThresholdRatio = 0.38
確認結果：
- 左・中央・右それぞれのPERFECTを直接チェック
- GOOD LEFT、GOOD RIGHT、MISSを直接チェック
- iPhone Simulator向けDebugビルド成功
- iPhone 17 Pro Simulatorで起動成功

Task 3を完了しました。
変更ファイル：
- [DangoGameScene.swift](/Users/evergreen/Program/xcode/DangoStack/DangoStack/DangoGameScene.swift)
  - 画面上部にピンクの円形団子を追加
  - 左右の範囲内を一定速度で自動往復
  - タップ時のX座標を維持して真下へ落下
  - 画面下へ出た後、0.6秒待って新しい団子を生成
  - 既存の3本の串は維持
  - 物理エンジン、串との当たり判定は未使用
調整可能な値は[DangoParameters (line 34)](/Users/evergreen/Program/xcode/DangoStack/DangoStack/DangoGameScene.swift:34)にまとめています。
- diameter：団子サイズ
- horizontalSpeed：左右移動速度
- horizontalRangeRatios：左右移動範囲
- fallingSpeed：落下速度
- respawnDelay：再生成までの待ち時間
確認結果：
- iPhone Simulator向けDebugビルド成功
- iPhone 17 Pro Simulatorで起動成功
- 団子が上部に表示され、時間経過で左右へ移動することを確認済みです。

Task 2を完了しました。
変更ファイル：
- [DangoGameScene.swift](/Users/evergreen/Program/xcode/DangoStack/DangoStack/DangoGameScene.swift)
  - 茶色のSKShapeNodeで3本の串を追加
  - 左・中央・右へ等間隔に配置
  - 位置とサイズをシーンサイズ比の定数として分離
  - シーンサイズ変更時に再配置
  - 団子、当たり判定、移動処理は未実装
確認結果：
- iPhone Simulator向けDebugビルド成功
- iPhone 17 Pro Simulatorで起動成功
- 画面下側に同じサイズの串が3本表示されることを確認済みです。

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
