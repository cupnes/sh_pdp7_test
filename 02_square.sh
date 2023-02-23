#!/bin/bash

set -ue

. type340/driver.sh

type340_drv_set_position 1000 1000
type340_drv_draw_line 100 0 0
type340_drv_draw_line 0 100 0
type340_drv_draw_line 300 0 0
type340_drv_draw_line 0 300 1
type340_drv_end_drawing
