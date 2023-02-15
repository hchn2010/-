// SPDX-License-Identifier: MIT
pragma solidity ^0.8;

contract RateRewards {
    IERC20 public  rateToken ;
    IERC20 public  rewardsToken;   

    address public owner;

    //待释放奖励
    mapping(address => uint) public waitingRateRewards;
    //已获得奖励      
    mapping(address => uint) public rateRewards; 
    //上次提取奖励时间  
    mapping (address => uint) public lastClaimTime;
    //释放速度 
    mapping (address => uint) public releaseSpeed;

    uint public rewardPerRate;

    constructor(address _rateToken, address _rewardsToken) {
        owner = msg.sender;
        rateToken = IERC20(_rateToken);        
        rewardsToken = IERC20(_rewardsToken);
        rewardPerRate = 10;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "not authorized");
        _;
    }

    modifier updateRateReward(address _account) { 
        if (msg.sender != address(0)) {
            rateRewards[msg.sender] = viewRateReward(_account);
        }
        _;
    }

    function updaterewardPerRate(uint _num) external onlyOwner{
       rewardPerRate = _num;
    }

    function destroy(uint _amount) external  {
        require(_amount > 0, "amount = 0");        
        rateToken.transferFrom(msg.sender, address(this), _amount);    
        waitingRateRewards[msg.sender] += rewardPerRate * _amount *86400; 
        if(lastClaimTime[msg.sender]==0){
            lastClaimTime[msg.sender]=block.timestamp;  
        }
        releaseSpeed[msg.sender]= waitingRateRewards[msg.sender]/86400;            
    }

    function withdrawRateReward() external updateRateReward(msg.sender){
        uint reward = rateRewards[msg.sender];
        if (reward > 0) {
            rateRewards[msg.sender] = 0;
            waitingRateRewards[msg.sender]=waitingRateRewards[msg.sender]-reward;
            rewardsToken.transfer(msg.sender, reward);
        }  
    }

    function viewRateReward(address _account) public view returns (uint) {
        require(lastClaimTime[_account]!=0, "not start"); 
        return
            min(releaseSpeed[_account] * (block.timestamp - lastClaimTime[_account]),waitingRateRewards[msg.sender]) ;
    }

    function min(uint x, uint y) private pure returns (uint) {
        return x <= y ? x : y;
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
