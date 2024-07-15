// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import "forge-std/Test.sol";
import "solady/src/tokens/ERC20.sol";
import "../mock/Mocked721.sol";
import "../../src/types/Offer.sol";
import "../../src/types/OfferItem.sol";
import "../../src/types/OfferItems.sol";

abstract contract OfferUtils is Test {
    // Exclude from coverage report
    function test() public virtual {}

    OfferItem[] private items;
    uint256 public in6hours;

    function generateOfferId(Offer memory offer) public pure returns (bytes32 offerId) {
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

    // TODO Should receive an array of types
    function generateOfferItems(
        address[] memory tokenAddresses,
        uint256[] memory tokenIds,
        uint256[] memory tokenAmounts,
        uint256 chainId
    ) public returns (OfferItems memory offerItems) {
        require(tokenAddresses.length == tokenIds.length, "Items arrays do not match");
        require(tokenAddresses.length == tokenAmounts.length, "Items arrays do not match");
        delete items;
        for (uint256 i = 0; i < tokenAddresses.length; i++) {
            if (tokenAmounts[i] > 0) {
                items.push(
                    OfferItem({
                        tokenAddress: tokenAddresses[i],
                        tokenIdOrAmount: tokenAmounts[i],
                        tokenType: TokenType.ERC20
                    })
                );
            } else {
                items.push(
                    OfferItem({
                        tokenAddress: tokenAddresses[i],
                        tokenIdOrAmount: tokenIds[i],
                        tokenType: TokenType.ERC721
                    })
                );
            }
        }
        offerItems = OfferItems({chainId: chainId, items: items});
    }

    function generateOffer(
        address sender,
        OfferItems memory senderItems,
        address receiver,
        OfferItems memory receiverItems,
        uint256 expiration,
        OfferState state
    ) public pure returns (Offer memory offer) {
        offer = Offer({
            sender: sender,
            receiver: receiver,
            senderItems: senderItems,
            receiverItems: receiverItems,
            expiration: expiration,
            state: state
        });
    }

    function assertOfferItemsOwnership(OfferItem[] memory _items, address owner) public {
        for (uint256 i = 0; i < _items.length; i++) {
            OfferItem memory item = _items[i];
            if (item.tokenType == TokenType.ERC20) {
                ERC20 tokenContract = ERC20(item.tokenAddress);
                assertEq(tokenContract.balanceOf(owner), item.tokenIdOrAmount);
            } else {
                Mocked721 tokenContract = Mocked721(item.tokenAddress);
                assertEq(tokenContract.ownerOf(item.tokenIdOrAmount), owner);
            }
        }
    }

    function assertOfferItemsEq(OfferItems memory items1, OfferItems memory items2) public {
        assertEq(items1.items.length, items2.items.length);
        assertEq(items1.chainId, items2.chainId);
        for (uint256 i = 0; i < items1.items.length; i++) {
            assertEq(items1.items[i].tokenAddress, items2.items[i].tokenAddress);
            assertEq(items1.items[i].tokenIdOrAmount, items2.items[i].tokenIdOrAmount);
            if (items1.items[i].tokenType != items2.items[i].tokenType) {
                assertTrue(false);
            }
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
