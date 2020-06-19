pragma solidity ^0.4.25;

contract Person{
    int _version;
    address _id;
    string _name;
    string _motto;
    address _father;
    address _mother;
    address _couple;
    address _children;
    
    event displayEvent(string str, string name, address id);
    
    constructor(int version, address id, string name, string motto, address father, address mother, address couple, address children) public{
        _version = version;
        _id = id;
        _name = name;
        _motto = motto;
        _father = father;
        _mother = mother;
        _couple = couple;
        _children = children;
    }
    
    function display() public view {
        emit displayEvent(" I am ", _name, _id);
    }

    function setVersion(int version) public{
        _version = version;
    }
    function setId(address id) public{
        _id = id;
    }
    function setName(string name) public{
        _name = name;
    }
    function setMotto(string motto) public{
        _motto = motto;
    }
    function setFather(address father) public{
        _father = father;
    }
    function setMother(address mother) public{
        _mother = mother;
    }
    function setCouple(address couple) public{
        _couple = couple;
    }
    function setChildren(address children) public{
        _children = children;
    }
    
    function getVersion() public  returns(int){
        return _version;
    }
    function getId() public returns(address){
        return _id;
    }
    function getName() public returns(string){
        return _name;
    }
    function getMotto() public returns(string){
        return _motto;
    }
    function getFather() public returns(address){
        return _father;
    }
    function getMother() public returns(address){
        return _mother;
    }
    function getCouple() public returns(address){
        return _couple;
    }
    function getChildren() public returns(address){
        return _children;
    }
}