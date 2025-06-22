// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

struct PlayerProposal {
    address player;
    uint256 proposal;
}

struct RoundResult {
    bool isCalculated;
    PlayerProposal[] proposals;
    address winner;
}

struct PlayerStats {
    uint256 gamesPlayed;
    uint256 gamesWon;
}