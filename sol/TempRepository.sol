pragma solidity ^0.4.25;

import "./Table.sol";
import "./DataFormat.sol";

contract TempRepository is DataFormat{
    
    string constant TABLE_NAME = "t_tempRepository";
    TableFactory tf;
    
    function create() public returns(int){
        tf = TableFactory(0x1001);  
        int count = tf.createTable(TABLE_NAME, "src_id", "relation, dst_id");
        
        return count;
    }
    
    // 功能：向(族谱待确认缓存合约TempRepository) 中添加1条亲属记录，以等待亲属确认
    // 场景：id说自己的 relation(一种关系) 是 dst, 平台把这条声明存下来，已待dst确认。
    // 使用：selectNperson(id, 'father', dst):表示叫id的用户，表示自己的父亲是 叫dst的用户
    //      selectNperson(id, 'mother', dst):表示叫id的用户，表示自己的母亲是 叫dst的用户
    function addRelativeItem(address id, string relation, address dst) public returns(int){
        Table table = tf.openTable(TABLE_NAME);
        
        string memory id_str = toString(id);
        string memory dst_str = toString(dst);
        
        Entry entry = table.newEntry();
        entry.set("src_id", id_str);
        entry.set("relation", relation);
        entry.set("dst_id", dst_str);
        
        int count = table.insert(id_str, entry);

        return count;
    }

    // 功能：向(族谱待确认缓存合约TempRepository) 中确认1条亲属记录，缓存合约将这条待确认的记录删除
    // 场景：id说自己的 relation(一种关系) 是 dst, 平台把这条声明存下来，已待dst确认。
    // 使用：voteRelativeItem(id, 'father', dst):表示叫id的用户，表示自己的父亲是 叫dst的用户
    //       voteRelativeItem(id, 'mother', dst):表示叫id的用户，表示自己的母亲是 叫dst的用户
    function voteRelativeItem(address id, string relation, address dst) public returns(int){
        Table table = tf.openTable(TABLE_NAME);
        
        string memory id_str = toString(id);
        string memory dst_str = toString(dst);
        
        Condition condition = table.newCondition();
        condition.EQ("src_id", id_str);
        condition.EQ("relation", relation);
        condition.EQ("dst_id", dst_str);
        
        int count = table.remove(id_str, condition);

        return count;
    }

    // 功能：查看(族谱合约EvidenceSave) 中，用户id待确认的亲属关系条数
    // 场景：用户添加个人信息到(族谱合约EvidenceSave)上后，总想看看 祖宗的基本信息吧，
    // 使用：selectNperson(1):查看父亲的基本信息
    //      selectNperson(2): 查看爷爷的基本信息
    //      selectNperson(3): 查看祖祖的基本信息
    function selectBySrcId(address id) public returns(address[],bytes32[],address[]){
        Table table = tf.openTable(TABLE_NAME);
        
        string memory id_str = toString(id);
        Condition condition = table.newCondition();
        condition.EQ("src_id", id_str);
        
        Entries entries = table.select(id_str, condition);
        address[] memory src_id_address_list = new address[](uint256(entries.size()));
        bytes32[] memory relation_bytes_list = new bytes32[](uint256(entries.size()));
        address[] memory dst_id_address_list = new address[](uint256(entries.size()));
        
        for(int i=0; i<entries.size(); ++i) {
            Entry entry = entries.get(i);
            
            src_id_address_list[uint256(i)] = toAddress(entry.getString("src_id"));
            relation_bytes_list[uint256(i)] = entry.getBytes32("relation");
            dst_id_address_list[uint256(i)] = toAddress(entry.getString("dst_id"));
        }
 
        return (src_id_address_list, relation_bytes_list, dst_id_address_list);
    }
}