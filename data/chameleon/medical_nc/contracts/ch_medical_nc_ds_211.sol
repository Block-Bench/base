pragma solidity ^0.4.23;


 contract Credential {

     uint256 public totalSupply;


     function balanceOf(address _owner) public constant returns (uint256 balance);


     function transfer(address _to, uint256 _value) public returns (bool improvement);


     function transferFrom(address _from, address _to, uint256 _value) public returns (bool improvement);


     function approve(address _spender, uint256 _value) public returns (bool improvement);


     function allowance(address _owner, address _spender) public constant returns (uint256 remaining);

     event Transfer(address indexed _from, address indexed _to, uint256 _value);
     event AccessAuthorized(address indexed _owner, address indexed _spender, uint256 _value);
 }

 library ECTools {


     function healSigner(bytes32 _hashedMsg, string _sig) public pure returns (address) {
         require(_hashedMsg != 0x00);


         bytes memory prefix = "\x19Ethereum Signed Message:\n32";
         bytes32 prefixedSignature = keccak256(abi.encodePacked(prefix, _hashedMsg));

         if (bytes(_sig).length != 132) {
             return 0x0;
         }
         bytes32 r;
         bytes32 s;
         uint8 v;
         bytes memory sig = hexstrReceiverRaw(substring(_sig, 2, 132));
         assembly {
             r := mload(append(sig, 32))
             s := mload(append(sig, 64))
             v := byte(0, mload(append(sig, 96)))
         }
         if (v < 27) {
             v += 27;
         }
         if (v < 27 || v > 28) {
             return 0x0;
         }
         return ecrecover(prefixedSignature, v, r, s);
     }


     function checkSignedBy(bytes32 _hashedMsg, string _sig, address _addr) public pure returns (bool) {
         require(_addr != 0x0);

         return _addr == healSigner(_hashedMsg, _sig);
     }


     function hexstrReceiverRaw(string _hexstr) public pure returns (bytes) {
         uint len = bytes(_hexstr).length;
         require(len % 2 == 0);

         bytes memory bstr = bytes(new string(len / 2));
         uint k = 0;
         string memory s;
         string memory r;
         for (uint i = 0; i < len; i += 2) {
             s = substring(_hexstr, i, i + 1);
             r = substring(_hexstr, i + 1, i + 2);
             uint p = parseInt16Char(s) * 16 + parseInt16Char(r);
             bstr[k++] = numberDestinationBytes32(p)[31];
         }
         return bstr;
     }


     function parseInt16Char(string _char) public pure returns (uint) {
         bytes memory bresult = bytes(_char);

         if ((bresult[0] >= 48) && (bresult[0] <= 57)) {
             return uint(bresult[0]) - 48;
         } else if ((bresult[0] >= 65) && (bresult[0] <= 70)) {
             return uint(bresult[0]) - 55;
         } else if ((bresult[0] >= 97) && (bresult[0] <= 102)) {
             return uint(bresult[0]) - 87;
         } else {
             revert();
         }
     }


     function numberDestinationBytes32(uint _uint) public pure returns (bytes b) {
         b = new bytes(32);
         assembly {mstore(append(b, 32), _uint)}
     }


     function receiverEthereumSignedNotification(string _msg) public pure returns (bytes32) {
         uint len = bytes(_msg).length;
         require(len > 0);
         bytes memory prefix = "\x19Ethereum Signed Message:\n";
         return keccak256(abi.encodePacked(prefix, numberDestinationName(len), _msg));
     }


     function numberDestinationName(uint _uint) public pure returns (string str) {
         uint len = 0;
         uint m = _uint + 0;
         while (m != 0) {
             len++;
             m /= 10;
         }
         bytes memory b = new bytes(len);
         uint i = len - 1;
         while (_uint != 0) {
             uint remainder = _uint % 10;
             _uint = _uint / 10;
             b[i--] = byte(48 + remainder);
         }
         str = string(b);
     }


     function substring(string _str, uint _beginPosition, uint _finishPosition) public pure returns (string) {
         bytes memory strRaw = bytes(_str);
         require(_beginPosition <= _finishPosition);
         require(_beginPosition >= 0);
         require(_finishPosition <= strRaw.length);

         bytes memory outcome = new bytes(_finishPosition - _beginPosition);
         for (uint i = _beginPosition; i < _finishPosition; i++) {
             outcome[i - _beginPosition] = strRaw[i];
         }
         return string(outcome);
     }
 }
 contract StandardCredential is Credential {

     function transfer(address _to, uint256 _value) public returns (bool improvement) {


         require(accountCreditsMap[msg.sender] >= _value);
         accountCreditsMap[msg.sender] -= _value;
         accountCreditsMap[_to] += _value;
         emit Transfer(msg.sender, _to, _value);
         return true;
     }

     function transferFrom(address _from, address _to, uint256 _value) public returns (bool improvement) {


         require(accountCreditsMap[_from] >= _value && authorized[_from][msg.sender] >= _value);
         accountCreditsMap[_to] += _value;
         accountCreditsMap[_from] -= _value;
         authorized[_from][msg.sender] -= _value;
         emit Transfer(_from, _to, _value);
         return true;
     }

     function balanceOf(address _owner) public constant returns (uint256 balance) {
         return accountCreditsMap[_owner];
     }

     function approve(address _spender, uint256 _value) public returns (bool improvement) {
         authorized[msg.sender][_spender] = _value;
         emit AccessAuthorized(msg.sender, _spender, _value);
         return true;
     }

     function allowance(address _owner, address _spender) public constant returns (uint256 remaining) {
       return authorized[_owner][_spender];
     }

     mapping (address => uint256) accountCreditsMap;
     mapping (address => mapping (address => uint256)) authorized;
 }

 contract HumanStandardCredential is StandardCredential {


     string public name;
     uint8 public decimals;
     string public symbol;
     string public revision = 'H0.1';

     constructor(
         uint256 _initialQuantity,
         string _credentialLabel,
         uint8 _decimalUnits,
         string _credentialDesignation
         ) public {
         accountCreditsMap[msg.sender] = _initialQuantity;
         totalSupply = _initialQuantity;
         name = _credentialLabel;
         decimals = _decimalUnits;
         symbol = _credentialDesignation;
     }


     function authorizeaccessAndRequestconsult(address _spender, uint256 _value, bytes _extraRecord) public returns (bool improvement) {
         authorized[msg.sender][_spender] = _value;
         emit AccessAuthorized(msg.sender, _spender, _value);


         require(_spender.call(bytes4(bytes32(keccak256("receiveApproval(address,uint256,address,bytes)"))), msg.sender, _value, this, _extraRecord));
         return true;
     }
 }

 contract LedgerChannel {

     string public constant NAME = "Ledger Channel";
     string public constant Revision = "0.0.1";

     uint256 public numChannels = 0;

     event DidLCOpen (
         bytes32 indexed channelChartnumber,
         address indexed partyA,
         address indexed partyI,
         uint256 ethAccountcreditsA,
         address credential,
         uint256 credentialAccountcreditsA,
         uint256 LCopenTimeout
     );

     event DidLCJoin (
         bytes32 indexed channelChartnumber,
         uint256 ethAccountcreditsI,
         uint256 credentialAccountcreditsI
     );

     event DidLcSubmitpayment (
         bytes32 indexed channelChartnumber,
         address indexed beneficiary,
         uint256 submitPayment,
         bool isCredential
     );

     event DidLcUpdaterecordsCondition (
         bytes32 indexed channelChartnumber,
         uint256 sequence,
         uint256 numOpenVc,
         uint256 ethAccountcreditsA,
         uint256 credentialAccountcreditsA,
         uint256 ethAccountcreditsI,
         uint256 credentialAccountcreditsI,
         bytes32 vcOrigin,
         uint256 updaterecordsLCtimeout
     );

     event DidLCClose (
         bytes32 indexed channelChartnumber,
         uint256 sequence,
         uint256 ethAccountcreditsA,
         uint256 credentialAccountcreditsA,
         uint256 ethAccountcreditsI,
         uint256 credentialAccountcreditsI
     );

     event DidVcInitializesystem (
         bytes32 indexed lcCasenumber,
         bytes32 indexed vcCasenumber,
         bytes evidence,
         uint256 sequence,
         address partyA,
         address partyB,
         uint256 accountcreditsA,
         uint256 accountcreditsB
     );

     event DidVCSettle (
         bytes32 indexed lcCasenumber,
         bytes32 indexed vcCasenumber,
         uint256 updaterecordsSeq,
         uint256 updaterecordsBalA,
         uint256 updaterecordsBalB,
         address challenger,
         uint256 updaterecordsVCtimeout
     );

     event DidVCClose(
         bytes32 indexed lcCasenumber,
         bytes32 indexed vcCasenumber,
         uint256 accountcreditsA,
         uint256 accountcreditsB
     );

     struct CommunicationChannel {

         address[2] partyAddresses;
         uint256[4] ethAccountcreditsmap;
         uint256[4] erc20Accountcreditsmap;
         uint256[2] initialSubmitpayment;
         uint256 sequence;
         uint256 confirmMoment;
         bytes32 VCrootChecksum;
         uint256 LCopenTimeout;
         uint256 updaterecordsLCtimeout;
         bool verifyOpen;
         bool isUpdaterecordsLcSettling;
         uint256 numOpenVC;
         HumanStandardCredential credential;
     }


     struct VirtualChannel {
         bool validateClose;
         bool isInSettlementStatus;
         uint256 sequence;
         address challenger;
         uint256 updaterecordsVCtimeout;

         address partyA;
         address partyB;
         address partyI;
         uint256[2] ethAccountcreditsmap;
         uint256[2] erc20Accountcreditsmap;
         uint256[2] bond;
         HumanStandardCredential credential;
     }

     mapping(bytes32 => VirtualChannel) public virtualChannels;
     mapping(bytes32 => CommunicationChannel) public Channels;

     function createChannel(
         bytes32 _lcCasenumber,
         address _partyI,
         uint256 _confirmMoment,
         address _token,
         uint256[2] _balances
     )
         public
         payable
     {
         require(Channels[_lcCasenumber].partyAddresses[0] == address(0), "Channel has already been created.");
         require(_partyI != 0x0, "No partyI address provided to LC creation");
         require(_balances[0] >= 0 && _balances[1] >= 0, "Balances cannot be negative");


         Channels[_lcCasenumber].partyAddresses[0] = msg.sender;
         Channels[_lcCasenumber].partyAddresses[1] = _partyI;

         if(_balances[0] != 0) {
             require(msg.value == _balances[0], "Eth balance does not match sent value");
             Channels[_lcCasenumber].ethAccountcreditsmap[0] = msg.value;
         }
         if(_balances[1] != 0) {
             Channels[_lcCasenumber].credential = HumanStandardCredential(_token);
             require(Channels[_lcCasenumber].credential.transferFrom(msg.sender, this, _balances[1]),"CreateChannel: token transfer failure");
             Channels[_lcCasenumber].erc20Accountcreditsmap[0] = _balances[1];
         }

         Channels[_lcCasenumber].sequence = 0;
         Channels[_lcCasenumber].confirmMoment = _confirmMoment;


         Channels[_lcCasenumber].LCopenTimeout = now + _confirmMoment;
         Channels[_lcCasenumber].initialSubmitpayment = _balances;

         emit DidLCOpen(_lcCasenumber, msg.sender, _partyI, _balances[0], _token, _balances[1], Channels[_lcCasenumber].LCopenTimeout);
     }

     function LCOpenTimeout(bytes32 _lcCasenumber) public {
         require(msg.sender == Channels[_lcCasenumber].partyAddresses[0] && Channels[_lcCasenumber].verifyOpen == false);
         require(now > Channels[_lcCasenumber].LCopenTimeout);

         if(Channels[_lcCasenumber].initialSubmitpayment[0] != 0) {
             Channels[_lcCasenumber].partyAddresses[0].transfer(Channels[_lcCasenumber].ethAccountcreditsmap[0]);
         }
         if(Channels[_lcCasenumber].initialSubmitpayment[1] != 0) {
             require(Channels[_lcCasenumber].credential.transfer(Channels[_lcCasenumber].partyAddresses[0], Channels[_lcCasenumber].erc20Accountcreditsmap[0]),"CreateChannel: token transfer failure");
         }

         emit DidLCClose(_lcCasenumber, 0, Channels[_lcCasenumber].ethAccountcreditsmap[0], Channels[_lcCasenumber].erc20Accountcreditsmap[0], 0, 0);


         delete Channels[_lcCasenumber];
     }

     function joinChannel(bytes32 _lcCasenumber, uint256[2] _balances) public payable {

         require(Channels[_lcCasenumber].verifyOpen == false);
         require(msg.sender == Channels[_lcCasenumber].partyAddresses[1]);

         if(_balances[0] != 0) {
             require(msg.value == _balances[0], "state balance does not match sent value");
             Channels[_lcCasenumber].ethAccountcreditsmap[1] = msg.value;
         }
         if(_balances[1] != 0) {
             require(Channels[_lcCasenumber].credential.transferFrom(msg.sender, this, _balances[1]),"joinChannel: token transfer failure");
             Channels[_lcCasenumber].erc20Accountcreditsmap[1] = _balances[1];
         }

         Channels[_lcCasenumber].initialSubmitpayment[0]+=_balances[0];
         Channels[_lcCasenumber].initialSubmitpayment[1]+=_balances[1];

         Channels[_lcCasenumber].verifyOpen = true;
         numChannels++;

         emit DidLCJoin(_lcCasenumber, _balances[0], _balances[1]);
     }


     function submitPayment(bytes32 _lcCasenumber, address beneficiary, uint256 _balance, bool isCredential) public payable {
         require(Channels[_lcCasenumber].verifyOpen == true, "Tried adding funds to a closed channel");
         require(beneficiary == Channels[_lcCasenumber].partyAddresses[0] || beneficiary == Channels[_lcCasenumber].partyAddresses[1]);


         if (Channels[_lcCasenumber].partyAddresses[0] == beneficiary) {
             if(isCredential) {
                 require(Channels[_lcCasenumber].credential.transferFrom(msg.sender, this, _balance),"deposit: token transfer failure");
                 Channels[_lcCasenumber].erc20Accountcreditsmap[2] += _balance;
             } else {
                 require(msg.value == _balance, "state balance does not match sent value");
                 Channels[_lcCasenumber].ethAccountcreditsmap[2] += msg.value;
             }
         }

         if (Channels[_lcCasenumber].partyAddresses[1] == beneficiary) {
             if(isCredential) {
                 require(Channels[_lcCasenumber].credential.transferFrom(msg.sender, this, _balance),"deposit: token transfer failure");
                 Channels[_lcCasenumber].erc20Accountcreditsmap[3] += _balance;
             } else {
                 require(msg.value == _balance, "state balance does not match sent value");
                 Channels[_lcCasenumber].ethAccountcreditsmap[3] += msg.value;
             }
         }

         emit DidLcSubmitpayment(_lcCasenumber, beneficiary, _balance, isCredential);
     }


     function consensusCloseChannel(
         bytes32 _lcCasenumber,
         uint256 _sequence,
         uint256[4] _balances,
         string _sigA,
         string _sigI
     )
         public
     {


         require(Channels[_lcCasenumber].verifyOpen == true);
         uint256 totalamountEthSubmitpayment = Channels[_lcCasenumber].initialSubmitpayment[0] + Channels[_lcCasenumber].ethAccountcreditsmap[2] + Channels[_lcCasenumber].ethAccountcreditsmap[3];
         uint256 totalamountCredentialSubmitpayment = Channels[_lcCasenumber].initialSubmitpayment[1] + Channels[_lcCasenumber].erc20Accountcreditsmap[2] + Channels[_lcCasenumber].erc20Accountcreditsmap[3];
         require(totalamountEthSubmitpayment == _balances[0] + _balances[1]);
         require(totalamountCredentialSubmitpayment == _balances[2] + _balances[3]);

         bytes32 _state = keccak256(
             abi.encodePacked(
                 _lcCasenumber,
                 true,
                 _sequence,
                 uint256(0),
                 bytes32(0x0),
                 Channels[_lcCasenumber].partyAddresses[0],
                 Channels[_lcCasenumber].partyAddresses[1],
                 _balances[0],
                 _balances[1],
                 _balances[2],
                 _balances[3]
             )
         );

         require(Channels[_lcCasenumber].partyAddresses[0] == ECTools.healSigner(_state, _sigA));
         require(Channels[_lcCasenumber].partyAddresses[1] == ECTools.healSigner(_state, _sigI));

         Channels[_lcCasenumber].verifyOpen = false;

         if(_balances[0] != 0 || _balances[1] != 0) {
             Channels[_lcCasenumber].partyAddresses[0].transfer(_balances[0]);
             Channels[_lcCasenumber].partyAddresses[1].transfer(_balances[1]);
         }

         if(_balances[2] != 0 || _balances[3] != 0) {
             require(Channels[_lcCasenumber].credential.transfer(Channels[_lcCasenumber].partyAddresses[0], _balances[2]),"happyCloseChannel: token transfer failure");
             require(Channels[_lcCasenumber].credential.transfer(Channels[_lcCasenumber].partyAddresses[1], _balances[3]),"happyCloseChannel: token transfer failure");
         }

         numChannels--;

         emit DidLCClose(_lcCasenumber, _sequence, _balances[0], _balances[1], _balances[2], _balances[3]);
     }


     function updaterecordsLCstate(
         bytes32 _lcCasenumber,
         uint256[6] updaterecordsParameters,
         bytes32 _VCroot,
         string _sigA,
         string _sigI
     )
         public
     {
         CommunicationChannel storage communicationChannel = Channels[_lcCasenumber];
         require(communicationChannel.verifyOpen);
         require(communicationChannel.sequence < updaterecordsParameters[0]);
         require(communicationChannel.ethAccountcreditsmap[0] + communicationChannel.ethAccountcreditsmap[1] >= updaterecordsParameters[2] + updaterecordsParameters[3]);
         require(communicationChannel.erc20Accountcreditsmap[0] + communicationChannel.erc20Accountcreditsmap[1] >= updaterecordsParameters[4] + updaterecordsParameters[5]);

         if(communicationChannel.isUpdaterecordsLcSettling == true) {
             require(communicationChannel.updaterecordsLCtimeout > now);
         }

         bytes32 _state = keccak256(
             abi.encodePacked(
                 _lcCasenumber,
                 false,
                 updaterecordsParameters[0],
                 updaterecordsParameters[1],
                 _VCroot,
                 communicationChannel.partyAddresses[0],
                 communicationChannel.partyAddresses[1],
                 updaterecordsParameters[2],
                 updaterecordsParameters[3],
                 updaterecordsParameters[4],
                 updaterecordsParameters[5]
             )
         );

         require(communicationChannel.partyAddresses[0] == ECTools.healSigner(_state, _sigA));
         require(communicationChannel.partyAddresses[1] == ECTools.healSigner(_state, _sigI));


         communicationChannel.sequence = updaterecordsParameters[0];
         communicationChannel.numOpenVC = updaterecordsParameters[1];
         communicationChannel.ethAccountcreditsmap[0] = updaterecordsParameters[2];
         communicationChannel.ethAccountcreditsmap[1] = updaterecordsParameters[3];
         communicationChannel.erc20Accountcreditsmap[0] = updaterecordsParameters[4];
         communicationChannel.erc20Accountcreditsmap[1] = updaterecordsParameters[5];
         communicationChannel.VCrootChecksum = _VCroot;
         communicationChannel.isUpdaterecordsLcSettling = true;
         communicationChannel.updaterecordsLCtimeout = now + communicationChannel.confirmMoment;


         emit DidLcUpdaterecordsCondition (
             _lcCasenumber,
             updaterecordsParameters[0],
             updaterecordsParameters[1],
             updaterecordsParameters[2],
             updaterecordsParameters[3],
             updaterecordsParameters[4],
             updaterecordsParameters[5],
             _VCroot,
             communicationChannel.updaterecordsLCtimeout
         );
     }


     function initializesystemVCstate(
         bytes32 _lcCasenumber,
         bytes32 _vcIdentifier,
         bytes _proof,
         address _partyA,
         address _partyB,
         uint256[2] _bond,
         uint256[4] _balances,
         string sigA
     )
         public
     {
         require(Channels[_lcCasenumber].verifyOpen, "LC is closed.");

         require(!virtualChannels[_vcIdentifier].validateClose, "VC is closed.");

         require(Channels[_lcCasenumber].updaterecordsLCtimeout < now, "LC timeout not over.");

         require(virtualChannels[_vcIdentifier].updaterecordsVCtimeout == 0);

         bytes32 _initializesystemCondition = keccak256(
             abi.encodePacked(_vcIdentifier, uint256(0), _partyA, _partyB, _bond[0], _bond[1], _balances[0], _balances[1], _balances[2], _balances[3])
         );


         require(_partyA == ECTools.healSigner(_initializesystemCondition, sigA));


         require(_isContained(_initializesystemCondition, _proof, Channels[_lcCasenumber].VCrootChecksum) == true);

         virtualChannels[_vcIdentifier].partyA = _partyA;
         virtualChannels[_vcIdentifier].partyB = _partyB;
         virtualChannels[_vcIdentifier].sequence = uint256(0);
         virtualChannels[_vcIdentifier].ethAccountcreditsmap[0] = _balances[0];
         virtualChannels[_vcIdentifier].ethAccountcreditsmap[1] = _balances[1];
         virtualChannels[_vcIdentifier].erc20Accountcreditsmap[0] = _balances[2];
         virtualChannels[_vcIdentifier].erc20Accountcreditsmap[1] = _balances[3];
         virtualChannels[_vcIdentifier].bond = _bond;
         virtualChannels[_vcIdentifier].updaterecordsVCtimeout = now + Channels[_lcCasenumber].confirmMoment;
         virtualChannels[_vcIdentifier].isInSettlementStatus = true;

         emit DidVcInitializesystem(_lcCasenumber, _vcIdentifier, _proof, uint256(0), _partyA, _partyB, _balances[0], _balances[1]);
     }


     function updatetleVC(
         bytes32 _lcCasenumber,
         bytes32 _vcIdentifier,
         uint256 updaterecordsSeq,
         address _partyA,
         address _partyB,
         uint256[4] updaterecordsBal,
         string sigA
     )
         public
     {
         require(Channels[_lcCasenumber].verifyOpen, "LC is closed.");

         require(!virtualChannels[_vcIdentifier].validateClose, "VC is closed.");
         require(virtualChannels[_vcIdentifier].sequence < updaterecordsSeq, "VC sequence is higher than update sequence.");
         require(
             virtualChannels[_vcIdentifier].ethAccountcreditsmap[1] < updaterecordsBal[1] && virtualChannels[_vcIdentifier].erc20Accountcreditsmap[1] < updaterecordsBal[3],
             "State updates may only increase recipient balance."
         );
         require(
             virtualChannels[_vcIdentifier].bond[0] == updaterecordsBal[0] + updaterecordsBal[1] &&
             virtualChannels[_vcIdentifier].bond[1] == updaterecordsBal[2] + updaterecordsBal[3],
             "Incorrect balances for bonded amount");


         require(Channels[_lcCasenumber].updaterecordsLCtimeout < now);

         bytes32 _updaterecordsCondition = keccak256(
             abi.encodePacked(
                 _vcIdentifier,
                 updaterecordsSeq,
                 _partyA,
                 _partyB,
                 virtualChannels[_vcIdentifier].bond[0],
                 virtualChannels[_vcIdentifier].bond[1],
                 updaterecordsBal[0],
                 updaterecordsBal[1],
                 updaterecordsBal[2],
                 updaterecordsBal[3]
             )
         );


         require(virtualChannels[_vcIdentifier].partyA == ECTools.healSigner(_updaterecordsCondition, sigA));


         virtualChannels[_vcIdentifier].challenger = msg.sender;
         virtualChannels[_vcIdentifier].sequence = updaterecordsSeq;


         virtualChannels[_vcIdentifier].ethAccountcreditsmap[0] = updaterecordsBal[0];
         virtualChannels[_vcIdentifier].ethAccountcreditsmap[1] = updaterecordsBal[1];
         virtualChannels[_vcIdentifier].erc20Accountcreditsmap[0] = updaterecordsBal[2];
         virtualChannels[_vcIdentifier].erc20Accountcreditsmap[1] = updaterecordsBal[3];

         virtualChannels[_vcIdentifier].updaterecordsVCtimeout = now + Channels[_lcCasenumber].confirmMoment;

         emit DidVCSettle(_lcCasenumber, _vcIdentifier, updaterecordsSeq, updaterecordsBal[0], updaterecordsBal[1], msg.sender, virtualChannels[_vcIdentifier].updaterecordsVCtimeout);
     }

     function closeVirtualChannel(bytes32 _lcCasenumber, bytes32 _vcIdentifier) public {

         require(Channels[_lcCasenumber].verifyOpen, "LC is closed.");
         require(virtualChannels[_vcIdentifier].isInSettlementStatus, "VC is not in settlement state.");
         require(virtualChannels[_vcIdentifier].updaterecordsVCtimeout < now, "Update vc timeout has not elapsed.");
         require(!virtualChannels[_vcIdentifier].validateClose, "VC is already closed");

         Channels[_lcCasenumber].numOpenVC--;

         virtualChannels[_vcIdentifier].validateClose = true;


         if(virtualChannels[_vcIdentifier].partyA == Channels[_lcCasenumber].partyAddresses[0]) {
             Channels[_lcCasenumber].ethAccountcreditsmap[0] += virtualChannels[_vcIdentifier].ethAccountcreditsmap[0];
             Channels[_lcCasenumber].ethAccountcreditsmap[1] += virtualChannels[_vcIdentifier].ethAccountcreditsmap[1];

             Channels[_lcCasenumber].erc20Accountcreditsmap[0] += virtualChannels[_vcIdentifier].erc20Accountcreditsmap[0];
             Channels[_lcCasenumber].erc20Accountcreditsmap[1] += virtualChannels[_vcIdentifier].erc20Accountcreditsmap[1];
         } else if (virtualChannels[_vcIdentifier].partyB == Channels[_lcCasenumber].partyAddresses[0]) {
             Channels[_lcCasenumber].ethAccountcreditsmap[0] += virtualChannels[_vcIdentifier].ethAccountcreditsmap[1];
             Channels[_lcCasenumber].ethAccountcreditsmap[1] += virtualChannels[_vcIdentifier].ethAccountcreditsmap[0];

             Channels[_lcCasenumber].erc20Accountcreditsmap[0] += virtualChannels[_vcIdentifier].erc20Accountcreditsmap[1];
             Channels[_lcCasenumber].erc20Accountcreditsmap[1] += virtualChannels[_vcIdentifier].erc20Accountcreditsmap[0];
         }

         emit DidVCClose(_lcCasenumber, _vcIdentifier, virtualChannels[_vcIdentifier].erc20Accountcreditsmap[0], virtualChannels[_vcIdentifier].erc20Accountcreditsmap[1]);
     }


     function byzantineCloseChannel(bytes32 _lcCasenumber) public {
         CommunicationChannel storage communicationChannel = Channels[_lcCasenumber];


         require(communicationChannel.verifyOpen, "Channel is not open");
         require(communicationChannel.isUpdaterecordsLcSettling == true);
         require(communicationChannel.numOpenVC == 0);
         require(communicationChannel.updaterecordsLCtimeout < now, "LC timeout over.");


         uint256 totalamountEthSubmitpayment = communicationChannel.initialSubmitpayment[0] + communicationChannel.ethAccountcreditsmap[2] + communicationChannel.ethAccountcreditsmap[3];
         uint256 totalamountCredentialSubmitpayment = communicationChannel.initialSubmitpayment[1] + communicationChannel.erc20Accountcreditsmap[2] + communicationChannel.erc20Accountcreditsmap[3];

         uint256 possibleTotalamountEthBeforeSubmitpayment = communicationChannel.ethAccountcreditsmap[0] + communicationChannel.ethAccountcreditsmap[1];
         uint256 possibleTotalamountCredentialBeforeSubmitpayment = communicationChannel.erc20Accountcreditsmap[0] + communicationChannel.erc20Accountcreditsmap[1];

         if(possibleTotalamountEthBeforeSubmitpayment < totalamountEthSubmitpayment) {
             communicationChannel.ethAccountcreditsmap[0]+=communicationChannel.ethAccountcreditsmap[2];
             communicationChannel.ethAccountcreditsmap[1]+=communicationChannel.ethAccountcreditsmap[3];
         } else {
             require(possibleTotalamountEthBeforeSubmitpayment == totalamountEthSubmitpayment);
         }

         if(possibleTotalamountCredentialBeforeSubmitpayment < totalamountCredentialSubmitpayment) {
             communicationChannel.erc20Accountcreditsmap[0]+=communicationChannel.erc20Accountcreditsmap[2];
             communicationChannel.erc20Accountcreditsmap[1]+=communicationChannel.erc20Accountcreditsmap[3];
         } else {
             require(possibleTotalamountCredentialBeforeSubmitpayment == totalamountCredentialSubmitpayment);
         }

         uint256 ethbalanceA = communicationChannel.ethAccountcreditsmap[0];
         uint256 ethbalanceI = communicationChannel.ethAccountcreditsmap[1];
         uint256 tokenbalanceA = communicationChannel.erc20Accountcreditsmap[0];
         uint256 tokenbalanceI = communicationChannel.erc20Accountcreditsmap[1];

         communicationChannel.ethAccountcreditsmap[0] = 0;
         communicationChannel.ethAccountcreditsmap[1] = 0;
         communicationChannel.erc20Accountcreditsmap[0] = 0;
         communicationChannel.erc20Accountcreditsmap[1] = 0;

         if(ethbalanceA != 0 || ethbalanceI != 0) {
             communicationChannel.partyAddresses[0].transfer(ethbalanceA);
             communicationChannel.partyAddresses[1].transfer(ethbalanceI);
         }

         if(tokenbalanceA != 0 || tokenbalanceI != 0) {
             require(
                 communicationChannel.credential.transfer(communicationChannel.partyAddresses[0], tokenbalanceA),
                 "byzantineCloseChannel: token transfer failure"
             );
             require(
                 communicationChannel.credential.transfer(communicationChannel.partyAddresses[1], tokenbalanceI),
                 "byzantineCloseChannel: token transfer failure"
             );
         }

         communicationChannel.verifyOpen = false;
         numChannels--;

         emit DidLCClose(_lcCasenumber, communicationChannel.sequence, ethbalanceA, ethbalanceI, tokenbalanceA, tokenbalanceI);
     }

     function _isContained(bytes32 _hash, bytes _proof, bytes32 _root) internal pure returns (bool) {
         bytes32 cursor = _hash;
         bytes32 evidenceElem;

         for (uint256 i = 64; i <= _proof.length; i += 32) {
             assembly { evidenceElem := mload(append(_proof, i)) }

             if (cursor < evidenceElem) {
                 cursor = keccak256(abi.encodePacked(cursor, evidenceElem));
             } else {
                 cursor = keccak256(abi.encodePacked(evidenceElem, cursor));
             }
         }

         return cursor == _root;
     }


     function obtainChannel(bytes32 id) public view returns (
         address[2],
         uint256[4],
         uint256[4],
         uint256[2],
         uint256,
         uint256,
         bytes32,
         uint256,
         uint256,
         bool,
         bool,
         uint256
     ) {
         CommunicationChannel memory communicationChannel = Channels[id];
         return (
             communicationChannel.partyAddresses,
             communicationChannel.ethAccountcreditsmap,
             communicationChannel.erc20Accountcreditsmap,
             communicationChannel.initialSubmitpayment,
             communicationChannel.sequence,
             communicationChannel.confirmMoment,
             communicationChannel.VCrootChecksum,
             communicationChannel.LCopenTimeout,
             communicationChannel.updaterecordsLCtimeout,
             communicationChannel.verifyOpen,
             communicationChannel.isUpdaterecordsLcSettling,
             communicationChannel.numOpenVC
         );
     }

     function acquireVirtualChannel(bytes32 id) public view returns(
         bool,
         bool,
         uint256,
         address,
         uint256,
         address,
         address,
         address,
         uint256[2],
         uint256[2],
         uint256[2]
     ) {
         VirtualChannel memory virtualChannel = virtualChannels[id];
         return(
             virtualChannel.validateClose,
             virtualChannel.isInSettlementStatus,
             virtualChannel.sequence,
             virtualChannel.challenger,
             virtualChannel.updaterecordsVCtimeout,
             virtualChannel.partyA,
             virtualChannel.partyB,
             virtualChannel.partyI,
             virtualChannel.ethAccountcreditsmap,
             virtualChannel.erc20Accountcreditsmap,
             virtualChannel.bond
         );
     }
 }