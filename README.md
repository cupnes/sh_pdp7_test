# SVGからそれを表示するsimhスクリプトを生成

## 注意事項

- LibreOffice Drawの「直線」あるいは「直線コネクター」で作った画像をエクスポートしたSVGであること
  - 未確認だがおそらくImpressでも大丈夫
- 幅と高さが同じであること
  - 動作確認時は幅と高さを共に7.47cmにしていた
- このREADME.mdがあるディレクトリをカレントディレクトリにした状態で実行すること

## 生成手順

1. SVGから直線が定義されたCSVを生成
   ```console
   $ tools/svg2ld test.svg test.csv
   ```
2. CSVからType 340命令列を生成
   ```console
   $ tools/ld2ml test.csv test.340ml
   ```
3. Type 340命令列を指定されたアドレス(8進数)以降に配置するsimhスクリプトを生成
   ```console
   $ tools/ml2simh test.340ml test.340simh 1000
   ```
4. Type 340命令列をロードして実行するプログラムをくっつけたsimhスクリプトを生成
   ```console
   $ cat test.340simh type340/load_infexec_set_param_and_run.simh > test.simh
   ```

## 動作確認

生成されたtest.simhを以下のように実行すると、ベクタースキャンディスプレイをシミュレートしているウィンドウに生成した画像が描画される。

```console
$ pdp7 test.simh
```

### 備考

- 実行を停止する際はCtrl+e
- 停止するとSimHのプロンプトに戻ってくるので、`exit`コマンド等で終了すること
