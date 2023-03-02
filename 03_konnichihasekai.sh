#!/bin/bash

set -ue

. type340/driver.sh

# TODO 文字の間隔をもう少し広げたほうが良いかも
# TODO 先に文字を置く領域に枠線を引いておいたほうが作業しやすいかも

# 文字の間隔(1文字の上と左に余白を置く)
CHAR_GAP=4
# 画面の幅・高さ(1024 x 1024 px)
DISPLAY_WIDTH=2000
DISPLAY_HEIGHT=2000
# 「コンニチハ」
## フォントサイズ(204 x 204 px)
KONNICHIHA_FONT_SIZE=314
## 開始座標(0, 615)
KONNICHIHA_START_X=0
KONNICHIHA_START_Y=1147
# 「世界」
## フォントサイズ(410 x 410 px)
SEKAI_FONT_SIZE=632
## 開始座標(200, 205)
SEKAI_START_X=310
SEKAI_START_Y=315

# カタカナの「コ」を描画(サイズ：204 x 204 px)
# 引数:
# 1. X座標
# 2. Y座標
draw_kata_ko_204() {
	# 変数定義
	local pos_x=$1
	local pos_y=$2
	local font_size_10=204
	local draw_size=$(bc <<< "obase=8;$font_size_10 - $CHAR_GAP")
	local draw_size_1=$TYPE340_DRV_DRAW_LINE_MAX_XY_8
	local draw_size_2=$(bc <<< "obase=8;ibase=8;$draw_size - $draw_size_1")
	local minus_draw_size_1=$(bc <<< "obase=8;ibase=8;200 + $draw_size_1")
	local minus_draw_size_2=$(bc <<< "obase=8;ibase=8;200 + $draw_size_2")

	# 開始座標設定
	pos_x=$(bc <<< "obase=8;ibase=8;$pos_x + $CHAR_GAP")
	type340_drv_set_position $pos_x $pos_y

	# 「コ」の下側の直線を左から右へ引く
	type340_drv_draw_line $draw_size_1 0 0
	type340_drv_draw_line $draw_size_2 0 0

	# 「コ」の真ん中の直線を下から上へ引く
	type340_drv_draw_line 0 $draw_size_1 0
	type340_drv_draw_line 0 $draw_size_2 0

	# 「コ」の上側の直線を右から左へ引く
	type340_drv_draw_line $minus_draw_size_1 0 0
	type340_drv_draw_line $minus_draw_size_2 0 1
}

# カタカナの「ン」を描画(サイズ：204 x 204 px)
# 引数:
# 1. X座標
# 2. Y座標
draw_kata_n_204() {
	# 変数定義
	local pos_x=$1
	local pos_y=$2
	local font_size_10=204
	local draw_size=$(bc <<< "obase=8;$font_size_10 - $CHAR_GAP")	# 0o310

	# 開始座標設定
	pos_x=$(bc <<< "obase=8;ibase=8;$pos_x + $CHAR_GAP")
	type340_drv_set_position $pos_x $pos_y

	# 「ン」の下の部分を横の直線で引く
	local delta_x_1=170
	type340_drv_draw_line $delta_x_1 0 0

	# 続けて左下から右上へ斜めの直線を引く
	local delta_x_2=$(bc <<< "obase=8;ibase=8;$draw_size - $delta_x_1")
	local delta_y_2=$(bc <<< "obase=8;ibase=8;$draw_size - 120")
	type340_drv_draw_line $delta_x_2 $delta_y_2 1
}

main() {
	# 作業用変数
	local cur_x
	local cur_y

	# 「コンニチハ」を描画
	## 開始座標を変数へ設定
	cur_x=$KONNICHIHA_START_X
	cur_y=$KONNICHIHA_START_Y
	## 「コ」を描画
	draw_kata_ko_204 $cur_x $cur_y
	## 座標を進める
	cur_x=$(bc <<< "obase=8;ibase=8;$cur_x + $KONNICHIHA_FONT_SIZE")
	## 「ン」を描画
	draw_kata_n_204 $cur_x $cur_y

	# 描画終了
	type340_drv_end_drawing
}

main
