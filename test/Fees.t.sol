// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import "./BaseTest.t.sol";
import "forge-std/Test.sol";

contract FeesTest is BaseTest {
    function testCannotAcceptOfferIfNotEnoughFunds() public {
        _setFees();
        Offer memory offer = _createSingleAssetOffer();
        bytes32 offerId = generateOfferId(offer);

        vm.prank(account2);
        vm.expectRevert(InvalidPayment.selector);
        echo.acceptOffer(offerId);
    }

    function testCannotExecuteOfferIfNotEnoughFunds() public {
        Offer memory offer = _createAndAcceptSingleAssetOffer();
        bytes32 offerId = generateOfferId(offer);

        _setFees();

        vm.prank(account1);
        vm.expectRevert(InvalidPayment.selector);
        echo.executeOffer(offerId);
    }

    function testCanExecuteOfferIfEnoughFunds() public {
        uint256 initialAccount1Balance = account1.balance;
        uint256 initialAccount2Balance = account2.balance;
        _setFees();
        _executeSingleAssetOffer();

        assertEq(account1.balance, initialAccount1Balance - echo.tradingFee());
        assertEq(account2.balance, initialAccount2Balance - echo.tradingFee());
        assertEq(address(echo).balance, echo.tradingFee() + echo.tradingFee());
    }
}
