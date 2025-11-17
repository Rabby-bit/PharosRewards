//SPDX-License-Idenitifier: MIT
pragma solidity ^0.8.19;

import {Script, console2} from "forge-std/Script.sol";
import {Contribution} from "../src/Contribution.sol";
import {IERC20} from "@openzeppelin/token/ERC20/IERC20.sol";
import {ERC20} from "@openzeppelin/token/ERC20/ERC20.sol";


contract DeployContribution is Script {

    function run() {
        vm.startBroadcast();

        Contribution contribution = new Contribution();

        vm.stopBroadcast();

    }
    }