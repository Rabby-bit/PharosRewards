//SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

import {Test} from "forge-std/Test.sol";
import {Vm} from "forge-std/Vm.sol";
import {Contribution} from "../src/Contribution.sol";

contract ContributionTest is Test {

    Contribution contribution;
    address recruiter; 

    function setUp() public { 
        //in setup you are to ideally put the parameter from your constructor 
        // setUp is to set the environment for testing 
        //creating a new contract for testing 

        recruiter = makeAddr("recruiter"); // this makes the test contract the recruiter
        vm.startPrank(recruiter);  

        address _rewardToken = 0x7d211F77525ea39A0592794f793cC1036eEaccD5;
        uint256 _rewardthreshold = 100;
        uint256 _rewardAmount = 0.01 ether;
        contribution = new Contribution ( _rewardToken , _rewardthreshold , _rewardAmount);
       
        vm.stopPrank();
    }

    function test_onlyRecruiterCanCallgetContributions() public {
        //Arrange
        //This is a mini setup for this test
       
        address payable randomcontributor = payable (makeAddr("randomcontributor"));  // this makes a fake randomcontributoraddress
        uint256 randomcontributorId = uint256(keccak256(abi.encodePacked("randomcontributorId"))); // this makes a fake contributorId
        string memory note = "first contribution";
        uint256 amountinETH = 1 ether;
   
        vm.startPrank(recruiter);  //this simulates a recruiter calling the function

        //Act
        //This is the action that i would like to be done
        
        (string memory _note, uint256 _amountinETH, uint256 _timestamp) = contribution.getContributions( randomcontributor ,  randomcontributorId );
        vm.stopPrank(); // this stops the simulation 

        //Assert
        //This is to show, what i expect when this function is ran
        assertGt ( bytes(note).length,  0  , "Note cant be empty" );
        //assertGT = assert greater than which show the first parameter is greater than the second parameter if not revert with the message in the third parameter
    }

    function test_RevertWhenNonRecruiterCallgetContribution() public {
        //Arrange
        address notRecruiter = makeAddr("notRecruiter"); //making an address that is not the recruiter 
        address payable randomcontributor = payable (makeAddr("randomcontributor"));  // this makes a fake randomcontributoraddress
        uint256 randomcontributorId = uint256(keccak256(abi.encodePacked("randomcontributorId"))); // this makes a fake contributorId
        string memory note = "first contribution";
        uint256 amountinETH = 1 ether;
        vm.startPrank(notRecruiter); //This simulates the non recruiter calling this function 
        vm.expectRevert( "only recruiter can call this function");
    
        //Act
        (string memory _note, uint256 _amountinETH, uint256 _timestamp) = contribution.getContributions( randomcontributor ,  randomcontributorId );
        vm.stopPrank(); // this stops the simulation 

        //Assert
       
    }

    function test_onlyRecruiterCanCallgetAllContributions() public {
        //Arrange
        uint256 randomcontributorId = uint256(keccak256(abi.encodePacked("randomcontributorId")));
        string memory note = "another contribution";
        uint256 amountinETH = 1 ether;
        vm.startPrank(recruiter);
        
        //Act
        (uint256[] memory contributorId, string[] memory _note, uint256[] memory timestamp, uint256[] memory _amountinETH) = contribution.getAllContributions(recruiter);
        vm.stopPrank();

        
        //Assert 
        for (uint256 i = 0 ; i < _note.length ; i++ )
        {
            assertGt (bytes(_note[i]).length,  0  , "Note cant be empty" );}
     for (uint256 i = 0 ; i < timestamp.length ; i++ )  
        {assertGt(timestamp[i], 0, "Timestamp should be greater than 0");}
       for (uint256 i = 0 ; i < _amountinETH.length ; i++)
       
        {assertEq( _amountinETH[i], 0 , "cant send no ether");}

        // testing this way to loop through all the info

    }


}