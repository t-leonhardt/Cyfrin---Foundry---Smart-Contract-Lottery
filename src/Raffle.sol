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
 * @dev Implements Chainlink VRFv2.5 https://docs.chain.link/vrf/v2-5/getting-started
 */

import {VRFConsumerBaseV2Plus} from "@chainlink/contracts/src/v0.8/vrf/dev/VRFConsumerBaseV2Plus.sol";
import {VRFV2PlusClient} from "@chainlink/contracts/src/v0.8/vrf/dev/libraries/VRFV2PlusClient.sol";
import {console} from "forge-std/Test.sol";


contract Raffle is VRFConsumerBaseV2Plus{
    error Raffle__NotEnoughETH();
    error Raffle__Failed();
    error Raffle__RaffleNotOpen();

    enum RaffleState{
        OPEN,               // 0
        CALCULATING         // 1
    }
    // enum is a method that permits the declaration of types
    // whatever is in the brackets describes the possible values 

    uint256 private immutable i_entranceFee;
    uint256 private immutable i_interval; 
    // @dev the interval descripes the duration of the lottery in secoonds
    address payable[] private s_players;
    // must be payable sice the winner is going to receive "money"
    uint256 private s_lastTimeStamp;
    bytes32 private immutable i_keyHash; // same as gasLane; which is 
    // maximum gasprice willing to pay for the transaction
    uint256 private immutable i_subscriptionId;
    uint16 private constant REQUEST_CONFIRMATION = 3;
    // RequestConfrimation is the number of blocks the chain is supposed to wait until responding,
    // the longer, the more secure 
    uint32 private immutable i_callbackGasLimit; 
    // describes the maximum of gas willing to spend 
    uint32 private constant NUM_WORDS = 1; 
    // describes the number of random numbers requested 
    address private s_recentWinner;
    RaffleState private s_raffleState; 


    event RaffleEntered(address indexed player);
    event WinnerPicked(address indexed winner);

    constructor(
        uint256 entranceFee, 
        uint256 interval, 
        address _vrfCoordinator, 
        bytes32 gasLane,
        uint256 subScriptionId, 
        uint32 callbackGasLimit
        ) 
        VRFConsumerBaseV2Plus (_vrfCoordinator){
        // when a child calss has a constrcutor and the parent class
        // also has a constructor, the child class must include 
        // the parents constructor in their constructor 
        // here: the _vrfCoordinator is passed from the Raffle constructor
        // to the VRF... constructor 
        i_entranceFee = entranceFee;
        i_interval = interval;
        s_lastTimeStamp = block.timestamp;
        // block.timestamp is the current time  
        i_keyHash = gasLane;
        i_subscriptionId = subScriptionId;
        i_callbackGasLimit = callbackGasLimit;

        s_raffleState = RaffleState.OPEN;
    }

    function enterRaffle() public payable{
        if(msg.value < i_entranceFee){
            revert Raffle__NotEnoughETH();
        }

        if(s_raffleState != RaffleState.OPEN){
            revert Raffle__RaffleNotOpen();
        }

        s_players.push(payable(msg.sender));

        emit RaffleEntered(msg.sender);
    }

    function pickWinner() external {
        if ((block.timestamp - s_lastTimeStamp) < i_interval){
            revert();
        }

        s_raffleState = RaffleState.CALCULATING;

        VRFV2PlusClient.RandomWordsRequest memory request =
            VRFV2PlusClient.RandomWordsRequest({
                keyHash: i_keyHash,
                subId: i_subscriptionId,
                requestConfirmations: REQUEST_CONFIRMATION,
                callbackGasLimit: i_callbackGasLimit,
                numWords: NUM_WORDS,
                // Set nativePayment to true to pay for VRF requests with Sepolia ETH instead of LINK
                extraArgs: VRFV2PlusClient._argsToBytes(VRFV2PlusClient.ExtraArgsV1({nativePayment: false}))
            }
        );

        uint256 requestId = s_vrfCoordinator.requestRandomWords(request);
    }

    function fulfillRandomWords(uint256 requestId, uint256[] calldata randomWords) internal override{
        uint256 indexOfWinner = randomWords[0] % s_players.length;
        address payable recentWinner = s_players[indexOfWinner];
        s_recentWinner = recentWinner;

        s_raffleState = RaffleState.OPEN;
        s_players = new address payable[](0);
        s_lastTimeStamp = block.timestamp;

        (bool success,) = recentWinner.call{value: address(this).balance}("");
        if (!success){
            revert Raffle__Failed();
        }

        emit WinnerPicked(s_recentWinner);
    }

    function getEntranceFee() external view returns(uint256){
        return i_entranceFee;
    }
}