//SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

import {Script} from "forge-std/Script.sol";
import {Raffle} from "../src/Raffle.sol";
import {HelperConfig} from "./HelperConfig.s.sol";
import {CreateSubscritption, FundSubscription, AddConsumer} from "./Interactions.s.sol";


contract DeployRaffle is Script{
    function run() public {
        delpoyContract();
    }

    function delpoyContract() public returns (Raffle, HelperConfig){
        HelperConfig helperConfig = new HelperConfig(); 
        // helperconfig contract 
        HelperConfig.NetworkConfig memory config = helperConfig.getConfig();
        // network config 

        if(config.subscriptionID == 0){
            CreateSubscritption createSubscription = new CreateSubscritption();
            (config.subscriptionID, config.vrfCoordinator) = createSubscription.createSubscritption(config.vrfCoordinator);

            FundSubscription fundSubscription = new FundSubscription();
            fundSubscription.fundSubscription(config.vrfCoordinator, config.subscriptionID, config.link);
            
        }

        vm.startBroadcast();
        Raffle raffle = new Raffle(
            config.entranceFee, 
            config.interval, 
            config.vrfCoordinator, 
            config.gasLane,
            config.subscriptionID, 
            config.callbackGasLimit
        );
        vm.stopBroadcast();

        AddConsumer addConsumer = new AddConsumer();
        addConsumer.addConsumer(address(raffle), config.vrfCoordinator, config.subscriptionID);

        return (raffle, helperConfig);
    }
}