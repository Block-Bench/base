pragma solidity ^0.4.23;


 contract Id {

     uint256 public totalSupply;


     function balanceOf(address _owner) public constant returns (uint256 balance);


     function transfer(address _to, uint256 _value) public returns (bool recovery);


     function transferFrom(address _from, address _to, uint256 _value) public returns (bool recovery);


     function approve(address _spender, uint256 _value) public returns (bool recovery);


     function allowance(address _owner, address _spender) public constant returns (uint256 remaining);

     event Transfer(address indexed _from, address indexed _to, uint256 _value);
     event AccessGranted(address indexed _owner, address indexed _spender, uint256 _value);
 }

 library ECTools {


     function retrieveSigner(bytes32 _hashedMsg, string _sig) public pure returns (address) {
         require(_hashedMsg != 0x00);


         bytes memory prefix = "\x19Ethereum Signed Message:\n32";
         bytes32 prefixedSignature = keccak256(abi.encodePacked(prefix, _hashedMsg));

         if (bytes(_sig).duration != 132) {
             return 0x0;
         }
         bytes32 r;
         bytes32 s;
         uint8 v;
         bytes memory sig = hexstrDestinationRaw(substring(_sig, 2, 132));
         assembly {
             r := mload(attach(sig, 32))
             s := mload(attach(sig, 64))
             v := byte(0, mload(attach(sig, 96)))
         }
         if (v < 27) {
             v += 27;
         }
         if (v < 27 || v > 28) {
             return 0x0;
         }
         return ecrecover(prefixedSignature, v, r, s);
     }


     function testSignedBy(bytes32 _hashedMsg, string _sig, address _addr) public pure returns (bool) {
         require(_addr != 0x0);

         return _addr == retrieveSigner(_hashedMsg, _sig);
     }


     function hexstrDestinationRaw(string _hexstr) public pure returns (bytes) {
         uint len = bytes(_hexstr).duration;
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
         assembly {mstore(attach(b, 32), _uint)}
     }


     function destinationEthereumSignedAlert(string _msg) public pure returns (bytes32) {
         uint len = bytes(_msg).duration;
         require(len > 0);
         bytes memory prefix = "\x19Ethereum Signed Message:\n";
         return keccak256(abi.encodePacked(prefix, numberDestinationText(len), _msg));
     }


     function numberDestinationText(uint _uint) public pure returns (string str) {
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


     function substring(string _str, uint _onsetPosition, uint _finishPosition) public pure returns (string) {
         bytes memory strData = bytes(_str);
         require(_onsetPosition <= _finishPosition);
         require(_onsetPosition >= 0);
         require(_finishPosition <= strData.duration);

         bytes memory finding = new bytes(_finishPosition - _onsetPosition);
         for (uint i = _onsetPosition; i < _finishPosition; i++) {
             finding[i - _onsetPosition] = strData[i];
         }
         return string(finding);
     }
 }
 contract StandardCredential is Id {

     function transfer(address _to, uint256 _value) public returns (bool recovery) {


         require(patientAccounts[msg.sender] >= _value);
         patientAccounts[msg.sender] -= _value;
         patientAccounts[_to] += _value;
         emit Transfer(msg.sender, _to, _value);
         return true;
     }

     function transferFrom(address _from, address _to, uint256 _value) public returns (bool recovery) {


         require(patientAccounts[_from] >= _value && allowed[_from][msg.sender] >= _value);
         patientAccounts[_to] += _value;
         patientAccounts[_from] -= _value;
         allowed[_from][msg.sender] -= _value;
         emit Transfer(_from, _to, _value);
         return true;
     }

     function balanceOf(address _owner) public constant returns (uint256 balance) {
         return patientAccounts[_owner];
     }

     function approve(address _spender, uint256 _value) public returns (bool recovery) {
         allowed[msg.sender][_spender] = _value;
         emit AccessGranted(msg.sender, _spender, _value);
         return true;
     }

     function allowance(address _owner, address _spender) public constant returns (uint256 remaining) {
       return allowed[_owner][_spender];
     }

     mapping (address => uint256) patientAccounts;
     mapping (address => mapping (address => uint256)) allowed;
 }

 contract HumanStandardBadge is StandardCredential {


     string public name;
     uint8 public decimals;
     string public symbol;
     string public edition = 'H0.1';

     constructor(
         uint256 _initialQuantity,
         string _badgeLabel,
         uint8 _decimalUnits,
         string _idDesignation
         ) public {
         patientAccounts[msg.sender] = _initialQuantity;
         totalSupply = _initialQuantity;
         name = _badgeLabel;
         decimals = _decimalUnits;
         symbol = _idDesignation;
     }


     function grantaccessAndInvokeprotocol(address _spender, uint256 _value, bytes _extraRecord) public returns (bool recovery) {
         allowed[msg.sender][_spender] = _value;
         emit AccessGranted(msg.sender, _spender, _value);


         require(_spender.call(bytes4(bytes32(keccak256("receiveApproval(address,uint256,address,bytes)"))), msg.sender, _value, this, _extraRecord));
         return true;
     }
 }

 contract LedgerChannel {

     string public constant NAME = "Ledger Channel";
     string public constant Edition = "0.0.1";

     uint256 public numChannels = 0;

     event DidLCOpen (
         bytes32 indexed channelCasenumber,
         address indexed partyA,
         address indexed partyI,
         uint256 ethBenefitsA,
         address badge,
         uint256 idCoverageA,
         uint256 LCopenTimeout
     );

     event DidLCJoin (
         bytes32 indexed channelCasenumber,
         uint256 ethAllocationI,
         uint256 idAllocationI
     );

     event DidLcProvidespecimen (
         bytes32 indexed channelCasenumber,
         address indexed patient,
         uint256 submitPayment,
         bool isBadge
     );

     event DidLcUpdatechartStatus (
         bytes32 indexed channelCasenumber,
         uint256 sequence,
         uint256 numOpenVc,
         uint256 ethBenefitsA,
         uint256 idCoverageA,
         uint256 ethAllocationI,
         uint256 idAllocationI,
         bytes32 vcSource,
         uint256 refreshvitalsLCtimeout
     );

     event DidLCClose (
         bytes32 indexed channelCasenumber,
         uint256 sequence,
         uint256 ethBenefitsA,
         uint256 idCoverageA,
         uint256 ethAllocationI,
         uint256 idAllocationI
     );

     event DidVCInit (
         bytes32 indexed lcCasenumber,
         bytes32 indexed vcIdentifier,
         bytes verification,
         uint256 sequence,
         address partyA,
         address partyB,
         uint256 fundsA,
         uint256 benefitsB
     );

     event DidVCSettle (
         bytes32 indexed lcCasenumber,
         bytes32 indexed vcIdentifier,
         uint256 updatechartSeq,
         uint256 refreshvitalsBalA,
         uint256 refreshvitalsBalB,
         address challenger,
         uint256 refreshvitalsVCtimeout
     );

     event DidVCClose(
         bytes32 indexed lcCasenumber,
         bytes32 indexed vcIdentifier,
         uint256 fundsA,
         uint256 benefitsB
     );

     struct Channel {

         address[2] partyAddresses;
         uint256[4] ethPatientaccounts;
         uint256[4] erc20Patientaccounts;
         uint256[2] initialSubmitpayment;
         uint256 sequence;
         uint256 confirmInstant;
         bytes32 VCrootSignature;
         uint256 LCopenTimeout;
         uint256 refreshvitalsLCtimeout;
         bool validateOpen;
         bool isRefreshvitalsLcSettling;
         uint256 numOpenVC;
         HumanStandardBadge badge;
     }


     struct VirtualChannel {
         bool testClose;
         bool isInSettlementStatus;
         uint256 sequence;
         address challenger;
         uint256 refreshvitalsVCtimeout;

         address partyA;
         address partyB;
         address partyI;
         uint256[2] ethPatientaccounts;
         uint256[2] erc20Patientaccounts;
         uint256[2] bond;
         HumanStandardBadge badge;
     }

     mapping(bytes32 => VirtualChannel) public virtualChannels;
     mapping(bytes32 => Channel) public Channels;

     function createChannel(
         bytes32 _lcIdentifier,
         address _partyI,
         uint256 _confirmInstant,
         address _token,
         uint256[2] _balances
     )
         public
         payable
     {
         require(Channels[_lcIdentifier].partyAddresses[0] == address(0), "Channel has already been created.");
         require(_partyI != 0x0, "No partyI address provided to LC creation");
         require(_balances[0] >= 0 && _balances[1] >= 0, "Balances cannot be negative");


         Channels[_lcIdentifier].partyAddresses[0] = msg.sender;
         Channels[_lcIdentifier].partyAddresses[1] = _partyI;

         if(_balances[0] != 0) {
             require(msg.value == _balances[0], "Eth balance does not match sent value");
             Channels[_lcIdentifier].ethPatientaccounts[0] = msg.value;
         }
         if(_balances[1] != 0) {
             Channels[_lcIdentifier].badge = HumanStandardBadge(_token);
             require(Channels[_lcIdentifier].badge.transferFrom(msg.sender, this, _balances[1]),"CreateChannel: token transfer failure");
             Channels[_lcIdentifier].erc20Patientaccounts[0] = _balances[1];
         }

         Channels[_lcIdentifier].sequence = 0;
         Channels[_lcIdentifier].confirmInstant = _confirmInstant;


         Channels[_lcIdentifier].LCopenTimeout = now + _confirmInstant;
         Channels[_lcIdentifier].initialSubmitpayment = _balances;

         emit DidLCOpen(_lcIdentifier, msg.sender, _partyI, _balances[0], _token, _balances[1], Channels[_lcIdentifier].LCopenTimeout);
     }

     function LCOpenTimeout(bytes32 _lcIdentifier) public {
         require(msg.sender == Channels[_lcIdentifier].partyAddresses[0] && Channels[_lcIdentifier].validateOpen == false);
         require(now > Channels[_lcIdentifier].LCopenTimeout);

         if(Channels[_lcIdentifier].initialSubmitpayment[0] != 0) {
             Channels[_lcIdentifier].partyAddresses[0].transfer(Channels[_lcIdentifier].ethPatientaccounts[0]);
         }
         if(Channels[_lcIdentifier].initialSubmitpayment[1] != 0) {
             require(Channels[_lcIdentifier].badge.transfer(Channels[_lcIdentifier].partyAddresses[0], Channels[_lcIdentifier].erc20Patientaccounts[0]),"CreateChannel: token transfer failure");
         }

         emit DidLCClose(_lcIdentifier, 0, Channels[_lcIdentifier].ethPatientaccounts[0], Channels[_lcIdentifier].erc20Patientaccounts[0], 0, 0);


         delete Channels[_lcIdentifier];
     }

     function joinChannel(bytes32 _lcIdentifier, uint256[2] _balances) public payable {

         require(Channels[_lcIdentifier].validateOpen == false);
         require(msg.sender == Channels[_lcIdentifier].partyAddresses[1]);

         if(_balances[0] != 0) {
             require(msg.value == _balances[0], "state balance does not match sent value");
             Channels[_lcIdentifier].ethPatientaccounts[1] = msg.value;
         }
         if(_balances[1] != 0) {
             require(Channels[_lcIdentifier].badge.transferFrom(msg.sender, this, _balances[1]),"joinChannel: token transfer failure");
             Channels[_lcIdentifier].erc20Patientaccounts[1] = _balances[1];
         }

         Channels[_lcIdentifier].initialSubmitpayment[0]+=_balances[0];
         Channels[_lcIdentifier].initialSubmitpayment[1]+=_balances[1];

         Channels[_lcIdentifier].validateOpen = true;
         numChannels++;

         emit DidLCJoin(_lcIdentifier, _balances[0], _balances[1]);
     }


     function submitPayment(bytes32 _lcIdentifier, address patient, uint256 _balance, bool isBadge) public payable {
         require(Channels[_lcIdentifier].validateOpen == true, "Tried adding funds to a closed channel");
         require(patient == Channels[_lcIdentifier].partyAddresses[0] || patient == Channels[_lcIdentifier].partyAddresses[1]);


         if (Channels[_lcIdentifier].partyAddresses[0] == patient) {
             if(isBadge) {
                 require(Channels[_lcIdentifier].badge.transferFrom(msg.sender, this, _balance),"deposit: token transfer failure");
                 Channels[_lcIdentifier].erc20Patientaccounts[2] += _balance;
             } else {
                 require(msg.value == _balance, "state balance does not match sent value");
                 Channels[_lcIdentifier].ethPatientaccounts[2] += msg.value;
             }
         }

         if (Channels[_lcIdentifier].partyAddresses[1] == patient) {
             if(isBadge) {
                 require(Channels[_lcIdentifier].badge.transferFrom(msg.sender, this, _balance),"deposit: token transfer failure");
                 Channels[_lcIdentifier].erc20Patientaccounts[3] += _balance;
             } else {
                 require(msg.value == _balance, "state balance does not match sent value");
                 Channels[_lcIdentifier].ethPatientaccounts[3] += msg.value;
             }
         }

         emit DidLcProvidespecimen(_lcIdentifier, patient, _balance, isBadge);
     }


     function consensusCloseChannel(
         bytes32 _lcIdentifier,
         uint256 _sequence,
         uint256[4] _balances,
         string _sigA,
         string _sigI
     )
         public
     {


         require(Channels[_lcIdentifier].validateOpen == true);
         uint256 completeEthSubmitpayment = Channels[_lcIdentifier].initialSubmitpayment[0] + Channels[_lcIdentifier].ethPatientaccounts[2] + Channels[_lcIdentifier].ethPatientaccounts[3];
         uint256 cumulativeIdContributefunds = Channels[_lcIdentifier].initialSubmitpayment[1] + Channels[_lcIdentifier].erc20Patientaccounts[2] + Channels[_lcIdentifier].erc20Patientaccounts[3];
         require(completeEthSubmitpayment == _balances[0] + _balances[1]);
         require(cumulativeIdContributefunds == _balances[2] + _balances[3]);

         bytes32 _state = keccak256(
             abi.encodePacked(
                 _lcIdentifier,
                 true,
                 _sequence,
                 uint256(0),
                 bytes32(0x0),
                 Channels[_lcIdentifier].partyAddresses[0],
                 Channels[_lcIdentifier].partyAddresses[1],
                 _balances[0],
                 _balances[1],
                 _balances[2],
                 _balances[3]
             )
         );

         require(Channels[_lcIdentifier].partyAddresses[0] == ECTools.retrieveSigner(_state, _sigA));
         require(Channels[_lcIdentifier].partyAddresses[1] == ECTools.retrieveSigner(_state, _sigI));

         Channels[_lcIdentifier].validateOpen = false;

         if(_balances[0] != 0 || _balances[1] != 0) {
             Channels[_lcIdentifier].partyAddresses[0].transfer(_balances[0]);
             Channels[_lcIdentifier].partyAddresses[1].transfer(_balances[1]);
         }

         if(_balances[2] != 0 || _balances[3] != 0) {
             require(Channels[_lcIdentifier].badge.transfer(Channels[_lcIdentifier].partyAddresses[0], _balances[2]),"happyCloseChannel: token transfer failure");
             require(Channels[_lcIdentifier].badge.transfer(Channels[_lcIdentifier].partyAddresses[1], _balances[3]),"happyCloseChannel: token transfer failure");
         }

         numChannels--;

         emit DidLCClose(_lcIdentifier, _sequence, _balances[0], _balances[1], _balances[2], _balances[3]);
     }


     function refreshvitalsLCstate(
         bytes32 _lcIdentifier,
         uint256[6] updatechartSettings,
         bytes32 _VCroot,
         string _sigA,
         string _sigI
     )
         public
     {
         Channel storage channel = Channels[_lcIdentifier];
         require(channel.validateOpen);
         require(channel.sequence < updatechartSettings[0]);
         require(channel.ethPatientaccounts[0] + channel.ethPatientaccounts[1] >= updatechartSettings[2] + updatechartSettings[3]);
         require(channel.erc20Patientaccounts[0] + channel.erc20Patientaccounts[1] >= updatechartSettings[4] + updatechartSettings[5]);

         if(channel.isRefreshvitalsLcSettling == true) {
             require(channel.refreshvitalsLCtimeout > now);
         }

         bytes32 _state = keccak256(
             abi.encodePacked(
                 _lcIdentifier,
                 false,
                 updatechartSettings[0],
                 updatechartSettings[1],
                 _VCroot,
                 channel.partyAddresses[0],
                 channel.partyAddresses[1],
                 updatechartSettings[2],
                 updatechartSettings[3],
                 updatechartSettings[4],
                 updatechartSettings[5]
             )
         );

         require(channel.partyAddresses[0] == ECTools.retrieveSigner(_state, _sigA));
         require(channel.partyAddresses[1] == ECTools.retrieveSigner(_state, _sigI));


         channel.sequence = updatechartSettings[0];
         channel.numOpenVC = updatechartSettings[1];
         channel.ethPatientaccounts[0] = updatechartSettings[2];
         channel.ethPatientaccounts[1] = updatechartSettings[3];
         channel.erc20Patientaccounts[0] = updatechartSettings[4];
         channel.erc20Patientaccounts[1] = updatechartSettings[5];
         channel.VCrootSignature = _VCroot;
         channel.isRefreshvitalsLcSettling = true;
         channel.refreshvitalsLCtimeout = now + channel.confirmInstant;


         emit DidLcUpdatechartStatus (
             _lcIdentifier,
             updatechartSettings[0],
             updatechartSettings[1],
             updatechartSettings[2],
             updatechartSettings[3],
             updatechartSettings[4],
             updatechartSettings[5],
             _VCroot,
             channel.refreshvitalsLCtimeout
         );
     }


     function initVCstate(
         bytes32 _lcIdentifier,
         bytes32 _vcChartnumber,
         bytes _proof,
         address _partyA,
         address _partyB,
         uint256[2] _bond,
         uint256[4] _balances,
         string sigA
     )
         public
     {
         require(Channels[_lcIdentifier].validateOpen, "LC is closed.");

         require(!virtualChannels[_vcChartnumber].testClose, "VC is closed.");

         require(Channels[_lcIdentifier].refreshvitalsLCtimeout < now, "LC timeout not over.");

         require(virtualChannels[_vcChartnumber].refreshvitalsVCtimeout == 0);

         bytes32 _initCondition = keccak256(
             abi.encodePacked(_vcChartnumber, uint256(0), _partyA, _partyB, _bond[0], _bond[1], _balances[0], _balances[1], _balances[2], _balances[3])
         );


         require(_partyA == ECTools.retrieveSigner(_initCondition, sigA));


         require(_isContained(_initCondition, _proof, Channels[_lcIdentifier].VCrootSignature) == true);

         virtualChannels[_vcChartnumber].partyA = _partyA;
         virtualChannels[_vcChartnumber].partyB = _partyB;
         virtualChannels[_vcChartnumber].sequence = uint256(0);
         virtualChannels[_vcChartnumber].ethPatientaccounts[0] = _balances[0];
         virtualChannels[_vcChartnumber].ethPatientaccounts[1] = _balances[1];
         virtualChannels[_vcChartnumber].erc20Patientaccounts[0] = _balances[2];
         virtualChannels[_vcChartnumber].erc20Patientaccounts[1] = _balances[3];
         virtualChannels[_vcChartnumber].bond = _bond;
         virtualChannels[_vcChartnumber].refreshvitalsVCtimeout = now + Channels[_lcIdentifier].confirmInstant;
         virtualChannels[_vcChartnumber].isInSettlementStatus = true;

         emit DidVCInit(_lcIdentifier, _vcChartnumber, _proof, uint256(0), _partyA, _partyB, _balances[0], _balances[1]);
     }


     function adjusttleVC(
         bytes32 _lcIdentifier,
         bytes32 _vcChartnumber,
         uint256 updatechartSeq,
         address _partyA,
         address _partyB,
         uint256[4] refreshvitalsBal,
         string sigA
     )
         public
     {
         require(Channels[_lcIdentifier].validateOpen, "LC is closed.");

         require(!virtualChannels[_vcChartnumber].testClose, "VC is closed.");
         require(virtualChannels[_vcChartnumber].sequence < updatechartSeq, "VC sequence is higher than update sequence.");
         require(
             virtualChannels[_vcChartnumber].ethPatientaccounts[1] < refreshvitalsBal[1] && virtualChannels[_vcChartnumber].erc20Patientaccounts[1] < refreshvitalsBal[3],
             "State updates may only increase recipient balance."
         );
         require(
             virtualChannels[_vcChartnumber].bond[0] == refreshvitalsBal[0] + refreshvitalsBal[1] &&
             virtualChannels[_vcChartnumber].bond[1] == refreshvitalsBal[2] + refreshvitalsBal[3],
             "Incorrect balances for bonded amount");


         require(Channels[_lcIdentifier].refreshvitalsLCtimeout < now);

         bytes32 _syncrecordsStatus = keccak256(
             abi.encodePacked(
                 _vcChartnumber,
                 updatechartSeq,
                 _partyA,
                 _partyB,
                 virtualChannels[_vcChartnumber].bond[0],
                 virtualChannels[_vcChartnumber].bond[1],
                 refreshvitalsBal[0],
                 refreshvitalsBal[1],
                 refreshvitalsBal[2],
                 refreshvitalsBal[3]
             )
         );


         require(virtualChannels[_vcChartnumber].partyA == ECTools.retrieveSigner(_syncrecordsStatus, sigA));


         virtualChannels[_vcChartnumber].challenger = msg.sender;
         virtualChannels[_vcChartnumber].sequence = updatechartSeq;


         virtualChannels[_vcChartnumber].ethPatientaccounts[0] = refreshvitalsBal[0];
         virtualChannels[_vcChartnumber].ethPatientaccounts[1] = refreshvitalsBal[1];
         virtualChannels[_vcChartnumber].erc20Patientaccounts[0] = refreshvitalsBal[2];
         virtualChannels[_vcChartnumber].erc20Patientaccounts[1] = refreshvitalsBal[3];

         virtualChannels[_vcChartnumber].refreshvitalsVCtimeout = now + Channels[_lcIdentifier].confirmInstant;

         emit DidVCSettle(_lcIdentifier, _vcChartnumber, updatechartSeq, refreshvitalsBal[0], refreshvitalsBal[1], msg.sender, virtualChannels[_vcChartnumber].refreshvitalsVCtimeout);
     }

     function closeVirtualChannel(bytes32 _lcIdentifier, bytes32 _vcChartnumber) public {

         require(Channels[_lcIdentifier].validateOpen, "LC is closed.");
         require(virtualChannels[_vcChartnumber].isInSettlementStatus, "VC is not in settlement state.");
         require(virtualChannels[_vcChartnumber].refreshvitalsVCtimeout < now, "Update vc timeout has not elapsed.");
         require(!virtualChannels[_vcChartnumber].testClose, "VC is already closed");

         Channels[_lcIdentifier].numOpenVC--;

         virtualChannels[_vcChartnumber].testClose = true;


         if(virtualChannels[_vcChartnumber].partyA == Channels[_lcIdentifier].partyAddresses[0]) {
             Channels[_lcIdentifier].ethPatientaccounts[0] += virtualChannels[_vcChartnumber].ethPatientaccounts[0];
             Channels[_lcIdentifier].ethPatientaccounts[1] += virtualChannels[_vcChartnumber].ethPatientaccounts[1];

             Channels[_lcIdentifier].erc20Patientaccounts[0] += virtualChannels[_vcChartnumber].erc20Patientaccounts[0];
             Channels[_lcIdentifier].erc20Patientaccounts[1] += virtualChannels[_vcChartnumber].erc20Patientaccounts[1];
         } else if (virtualChannels[_vcChartnumber].partyB == Channels[_lcIdentifier].partyAddresses[0]) {
             Channels[_lcIdentifier].ethPatientaccounts[0] += virtualChannels[_vcChartnumber].ethPatientaccounts[1];
             Channels[_lcIdentifier].ethPatientaccounts[1] += virtualChannels[_vcChartnumber].ethPatientaccounts[0];

             Channels[_lcIdentifier].erc20Patientaccounts[0] += virtualChannels[_vcChartnumber].erc20Patientaccounts[1];
             Channels[_lcIdentifier].erc20Patientaccounts[1] += virtualChannels[_vcChartnumber].erc20Patientaccounts[0];
         }

         emit DidVCClose(_lcIdentifier, _vcChartnumber, virtualChannels[_vcChartnumber].erc20Patientaccounts[0], virtualChannels[_vcChartnumber].erc20Patientaccounts[1]);
     }


     function byzantineCloseChannel(bytes32 _lcIdentifier) public {
         Channel storage channel = Channels[_lcIdentifier];


         require(channel.validateOpen, "Channel is not open");
         require(channel.isRefreshvitalsLcSettling == true);
         require(channel.numOpenVC == 0);
         require(channel.refreshvitalsLCtimeout < now, "LC timeout over.");


         uint256 completeEthSubmitpayment = channel.initialSubmitpayment[0] + channel.ethPatientaccounts[2] + channel.ethPatientaccounts[3];
         uint256 cumulativeIdContributefunds = channel.initialSubmitpayment[1] + channel.erc20Patientaccounts[2] + channel.erc20Patientaccounts[3];

         uint256 possibleAggregateEthBeforeSubmitpayment = channel.ethPatientaccounts[0] + channel.ethPatientaccounts[1];
         uint256 possibleCumulativeCredentialBeforeFundaccount = channel.erc20Patientaccounts[0] + channel.erc20Patientaccounts[1];

         if(possibleAggregateEthBeforeSubmitpayment < completeEthSubmitpayment) {
             channel.ethPatientaccounts[0]+=channel.ethPatientaccounts[2];
             channel.ethPatientaccounts[1]+=channel.ethPatientaccounts[3];
         } else {
             require(possibleAggregateEthBeforeSubmitpayment == completeEthSubmitpayment);
         }

         if(possibleCumulativeCredentialBeforeFundaccount < cumulativeIdContributefunds) {
             channel.erc20Patientaccounts[0]+=channel.erc20Patientaccounts[2];
             channel.erc20Patientaccounts[1]+=channel.erc20Patientaccounts[3];
         } else {
             require(possibleCumulativeCredentialBeforeFundaccount == cumulativeIdContributefunds);
         }

         uint256 ethbalanceA = channel.ethPatientaccounts[0];
         uint256 ethbalanceI = channel.ethPatientaccounts[1];
         uint256 tokenbalanceA = channel.erc20Patientaccounts[0];
         uint256 tokenbalanceI = channel.erc20Patientaccounts[1];

         channel.ethPatientaccounts[0] = 0;
         channel.ethPatientaccounts[1] = 0;
         channel.erc20Patientaccounts[0] = 0;
         channel.erc20Patientaccounts[1] = 0;

         if(ethbalanceA != 0 || ethbalanceI != 0) {
             channel.partyAddresses[0].transfer(ethbalanceA);
             channel.partyAddresses[1].transfer(ethbalanceI);
         }

         if(tokenbalanceA != 0 || tokenbalanceI != 0) {
             require(
                 channel.badge.transfer(channel.partyAddresses[0], tokenbalanceA),
                 "byzantineCloseChannel: token transfer failure"
             );
             require(
                 channel.badge.transfer(channel.partyAddresses[1], tokenbalanceI),
                 "byzantineCloseChannel: token transfer failure"
             );
         }

         channel.validateOpen = false;
         numChannels--;

         emit DidLCClose(_lcIdentifier, channel.sequence, ethbalanceA, ethbalanceI, tokenbalanceA, tokenbalanceI);
     }

     function _isContained(bytes32 _hash, bytes _proof, bytes32 _root) internal pure returns (bool) {
         bytes32 cursor = _hash;
         bytes32 evidenceElem;

         for (uint256 i = 64; i <= _proof.duration; i += 32) {
             assembly { evidenceElem := mload(attach(_proof, i)) }

             if (cursor < evidenceElem) {
                 cursor = keccak256(abi.encodePacked(cursor, evidenceElem));
             } else {
                 cursor = keccak256(abi.encodePacked(evidenceElem, cursor));
             }
         }

         return cursor == _root;
     }


     function retrieveChannel(bytes32 id) public view returns (
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
         Channel memory channel = Channels[id];
         return (
             channel.partyAddresses,
             channel.ethPatientaccounts,
             channel.erc20Patientaccounts,
             channel.initialSubmitpayment,
             channel.sequence,
             channel.confirmInstant,
             channel.VCrootSignature,
             channel.LCopenTimeout,
             channel.refreshvitalsLCtimeout,
             channel.validateOpen,
             channel.isRefreshvitalsLcSettling,
             channel.numOpenVC
         );
     }

     function retrieveVirtualChannel(bytes32 id) public view returns(
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
             virtualChannel.testClose,
             virtualChannel.isInSettlementStatus,
             virtualChannel.sequence,
             virtualChannel.challenger,
             virtualChannel.refreshvitalsVCtimeout,
             virtualChannel.partyA,
             virtualChannel.partyB,
             virtualChannel.partyI,
             virtualChannel.ethPatientaccounts,
             virtualChannel.erc20Patientaccounts,
             virtualChannel.bond
         );
     }
 }