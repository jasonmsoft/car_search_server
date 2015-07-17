#!/bin/sh
echo $PWD
cd `dirname $0`
export ERL_LIBS=$PWD:$PWD/deps
erl  -name car_search_server@localhost  -s car_search_server