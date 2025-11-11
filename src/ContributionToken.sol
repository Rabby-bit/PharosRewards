//SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {ERC20} from "@openzeppelin/token/ERC20/ERC20.sol";

contract ContributionToken is ERC20 {
    address public immutable recruiter;
    modifier onlyRecruiter  {
        require(
        msg.sender == recruiter,
        "only recruiter can call this function");
        _; 

    }

    constructor()
    ERC20 ("ContributionToken", "CTT") 
    {
        recruiter = msg.sender;
    }

    function mint(address to, uint256 amount) external onlyRecruiter {
        _mint(to, amount);
    }

}