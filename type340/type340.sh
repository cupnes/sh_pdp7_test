if [ "${TYPE340_SH+is_defined}" ]; then
	return
fi
TYPE340_SH=true

set -ue
# set -uex

TYPE340_MODE_PARAM=0
TYPE340_MODE_POINT=1
TYPE340_MODE_VECTOR=4

# ※ 引数の数値は全て8進数指定
# ※ 機械語命令を出力する関数は、それを8進数6桁の数値文字列で出力する

# パラメータモードの機械語命令を出力
# 引数:
# 1. mode: 次の命令のモード番号(3ビット)
# 2. allow_lp_enable: ライトペンイネーブル回路のセット/クリアの許可(1ビット)
# 3. lp_enable: ライトペンイネーブル回路のセット/クリア(1ビット)
# 4. stop_display_operation: 1の場合に表示動作を停止させる(1ビット)
# 5. generate_stop_intr: 第4引数と共に1の場合にSTOP割り込みを発生させる(1ビット)
# 6. allow_set_scale: スケールの設定を許可(1ビット)
# 7. scale: スケールを設定(2ビット)
#               | 設定値 | スケール |
#               |--------+----------|
#               |      0 |        1 |
#               |      1 |        2 |
#               |      2 |        4 |
#               |      3 |        8 |
# 8. allow_set_intensity: 明度の設定を許可(1ビット)
# 9. intensity: 明度を設定(3ビット)
#                   | 設定値 | 明度       |
#                   |--------+------------|
#                   |      0 | 最も暗い   |
#                   |    ... | ...        |
#                   |      7 | 最も明るい |
type340_parameter_mode() {
	# 引数を変数へ取得
	local mode=$1
	local allow_lp_enable=$2
	local lp_enable=$3
	local stop_display_operation=$4
	local generate_stop_intr=$5
	local allow_set_scale=$6
	local scale=$7
	local allow_set_intensity=$8
	local intensity=$9

	# 2ビット以上の値は2進数へ変換
	local mode_2=$(printf "%03d" $(bc <<< "obase=2;$mode"))
	local scale_2=$(printf "%02d" $(bc <<< "obase=2;$scale"))
	local intensity_2=$(printf "%03d" $(bc <<< "obase=2;$intensity"))

	# 2進数で機械語を構成
	local ml_2="00${mode_2}${allow_lp_enable}${lp_enable}"
	ml_2="${ml_2}${stop_display_operation}${generate_stop_intr}00"
	ml_2="${ml_2}${allow_set_scale}${scale_2}${allow_set_intensity}"
	ml_2="${ml_2}${intensity_2}"

	# 8進数へ変換し出力
	printf "%06d" $(bc <<< "obase=8;ibase=2;$ml_2")
}

# ポイントモードの機械語命令を出力
# 引数:
# 1. position: 座標アドレスの軸指定(1ビット)
#              | 設定値 | 軸   |
#              |--------+------|
#              |      0 | 水平 |
#              |      1 | 垂直 |
# 2. mode: 次の命令のモード番号(3ビット)
# 3. allow_lp_enable: ライトペンイネーブル回路のセット/クリアの許可(1ビット)
# 4. lp_enable: ライトペンイネーブル回路のセット/クリア(1ビット)
# 5. intensify: 指定した座標に光のスポットを出現させるか否か(1ビット)
# 6. address: 座標アドレス(10ビット)
#             - 原点は左下
type340_point_mode() {
	# 引数を変数へ取得
	local position=$1
	local mode=$2
	local allow_lp_enable=$3
	local lp_enable=$4
	local intensify=$5
	local address=$6

	# 2ビット以上の値は2進数へ変換
	local mode_2=$(printf "%03d" $(bc <<< "obase=2;$mode"))
	local address_2=$(printf "%010d" $(bc <<< "obase=2;ibase=8;$address"))

	# 2進数で機械語を構成
	local ml_2="0${position}${mode_2}${allow_lp_enable}${lp_enable}"
	ml_2="${ml_2}${intensify}${address_2}"

	# 8進数へ変換し出力
	printf "%06d" $(bc <<< "obase=8;ibase=2;$ml_2")
}

# ベクターモードの機械語命令を出力
# 引数:
# 1. escape: 1の時、ディスプレイの各設定がクリアされ、パラメータモードへ戻る(1ビット)
# 2. intensify: 1の時、
