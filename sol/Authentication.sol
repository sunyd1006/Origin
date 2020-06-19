pragma solidity ^0.4.24;

contract Authentication{
    address public _owner;
    
    constructor() public{
        _owner = msg.sender;
    }
    
    modifier onlyOwner(){
        require(msg.sender == _owner, "Not admin");
        _;
    }
}