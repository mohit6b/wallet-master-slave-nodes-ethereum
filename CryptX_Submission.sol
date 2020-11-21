pragma solidity ^0.4.20;

contract CryptX_Submission{
    
    address private minter;
    
// Mapping to get balance of a particular address
// Mapping to check whether a particular node is master or not
// Mapping from slave address to master address

    mapping(address => uint) wallet_balance;
    mapping(address => bool) masterCheck;
    mapping(address => address) makeMaster;
    
// Event when there will be transaction between sender(msg.sender or senderL) and slave(recieverL) address
// Event when there will be automatic deduction from slave(senderS) address to Master(recieverS) address
// Event when reciever will be Master(recieverM) address only

    event LogAtSlave(address senderL, address recieverL, uint amountL);
    event LogAtSlavetoM(address senderS, address recieverS, uint amountS);
    event LogAtMastertoM(address senderM, address recieverM, uint amountM);


// Constructor to assign contract deployer as minter 

    function CryptX_Submission(){
        minter = msg.sender;    
    }
    
// Function to mint amount for a particular address through contract deployer

    function mint(address reciever, uint amount ){
        require(msg.sender == minter);
        wallet_balance[reciever] += amount;        
    }

// Function for the selection of master for any slave node    

    function chooseMaster(address masterJi){
        require(msg.sender != masterJi);
        makeMaster[msg.sender] = masterJi;
        masterCheck[masterJi] = true;        
    }

// function for sending amount by a random user to 1.Slave node 2. Master Node
// If transfer will be from random user to master node then amount will simply added to master balance and deducted from random user
// If transfer will be from random user to slave node then it will check for master of slave node, 
// if there is master of slave node amount be deposited in master node through slave node (Event will be created for both transaction)
// if master is not present, then the automatic master is contract deployer(minter), Amount will be deposited in minter node.

    function send(address sender, address reciever, uint amount) {
        require(msg.sender == sender && wallet_balance[sender] > 0 );
        
        address temporary;
        address slave;
        if(masterCheck[reciever] == false){
            wallet_balance[sender] -= amount;
            wallet_balance[reciever] += amount;
            LogAtSlave(sender, reciever, amount);
            
            if(makeMaster[reciever] != 0){
                temporary = makeMaster[reciever];
                if(masterCheck[temporary] == true){
                    wallet_balance[reciever] -= amount;
                    wallet_balance[temporary] += amount;
                    LogAtSlavetoM(reciever, temporary, amount);
                }

            } else{
                wallet_balance[reciever] -= amount;
                wallet_balance[minter] += amount;
                LogAtSlavetoM(reciever, minter, amount);
            }            
        }
        
        if(masterCheck[reciever] == true){
            wallet_balance[sender] -= amount;
            wallet_balance[reciever] += amount;
            LogAtMastertoM(sender, reciever, amount);
        }
    }
    
    function get() public constant returns (uint) {
        return wallet_balance[msg.sender];
    }
}
