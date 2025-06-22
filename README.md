# Game of Traps - MinUniqueGame

MinUniqueGame is a smart contract for playing the "Minimum Unique Number" game on Ethereum Holesky. The contract is designed for fast, competitive rounds where players race to submit their numbers and try to win by being the only one to pick the lowest unique number. To do so, the players use **Drosera traps** that will choose and submit a number for each round using the algorithm implemented in their code.

## How the Game Works

- **Rounds:**  
  Each game round lasts for only **two blocks**. During this short window, players must submit their numbers using Drosera traps by calling the `play()` method as a trap response function.

- **Winning Condition:**  
  After the round ends, the winner is the player who submitted the **smallest number that no one else picked** (the minimum unique number).

- **Game Flow:**  
  1. **Start:**  
     The round is started by a special "starter" trap, which calls the `start()` method. Only whitelisted addresses can start a round. The round is finished automatically after 2 blocks.
  2. **Play:**  
     Players (traps) submit their numbers during the active round.
  3. **Calculate:**  
     After the round ends, a "calculator" trap calls the `calculate()` method to determine the winner and finalize the round.

## Traps hosting the game

- **Starter Trap:**  
  Calls `start()` to begin a new round. Only whitelisted addresses can start rounds.

- **Calculator Trap:**  
  Calls `calculate()` to process the results and determine the winner after the round ends. Also must be whitelisted in the game.

## Player Traps

- **PlayerTrap:**  
  Each player writes their own PlayerTrap contract implementing a strategy for picking numbers. The goal is to design a trap that wins more often than others by analyzing previous rounds and predicting what numbers will be unique.

- **Strategy:**  
  Players can use any algorithm they like — random, statistical, or based on analysis of previous results. The only requirement is to submit a positive number during the round.

## Security and Fairness

- Each player can only submit one number per round.
- All results are stored on-chain and can be verified by anyone.

## How to Participate

1. **Write your own PlayerTrap contract** (`PlayerTrap.sol`) with your strategy.
2. **Deploy your PlayerTrap** to Drosera and configure the `play()` method on MinUniqueGame as a response function.
3. **Compete** to see whose trap wins the most rounds!

---

This is a voluntary project, part of the [Drosera Network](https://github.com/drosera-network) ecosystem.
