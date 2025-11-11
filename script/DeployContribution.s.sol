//SPDX-License-Idenitifier: MIT
pragma solidity ^0.8.19;

import {Script, console2} from "forge-std/Script.sol";
import {Contribution} from "../src/Contribution.sol";
import {IERC20} from "@openzeppelin/token/ERC20/IERC20.sol";
import {ERC20} from "@openzeppelin/token/ERC20/ERC20.sol";


abstract contract CodeConstant {
    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    //CHAINIDS
    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

    uint256 public constant PHAROSATLANTIC_CHAIN_ID = 688689;
    uint256 public constant PHAROSTESTNET_CHAIN_ID = 688688;


    }

    contract DeployContribution is CodeConstant, Script {

        Contribution public contribution;
        address public rewardTokenAddress;
        IERC20 public rewardToken;
        uint256 public rewardAmount;
        uint256 public rewardthreshold;

        event DeployedOnThePharosAltanticTestnet ( bool success);
        event DeployedOnThePharosTestnet (bool success);


    function deployContriution() public returns (Contribution) {

      
    
        rewardTokenAddress = 0x087804f808C55c0Ee8D5287558896fFdF73A2D16;
        //zentrafi app reward token on pharos testnet
        rewardthreshold = 1 ether; 
        rewardAmount = 10 ether; 

      

        if (block.chainid == 688689) {
             emit DeployedOnThePharosAltanticTestnet ( true);

            } else if (block.chainid == 688688) { 
                emit DeployedOnThePharosTestnet (true);
            
        }


        vm.startBroadcast();
        contribution = new Contribution ( rewardTokenAddress , rewardthreshold , rewardAmount);
        vm.stopBroadcast();

    }
    function run() external returns (Contribution) {
        return deployContriution();
    }
    }