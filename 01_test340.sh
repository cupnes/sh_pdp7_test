#!/bin/bash

set -ue

. type340/driver.sh

type340_drv_set_position 512 512
type340_drv_draw_line 64 0 1
type340_drv_end_drawing
