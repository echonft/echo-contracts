// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import "forge-std/Script.sol";
import "../src/Echo.sol";

contract TestPacking is Script {
    // Exclude from coverage report
    function test() public {}

    function run() external view {
        OfferItem[] memory offerItems = new OfferItem[](1);
        offerItems[0] = OfferItem({
            tokenAddress: 0x7DA16cd402106Adaf39092215DbB54092b80B6E6,
            tokenIdOrAmount: 2,
            tokenType: TokenType.ERC721
        });

        Offer memory offer = Offer({
            sender: 0x7DA16cd402106Adaf39092215DbB54092b80B6E6,
            receiver: 0x7DA16cd402106Adaf39092215DbB54092b80B6E6,
            senderItems: OfferItems({chainId: 1, items: offerItems}),
            receiverItems: OfferItems({chainId: 1, items: offerItems}),
            expiration: 1,
            state: OfferState.OPEN
        });

        bytes memory offerIdHash = abi.encode(
            offer.sender,
            offer.receiver,
            offer.senderItems.chainId,
            keccak256(abi.encode(offer.senderItems.items)), // OfferItem[]
            offer.receiverItems.chainId,
            keccak256(abi.encode(offer.receiverItems.items)), // OfferItem[]
            offer.expiration
        );
        bytes32 offerId = keccak256(offerIdHash);

        console.logBytes(offerIdHash);
        console.logBytes32(offerId);
    }
}
