// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.12;

import { IGameInfo } from "./IGameInfo.sol";
import { IGameHost } from "./IGameHost.sol";

interface IGame is IGameInfo, IGameHost {
}

struct CollectedGameStateForStart {
    bool canStart;
    uint256 blockNumber;
    uint256 roundStartBlock;
}

contract MinUniqueGameStarterTrap {
    uint256 constant minBlocksBetweenGames = 5;
    uint256 constant avgBlocksBetweenGames = 32;

    // Replace with the actual game address
    address private gameAddress = address(0xDB5A74A6805DC7570293f56467621B40c706510e);

    constructor() {}

    function collect() external view returns (bytes memory) {
        IGame game = IGame(gameAddress);
        CollectedGameStateForStart memory result = CollectedGameStateForStart({
            canStart: game.canStart(),
            blockNumber: block.number,
            roundStartBlock: game.roundStartBlock()
        });
        return abi.encode(result);
    }

    function shouldRespond(
        bytes[] calldata data
    ) external pure returns (bool, bytes memory) {
        if (data.length == 0) {
            return (false, bytes("No data"));
        }

        CollectedGameStateForStart memory gameState = abi.decode(data[0], (CollectedGameStateForStart));

        // Check if the game can start
        if (!gameState.canStart) {
            return (false, bytes("Game cannot start"));
        }

        if (gameState.roundStartBlock == 0) {
            return (false, bytes("Start first round manually"));
        }

        // Calculating pseudo-random block number for the next game
        uint256 blocksTillNextGame =
            uint256(keccak256(abi.encodePacked(gameState.roundStartBlock))) % avgBlocksBetweenGames
            + minBlocksBetweenGames;
        uint256 nextGameBlock = gameState.roundStartBlock + blocksTillNextGame;

        return gameState.blockNumber >= nextGameBlock
            ? (true, bytes("Start!"))
            : (false, bytes("Waiting game start"));  
    }

    // For testing purposes, allows changing the game address
    function setGameAddress(address newGameAddress) external {
        gameAddress = newGameAddress;
    }
}
