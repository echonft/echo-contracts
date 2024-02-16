#!/bin/bash

source ../.env

receiver=0x2a201c109231d2f3D9511F8B0F078b6448602d39
sender=0x213bE2f484Ab480db4f18b0Fe4C38e1C25877f09

bayc=0x65426F3C04e85936b0F875510d045b413134186A
idsBayc=(86 87)
mayc=0xd91303F46C3f4883D9D74c703C15948e5E04E110
idsMayc=(71 72)
cyberkongz=0x43bE93945E168A205D708F1A41A124fA302e1f76
idsKongz=(61 62)
sora=0x3512BbCAD47275F8e11e7B843FA4BDf7b526f5b8
idsSora=(39 40)
creepz=0xB9FBf3cDf5B344a9e09528FEe853e376d57eE7cA
idsCreepz=(39 40)

# Distribute BAYC
for id in "${idsBayc[@]}"
do
    cast send $bayc "transferFrom(address, address, uint256)" $sender $receiver $id --rpc-url $SEPOLIA_RPC_URL --private-key $PRIVATE_KEY
done

# Distribute MAYC
for id in "${idsMayc[@]}"
do
    cast send $mayc "transferFrom(address, address, uint256)" $sender $receiver $id --rpc-url $SEPOLIA_RPC_URL --private-key $PRIVATE_KEY
done

# Distribute Cyberkongz
for id in "${idsKongz[@]}"
do
    cast send $cyberkongz "transferFrom(address, address, uint256)" $sender $receiver $id --rpc-url $SEPOLIA_RPC_URL --private-key $PRIVATE_KEY
done

# Distribute Soras
for id in "${idsSora[@]}"
do
    cast send $sora "transferFrom(address, address, uint256)" $sender $receiver $id --rpc-url $SEPOLIA_RPC_URL --private-key $PRIVATE_KEY
done

# Distribute Creepz
for id in "${idsCreepz[@]}"
do
    cast send $creepz "transferFrom(address, address, uint256)" $sender $receiver $id --rpc-url $SEPOLIA_RPC_URL --private-key $PRIVATE_KEY
done
