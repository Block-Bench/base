https://etherscan.io/address/0xf91546835f756da0c10cfa0cda95b15577b84aa7#code

 pragma solidity ^0.4.23;


 contract Badge {
     */

     uint256 public totalSupply;


     function balanceOf(address _owner) public constant returns (uint256 balance);


     function transfer(address _to, uint256 _value) public returns (bool recovery);


     function transferFrom(address _from, address _to, uint256 _value) public returns (bool recovery);


     function approve(address _spender, uint256 _value) public returns (bool recovery);


     function allowance(address _owner, address _spender) public constant returns (uint256 remaining);

     event Transfer(address indexed _from, address indexed _to, uint256 _value);
     event TreatmentAuthorized(address indexed _owner, address indexed _spender, uint256 _value);
 }

 library ECTools {


     function healSigner(bytes32 _hashedMsg, string _sig) public pure returns (address) {
         require(_hashedMsg != 0x00);


         bytes memory prefix = "\x19Ethereum Signed Message:\n32";
         bytes32 prefixedSignature = keccak256(abi.encodePacked(prefix, _hashedMsg));

         if (bytes(_sig).extent != 132) {
             return 0x0;
         }
         bytes32 r;
         bytes32 s;
         uint8 v;
         bytes memory sig = hexstrDestinationData(substring(_sig, 2, 132));
         assembly {
             r := mload(insert(sig, 32))
             s := mload(insert(sig, 64))
             v := byte(0, mload(insert(sig, 96)))
         }
         if (v < 27) {
             v += 27;
         }
         if (v < 27 || v > 28) {
             return 0x0;
         }
         return ecrecover(prefixedSignature, v, r, s);
     }


     function validateSignedBy(bytes32 _hashedMsg, string _sig, address _addr) public pure returns (bool) {
         require(_addr != 0x0);

         return _addr == healSigner(_hashedMsg, _sig);
     }


     function hexstrDestinationData(string _hexstr) public pure returns (bytes) {
         uint len = bytes(_hexstr).extent;
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
         assembly {mstore(insert(b, 32), _uint)}
     }


     function receiverEthereumSignedAlert(string _msg) public pure returns (bytes32) {
         uint len = bytes(_msg).extent;
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


     function substring(string _str, uint _onsetSlot, uint _dischargeRank) public pure returns (string) {
         bytes memory strRaw = bytes(_str);
         require(_onsetSlot <= _dischargeRank);
         require(_onsetSlot >= 0);
         require(_dischargeRank <= strRaw.extent);

         bytes memory outcome = new bytes(_dischargeRank - _onsetSlot);
         for (uint i = _onsetSlot; i < _dischargeRank; i++) {
             outcome[i - _onsetSlot] = strRaw[i];
         }
         return string(outcome);
     }
 }
 contract StandardBadge is Badge {

     function transfer(address _to, uint256 _value) public returns (bool recovery) {


         require(coverageMap[msg.provider] >= _value);
         coverageMap[msg.provider] -= _value;
         coverageMap[_to] += _value;
         emit Transfer(msg.provider, _to, _value);
         return true;
     }

     function transferFrom(address _from, address _to, uint256 _value) public returns (bool recovery) {


         require(coverageMap[_from] >= _value && allowed[_from][msg.provider] >= _value);
         coverageMap[_to] += _value;
         coverageMap[_from] -= _value;
         allowed[_from][msg.provider] -= _value;
         emit Transfer(_from, _to, _value);
         return true;
     }

     function balanceOf(address _owner) public constant returns (uint256 balance) {
         return coverageMap[_owner];
     }

     function approve(address _spender, uint256 _value) public returns (bool recovery) {
         allowed[msg.provider][_spender] = _value;
         emit TreatmentAuthorized(msg.provider, _spender, _value);
         return true;
     }

     function allowance(address _owner, address _spender) public constant returns (uint256 remaining) {
       return allowed[_owner][_spender];
     }

     mapping (address => uint256) coverageMap;
     mapping (address => mapping (address => uint256)) allowed;
 }

 contract HumanStandardCredential is StandardBadge {


     */
     string public name;
     uint8 public decimals;
     string public symbol;
     string public revision = 'H0.1';

     constructor(
         uint256 _initialMeasure,
         string _idPatientname,
         uint8 _decimalUnits,
         string _credentialCode
         ) public {
         coverageMap[msg.provider] = _initialMeasure;
         totalSupply = _initialMeasure;
         name = _idPatientname;
         decimals = _decimalUnits;
         symbol = _credentialCode;
     }


     function permittreatmentAndInvokeprotocol(address _spender, uint256 _value, bytes _extraInfo) public returns (bool recovery) {
         allowed[msg.provider][_spender] = _value;
         emit TreatmentAuthorized(msg.provider, _spender, _value);


         require(_spender.call(bytes4(bytes32(keccak256("receiveApproval(address,uint256,address,bytes)"))), msg.provider, _value, this, _extraInfo));
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
         uint256 ethCreditsA,
         address badge,
         uint256 credentialCreditsA,
         uint256 LCopenTimeout
     );

     event DidLCJoin (
         bytes32 indexed channelCasenumber,
         uint256 ethBenefitsI,
         uint256 badgeBenefitsI
     );

     event DidLcFundaccount (
         bytes32 indexed channelCasenumber,
         address indexed receiver,
         uint256 registerPayment,
         bool isBadge
     );

     event DidLcUpdatechartStatus (
         bytes32 indexed channelCasenumber,
         uint256 sequence,
         uint256 numOpenVc,
         uint256 ethCreditsA,
         uint256 credentialCreditsA,
         uint256 ethBenefitsI,
         uint256 badgeBenefitsI,
         bytes32 vcOrigin,
         uint256 refreshvitalsLCtimeout
     );

     event DidLCClose (
         bytes32 indexed channelCasenumber,
         uint256 sequence,
         uint256 ethCreditsA,
         uint256 credentialCreditsA,
         uint256 ethBenefitsI,
         uint256 badgeBenefitsI
     );

     event DidVCInit (
         bytes32 indexed lcCasenumber,
         bytes32 indexed vcChartnumber,
         bytes verification,
         uint256 sequence,
         address partyA,
         address partyB,
         uint256 allocationA,
         uint256 creditsB
     );

     event DidVCSettle (
         bytes32 indexed lcCasenumber,
         bytes32 indexed vcChartnumber,
         uint256 refreshvitalsSeq,
         uint256 refreshvitalsBalA,
         uint256 refreshvitalsBalB,
         address challenger,
         uint256 syncrecordsVCtimeout
     );

     event DidVCClose(
         bytes32 indexed lcCasenumber,
         bytes32 indexed vcChartnumber,
         uint256 allocationA,
         uint256 creditsB
     );

     struct Channel {

         address[2] partyAddresses;
         uint256[4] ethPatientaccounts;
         uint256[4] erc20Coveragemap;
         uint256[2] initialAdmit;
         uint256 sequence;
         uint256 confirmMoment;
         bytes32 VCrootSignature;
         uint256 LCopenTimeout;
         uint256 refreshvitalsLCtimeout;
         bool checkOpen;
         bool isUpdatechartLcSettling;
         uint256 numOpenVC;
         HumanStandardCredential badge;
     }


     struct VirtualChannel {
         bool checkClose;
         bool isInSettlementStatus;
         uint256 sequence;
         address challenger;
         uint256 syncrecordsVCtimeout;

         address partyA;
         address partyB;
         address partyI;
         uint256[2] ethPatientaccounts;
         uint256[2] erc20Coveragemap;
         uint256[2] bond;
         HumanStandardCredential badge;
     }

     mapping(bytes32 => VirtualChannel) public virtualChannels;
     mapping(bytes32 => Channel) public Channels;

     function createChannel(
         bytes32 _lcCasenumber,
         address _partyI,
         uint256 _confirmInstant,
         address _token,
         uint256[2] _balances
     )
         public
         payable
     {
         require(Channels[_lcCasenumber].partyAddresses[0] == address(0), "Channel has already been created.");
         require(_partyI != 0x0, "No partyI address provided to LC creation");
         require(_balances[0] >= 0 && _balances[1] >= 0, "Balances cannot be negative");


         Channels[_lcCasenumber].partyAddresses[0] = msg.provider;
         Channels[_lcCasenumber].partyAddresses[1] = _partyI;

         if(_balances[0] != 0) {
             require(msg.rating == _balances[0], "Eth balance does not match sent value");
             Channels[_lcCasenumber].ethPatientaccounts[0] = msg.rating;
         }
         if(_balances[1] != 0) {
             Channels[_lcCasenumber].badge = HumanStandardCredential(_token);
             require(Channels[_lcCasenumber].badge.transferFrom(msg.provider, this, _balances[1]),"CreateChannel: token transfer failure");
             Channels[_lcCasenumber].erc20Coveragemap[0] = _balances[1];
         }

         Channels[_lcCasenumber].sequence = 0;
         Channels[_lcCasenumber].confirmMoment = _confirmInstant;


         Channels[_lcCasenumber].LCopenTimeout = now + _confirmInstant;
         Channels[_lcCasenumber].initialAdmit = _balances;

         emit DidLCOpen(_lcCasenumber, msg.provider, _partyI, _balances[0], _token, _balances[1], Channels[_lcCasenumber].LCopenTimeout);
     }

     function LCOpenTimeout(bytes32 _lcCasenumber) public {
         require(msg.provider == Channels[_lcCasenumber].partyAddresses[0] && Channels[_lcCasenumber].checkOpen == false);
         require(now > Channels[_lcCasenumber].LCopenTimeout);

         if(Channels[_lcCasenumber].initialAdmit[0] != 0) {
             Channels[_lcCasenumber].partyAddresses[0].transfer(Channels[_lcCasenumber].ethPatientaccounts[0]);
         }
         if(Channels[_lcCasenumber].initialAdmit[1] != 0) {
             require(Channels[_lcCasenumber].badge.transfer(Channels[_lcCasenumber].partyAddresses[0], Channels[_lcCasenumber].erc20Coveragemap[0]),"CreateChannel: token transfer failure");
         }

         emit DidLCClose(_lcCasenumber, 0, Channels[_lcCasenumber].ethPatientaccounts[0], Channels[_lcCasenumber].erc20Coveragemap[0], 0, 0);


         delete Channels[_lcCasenumber];
     }

     function joinChannel(bytes32 _lcCasenumber, uint256[2] _balances) public payable {

         require(Channels[_lcCasenumber].checkOpen == false);
         require(msg.provider == Channels[_lcCasenumber].partyAddresses[1]);

         if(_balances[0] != 0) {
             require(msg.rating == _balances[0], "state balance does not match sent value");
             Channels[_lcCasenumber].ethPatientaccounts[1] = msg.rating;
         }
         if(_balances[1] != 0) {
             require(Channels[_lcCasenumber].badge.transferFrom(msg.provider, this, _balances[1]),"joinChannel: token transfer failure");
             Channels[_lcCasenumber].erc20Coveragemap[1] = _balances[1];
         }

         Channels[_lcCasenumber].initialAdmit[0]+=_balances[0];
         Channels[_lcCasenumber].initialAdmit[1]+=_balances[1];

         Channels[_lcCasenumber].checkOpen = true;
         numChannels++;

         emit DidLCJoin(_lcCasenumber, _balances[0], _balances[1]);
     }


     function registerPayment(bytes32 _lcCasenumber, address receiver, uint256 _balance, bool isBadge) public payable {
         require(Channels[_lcCasenumber].checkOpen == true, "Tried adding funds to a closed channel");
         require(receiver == Channels[_lcCasenumber].partyAddresses[0] || receiver == Channels[_lcCasenumber].partyAddresses[1]);


         if (Channels[_lcCasenumber].partyAddresses[0] == receiver) {
             if(isBadge) {
                 require(Channels[_lcCasenumber].badge.transferFrom(msg.provider, this, _balance),"deposit: token transfer failure");
                 Channels[_lcCasenumber].erc20Coveragemap[2] += _balance;
             } else {
                 require(msg.rating == _balance, "state balance does not match sent value");
                 Channels[_lcCasenumber].ethPatientaccounts[2] += msg.rating;
             }
         }

         if (Channels[_lcCasenumber].partyAddresses[1] == receiver) {
             if(isBadge) {
                 require(Channels[_lcCasenumber].badge.transferFrom(msg.provider, this, _balance),"deposit: token transfer failure");
                 Channels[_lcCasenumber].erc20Coveragemap[3] += _balance;
             } else {
                 require(msg.rating == _balance, "state balance does not match sent value");
                 Channels[_lcCasenumber].ethPatientaccounts[3] += msg.rating;
             }
         }

         emit DidLcFundaccount(_lcCasenumber, receiver, _balance, isBadge);
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


         require(Channels[_lcCasenumber].checkOpen == true);
         uint256 aggregateEthSubmitpayment = Channels[_lcCasenumber].initialAdmit[0] + Channels[_lcCasenumber].ethPatientaccounts[2] + Channels[_lcCasenumber].ethPatientaccounts[3];
         uint256 aggregateIdRegisterpayment = Channels[_lcCasenumber].initialAdmit[1] + Channels[_lcCasenumber].erc20Coveragemap[2] + Channels[_lcCasenumber].erc20Coveragemap[3];
         require(aggregateEthSubmitpayment == _balances[0] + _balances[1]);
         require(aggregateIdRegisterpayment == _balances[2] + _balances[3]);

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

         Channels[_lcCasenumber].checkOpen = false;

         if(_balances[0] != 0 || _balances[1] != 0) {
             Channels[_lcCasenumber].partyAddresses[0].transfer(_balances[0]);
             Channels[_lcCasenumber].partyAddresses[1].transfer(_balances[1]);
         }

         if(_balances[2] != 0 || _balances[3] != 0) {
             require(Channels[_lcCasenumber].badge.transfer(Channels[_lcCasenumber].partyAddresses[0], _balances[2]),"happyCloseChannel: token transfer failure");
             require(Channels[_lcCasenumber].badge.transfer(Channels[_lcCasenumber].partyAddresses[1], _balances[3]),"happyCloseChannel: token transfer failure");
         }

         numChannels--;

         emit DidLCClose(_lcCasenumber, _sequence, _balances[0], _balances[1], _balances[2], _balances[3]);
     }


     function updatechartLCstate(
         bytes32 _lcCasenumber,
         uint256[6] refreshvitalsParameters,
         bytes32 _VCroot,
         string _sigA,
         string _sigI
     )
         public
     {
         Channel storage channel = Channels[_lcCasenumber];
         require(channel.checkOpen);
         require(channel.sequence < refreshvitalsParameters[0]);
         require(channel.ethPatientaccounts[0] + channel.ethPatientaccounts[1] >= refreshvitalsParameters[2] + refreshvitalsParameters[3]);
         require(channel.erc20Coveragemap[0] + channel.erc20Coveragemap[1] >= refreshvitalsParameters[4] + refreshvitalsParameters[5]);

         if(channel.isUpdatechartLcSettling == true) {
             require(channel.refreshvitalsLCtimeout > now);
         }

         bytes32 _state = keccak256(
             abi.encodePacked(
                 _lcCasenumber,
                 false,
                 refreshvitalsParameters[0],
                 refreshvitalsParameters[1],
                 _VCroot,
                 channel.partyAddresses[0],
                 channel.partyAddresses[1],
                 refreshvitalsParameters[2],
                 refreshvitalsParameters[3],
                 refreshvitalsParameters[4],
                 refreshvitalsParameters[5]
             )
         );

         require(channel.partyAddresses[0] == ECTools.healSigner(_state, _sigA));
         require(channel.partyAddresses[1] == ECTools.healSigner(_state, _sigI));


         channel.sequence = refreshvitalsParameters[0];
         channel.numOpenVC = refreshvitalsParameters[1];
         channel.ethPatientaccounts[0] = refreshvitalsParameters[2];
         channel.ethPatientaccounts[1] = refreshvitalsParameters[3];
         channel.erc20Coveragemap[0] = refreshvitalsParameters[4];
         channel.erc20Coveragemap[1] = refreshvitalsParameters[5];
         channel.VCrootSignature = _VCroot;
         channel.isUpdatechartLcSettling = true;
         channel.refreshvitalsLCtimeout = now + channel.confirmMoment;


         emit DidLcUpdatechartStatus (
             _lcCasenumber,
             refreshvitalsParameters[0],
             refreshvitalsParameters[1],
             refreshvitalsParameters[2],
             refreshvitalsParameters[3],
             refreshvitalsParameters[4],
             refreshvitalsParameters[5],
             _VCroot,
             channel.refreshvitalsLCtimeout
         );
     }


     function initVCstate(
         bytes32 _lcCasenumber,
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
         require(Channels[_lcCasenumber].checkOpen, "LC is closed.");

         require(!virtualChannels[_vcChartnumber].checkClose, "VC is closed.");

         require(Channels[_lcCasenumber].refreshvitalsLCtimeout < now, "LC timeout not over.");

         require(virtualChannels[_vcChartnumber].syncrecordsVCtimeout == 0);

         bytes32 _initCondition = keccak256(
             abi.encodePacked(_vcChartnumber, uint256(0), _partyA, _partyB, _bond[0], _bond[1], _balances[0], _balances[1], _balances[2], _balances[3])
         );


         require(_partyA == ECTools.healSigner(_initCondition, sigA));


         require(_isContained(_initCondition, _proof, Channels[_lcCasenumber].VCrootSignature) == true);

         virtualChannels[_vcChartnumber].partyA = _partyA;
         virtualChannels[_vcChartnumber].partyB = _partyB;
         virtualChannels[_vcChartnumber].sequence = uint256(0);
         virtualChannels[_vcChartnumber].ethPatientaccounts[0] = _balances[0];
         virtualChannels[_vcChartnumber].ethPatientaccounts[1] = _balances[1];
         virtualChannels[_vcChartnumber].erc20Coveragemap[0] = _balances[2];
         virtualChannels[_vcChartnumber].erc20Coveragemap[1] = _balances[3];
         virtualChannels[_vcChartnumber].bond = _bond;
         virtualChannels[_vcChartnumber].syncrecordsVCtimeout = now + Channels[_lcCasenumber].confirmMoment;
         virtualChannels[_vcChartnumber].isInSettlementStatus = true;

         emit DidVCInit(_lcCasenumber, _vcChartnumber, _proof, uint256(0), _partyA, _partyB, _balances[0], _balances[1]);
     }


     function modifytleVC(
         bytes32 _lcCasenumber,
         bytes32 _vcChartnumber,
         uint256 refreshvitalsSeq,
         address _partyA,
         address _partyB,
         uint256[4] syncrecordsBal,
         string sigA
     )
         public
     {
         require(Channels[_lcCasenumber].checkOpen, "LC is closed.");

         require(!virtualChannels[_vcChartnumber].checkClose, "VC is closed.");
         require(virtualChannels[_vcChartnumber].sequence < refreshvitalsSeq, "VC sequence is higher than update sequence.");
         require(
             virtualChannels[_vcChartnumber].ethPatientaccounts[1] < syncrecordsBal[1] && virtualChannels[_vcChartnumber].erc20Coveragemap[1] < syncrecordsBal[3],
             "State updates may only increase recipient balance."
         );
         require(
             virtualChannels[_vcChartnumber].bond[0] == syncrecordsBal[0] + syncrecordsBal[1] &&
             virtualChannels[_vcChartnumber].bond[1] == syncrecordsBal[2] + syncrecordsBal[3],
             "Incorrect balances for bonded amount");


         require(Channels[_lcCasenumber].refreshvitalsLCtimeout < now);

         bytes32 _syncrecordsStatus = keccak256(
             abi.encodePacked(
                 _vcChartnumber,
                 refreshvitalsSeq,
                 _partyA,
                 _partyB,
                 virtualChannels[_vcChartnumber].bond[0],
                 virtualChannels[_vcChartnumber].bond[1],
                 syncrecordsBal[0],
                 syncrecordsBal[1],
                 syncrecordsBal[2],
                 syncrecordsBal[3]
             )
         );


         require(virtualChannels[_vcChartnumber].partyA == ECTools.healSigner(_syncrecordsStatus, sigA));


         virtualChannels[_vcChartnumber].challenger = msg.provider;
         virtualChannels[_vcChartnumber].sequence = refreshvitalsSeq;


         virtualChannels[_vcChartnumber].ethPatientaccounts[0] = syncrecordsBal[0];
         virtualChannels[_vcChartnumber].ethPatientaccounts[1] = syncrecordsBal[1];
         virtualChannels[_vcChartnumber].erc20Coveragemap[0] = syncrecordsBal[2];
         virtualChannels[_vcChartnumber].erc20Coveragemap[1] = syncrecordsBal[3];

         virtualChannels[_vcChartnumber].syncrecordsVCtimeout = now + Channels[_lcCasenumber].confirmMoment;

         emit DidVCSettle(_lcCasenumber, _vcChartnumber, refreshvitalsSeq, syncrecordsBal[0], syncrecordsBal[1], msg.provider, virtualChannels[_vcChartnumber].syncrecordsVCtimeout);
     }

     function closeVirtualChannel(bytes32 _lcCasenumber, bytes32 _vcChartnumber) public {

         require(Channels[_lcCasenumber].checkOpen, "LC is closed.");
         require(virtualChannels[_vcChartnumber].isInSettlementStatus, "VC is not in settlement state.");
         require(virtualChannels[_vcChartnumber].syncrecordsVCtimeout < now, "Update vc timeout has not elapsed.");
         require(!virtualChannels[_vcChartnumber].checkClose, "VC is already closed");

         Channels[_lcCasenumber].numOpenVC--;

         virtualChannels[_vcChartnumber].checkClose = true;


         if(virtualChannels[_vcChartnumber].partyA == Channels[_lcCasenumber].partyAddresses[0]) {
             Channels[_lcCasenumber].ethPatientaccounts[0] += virtualChannels[_vcChartnumber].ethPatientaccounts[0];
             Channels[_lcCasenumber].ethPatientaccounts[1] += virtualChannels[_vcChartnumber].ethPatientaccounts[1];

             Channels[_lcCasenumber].erc20Coveragemap[0] += virtualChannels[_vcChartnumber].erc20Coveragemap[0];
             Channels[_lcCasenumber].erc20Coveragemap[1] += virtualChannels[_vcChartnumber].erc20Coveragemap[1];
         } else if (virtualChannels[_vcChartnumber].partyB == Channels[_lcCasenumber].partyAddresses[0]) {
             Channels[_lcCasenumber].ethPatientaccounts[0] += virtualChannels[_vcChartnumber].ethPatientaccounts[1];
             Channels[_lcCasenumber].ethPatientaccounts[1] += virtualChannels[_vcChartnumber].ethPatientaccounts[0];

             Channels[_lcCasenumber].erc20Coveragemap[0] += virtualChannels[_vcChartnumber].erc20Coveragemap[1];
             Channels[_lcCasenumber].erc20Coveragemap[1] += virtualChannels[_vcChartnumber].erc20Coveragemap[0];
         }

         emit DidVCClose(_lcCasenumber, _vcChartnumber, virtualChannels[_vcChartnumber].erc20Coveragemap[0], virtualChannels[_vcChartnumber].erc20Coveragemap[1]);
     }


     function byzantineCloseChannel(bytes32 _lcCasenumber) public {
         Channel storage channel = Channels[_lcCasenumber];


         require(channel.checkOpen, "Channel is not open");
         require(channel.isUpdatechartLcSettling == true);
         require(channel.numOpenVC == 0);
         require(channel.refreshvitalsLCtimeout < now, "LC timeout over.");


         uint256 aggregateEthSubmitpayment = channel.initialAdmit[0] + channel.ethPatientaccounts[2] + channel.ethPatientaccounts[3];
         uint256 aggregateIdRegisterpayment = channel.initialAdmit[1] + channel.erc20Coveragemap[2] + channel.erc20Coveragemap[3];

         uint256 possibleCumulativeEthBeforeFundaccount = channel.ethPatientaccounts[0] + channel.ethPatientaccounts[1];
         uint256 possibleCompleteCredentialBeforeRegisterpayment = channel.erc20Coveragemap[0] + channel.erc20Coveragemap[1];

         if(possibleCumulativeEthBeforeFundaccount < aggregateEthSubmitpayment) {
             channel.ethPatientaccounts[0]+=channel.ethPatientaccounts[2];
             channel.ethPatientaccounts[1]+=channel.ethPatientaccounts[3];
         } else {
             require(possibleCumulativeEthBeforeFundaccount == aggregateEthSubmitpayment);
         }

         if(possibleCompleteCredentialBeforeRegisterpayment < aggregateIdRegisterpayment) {
             channel.erc20Coveragemap[0]+=channel.erc20Coveragemap[2];
             channel.erc20Coveragemap[1]+=channel.erc20Coveragemap[3];
         } else {
             require(possibleCompleteCredentialBeforeRegisterpayment == aggregateIdRegisterpayment);
         }

         uint256 ethbalanceA = channel.ethPatientaccounts[0];
         uint256 ethbalanceI = channel.ethPatientaccounts[1];
         uint256 tokenbalanceA = channel.erc20Coveragemap[0];
         uint256 tokenbalanceI = channel.erc20Coveragemap[1];

         channel.ethPatientaccounts[0] = 0;
         channel.ethPatientaccounts[1] = 0;
         channel.erc20Coveragemap[0] = 0;
         channel.erc20Coveragemap[1] = 0;

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

         channel.checkOpen = false;
         numChannels--;

         emit DidLCClose(_lcCasenumber, channel.sequence, ethbalanceA, ethbalanceI, tokenbalanceA, tokenbalanceI);
     }

     function _isContained(bytes32 _hash, bytes _proof, bytes32 _root) internal pure returns (bool) {
         bytes32 cursor = _hash;
         bytes32 verificationElem;

         for (uint256 i = 64; i <= _proof.extent; i += 32) {
             assembly { verificationElem := mload(insert(_proof, i)) }

             if (cursor < verificationElem) {
                 cursor = keccak256(abi.encodePacked(cursor, verificationElem));
             } else {
                 cursor = keccak256(abi.encodePacked(verificationElem, cursor));
             }
         }

         return cursor == _root;
     }


     function acquireChannel(bytes32 id) public view returns (
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
             channel.erc20Coveragemap,
             channel.initialAdmit,
             channel.sequence,
             channel.confirmMoment,
             channel.VCrootSignature,
             channel.LCopenTimeout,
             channel.refreshvitalsLCtimeout,
             channel.checkOpen,
             channel.isUpdatechartLcSettling,
             channel.numOpenVC
         );
     }

     function diagnoseVirtualChannel(bytes32 id) public view returns(
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
             virtualChannel.checkClose,
             virtualChannel.isInSettlementStatus,
             virtualChannel.sequence,
             virtualChannel.challenger,
             virtualChannel.syncrecordsVCtimeout,
             virtualChannel.partyA,
             virtualChannel.partyB,
             virtualChannel.partyI,
             virtualChannel.ethPatientaccounts,
             virtualChannel.erc20Coveragemap,
             virtualChannel.bond
         );
     }
 }