// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.12;

// Game interfaces and structs
interface IGameInfo {
    function isActive() external view returns (bool);
    function roundId() external view returns (uint256);
    function getResults(uint256 round) external view returns (RoundResult memory);
}
struct RoundResult {
    bool isCalculated;
    PlayerProposal[] proposals;
    address winner;
}
struct PlayerProposal {
    address player;
    uint256 proposal;
}

// Trap structs
struct CollectedGameResult {
    PlayerProposal[] playerProposals;
}
struct CollectedGameState {
    uint256 roundId;
    bool isActive;
    CollectedGameResult[] lastResults;
}

contract PlayerTrap {
    // Replace with the actual game address
    address private gameAddress = address(0xDB5A74A6805DC7570293f56467621B40c706510e);

    constructor() {}

    function collect() external view returns (bytes memory) {
        IGameInfo game = IGameInfo(gameAddress);
        bool isActive = game.isActive();

        // Change this value if necessary.
        uint256 lastResultsCount = 3;
        CollectedGameState memory gameState = CollectedGameState({
            roundId: game.roundId(),
            isActive: isActive,
            lastResults: isActive
                ? getPreviousResults(game, lastResultsCount)
                : new CollectedGameResult[](0)
        });

        return abi.encode(gameState);
    }

    function shouldRespond(bytes[] calldata data) external pure returns (bool, bytes memory) {
        if (data.length == 0) {
            return (false, abi.encode(0));
        }

        CollectedGameState memory gameState = abi.decode(data[0], (CollectedGameState));

        if (!gameState.isActive ) {
            return (false, abi.encode(0));
        }

        ////////////////////////////////////
        // IMPLEMENT YOUR TRAP LOGIC HERE //
        ////////////////////////////////////
        
        // Option 1. Always return constant value.
        // Very simple. But will rarely win.
        uint256 proposal = 1;
        return (true, abi.encode(proposal));

        // Option 2. Return a random value based on the last results. Will win sometimes.
        // IMPORTANT: Change the seed to a unique number, otherwise, your proposals will conflict with someone else's.
        // uint256 seed = 123456789; // Change this to the value no one else is using!!!
        // uint256 lastPlayersCount = gameState.lastResults.length > 0 ? gameState.lastResults[0].playerProposals.length : 0;
        // uint256 maxProposal = lastPlayersCount >= 2 ? lastPlayersCount : 2;
        // uint256 proposal = uint256(keccak256(abi.encodePacked(seed, gameState.roundId))) % (maxProposal - 1) + 1;
        // return (true, abi.encode(proposal));

        // Option 3. Write your own logic that will analyze last N results and choose a value that will win with the largest probability.
        // ... 

        // Or just never respond true and don't play the game :-)       
        // return (false, abi.encode(0));
    }

    // Returns the last N results of the game
    // If not enough rounds have been played, returns all available results
    function getPreviousResults(IGameInfo game, uint256 maxResultsCount) private view returns (CollectedGameResult[] memory) {
        uint256 currentRoundId = game.roundId();
        uint256 lastRoundId = currentRoundId - 1;

        uint256 resultsCount = lastRoundId < maxResultsCount
            ? lastRoundId
            : maxResultsCount;

        CollectedGameResult[] memory lastResults = new CollectedGameResult[](resultsCount);

        for (uint256 i = 0; i < resultsCount; i++) {
            uint256 round = lastRoundId - i;
            RoundResult memory result = game.getResults(round);
            lastResults[i] = CollectedGameResult({
                playerProposals: result.proposals
            });
        }

        return lastResults;
    }

    // For testing purposes, allows changing the game address
    function setGameAddress(address newGameAddress) external {
        gameAddress = newGameAddress;
    }
}
