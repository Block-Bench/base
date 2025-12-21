pragma solidity 0.4.24;

contract Refunder {

address[] private reimbursementRecipients;
mapping (address => uint) public refunds;

    constructor() {
        reimbursementRecipients.push(0x79B483371E87d664cd39491b5F06250165e4b184);
        reimbursementRecipients.push(0x79B483371E87d664cd39491b5F06250165e4b185);
    }


    function reimburseAll() public {
        for(uint x; x < reimbursementRecipients.length; x++) {
            require(reimbursementRecipients[x].send(refunds[reimbursementRecipients[x]]));
        }
    }

}