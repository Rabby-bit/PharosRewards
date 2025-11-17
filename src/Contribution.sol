//License & pragma
//Imports
//Interfaces
//Libraries
//Contract declaration
//Structs & enums
//State variables
//Events
//Modifiers
//Constructor
//External/public functions
//Internal functions
//Private functions





//SPDX-License-Idenitifier: MIT
pragma solidity ^0.8.19;

import {Log, ILogAutomation} from "@chainlink/contracts/src/v0.8/automation/interfaces/ILogAutomation.sol";
import {IERC20} from "@openzeppelin/token/ERC20/IERC20.sol";
import "forge-std/console.sol";


 contract Contribution is ILogAutomation {



  
  struct Contributor{

    uint256 contributorId;
    address payable contributor;
    string note;
    uint256 timestamp;
    uint256 amountinETH;
    
 }
  enum ActionType {
     ContributionAdded, //1
     notTypicalContribution,//2
     RewardStatus//3
     }

    address immutable recruiter;
    uint256 contributorid; 
    bool private locked;
    IERC20 public rewardToken;
    uint256 public rewardAmount;
    uint256 public rewardthreshold; 
  bytes32 public immutable ContributionAdded_SIG;
  bytes32 public immutable notTypicalContribution_SIG;
  bytes32 public immutable RewardStatus_SIG;


  mapping(address => mapping(uint256 => Contributor)) public contributors;
  mapping(address => uint[] ) public contributorids;
  mapping(address => uint256) public totalcontributions;
  mapping(address => bool) public hasClaimedRewards;
  mapping(address => uint256) contributorCount;
  Contributor[] public allContributions;


  event ContributionAdded(address payable indexed contributor, string);
  event notTypicalContribution (address indexed sender, uint256 value, bytes data );
  event RewardStatus(address indexed recipient, uint256 _rewardamount, bool indexed success);
  
    modifier onlyRecruiter {
    require(
      msg.sender == recruiter ,
      "only recruiter can call this function"
    );
    _;
  }
  modifier noReClaim {
    require (
    !locked , "cant claim twice");
    locked = true;
    _;
    locked = false;
  }
  constructor(address _rewardToken, uint256 _rewardthreshold, uint256 _rewardAmount) {
           require(_rewardToken != address(0), "rewardToken can't be zero");


        recruiter = msg.sender;
        rewardToken = IERC20(_rewardToken);
        rewardthreshold = _rewardthreshold; // 1 ether  
        rewardAmount = _rewardAmount;
        ContributionAdded_SIG = keccak256("ContributionAdded(address,string)");
        notTypicalContribution_SIG = keccak256 ("notTypicalContribution(address, uint256, bytes)");
        RewardStatus_SIG = keccak256 ("RewardStatus(address,uint256, bool)");

        console.log("Reward token address in contract:", address(rewardToken));
    console.log("Contract token balance:", rewardToken.balanceOf(address(this)));
 }
      
  /// no need for the previous function 

  fallback() external payable {
    if (msg.value > 0 && msg.data.length > 0) {
      emit notTypicalContribution(msg.sender, msg.value, msg.data);
  }  else if (msg.value > 0) { 
    emit notTypicalContribution(msg.sender, msg.value , "");
    }

  
   else if (msg.data.length > 0){
      emit notTypicalContribution(msg.sender, 0, msg.data);
    }
  }

  function checkLog(  
        Log calldata log,  
        bytes memory  
    ) external pure returns (bool upkeepNeeded, bytes memory performData) {  
      bytes32 ContributionAdded_SIG = keccak256("ContributionAdded(address,string)");
      bytes32 notTypicalContribution_SIG = keccak256 ("notTypicalContribution(address, uint256, bytes)");
      bytes32 RewardStatus_SIG = keccak256 ("RewardStatus(address,uint256, bool)");

        if (log.topics[0] ==  ContributionAdded_SIG)
        {address payable Contributor = payable (address((uint160(uint256(log.topics[1]))))); 
        string memory data = string(log.data);
        performData = abi.encode( ActionType.ContributionAdded ,Contributor , data );
        
        upkeepNeeded = true; }
          else if (log.topics[0] == notTypicalContribution_SIG)
        { address sender = address((uint160(uint256(log.topics[1]))));
          (uint256 value, bytes memory data) = abi.decode(log.data, (uint256, bytes));
        performData = abi.encode(ActionType.notTypicalContribution ,sender, value, data);
        upkeepNeeded = true; 
               }  
          else if (log.topics[0] == RewardStatus_SIG) 
          {
            address recipient = address((uint160(uint256(log.topics[1]))));
            bool success = (uint256(log.topics[2]) != 0);
            (uint256 rewardAmount) = abi.decode(log.data, (uint256));
            performData = abi.encode(ActionType.RewardStatus , recipient, success, rewardAmount);
            upkeepNeeded = true;
              }
          else {
            upkeepNeeded = false;
          }

    }

    function performUpkeep(bytes calldata performData) external override {  
      // performData = abi.encode(Contributor , data );
      //(address Contributor, string memory data) = abi.decode(performData , (address,string));
      //(uint256 value, bytes memory data) = abi.decode(log.data, (uint256, bytes));
      //(address sender, uint256 value, bytes memory data) = abi.decode(performData, (address, uint256, bytes));
      //performData = abi.encode(recipient, success, rewardAmount);
      //(address recipient, bool success, uint256 rewardAmount) = abi.decode(performData, (address, bool , uint256));
      // the code above was to determine how to decode performData based on different events
      // the code below now using enums we are able to determine which event it is


       (ActionType action) = abi.decode(performData, (ActionType));

       if (action == ActionType.ContributionAdded) {
        (, address payable Contributor , string memory data) = abi.decode(performData , (ActionType, address ,string));
        
       } 
       else if (action == ActionType.notTypicalContribution) {
        (  ,address sender, uint256 value, bytes memory data) = abi.decode(performData, (ActionType, address, uint256, bytes));
        
       }
       else if (action == ActionType.RewardStatus) {
        ( ,address recipient, bool success, uint256 rewardAmount) = abi.decode(performData, (ActionType, address, bool , uint256));
        
       }

      


       
    }

 




function addContribution( address payable _contributor, string memory _note, uint256 _amountinETH) public payable {
  // added payable because test failed 
  //makes it transfer of eth from contributor to blockchain feasible 
    contributorCount[_contributor]++;
    contributors[_contributor][contributorid] = Contributor ({
      contributorId : contributorid,
      contributor : _contributor ,
      note : _note ,
      timestamp : block.timestamp, 
      amountinETH : _amountinETH
    });

    allContributions.push (Contributor ({
      contributorId : contributorid,
      contributor : _contributor ,
      note : _note ,
      timestamp : block.timestamp, 
      amountinETH : _amountinETH
    }));

    totalcontributions[_contributor] += _amountinETH;

    emit ContributionAdded (_contributor, _note);

}



 function getContributions  ( address payable _contributor, uint256 _contributorId) public view onlyRecruiter returns ( string memory note, uint256 amountinETH, uint256 timestamp) {
 Contributor memory record = contributors[_contributor][_contributorId];
 return (record.note, record.amountinETH, record.timestamp);
 
}
function getMyContributions  ( uint256 _contributorId) public view  returns ( string memory note, uint256 amountinETH, uint256 timestamp) {
 Contributor memory record = contributors[msg.sender][_contributorId];
 return (record.note, record.amountinETH, record.timestamp);
 
}

function getAllContributions (address _recruiter) public view onlyRecruiter returns (uint256[] memory contributorId, string[] memory note, uint256[] memory timestamp, uint256[] memory amountinETH)
{
uint256[] memory _ids = contributorids[_recruiter];


uint256 length = allContributions.length;
contributorId = new uint256[](length);
note = new string[](length);
timestamp = new uint256[](length);
amountinETH = new uint256[](length);

for ( uint i = 0; i< length ; i++)
{
  Contributor memory c = allContributions[i];
  contributorId[i] = c.contributorId;
  note[i] = c.note;
  timestamp[i] = c.timestamp;
  amountinETH[i] = c.amountinETH;

}
return (contributorId, note , timestamp , amountinETH );

}
  




  /////////////////////////////////////////////////////////////////////////////////////////////
  /////////////////////////////REWARDS/////////////////////////////////////////////////////////
  /////////////////////////////////////////////////////////////////////////////////////////////

 function claimRewards() noReClaim external returns (address payable , uint256 _rewardAmount ) {
  require (totalcontributions[msg.sender] >= rewardthreshold , "Not eligible");
  require (!hasClaimedRewards[msg.sender] , "cant claim twice" ); 

  hasClaimedRewards[msg.sender] = true ;  //it is supposed to be true for the function to pass 
  rewardToken.transfer (msg.sender , rewardAmount);
  require(rewardAmount > 0,"Rewards exhausted ");
  emit RewardStatus ( msg.sender , rewardAmount , true );
  return (payable(msg.sender) , rewardAmount);

 }

  

}