#!/bin/bash
SD=`pwd`
SD=$SD/"./setup-debian.sh"

$SD dotdeb
$SD system
$SD iptables 22
$SD nginx
$SD php
$SD mysql

