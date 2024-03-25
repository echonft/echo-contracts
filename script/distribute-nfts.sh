#!/bin/bash

source ../.env

# Constants
bayc=0x65426F3C04e85936b0F875510d045b413134186A
mayc=0xd91303F46C3f4883D9D74c703C15948e5E04E110
cyberkongz=0x43bE93945E168A205D708F1A41A124fA302e1f76
sora=0x3512BbCAD47275F8e11e7B843FA4BDf7b526f5b8
creepz=0xB9FBf3cDf5B344a9e09528FEe853e376d57eE7cA
nftsToSend=2

# Addresses
receiver=0xD1098fe3019646C85337528323d8B63458C2De30
sender=0x213bE2f484Ab480db4f18b0Fe4C38e1C25877f09

# IDs
baycStartingId=106
kongzStartingId=81
maycStartingId=91
kongzStartingId=81
soraStartingId=61
creepzStartingId=61

# Distribute BAYC
for((id=baycStartingId;id<baycStartingId + nftsToSend; id++))
do
    cast send $bayc "transferFrom(address, address, uint256)" $sender $receiver $id --rpc-url $SEPOLIA_RPC_URL --private-key $PRIVATE_KEY
done

# Distribute MAYC
for((id=maycStartingId;id<maycStartingId + nftsToSend; id++))
do
    cast send $mayc "transferFrom(address, address, uint256)" $sender $receiver $id --rpc-url $SEPOLIA_RPC_URL --private-key $PRIVATE_KEY
done

# Distribute Cyberkongz
for((id=kongzStartingId;id<kongzStartingId + nftsToSend; id++))
do
    cast send $cyberkongz "transferFrom(address, address, uint256)" $sender $receiver $id --rpc-url $SEPOLIA_RPC_URL --private-key $PRIVATE_KEY
done

# Distribute Soras
for((id=soraStartingId;id<soraStartingId + nftsToSend; id++))
do
    cast send $sora "transferFrom(address, address, uint256)" $sender $receiver $id --rpc-url $SEPOLIA_RPC_URL --private-key $PRIVATE_KEY
done

# Distribute Creepz
for((id=creepzStartingId;id<creepzStartingId + nftsToSend; id++))
do
    cast send $creepz "transferFrom(address, address, uint256)" $sender $receiver $id --rpc-url $SEPOLIA_RPC_URL --private-key $PRIVATE_KEY
done

echo "New starting ids:"
echo "BAYC:$((baycStartingId + nftsToSend))"
echo "MAYC:$((maycStartingId + nftsToSend))"
echo "Cyberkongz:$((kongzStartingId + nftsToSend))"
echo "Soras:$((soraStartingId + nftsToSend))"
echo "Creepz:$((creepzStartingId + nftsToSend))"