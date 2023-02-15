// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Airdropwater{
    IERC20 public immutable SaleToken;
    address public owner;
    uint public airdropnum;
    uint public starttime;
    uint public intervaltime;
    mapping(address => uint) public submitdate;
    mapping(address => address) public Recommended;
    mapping(address => bool) public Whitelist;
 
    constructor(address _saleToken,uint _airdropnum){
        owner = msg.sender;
        Whitelist[owner]=true;
        SaleToken = IERC20(_saleToken);
        airdropnum = _airdropnum;
        starttime = 1672502400;
        intervaltime = 86400;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "not authorized");
        _;
    }

    modifier isWhitelist() {
        require(Whitelist[msg.sender]==true,"not whitelist");
        _;
    }

    function addWhitelist() external payable{
         require(msg.value>=10000000,"require 1VS"); //update
         Whitelist[msg.sender]=true;
    }

    function getWater() external isWhitelist{
        uint nowdate = (block.timestamp - starttime) / intervaltime;
        require(nowdate != submitdate[msg.sender] ,"please got it tomorrow");
        uint ERCbalance = SaleToken.balanceOf(address(this));          
        require(airdropnum*14/10 <= ERCbalance,"NOT ENOUGH TOKEN");
        SaleToken.transfer(msg.sender,airdropnum);
        if(Recommended[msg.sender]!= address(0)){
            SaleToken.transfer(Recommended[msg.sender],airdropnum*4/10);
        }  
        submitdate[msg.sender] = nowdate;
    }

    function bind(address _leader) external{
        Recommended[msg.sender] = _leader;
    }

    function setairdropnum(uint _num) external onlyOwner {
        airdropnum = _num;
    }

    function setintervaltime(uint _num) external onlyOwner {
        intervaltime = _num;
    }   
    
    function withdraw(uint _amount) external onlyOwner{
        require(_amount <= address(this).balance ,"NOT ENOUGH TOKEN");
        payable(msg.sender).transfer(_amount);
    }

    function leftERCbalance() public view returns(uint){
         return(SaleToken.balanceOf(address(this)));
    }

    function viewERCbalanceOf(address _account) public view returns(uint){
         return(SaleToken.balanceOf(_account));
    }

    function viewVS() public view returns(uint){
         return(address(this).balance);
    }

    function viewRecommended() public view returns(address){
         return(Recommended[msg.sender]);
    }

    function viewWhitelist() public view returns(bool){
         return(Whitelist[msg.sender]);
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


// 定义一个起始时间 1.1
// 定义一个周期 24hours
// 定义一个签到bool
// 签到函数--
// 判断现在时间是否在周期内
// 点击后,bool=false;
