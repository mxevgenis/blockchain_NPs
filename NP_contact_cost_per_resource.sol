pragma solidity >=0.4.22 <0.7.0;


contract NPcontract {
// An array is created where information regarding the NPs will be stored///////
    NetworkProvider[] public NetworkProviders;

// Ether var
    uint value = 1 ether;

// The counter is used in order to find easier the number of participants///////
    uint256 public np_count = 0;
// When an Network Provider is accepted and want to join the network, the NP gets an address that gives him the ability to add a Network Provider. The NP can execute the  addNetworkProvider function to add himself
     address  admin;
//The modifier is used for perfoming the afore mentioned action
    // modifier onlyParticipant(){
    //     require(msg.sender == accepted_participant);
    //     _;
    // }
// The model of the Network Provider is created, that defines the information regarding the NP, which is contained in the array
    struct NetworkProvider{
        string name;                    // The name of the NP
        uint offered_resources;         // The amount of resources the NP offers to the network
        uint reserved_resources;        // The amount of resources the NP has for his own needs
        uint cost;                      // The cost of resources
        string domain;                  // The domain where these resources can be deployed
        uint sla;                       // A number that corresponds to certain SLA profiles

    }

    // mapping (address => NetworkProvider) public NPs;

    mapping (uint => address payable) public NetProvtoOwner;

    mapping (address => uint) OwnertoNetProv;

    mapping (address => bool) public HasNetProv;

//The constructor is used for perfoming the afore mentioned action regarding the ownership of the addNetworkProvider function
    constructor() public {
    admin =msg.sender;
    addNetworkProvider("",0,0,1000000000000000000000000000000000000000000000000000000000000000,"",0,0x55f8AFc0681fd701E2f43D145f71f3594b95eD5B);
    //addNetworkProvider("OTE",10,8,7,"Athens",6,0x14723A09ACff6D2A60DcdF7aA4AFf308FDDC160C);
    //addNetworkProvider("Vodafone",10,5,5,"Athens",5,0x4B0897b0513fdC7C541B6d9D7E929C4e5364D2dB);
    }

    modifier onlyAdmin(address _address) {
        require (_address== admin);
        _;

    }


    //This functions add Network Provider to the array, with the predifined information
    function addNetworkProvider(string memory name, uint  offered_resources, uint reserved_resources, uint  cost, string memory domain, uint  sla, address payable _address) public onlyAdmin(msg.sender) {
    uint   id= NetworkProviders.push(NetworkProvider(name,offered_resources,reserved_resources,cost,domain,sla)) - 1 ;
        NetProvtoOwner[id] =_address;
        OwnertoNetProv[_address] = id;
        HasNetProv[_address] = true;
        np_count +=1;
    }






// The following contract checks if there is a need for performing a request for resources



// The output is boolean. True is request for resources should be made and false if not.
    // function get_request_resources(uint demand_resources, uint i) public view returns (bool) {
    //     if (NetworkProviders[i].reserved_resources > demand_resources) {
    //         return  false;
    //     }else {
    //         return  true;
    //     }
    // }
// The output is boolean. True is request for resources should be made and false if not.
    function get_request_resources(uint demand_resources) public view returns (bool) {
        if (NetworkProviders[OwnertoNetProv[msg.sender]].reserved_resources > demand_resources) {
            return  false;
        }else {
            return  true;
        }
    }


//This function returns the best match when there is  demand of resources. This function checks every NP that meets the demands and selects the one (or many) with the minimum cost. ////

    function getBestMatch(uint demand_resources) external view returns(uint[] memory,uint[] memory, uint, address) {
    uint counter = 0;     //set first counter
    uint counter2 = 0;    // set second counter

    uint[] memory result = new uint[](np_count);   //create an array (used in storing resources result) in memory that is not stored in the blockchain. The array is empty it is a uint type and the length is taken by previous contract and is equal to the number of NPs stored.
    uint[] memory newresult = new uint[](np_count); //create an array (used in storing cost result) in memory that is not stored in the blockchain. The array is empty it is a uint type and the length is taken by previous contract and is equal to the number of NPs stored.
// This loop is executed until we reach the number that denotes the length of NetworkProviders array.
// If the field of offered resources of each Network Provider is larger or equal to the given demand_resources the it stores the id of this element in the result array and increases the counter by 1.
    for (uint i = 0; i < NetworkProviders.length; i++) {
      if (NetworkProviders[i].offered_resources >= demand_resources) {

        result[counter] = i;
        counter++;

      }
    }
// This loop is executed until we reach the number that denotes the length of results array, constructed previously. Also we set a new empty uint leastPrice used as a value inside the if.
// The if compares the field cost of each element of the Network Providers array with the leastPrice and if the values is smaller or equal to leastPrice or the leastPrice is 0, then the leastPrice is ste to the value included in the cost field of the specified Network Provider.
    uint leastPrice;
    for (uint j = 0; j < result.length; j++) {
// The output of this if is the minimum value stored in leastPrice
      if (NetworkProviders[result[j]].cost <= leastPrice || leastPrice == 0) {


        leastPrice = NetworkProviders[result[j]].cost;
      }
    }
// This loop is executed until we reach the number that denotes the length of results array, constructed previously.
// The if compares the field cost of each element of the Network Providers array with the leastPrice computed previously and if it is identical it stores the id of this network provider to the newresult array and then increments the counter.
    for (uint k = 0; k < result.length; k++) {
        if (NetworkProviders[result[k]].cost == leastPrice){
            newresult[counter2] = result[k];
            counter2++;
        }
    }
    return (result,newresult, leastPrice, msg.sender);
  }
  function transaction(uint _result, uint _demand_resources) external  payable {
   require(HasNetProv[msg.sender]== true);
   require (NetworkProviders[_result].offered_resources >= _demand_resources);
   //uint payFee = NetworkProviders[_result].cost ether;
   require(msg.value == NetworkProviders[_result].cost * value * _demand_resources);
   NetworkProvider  storage NPRequest = NetworkProviders[OwnertoNetProv[msg.sender]];
   NetworkProvider  storage NPReply = NetworkProviders[_result];
   NPRequest.reserved_resources = NPRequest.reserved_resources + _demand_resources;
   NPReply.offered_resources = NPReply.offered_resources - _demand_resources;
   withdraw(NetProvtoOwner[_result]);
   //emit transaction_event//



    }


    function withdraw(address payable _address_rec) internal returns(bool) {

    //uint payFee = 0.001 ether;
    _address_rec.transfer(address(this).balance);
    return true;
  }




}
