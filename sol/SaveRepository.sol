pragma solidity ^0.4.25;
pragma experimental ABIEncoderV2;

import "./Table.sol";
import "./DataFormat.sol";
import "./Person.sol";

contract SaveRepository is DataFormat{
    string constant TABLE_NAME = "t_saveRepository";
    TableFactory tf;
    string private id_str;
    
    function create() public returns(int){
        tf = TableFactory(0x1001);  
        int count = tf.createTable(TABLE_NAME, "id", "version,name,motto,father,fatherConfirmed,mother,motherConfirmed,couple,coupleConfirm,children,childrenConfirmed");
        return count;
    }
    
    // 功能：向族谱合约(SaveRepository)中，添加一个人的信息
    function addPerson(int  version, address id, string name,string motto, address fatherId, address motherId) public returns(int){
        Table table = tf.openTable(TABLE_NAME);
        
        id_str = toString(id);
        
        Entry entry = table.newEntry();
        entry.set("id", id_str);
        entry.set("name", name);
        entry.set("motto", motto);
        entry.set("father", fatherId);
        entry.set("mother", motherId);
        entry.set("version", version);

        int count = table.insert(id_str, entry);
        // emit UpdateResult(count);
        
        return count;
    }
    
    // 功能：向族谱合约(SaveRepository)中，添加一个人的亲属信息
    function addRelativeItem(address id , string relationName, address relativeId) public returns(int){
        Table table = tf.openTable(TABLE_NAME);
        
        id_str = toString(id);
        
        Entry entry = table.newEntry();
        entry.set("id", id_str);
        entry.set(relationName, relativeId);
        
        Condition condition = table.newCondition();
        condition.EQ("id", id_str);

        int count = table.update(id_str, entry, condition);
        // emit UpdateResult(count);
        
        return count;
    }
    
    // 功能：在族谱合约(SaveRepository)中，确认某个亲属的亲属信息
    function voteRelativeItem(address id, string relationName, address relativeId)public returns(int){
        Table table = tf.openTable(TABLE_NAME);
        
        id_str = toString(id);
        string memory relationConfirmed = strConcat(relationName,"Confirmed");
        
        Entry entry = table.newEntry();
        entry.set("id", id_str);
        entry.set(relationConfirmed, int(1));
        
        Condition condition = table.newCondition();
        condition.EQ("id", id_str);

        int count = table.update(id_str, entry, condition);
        // emit UpdateResult(count);
        
        return count;
    }
    
    // 功能：在族谱合约(SaveRepository)中，查看某个人的信息
    function selectPersonById(address id) public view returns(address){
        Table table = tf.openTable(TABLE_NAME);
        
        id_str = toString(id);
        
        Condition condition = table.newCondition();
        condition.EQ("src_id", id_str);
        
        // 由于controller设置了判定，故一定是entries.size() 为1
        Entries entries = table.select(id_str, condition);
        
        Entry entry = entries.get(0);
	
	    int version = entry.getInt("version");
        string memory name= entry.getString("name");
        string memory motto = entry.getString("motto");
        address father = entry.getAddress("father");
        address mother = entry.getAddress("mother");
        address couple = entry.getAddress("couple");
        address children = entry.getAddress("children");

	    address person = new Person(version, id, name, motto, father, mother, couple, children);
	    return person;
    }
    // 功能：在族谱合约(SaveRepository)中，查看调用者父亲的信息
    function selectFatherIdById(address id) public view returns(int, address){
        Table table = tf.openTable(TABLE_NAME);
        
        id_str = toString(id);
        
        Condition condition = table.newCondition();
        condition.EQ("src_id", id_str);
        
        // 由于controller设置了判定，故一定是entries.size() 为1
        Entries entries = table.select(id_str, condition);
        int size = entries.size();
        
        if(size == 1){
            Entry entry = entries.get(0);
    	    address person = entry.getAddress('father');            
        }
	    return (size, person) ;
    }
    // 功能：在族谱合约(SaveRepository)中，确认该id的用户是否存在
    function isIdExisted(address id) public view returns(bool){
        Table table = tf.openTable(TABLE_NAME);
        
        id_str = toString(id);
        Condition condition = table.newCondition();
        condition.EQ("id", id_str);
        
        Entries entries = table.select(id_str, condition);
        if(entries.size()==1){
            return true;
        }else{
            return false;
        }
    }
}