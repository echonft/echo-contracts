// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import "forge-std/Test.sol";
import "../mock/Mocked721.sol";
import "../../src/types/Offer.sol";
import "../../src/types/OfferItem.sol";
import "../../src/types/OfferItems.sol";

abstract contract OfferUtils is Test {
    OfferItem[] public senderItems;
    OfferItem[] public receiverItems;

    uint256 public in6hours;

    function generateOfferId(Offer memory offer) public pure returns (bytes32 offerId) {
        // TODO Validate this behaviour
        offerId = keccak256(
            abi.encode(
                offer.sender,
                offer.receiver,
                offer.senderItems.chainId,
                keccak256(abi.encode(offer.senderItems.items)), // OfferItem[]
                offer.receiverItems.chainId,
                keccak256(abi.encode(offer.receiverItems.items)), // OfferItem[]
                offer.expiration
            )
        );
    }

    function generateOffer(
        address sender,
        address[] memory senderTokenAddresses,
        uint256[] memory senderTokenIds,
        uint256 senderChainId,
        address receiver,
        address[] memory receiverTokenAddresses,
        uint256[] memory receiverTokenIds,
        uint256 receiverChainId,
        uint256 expiration,
        OfferState state
    ) public returns (Offer memory offer) {
        require(senderTokenAddresses.length != senderTokenIds.length, "Sender items arrays do not match");

        require(receiverTokenAddresses.length != receiverTokenIds.length, "Receiver items arrays do not match");

        for (uint256 i = 0; i < senderTokenAddresses.length; i++) {
            senderItems.push(OfferItem({tokenAddress: senderTokenAddresses[i], tokenId: senderTokenIds[i]}));
        }

        for (uint256 i = 0; i < receiverTokenAddresses.length; i++) {
            receiverItems.push(OfferItem({tokenAddress: receiverTokenAddresses[i], tokenId: receiverTokenIds[i]}));
        }

        offer = Offer({
            sender: sender,
            receiver: receiver,
            senderItems: OfferItems({chainId: senderChainId, items: senderItems}),
            receiverItems: OfferItems({chainId: receiverChainId, items: receiverItems}),
            expiration: expiration,
            state: state
        });
    }

    function assertOfferItemsOwnership(OfferItem[] memory items, address owner) public {
        for (uint256 i = 0; i < items.length; i++) {
            Mocked721 tokenContract = Mocked721(items[i].tokenAddress);
            assertEq(tokenContract.ownerOf(items[i].tokenId), owner);
        }
    }

    function assertOfferItemsEq(OfferItems memory items1, OfferItems memory items2) public {
        assertEq(items1.items.length, items2.items.length);
        assertEq(items1.chainId, items2.chainId);
        for (uint256 i = 0; i < items1.items.length; i++) {
            assertEq(items1.items[i].tokenAddress, items2.items[i].tokenAddress);
            assertEq(items1.items[i].tokenId, items2.items[i].tokenId);
        }
    }

    function assertOfferEq(Offer memory offer1, Offer memory offer2) public {
        assertEq(offer1.sender, offer2.sender);
        assertOfferItemsEq(offer1.senderItems, offer2.senderItems);
        assertEq(offer1.receiver, offer2.receiver);
        assertOfferItemsEq(offer1.receiverItems, offer2.receiverItems);
        assertEq(uint256(offer1.state), uint256(offer2.state));
        assertEq(offer1.expiration, offer2.expiration);
    }
}
