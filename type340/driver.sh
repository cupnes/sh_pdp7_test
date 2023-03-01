if [ "${TYPE340_DRIVER_SH+is_defined}" ]; then
	return
fi
TYPE340_DRIVER_SH=true

. common/common.sh
. type340/dsp.sh

set -ue
# set -uex

# ※ 基本的に値は全て8進数

# 使い方
# 1. set_position で(X座標, Y座標)をセット
# 2. draw_line で指定した(ΔX, ΔY)の直線を引く
#    - (X座標, Y座標)は(ΔX, ΔY)を加算した値で更新される
# 3. 2.を1回以上繰り返す
# 4. 1.〜3.を任意の回数繰り返す
# 5. 最後に end_drawing を呼び出す

# 各種パラメータとデフォルト値
TYPE340_DRV_ALLOW_LP_ENABLE=0
TYPE340_DRV_LP_ENABLE=0
TYPE340_DRV_STOP_DISPLAY_OPERATION=0
TYPE340_DRV_GENERATE_STOP_INTR=0
TYPE340_DRV_ALLOW_SET_SCALE=1
TYPE340_DRV_SCALE=0
TYPE340_DRV_ALLOW_SET_INTENSITY=1
TYPE340_DRV_INTENSITY=7
TYPE340_DRV_POINT_INTENSIFY=0
TYPE340_DRV_VECTOR_INTENSIFY=1
TYPE340_DRV_X=0
TYPE340_DRV_Y=0

# 座標をセットする
# 引数:
# 1. X座標
# 2. Y座標
type340_drv_set_position() {
	# 引数を変数へ設定
	TYPE340_DRV_X=$1
	TYPE340_DRV_Y=$2

	# パラメータモードの命令を生成
	type340_dsp_parameter_mode $TYPE340_DSP_MODE_POINT \
				   $TYPE340_DRV_ALLOW_LP_ENABLE \
				   $TYPE340_DRV_LP_ENABLE \
				   $TYPE340_DRV_STOP_DISPLAY_OPERATION \
				   $TYPE340_DRV_GENERATE_STOP_INTR \
				   $TYPE340_DRV_ALLOW_SET_SCALE \
				   $TYPE340_DRV_SCALE \
				   $TYPE340_DRV_ALLOW_SET_INTENSITY \
				   $TYPE340_DRV_INTENSITY

	# X座標・Y座標をセットするポイントモードの命令を生成
	type340_dsp_point_mode $TYPE340_DSP_AXIS_X $TYPE340_DSP_MODE_POINT \
			       $TYPE340_DRV_ALLOW_LP_ENABLE \
			       $TYPE340_DRV_LP_ENABLE \
			       $TYPE340_DRV_POINT_INTENSIFY $TYPE340_DRV_X
	type340_dsp_point_mode $TYPE340_DSP_AXIS_Y $TYPE340_DSP_MODE_VECTOR \
			       $TYPE340_DRV_ALLOW_LP_ENABLE \
			       $TYPE340_DRV_LP_ENABLE \
			       $TYPE340_DRV_POINT_INTENSIFY $TYPE340_DRV_Y
}

# 現在の座標から(ΔX, ΔY)の直線を描画
# 引数:
# 1. ΔX
# 2. ΔY
# 3. エスケープフラグ
#    - 次も直線描画を行う場合は0を、
#      そうでない場合は1を指定する
TYPE340_DRV_DRAW_LINE_MAX_XY=177	# 1度に描画できるX/Y成分の最大(127)
type340_drv_draw_line() {
	# 引数を変数へ設定
	local delta_x=$1
	local delta_y=$2
	local escape=$3

	# ベクターモードの命令を生成
	type340_dsp_vector_mode $escape $TYPE340_DRV_VECTOR_INTENSIFY \
				$delta_y $delta_x
}

# 描画を終える
type340_drv_end_drawing() {
	# パラメータモードの命令を生成
	type340_dsp_parameter_mode $TYPE340_DSP_MODE_PARAM \
				   0 0 1 1 0 0 0 0
}
