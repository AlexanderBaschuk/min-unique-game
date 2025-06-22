// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import "forge-std/Test.sol";
import "../src/MinUniqueGame.sol";
import "../src/MinUniqueGameCalculatorTrap.sol";

contract MinUniqueGameCalculatorTrapTest is Test {
    MinUniqueGameCalculatorTrap trap;
    uint256 startBlock = block.number;

    function setUp() public {
        trap = new MinUniqueGameCalculatorTrap();
    }

    function test_calculator_shouldRespond_true() public view {
        checkShouldRespond(true, true);
    }

    function test_calculator_shouldRespond_false() public view {
        checkShouldRespond(false, false);
    }

    function checkShouldRespond(bool needsCalculation, bool expected) internal view {
        CollectedGameInfo memory result = CollectedGameInfo({
            needsCalculation: needsCalculation
        });

        bytes[] memory dataItems = new bytes[](1);
        dataItems[0] = abi.encode(result);

        (bool shouldRespond, ) = trap.shouldRespond(dataItems);
        assertEq(shouldRespond, expected);
    }
}
