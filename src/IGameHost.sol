// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import { PlayerProposal } from "./Structs.sol";
import { RoundResult } from "./Structs.sol";

interface IGameHost {
    function needsCalculation() external view returns (bool);
    function canStart() external view returns (bool);
    function start() external returns (uint256);
    function calculate() external;
}
