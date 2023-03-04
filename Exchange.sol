// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract ExChange{
    IERC20 public immutable SaleToken;
    address public owner;
    uint public price;
    mapping(address => address) public Recommended;    
 
    constructor(address _saleToken,uint _price) {
        owner = msg.sender;
        SaleToken = IERC20(_saleToken);
        price = _price;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "not authorized");
        _;
    }

    function buyToekn() payable public{
        uint amount = msg.value;
        uint ERCbalance = SaleToken.balanceOf(address(this));
        require(amount/price*11/10 <= ERCbalance,"NOT ENOUGH TOKEN");
        SaleToken.transfer(msg.sender,amount/price);
        if(Recommended[msg.sender]!= address(0)){
            SaleToken.transfer(Recommended[msg.sender],amount/price*1/10);
        }       
    }

    function bind(address _leader) external{
        Recommended[msg.sender] = _leader;
    }

    function setprice(uint _price) external onlyOwner{
        price = _price;
    }

    function withdraw(uint _amount) external onlyOwner{
        require(_amount <= address(this).balance ,"NOT ENOUGH TOKEN");
        payable(msg.sender).transfer(_amount);
    }

    function viewcontractERC() public view returns(uint){
         return(SaleToken.balanceOf(address(this)));
    }

    function viewaddressERC(address _account) public view returns(uint){
         return(SaleToken.balanceOf(_account));
    }

    function viewETH() public view returns(uint){
         return(address(this).balance);
    }

    function viewRecommended() public view returns(address){
         return(Recommended[msg.sender]);
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
