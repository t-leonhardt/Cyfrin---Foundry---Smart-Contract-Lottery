// the following is the commonly used layout for solidity

// Layout of Contract:
// version
// imports
// errors
// interfaces, libraries, contracts
// Type declarations
// State variables
// Events
// Modifiers
// Functions

// Layout of Functions:
// constructor
// receive function (if exists)
// fallback function (if exists)
// external
// public
// internal
// private
// internal & private view & pure functions
// external & public view & pure functions

pragma solidity 0.8.19;

/**
 * @title A truly random raffle contract
 * @author Tim Leonhardt
 * @notice Creating a sample raffle contract
 * @dev Implements Chainlink VRFv2.5
 */

contract Raffle{
    error Raffle__NotEnoughETH();

    uint256 private immutable i_entranceFee;
    address payable[] private s_players;
    // must be payable sice the winner is going to receive "money"

    event RaffleEntered(address indexed player);

    constructor(uint256 entranceFee){
        i_entranceFee = entranceFee;
    }
    function enterRaffle() public payable{
        if(msg.value < i_entranceFee){
            revert Raffle__NotEnoughETH();
        }
        s_players.push(payable(msg.sender));

        emit RaffleEntered(msg.sender);
    }

    function pickWinner() public {

    }

    function getEntranceFee() external view returns(uint256){
        return i_entranceFee;
    }
}