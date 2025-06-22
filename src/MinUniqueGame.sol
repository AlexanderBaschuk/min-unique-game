// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import { PlayerProposal } from "./Structs.sol";
import { RoundResult } from "./Structs.sol";
import { PlayerStats } from "./Structs.sol";
import { IGameHost } from "./IGameHost.sol";
import { IGameInfo } from "./IGameInfo.sol";

interface ITrapConfig {
    function owner() external view returns (address);
}

interface IDrosera {
    function getRewardAddress(address _trap) external view returns (address);
}

contract MinUniqueGame is IGameHost, IGameInfo {
    // address public drosera;
    uint256 public roundId;
    uint256 public roundStartBlock;
    bool private needsCalculationFlag;
    address[] public players;

    mapping(address => bool) public admins;

    mapping(uint256 => RoundResult) private results;
    mapping(address => uint256) private proposals;
    mapping(address => PlayerStats) private playerStats;

    mapping(uint256 => uint256) public calculation;

    // constructor(address _drosera) {
    constructor() {
        // drosera = _drosera;
        admins[msg.sender] = true;
    }

    function isActive() public view returns (bool) {
        if (roundStartBlock == 0) {
            return false;
        }
        return block.number <= roundStartBlock + 2;
    }

    function needsCalculation() public view returns (bool) {
        return !isActive() && needsCalculationFlag;
    }

    function canStart() public view returns (bool) {
        return !isActive() && !needsCalculationFlag;
    }

    function getResults(uint256 round) external view returns (RoundResult memory) {
        return results[round];
    }

    modifier onlyAdmin() {
        require(admins[msg.sender], "Not an admin");
        _;
    }

    function addAdmin(address admin) external onlyAdmin {
        require(admin != address(0), "Invalid address");
        admins[admin] = true;
    }

    function removeAdmin(address admin) external onlyAdmin {
        require(admins[admin], "Not an admin");
        require(admin != msg.sender, "Cannot remove self");
        admins[admin] = false;
    }

    function start() external onlyAdmin returns (uint256) {
        require(!isActive(), "Game is already active");
        require(players.length == 0, "Previous results not calculated");
        roundId++;
        roundStartBlock = block.number;
        needsCalculationFlag = true;
        return roundId;
    }

    function play(uint256 number) external {
        require(number > 0, "Number must be greater than zero");
        require(isActive(), "Game is not active");
        require(proposals[msg.sender] == 0, "Already playing");

        players.push(msg.sender);
        proposals[msg.sender] = number;

        // TODO
        // reverts if the address is not a valid trap
        // IDrosera(drosera).getRewardAddress(msg.sender);
        // address user = ITrapConfig(msg.sender).owner();
        // players.push(user);
        // proposals[user] = number;
    }

    function calculate() external onlyAdmin {
        require(!isActive(), "Game is still active");

        // Calculating the proposals count by each number
        for (uint256 i = 0; i < players.length; i++) {
            address player = players[i];
            uint256 proposal = proposals[player];
            calculation[proposal]++;
        }

        // Finding the minimum unique proposal
        uint256 minUniqueProposal = 0;
        address winner;
        for (uint256 i = 0; i < players.length; i++) {
            address player = players[i];
            uint256 proposal = proposals[player];

            if (calculation[proposal] == 1 &&
              (minUniqueProposal == 0 || proposal < minUniqueProposal)) {
                minUniqueProposal = proposal;
                winner = player;
            }
        }

        // Filling the results, updating player stats, and resetting state
        RoundResult storage result = results[roundId];
        result.isCalculated = true;
        result.winner = winner;
        for (uint256 i = 0; i < players.length; i++) {
            address player = players[i];
            uint256 proposal = proposals[player];
            result.proposals.push(PlayerProposal({
                player: player,
                proposal: proposal
            }));
            playerStats[player].gamesPlayed++;

            proposals[player] = 0;
            calculation[proposal] = 0;
        }

        if (winner != address(0)) {
            playerStats[winner].gamesWon++;
        }

        delete players;

        needsCalculationFlag = false;
    }
}
