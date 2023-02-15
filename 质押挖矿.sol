// SPDX-License-Identifier: MIT
pragma solidity ^0.8;

contract StakingRewards {
    IERC20 public immutable stakingToken;
    IERC20 public immutable rewardsToken;
    IERC20 public immutable rateToken;    

    address public owner;

    mapping(address => uint) public duration;  
    mapping(address => uint) public stakeChangeTime;    
    mapping(address => uint) public ratetime;  

    mapping(address => uint) public RewardRate;
 
    mapping(address => uint) public stakeRewards;
    mapping(address => uint) public rateRewards;

    uint public totalStaked;
 
    mapping(address => uint) public stakedAmount;
    mapping(address => uint) public rateAmount;

    uint public rewardPerStake;
    uint public rewardPerRate;

    constructor(address _stakingToken, address _rewardToken, address _rateToken) {
        owner = msg.sender;
        stakingToken = IERC20(_stakingToken);
        rewardsToken = IERC20(_rewardToken);
        rateToken = IERC20(_rateToken);
        rewardPerStake = 26 ;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "not authorized");
        _;
    }

    modifier updateStakeReward(address _account) {
        
        // updatedAt = lastTimeRewardApplicable();

        if (_account != address(0)) {
            stakeRewards[_account] = viewStakeReward(_account);
            // userRewardPerTokenPaid[_account] = rewardPerToken;
        }

        _;
    }

   
    function updateRewardPerStake(uint _num) external onlyOwner{
       rewardPerStake = _num;
    }

    function stake(uint _amount) external updateStakeReward(msg.sender) {
        require(_amount > 0, "amount = 0");
        stakingToken.transferFrom(msg.sender, address(this), _amount);
        stakedAmount[msg.sender] += _amount;
        totalStaked += _amount;
        stakeChangeTime[msg.sender] = block.timestamp;
    }

    function unstake(uint _amount) external updateStakeReward(msg.sender) {
        require(_amount > 0, "amount = 0");
        require(stakedAmount[msg.sender] > 0,"no staked");
        stakedAmount[msg.sender] -= _amount;
        totalStaked -= _amount;
        stakeChangeTime[msg.sender] = block.timestamp;    
        stakingToken.transfer(msg.sender, _amount);
    }

    function viewStakeReward(address _account) public view returns (uint) {
        require(stakeChangeTime[_account]!=0, "not start");
        return
            (rewardPerStake * stakedAmount[_account] * (block.timestamp - stakeChangeTime[_account])) + stakeRewards[_account];
    }

    function rateReward(address _account) public view returns (uint) {
        require(ratetime[msg.sender]!=0, "not rate");
        if (block.timestamp - ratetime[msg.sender] < 386400){
        return
            (rewardPerRate * rateAmount[_account] * (block.timestamp - ratetime[msg.sender])) + rateRewards[_account];
            }
        else{
        return
            (rewardPerRate * rateAmount[_account] * 386400) + rateRewards[_account];   
            }
    }     

    function withdrawReward() external updateStakeReward(msg.sender) {
        uint reward = stakeRewards[msg.sender];
        if (reward > 0) {
            stakeRewards[msg.sender] = 0;
            rewardsToken.transfer(msg.sender, reward);
        }
    }   
}

interface IERC20 {
    function totalSupply() external view returns (uint);

    function balanceOf(address account) external view returns (uint);

    function transfer(address recipient, uint amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint value);
    event Approval(address indexed owner, address indexed spender, uint value);
}
