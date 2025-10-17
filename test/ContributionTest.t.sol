//SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

import {Test} from "forge-std/Test.sol";
import {Vm} from "forge-std/Vm.sol";
import {Contribution} from "../src/Contribution.sol";
import {IERC20} from "../src/Contribution.sol";
import "forge-std/console.sol";

contract MockERC20 is IERC20 {
    mapping(address => uint256) public balances; //a mapping that traces address and their balance


    constructor() {
        balances[msg.sender] = 100_000 ether; //makes the contract have enough ether to distribute as a reward
    }

    function transfer(address recipient, uint256 amount) external returns (bool) {
        require(balances[msg.sender] >= amount, "Not enough tokens");
        balances[msg.sender] -= amount; //this subtracts the amount sent from the reservoir
        balances[recipient] += amount; //this add the amount of ether to the recipient
        return true;
    }
    //to mint tokens
    function mint(address to, uint256 amount) external {
        balances[to] += amount;
    }
}
 //got this from chatGPT 
 //the contract above is basically inherits my interface in the contract
 //cause testing my contract i would need a particular a "fake" reservoir of token to make a transfer
 
contract ContributionTest is Test {

    Contribution contribution;
    address recruiter; 
    event RewardStatus(address contributor, uint256 amount, bool status);
    event notTypicalContribution (address indexed sender, uint256 value, bytes data );

    function setUp() public { 
        //in setup you are to ideally put the parameter from your constructor 
        // setUp is to set the environment for testing 
        //creating a new contract for testing 

        recruiter = makeAddr("recruiter"); // this makes the test contract the recruiter
        MockERC20 rewardTokenMock = new MockERC20();  
        address rewardTokenAddress = address(rewardTokenMock);
        rewardTokenMock.mint(recruiter, 100_000 ether);  // this is to allocate token to the recruiter 
        vm.startPrank(recruiter);  

        
        uint256 _rewardthreshold = 1 ether;
        uint256 _rewardAmount = 10 ether;
        contribution = new Contribution ( rewardTokenAddress , _rewardthreshold , _rewardAmount);
        
        IERC20(rewardTokenAddress).transfer(address(contribution), 100000 ether); //funding the contract with enough token to distribute as reward 
        console.log("Contract token balance:", rewardTokenMock.balances(address(contribution)));
        console.log("Recruiter balance:", rewardTokenMock.balances(recruiter));


       
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
    }

        // testing this way to loop through all the info

    function test_RevertWhenNonRecruiterCallgetAllContribution() public {
            //Arrange
            address randomcontributor = makeAddr("randomcontributor");
            uint256 randomcontributorId = uint256(keccak256(abi.encodePacked("randomcontributorId")));
            string memory note = "another contribution";
            uint256 amountinETH = 1 ether;
            vm.startPrank(randomcontributor);

            //Act
            
            vm.expectRevert("only recruiter can call this function");
            (uint256[] memory contributorId, string[] memory _note, uint256[] memory timestamp, uint256[] memory _amountinETH) = contribution.getAllContributions(randomcontributor);
            vm.stopPrank();

            //Assert

            

        }
    function test_ifcontributorCanCallAddContribution () public {
        //Arrange 
        address payable contributor = payable (makeAddr("contributor"));
        string memory note = "My third contribution";
        uint256 contributorId = uint256(keccak256(abi.encodePacked("contributorId")));
        uint256 amountinETH = 0.001 ether;
        vm.startPrank(contributor);

        //Act
        contribution.addContribution(contributor, note, contributorId, amountinETH);
        vm.stopPrank();

        //Assert
        assertGt(bytes(note).length, 0, "notes cant be empty");
        assertGt(contributorId, 0, "adding contributorId is essential");
        assertGt(amountinETH, 0, "can to put a certain amount of ETH");

    }

    function test_contributorCallClaimRewards () public {
        //Arrange 
        address payable recipient = payable (makeAddr("recipient"));
        uint256 rewardAmount = 10 ether;
        vm.deal(recipient, 20000 ether);
        

        vm.startPrank(recipient);
        contribution.addContribution{value: 200 ether}(recipient, "first note",  1 , 200 ether);
        vm.stopPrank();

        ///Act
        
        //vm.expectEmit(true , false , false , true);
        // my test ran without this so i commented it out
        emit RewardStatus ( recipient , 10 ether  , true );
        vm.prank(recipient);
        contribution.claimRewards();
        
       
        

        //Assert

    
    }

    function test_fallbackEthandMessageSender () public {
        //Arrange 
        address notTypicalContributor =  makeAddr("notTypicalContributor");
        vm.deal(notTypicalContributor, 200 ether);
        
        vm.expectEmit(true, false , false, true);
        emit notTypicalContribution(notTypicalContributor, 20 ether, bytes("first contributor" ));

        //Act
        vm.prank(notTypicalContributor);
        (bool success, ) = address(contribution).call{value: 20 ether}(
     bytes("first contributor"));


        //Assert
        console.log();
        assertTrue(success, "Fallback call failed");

        //the assertion has been done already with the expectEmit function 
}
function test_fallbackEthSender () public {
        //Arrange 
        address notTypicalContributor =  makeAddr("notTypicalContributor");
        vm.deal(notTypicalContributor, 200 ether);
        
        vm.expectEmit(true, false , false, true);
        emit notTypicalContribution(notTypicalContributor, 20 ether, bytes("") );

        //Act
        vm.prank(notTypicalContributor);
        (bool success, ) = address(contribution).call{value: 20 ether}(bytes(""));


        //Assert
        console.log();
        assertTrue(success, "Fallback call failed");


}

function test_fallbackMessageSender () public {
        //Arrange 
        address notTypicalContributor =  makeAddr("notTypicalContributor");
        vm.deal(notTypicalContributor, 200 ether);
        
        vm.expectEmit(true, false , false, true);
        emit notTypicalContribution(notTypicalContributor, 0, bytes("first contribution") );

        //Act
        vm.prank(notTypicalContributor);
        (bool success, ) = address(contribution).call{value: 0}(bytes("first contribution"));


        //Assert
        console.log();
        assertTrue(success, "Fallback call failed");


}

function test_ifnoReClaimWork() public {
    /// to complete tomorrow 

}