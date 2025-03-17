//SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

import {Script, console} from "forge-std/Script.sol";
import {HelperConfig, CodeConstants} from "./HelperConfig.s.sol";
import {VRFCoordinatorV2Mock} from "../lib/chainlink-brownie-contracts/contracts/src/v0.8/mocks/VRFCoordinatorV2Mock.sol";
import {LinkToken} from "../test/mocks/LinkToekn.sol";
import {DevOpsTools} from "lib/foundry-devops/src/DevOpsTools.sol";

contract CreateSubscritption is Script{
    function createSubscriptionUsingConfig() public returns(uint256, address) {
        HelperConfig helperConfig = new HelperConfig();
        address vrfCoordinator = helperConfig.getConfig().vrfCoordinator;
        address account = helperConfig.getConfig().account;
        (uint256 subID, ) = createSubscritption(vrfCoordinator, account);
        return (subID, vrfCoordinator);
    }

    function createSubscritption(address vrfCoordinator, address account) public returns(uint256, address) {
        console.log("Creating subscription on chain: ", block.chainid);
        vm.startBroadcast();
        uint256 subID = VRFCoordinatorV2Mock(vrfCoordinator).createSubscription();
        vm.stopBroadcast();

        console.log("Your subscription ID is: ", subID);

        return (subID, vrfCoordinator);
    }

    function run() public {
        createSubscriptionUsingConfig();
    }
}

contract FundSubscription is Script, CodeConstants{
    uint256 public constant FUND_AMOUNT = 3 ether;

    function fundSubscriptionConfig() public {
        HelperConfig helperConfig = new HelperConfig();
        address vrfCoordinator = helperConfig.getConfig().vrfCoordinator;
        uint256 subscriptionID = helperConfig.getConfig().subscriptionID;
        address linkToken = helperConfig.getConfig().link;
        address account = helperConfig.getConfig().account; 
        fundSubscription(vrfCoordinator, subscriptionID, linkToken, account);
    }

    function fundSubscription(address vrfCoordinator, uint256 subscriptionID, address linkToken, address account) public{
        console.log("Funding subscription: ", subscriptionID);
        console.log("Using vrfCoordinator: ", vrfCoordinator);
        console.log("On chainID: ", block.chainid);

        if(block.chainid == LOCAL_CHAIN_ID){
            vm.startBroadcast();
            VRFCoordinatorV2Mock(vrfCoordinator).fundSubscription(uint64(subscriptionID), uint96(FUND_AMOUNT * 100));
            vm.stopBroadcast();
        }else{
            vm.startBroadcast(account);
            LinkToken(linkToken).transferAndCall(vrfCoordinator, FUND_AMOUNT, abi.encode(subscriptionID));
            vm.stopBroadcast();
        }
    }

    function run() public{
        fundSubscriptionConfig();
    }
}

contract AddConsumer is Script{
    function addConsumerUsingConfig(address mostRecentlyDeployeed) public{
        HelperConfig helperConfig = new HelperConfig();
        uint256 subId = helperConfig.getConfig().subscriptionID;
        address vrfCoordinator = helperConfig.getConfig().vrfCoordinator;
        address account = helperConfig.getConfig().account;
        addConsumer(mostRecentlyDeployeed, vrfCoordinator, subId, account);
    }
    
    function addConsumer(address contractToAddToVRF, address vrfCoordinator, uint256 subID, address account) public{
        console.log("Adding consumer contract: ", contractToAddToVRF);
        console.log("To vrfCoordinator: ", vrfCoordinator);
        console.log("On chainid: ", block.chainid);
        vm.startBroadcast(account);
        VRFCoordinatorV2Mock(vrfCoordinator).addConsumer(uint64(subID), contractToAddToVRF);
        vm.stopBroadcast();
    }

    function run() external{
        address mostRecentlyDeployed = DevOpsTools.get_most_recent_deployment("Raffle", block.chainid);
        addConsumerUsingConfig(mostRecentlyDeployed);
    }
}