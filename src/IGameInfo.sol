// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import { PlayerProposal } from "./Structs.sol";
import { RoundResult } from "./Structs.sol";

interface IGameInfo {
    function roundId() external view returns (uint256);
    function roundStartBlock() external view returns (uint256);
    function isActive() external view returns (bool);
    function getResults(uint256 round) external view returns (RoundResult memory);
}