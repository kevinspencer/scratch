#!/bin/bash

WP_USER=$(<wp.user); export WP_USER
WP_PASS=$(<wp.pass); export WP_PASS

./wordpress.pl
