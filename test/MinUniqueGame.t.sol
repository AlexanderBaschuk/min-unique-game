// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import "forge-std/Test.sol";
import "../src/MinUniqueGame.sol";
import { PlayerProposal } from "../src/Structs.sol";
import { RoundResult } from "../src/Structs.sol";
import { PlayerStats } from "../src/Structs.sol";

contract MinUniqueGameTest is Test {
    MinUniqueGame game;

    address player1 = address(0x1);
    address player2 = address(0x2);
    address player3 = address(0x3);
    address player4 = address(0x4);

    function setUp() public {
        game = new MinUniqueGame();
    }

    function testIsActive() public {
        assertFalse(game.isActive(), "Wrong active state before starting");

        game.start();
        assertTrue(game.isActive(), "Wrong active state after starting");
        
        vm.roll(block.number + 1);
        assertTrue(game.isActive(), "Wrong active state 1 block after starting");

        vm.roll(block.number + 1);
        assertTrue(game.isActive(), "Wrong active state 2 blocks after starting");

        vm.roll(block.number + 1);
        assertFalse(game.isActive(), "Wrong active state after finish");
    }

    function testBasicGameFlow() public {
        uint256 round = game.start();
        assertEq(round, 1);
        assertTrue(game.isActive());

        vm.prank(player1);
        game.play(2);

        vm.prank(player2);
        game.play(2);

        vm.prank(player3);
        game.play(3);

        vm.prank(player4);
        game.play(4);

        // Finish the round
        vm.roll(block.number + 3);
        assertFalse(game.isActive());

        game.calculate();

        RoundResult memory result = game.getResults(1);
        assertEq(result.proposals.length, 4);
        assertEq(result.winner, player3, "Incorrect winner");
    }

    function testGameNoWinner() public {
        uint256 round = game.start();
        assertEq(round, 1);
        assertTrue(game.isActive());

        vm.prank(player1);
        game.play(2);

        vm.prank(player2);
        game.play(2);

        vm.prank(player3);
        game.play(4);

        vm.prank(player4);
        game.play(4);

        // Finish the round
        vm.roll(block.number + 3);
        assertFalse(game.isActive());

        game.calculate();

        RoundResult memory result = game.getResults(1);
        assertEq(result.proposals.length, 4);
        assertEq(result.winner, address(0x0), "Expected no winner");
    }
}