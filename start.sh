#!/bin/sh
echo $PWD
cd `dirname $0`
erl  -pa $PWD/ebin/ $PWD/deps/*/ebin $PWD/deps/*/*/ebin -config app.config  -name car_search_server@localhost  -s car_search_server