#! /usr/bin/env bash
shopt -s expand_aliases

alias cardano-cli="~/git/cardano-node/cardano-cli-build/bin/cardano-cli"

cardano-cli address key-gen \
    --verification-key-file payment.vkey \
    --signing-key-file payment.skey

cardano-cli address build \
    --payment-verification-key-file payment.vkey \
    --out-file payment.addr \
    --testnet-magic 1097911063

small_addr=$(cat payment.addr | cut -c1-20)
mkdir $small_addr

mv payment.skey $small_addr/$small_addr.skey
mv payment.vkey $small_addr/$small_addr.vkey
mv payment.addr $small_addr/$small_addr.addr
