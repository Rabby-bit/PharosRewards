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

interface IERC20 {
  function transfer (address recipient, uint amount ) external returns (bool);
}


contract Contribution {


  

  struct Contributor{
    uint256 contributorId;
    address payable contributor;
    string note;
    uint256 timestamp;
    uint256 amountinETH;
 }
    address immutable recruiter;
    uint256 contributorid; 
    bool private locked;
    IERC20 public rewardToken;
    uint256 public rewardAmount;
    uint256 public rewardthreshold; 


  mapping(address => mapping(uint256 => Contributor)) public contributors;
  mapping(address => uint[] ) public contributorids;
  mapping(address => uint256) public totalcontributions;
  mapping(address => bool) public hasClaimedRewards;

  event ContributionAdded(address payable indexed contributor, string);
  event notTypicalContribution (address indexed sender, uint256 value, bytes data );
  event RewardStatus(address indexed recipient, uint256 _rewardamount, bool success);
  
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

        recruiter = msg.sender;
        rewardToken = IERC20(_rewardToken);
        rewardthreshold = rewardthreshold; 
        rewardAmount = rewardAmount;
      }
  receive() external payable {}

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

     
function addContribution( address payable _contributor, string memory _note,uint _contributorId, uint _amountinETH) public {
    contributorid++;
    contributors[_contributor][contributorid] = Contributor ({
      contributorId : _contributorId ,
      contributor : _contributor ,
      note : _note ,
      timestamp : block.timestamp, 
      amountinETH : _amountinETH
    });

    totalcontributions[_contributor] += _amountinETH;

    emit ContributionAdded (_contributor, _note);

}



 function getContributions  ( address payable _contributor, uint256 _contributorId) public view onlyRecruiter returns ( string memory note, uint256 amountinETH, uint256 timestamp) {
 Contributor memory record = contributors[_contributor][_contributorId];
 return (record.note, record.amountinETH, record.timestamp);
 
}

function getAllContributions (address _recruiter) public view onlyRecruiter returns (uint256[] memory contributorId, string[] memory note, uint256[] memory timestamp, uint256[] memory amountinETH)
{
uint256[] memory _ids = contributorids[_recruiter];
uint length = _ids.length; 

_ids = new uint256[](length);
note = new string[](length);
timestamp = new uint256[](length);
amountinETH = new uint256[](length);

for ( uint i = 0; i< length ; i++)
{
  Contributor memory record = contributors[_recruiter][_ids[i]];
  _ids[i] = record.contributorId;
  note[i] = record.note;
  timestamp[i] = record.timestamp;
  amountinETH[i] = record.amountinETH;

}
return (_ids , note , timestamp , amountinETH );

}
  




  /////////////////////////////////////////////////////////////////////////////////////////////
  /////////////////////////////REWARDS/////////////////////////////////////////////////////////
  /////////////////////////////////////////////////////////////////////////////////////////////

 function claimRewards() noReClaim external returns (address payable , uint256 _rewardAmount ) {
  require (totalcontributions[msg.sender] >= rewardthreshold , "Not eligible");
  require (!hasClaimedRewards[msg.sender] , "cant claim twice" ); 

  hasClaimedRewards[msg.sender] = false ;
  rewardToken.transfer (msg.sender , rewardAmount);
  emit RewardStatus ( msg.sender , rewardAmount , true );

 }
  

}