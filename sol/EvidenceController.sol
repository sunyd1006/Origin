pragma solidity ^0.4.25;
pragma experimental ABIEncoderV2;

import "./TempRepository.sol";
import "./SaveRepository.sol";
import "./DataFormat.sol";
import "./Person.sol";

contract EvidenceController is DataFormat{
    TempRepository private _temp;
    SaveRepository private _save;
    Person private person;
    
    event strEvent(string str);
    
    constructor(address temp, address save) public {
        _temp = TempRepository(temp);
        _save = SaveRepository(save);

        _save.create();
        _temp.create();
    }
    
    // 功能：检验用户输入的关系 relation 是否是 恰当的关系
    // 场景：外部账户地址( 是本系统的 登录id ),这个用户想要添加自己的亲属关系时，需要验明是否是 合法的亲属关系
    modifier isProperRelation(string str){
        if(compareTwoString(str, "father") || compareTwoString(str, "mother") || compareTwoString(str, "couple")|| compareTwoString(str, "children") ){
            _;
        }else{
            emit strEvent("relation invalid.");
        }
    }
    
    // 功能：检验用户查询的本族族谱时，最大查询的先辈代数，目前默认为5代
    // 场景：在查询上数第 n 代时用于判断
    modifier isFiveGeneration(uint n){
        require(n<=5, "Up to five generations.");
        _;
    }
    
    // 功能：用户将自己的个人基本信息存入平台(族谱合约SaveRepository)
    // 场景：用户首次想将自己的信息存入 “起点Origin” 平台时调用
    function addPerson(int version, string name, string motto, address father, address mother) public returns(int, int, int){
        
        if( _save.isIdExisted(tx.origin) ){
            revert("Current account has existed, please use function addRelative");
            return (0,0,0);
        }else{
            int item1 = _temp.addRelativeItem(tx.origin, "father", father);
            int item2 = _temp.addRelativeItem(tx.origin, "mother", mother);
            
            int item3 = _save.addPerson(version, tx.origin, name, motto, father, mother);
            
            return (item1, item2, item3);
        }
    }
    
    // 功能：用户将自己的个人额外亲属信息存入平台(族谱合约SaveRepository)
    // 场景：当用户已经存入基本信息后(在已经调用addPerson后)，还想添加 伴侣couple/子女children时调用
    function addRelative(string relation, address id)public isProperRelation(relation) returns(int, int){
        if( _save.isIdExisted(tx.origin) ){
            int item1 = _temp.addRelativeItem(id, relation, tx.origin);
            int item2 = _save.addRelativeItem(tx.origin, relation, id);
            return (item1, item2);
        }else{
            revert("Current account has no record, please use function addPerson");
            return (0,0);
        }
    }

    // 功能：查看用户id待确认的 亲属关系列表
    // 优势：亲属之间的互相确认机制。
    function selectWaitingList() public returns(address[],bytes32[],address[]){
        return _temp.selectBySrcId(tx.origin);
    }
    
    // 功能：同意在族谱上(族谱合约SaveRepository) 与亲属(id) 正式建立 一个叫relation的关系
    // 场景：用户想确认自己与id 是一种叫做 relation 的亲属关系时调用
    // 优势：亲属之间的互相确认机制。
    function voteRelative(string relation, address id)public isProperRelation(relation) returns(int, int){
        if( _save.isIdExisted(tx.origin) ){
            int item1 = _temp.voteRelativeItem(tx.origin, relation, id);
            int item2 = 0;
            if(item1 ==1){
                item2 = _save.voteRelativeItem(tx.origin, relation, id);
            }else{
                revert("No one needs to vote in the current account");
            }
            return (item1, item2);
        }else{
            revert("Current account has no record, please use function addRelative");
            return (0,0);
        }
    }  

    // 功能：查看(族谱合约SaveRepository) 合约调用者tx.origin的 n 代族谱信息
    // 场景：用户添加个人信息到(族谱合约SaveRepository)上后，总想看看 这几代的状况吧，这时调用此合约
    function selectNLineage(uint n) public isFiveGeneration(n) view returns(bool, address[]){
        address[] memory temp = new address[](5);
        
        if( _save.isIdExisted(tx.origin) ){
            // todo
            address elderTemp = tx.origin;
            bool isValid = true;
            uint i=0;

            while(i++ <n && isValid){
                (isValid, elderTemp) = selectNPerson(i);
                
                if(isValid){
                    temp[i-1] = elderTemp;
                } 
            }
            if( i==1 && !isValid){
                return (false, temp);
            }else{
                return (true, temp);
            }
        }else{
            revert("Current query has no recod");
            return (false, temp);
        }
    }
    
    // 功能：查看(族谱合约SaveRepository) 合约调用者tx.origin的 n 代族谱信息
    // 场景：用户添加个人信息到(族谱合约SaveRepository)上后，总想看看 祖宗的基本信息吧，
    // 使用：selectNperson(1):查看父亲的基本信息
    //      selectNperson(2): 查看爷爷的基本信息
    //      selectNperson(3): 查看祖祖的基本信息
    function selectNPerson(uint n) public  view returns(bool, address){
        if( _save.isIdExisted(tx.origin) ){
            // todo
            address elderTemp = tx.origin;
            bool isValid = true;
            int intTemp;
            while(n-- >0 && isValid){
                (intTemp, elderTemp) = _save.selectFatherIdById(elderTemp);
                isValid = (intTemp>0)?true:false;
            }
            
            if(elderTemp != address(0) && isValid){
                return(true, elderTemp);
            }else{
                return(false, address(0));
            }
        }else{
            revert("Current query has no recod");
            return (false, address(0));
        }
    }

    // 功能：查看(族谱合约SaveRepository) 用户id 为 id 的用户
    // 场景：用户添加个人信息到族谱上后，总想看看某个人的信息吧，可以根据那个人的id查看
    function selectPersonById(address id) public returns(int){
        if( _save.isIdExisted(id) ){
            person = Person( _save.selectPersonById(id) );
            return 1;
        }else{
            revert("Current query has no record");
            return 0;
        }
    }
}