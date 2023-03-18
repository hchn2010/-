// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Mining {
    IERC20 public tokenA;
    IERC20 public tokenB;
    IERC20 public tokenC;

    address public owner;
    //质押数量  
    mapping (address => uint) public stakedAmount; 

    uint public totalStaked;

    //已获得质押奖励 
    mapping(address => uint) public stakeRewards;  

    //质押或解押时间 
    mapping(address => uint) public stakeChangeTime; 
    //质押每秒奖励 
    uint public rewardPerStake;    

    //待释放奖励
    mapping(address => uint) public waitingRateRewards;
    //已获得加速奖励  
    mapping(address => uint) public rateRewards;
    //上次提取奖励时间  
    mapping (address => uint) public lastClaimTime;
    //释放速度 
    mapping (address => uint) public releaseSpeed;
    //初始释放速度 
    uint public rewardPerRate;
    //释放周期 
    uint public releasePeriod;

    constructor(address _tokenA, address _tokenB, address _tokenC) {
        owner = msg.sender;
        tokenA = IERC20(_tokenA);
        tokenB = IERC20(_tokenB);
        tokenC = IERC20(_tokenC);
        rewardPerStake = 10;
        rewardPerRate = 1;
        releasePeriod = 86400;
    }
     
    modifier onlyOwner() {
        require(msg.sender == owner, "not authorized");
        _;
    }
    //更新质押奖励 
    modifier updateStakeReward(address _account) {   
         if (_account != address(0)) {
            stakeRewards[_account] = viewStakeReward(_account);
        }
        _;
    }
   //更新加速奖励 
   modifier updateRateReward(address _account) { 
        if (msg.sender != address(0)) {
            rateRewards[msg.sender] = viewRateReward(_account);
        }
        _;
    }
    //更改每秒质押奖励数 
    function updateRewardPerStake(uint _num) external onlyOwner{
       rewardPerStake = _num;
    }

    //更改每秒释放奖励数 
    function updateRewardPerRate(uint _num) external onlyOwner{
       rewardPerRate = _num;
    }

    //更改每秒释放周期
    function updateReleasePeriod(uint _num) external onlyOwner{
       rewardPerRate = _num;
    }
    //查看质押奖励 
    function viewStakeReward(address _account) public view returns (uint) {
        if(stakeChangeTime[_account]!=0){
        return
            (rewardPerStake * stakedAmount[_account] * (block.timestamp - stakeChangeTime[_account])) + stakeRewards[_account];
        }else{
        return 0;
        }
    }

    //查看销毁奖励 
    function viewRateReward(address _account) public view returns (uint) {
        if(lastClaimTime[_account]!=0){
        return
            min(releaseSpeed[_account] * (block.timestamp - lastClaimTime[_account]),waitingRateRewards[msg.sender]) ;
        }else{
        return 0;
        }
    }

    //查看总奖励 
    function viewAllReward(address _account) public view returns (uint) {
        if(lastClaimTime[_account]==0 && stakeChangeTime[_account]==0){
        return 0;
        }else{
        return
        viewStakeReward(_account)+ viewRateReward(_account);       
        }
    }

    //质押 
    function stake(uint _amount) external updateStakeReward(msg.sender) {
        require(_amount > 0, "amount = 0");
        tokenA.transferFrom(msg.sender, address(this), _amount);
        stakedAmount[msg.sender] += _amount;
        totalStaked += _amount;
        stakeChangeTime[msg.sender] = block.timestamp;
    }

    //解押 
    function cancelStake(uint _amount) external updateStakeReward(msg.sender) {
        require(_amount > 0, "amount = 0");
        require(stakedAmount[msg.sender] > 0,"no staked");
        stakedAmount[msg.sender] -= _amount;
        totalStaked -= _amount;
        stakeChangeTime[msg.sender] = block.timestamp;    
        tokenA.transfer(msg.sender, _amount);
    }

    //owner提取质押 
    function getstake(uint _amount) external onlyOwner{
        require(_amount > 0, "amount = 0");
        tokenA.transferFrom(msg.sender, address(this), _amount);            
    }

    //销毁 
    function destroy(uint _amount) external  {
        require(_amount > 0, "amount = 0");        
        tokenB.transferFrom(msg.sender, address(this), _amount);    
        waitingRateRewards[msg.sender] += rewardPerRate * _amount * 86400; 
        if(lastClaimTime[msg.sender]==0){
            lastClaimTime[msg.sender]=block.timestamp;  
        }
        if(waitingRateRewards[msg.sender]/releasePeriod >= rewardPerRate){
           releaseSpeed[msg.sender]= waitingRateRewards[msg.sender]/releasePeriod; 
        }else{
           releaseSpeed[msg.sender]= rewardPerRate;
        }         
    }

    //提取总奖励 
    function withdrawReward() external updateStakeReward(msg.sender) updateRateReward(msg.sender){
        uint reward = stakeRewards[msg.sender] + rateRewards[msg.sender];
        require (reward > 0,"REWARD = 0") ;
        require (stakedAmount[msg.sender]>0,"no pledge");
        if(rateRewards[msg.sender]!=0){
            lastClaimTime[msg.sender]=block.timestamp;
            waitingRateRewards[msg.sender]=waitingRateRewards[msg.sender]-rateRewards[msg.sender];  
            } 
        stakeRewards[msg.sender] = 0;
        rateRewards[msg.sender] = 0;                     
        tokenC.transfer(msg.sender, reward);        
    }
    //纯函数，取最小值
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
