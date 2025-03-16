pragma solidity ^0.8.19;

import {Script} from "forge-std/Script.sol";

abstract contract CodeConstants{
    uint256 public constant ETH_SEPOLIA_CHAIN_ID = 11155111;
    uint256 public constant LOCAL_CHAIN_ID = 31337;
}

contract HelperConfig is CodeConstants, Script{
    error HelperConfig__InvalidChainID();
    
    struct NetworkConfig{
        uint256 entranceFee;
        uint256 interval;
        address vrfCoordinator;
        bytes32 gasLane;
        uint32 callbackGasLimit;
        uint256 subscriptionID;
    }

    NetworkConfig public localNetworkConfig;
    mapping(uint256 chainID => NetworkConfig) public networkConfigs;

    constructor(){
        networkConfigs[ETH_SEPOLIA_CHAIN_ID] = getSepoliaEthConfig();
    }

    function getConfigByChainID(uint256 chainID) public returns(NetworkConfig memory){
        if (networkConfigs[chainID].vrfCoordinator != address(0)){
            return networkConfigs[chainID];
        }else if (chainID == LOCAL_CHAIN_ID){
            return getOrCreateAnvilConfig();
        }else{
            revert HelperConfig__InvalidChainID();
        }
    }

    function getSepoliaEthConfig() public pure returns(NetworkConfig memory){
        return NetworkConfig({
            entranceFee: 0.01 ether,
            interval: 30,
            vrfCoordinator: 0x9DdfaCa8183c41ad55329BdeeD9F6A8d53168B1B,
            gasLane: 0x787d74caea10b2b357790d5b5247c2f63d1d91572a9846f780606e4d953677ae,
            callbackGasLimit: 50000,
            subscriptionID: 0
        });
    }

    function getOrCreateAnvilConfig() public returns(NetworkConfig memory){
        if(localNetworkConfig.vrfCoordinator != address(0)){
            return localNetworkConfig;
        }
    }
}