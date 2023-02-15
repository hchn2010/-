// SPDX-License-Identifier: MIT
pragma solidity ^0.8;

contract RateRewards {
    IERC20 public  rateToken ;
    IERC20 public  rewardsToken;   

    address public owner;

    //总销毁
    mapping(address => uint) public allrateRewards;  

    //销毁时已释放
    mapping(address => uint) public destructrateRewards;
    //已提取
    mapping(address => uint) public getedrateRewards;
    
    //销毁时间点
    mapping(address => uint) public ratetime;  

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

    function updaterewardPerRate(uint _num) external onlyOwner{
       rewardPerRate = _num;
    }

    function destructratetoken(uint _amount) external  {
        require(_amount > 0, "amount = 0");
        
        rateToken.transferFrom(msg.sender, address(this), _amount);        
        destructrateRewards[msg.sender] = destructrateRewards[msg.sender]+ (allrateRewards[msg.sender]-destructrateRewards[msg.sender])*rateduration()/386400;
        allrateRewards[msg.sender] =  allrateRewards[msg.sender]+ rewardPerRate * _amount *86400;
        ratetime[msg.sender] = block.timestamp;
    }

    function viewrateReward() public view returns (uint) {        
        require(ratetime[msg.sender]!=0, "not start"); 
        uint durationtemp = rateduration();       
        return
        destructrateRewards[msg.sender] + (allrateRewards[msg.sender]-destructrateRewards[msg.sender])*durationtemp/86400 - getedrateRewards[msg.sender] ;            
     }

    function withdrawrateReward() external {
        uint reward = viewrateReward();
        require(reward>0,"no RATEREWARDS");
        getedrateRewards[msg.sender] += reward;        
        rewardsToken.transfer(msg.sender, reward);      
    }

    function rateduration() internal view returns (uint) {
        uint duration = block.timestamp - ratetime[msg.sender];
        if( duration < 86400 ){
         return duration;
        }else {
         return 86400 ;
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
