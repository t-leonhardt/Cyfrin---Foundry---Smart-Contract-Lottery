//SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

import {Script, console} from "forge-std/Script.sol";
import {HelperConfig} from "./HelperConfig.s.sol";
import {VRFCoordinatorV2Mock} from "../lib/chainlink-brownie-contracts/contracts/src/v0.8/mocks/VRFCoordinatorV2Mock.sol";

contract CreateSubscritption is Script{
    function createSubscriptionUsingConfig() public returns(uint256, address) {
        HelperConfig helperConfig = new HelperConfig();
        address vrfCoordinator = helperConfig.getConfig().vrfCoordinator;
        (uint256 subID, ) = createSubscritption(vrfCoordinator);
        return (subID, vrfCoordinator);
    }

    function createSubscritption(address vrfCoordinator) public returns(uint256, address) {
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