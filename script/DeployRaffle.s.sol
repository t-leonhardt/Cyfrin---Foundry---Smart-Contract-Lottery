pragma solidity ^0.8.19;

import {Script} from "forge-std/Script.sol";
import {Raffle} from "../src/Raffle.sol";
import {HelperConfig} from "./HelperConfig.s.sol";


contract DeployRaffle is Script{
    function run() public {}

    function delpoyContract() public returns (Raffle, HelperConfig){
        HelperConfig helperConfig = new HelperConfig(); 
        // helperconfig contract 
        HelperConfig.NetworkConfig memory config = helperConfig.getConfig();
        // network config 
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
        return (raffle, helperConfig);
    }
}