// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import "forge-std/Test.sol";
import "../src/MinUniqueGame.sol";
import "../src/MinUniqueGameStarterTrap.sol";

contract MinUniqueGameStarterTrapTest is Test {
    MinUniqueGameStarterTrap trap;
    uint256 startBlock = block.number;

    function setUp() public {
        trap = new MinUniqueGameStarterTrap();
    }

    function test_tooEarlyForStart() public view {
        CollectedGameStateForStart memory result = CollectedGameStateForStart({
            canStart: true,
            blockNumber: 105,
            roundStartBlock: 100
        });

        bytes[] memory dataItems = new bytes[](1);
        dataItems[0] = abi.encode(result);

        (bool shouldRespond,) = trap.shouldRespond(dataItems);
        assertFalse(shouldRespond);
    }

    function test_enoughBlocksForStart() public view {
        CollectedGameStateForStart memory result = CollectedGameStateForStart({
            canStart: true,
            blockNumber: 1000,
            roundStartBlock: 100
        });

        bytes[] memory dataItems = new bytes[](1);
        dataItems[0] = abi.encode(result);

        (bool shouldRespond,) = trap.shouldRespond(dataItems);
        assertTrue(shouldRespond);
    }

    function test_notAllowedToStart() public view {
        CollectedGameStateForStart memory result = CollectedGameStateForStart({
            canStart: false,
            blockNumber: 1000,
            roundStartBlock: 100
        });

        bytes[] memory dataItems = new bytes[](1);
        dataItems[0] = abi.encode(result);

        (bool shouldRespond,) = trap.shouldRespond(dataItems);
        assertFalse(shouldRespond);
    }
}