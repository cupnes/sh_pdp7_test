#!/bin/bash

set -ue

. type340/driver.sh

type340_drv_set_position 1000 1000
type340_drv_draw_line 100 0 1
type340_drv_end_drawing
