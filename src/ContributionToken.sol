//SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract ContributionToken is ERC20 {
    modifier onlyRecruiter  {
        require(
        msg.sender == recruiter,
        "only recruiter can call this function");
        _; 

    }

    constructor()
    ERC20 ("ContributionToken", "CTT")

    function mint(address to, uint256 amount) external onlyRecruiter {
        _mint(to, amount);
    }

}