// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.12;

import { IGameInfo } from "./IGameInfo.sol";
import { IGameHost } from "./IGameHost.sol";

interface IGame is IGameInfo, IGameHost {
}

struct CollectedGameInfo {
    bool needsCalculation;
}

contract MinUniqueGameCalculatorTrap {
    // Replace with the actual game address
    address private gameAddress = address(0xDB5A74A6805DC7570293f56467621B40c706510e);

    constructor() {}

    function collect() external view returns (bytes memory) {
        IGame game = IGame(gameAddress);
        CollectedGameInfo memory result = CollectedGameInfo({
            needsCalculation: game.needsCalculation()
        });
        return abi.encode(result);
    }

    function shouldRespond(bytes[] calldata data) external pure returns (bool, bytes memory) {
        if (data.length == 0) {
            return (false, bytes("No data"));
        }

        CollectedGameInfo memory collectedGameInfo = abi.decode(data[0], (CollectedGameInfo));
        return collectedGameInfo.needsCalculation
            ? (true, bytes("Needs calculation"))
            : (false, bytes("Calculation not required"));        
    }

    // For testing purposes, allows changing the game address
    function setGameAddress(address newGameAddress) external {
        gameAddress = newGameAddress;
    }
}
