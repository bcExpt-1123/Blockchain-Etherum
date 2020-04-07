pragma solidity ^0.6.0;

contract MultisigWallet {
  address[] public approvers;
   uint public quorum;
   struct Transfer {
     uint id;
     uint amount;
     address payable to;
     uint approvals;
     bool sent;
   }
   mapping(uint => Transfer) transfers;
   uint nextId;
   mapping(address => mapping(uint => bool)) approvals;

   constructor(address[] memory _approvers, uint _quorum) payable public {
     approvers = _approvers;
     quorum = _quorum;
   }

   function createTransfer(uint amount, address payable to) external {
     transfers[nextId] = Transfer(
       nextId,
       amount,
       to,
       0,
       false
     );
     nextId++;
   }

  function sendTransfer(uint id) onlyApprover() external {
    require(transfers[id].sent == false, 'transfer has already been sent');
    if(approvals[msg.sender][id] == false) {
      approvals[msg.sender][id] = true;
      transfers[id].approvals++;
    }

    if(transfers[id].approvals >= quorum) {
      transfers[id].sent = true;
      address payable to = transfers[id].to;
      uint amount = transfers[id].amount;
      to.transfer(amount);
      return;
    }
  }
}
