pragma solidity ^0.4.17;

//Contract campaign factory does two things:
//1. Deploys instances of campaigns 
//2. Retrieves a list of all different instances it has deployed
contract CampaignFactory {
    address[] public deployedCampaigns;

    function createCampaign(uint minimum) public {
        address newCampaign = new Campaign(minimum, msg.sender);
        deployedCampaigns.push(newCampaign);
    }

    function getDeployedCampaigns() public view returns (address[]) {   //pubic:anyone can call this function,view:no data in the contract is modified by this function
        return deployedCampaigns;                                       //returns address : Function returns an array of type address 
    }
}

contract Campaign {
    /*Spending Request created by manager when that he wants to transfer some money to 
    the vendor,then contributors would have voting system ,if majority approves then 
    only the money can be send to the vendor*/

    struct Request {
      
        string description;  //Describes why the request has been created
        uint value;          //Amount of money that the manager wants to send to the vendor
        address recipient;   //Address the money will be sent to
        bool complete;      //True if the request has already been processed
        
        //Voting Mechanism

        uint approvalCount;  //Count of people who vote 'YES'
        mapping(address => bool) approvals;  //Addresses of contributors and their vote 'YES' or 'NO'
    }

    Request[] public requests;  //Array of type Request(struct)
    address public manager;
    uint public minimumContribution;
    mapping(address => bool) public approvers;
    uint public approversCount;

    modifier restricted() {
        require(msg.sender == manager);
        _;
    }

    function Campaign(uint minimum,address creator) public {
        manager = creator;
        minimumContribution = minimum;
    }

    function contribute() public payable {
        require(msg.value > minimumContribution); //Amount in Wei 

        approvers[msg.sender] = true;
        approversCount++;
    }
     

     //This function can only be called by the manager as modifier restricted has been added
    function createRequest(string description, uint value, address recipient) public restricted {
       //Parameters description,value,recipient are of type memory
       //Whereas normally variables are of type storage
       //Just fact- Memory uses less gas than storage
        Request memory newRequest = Request({
           description: description,
           value: value,
           recipient: recipient,
           complete: false,
           approvalCount: 0
           //Map is a reference type whereas all other data types defined 
           //in the structure are value type and there is no need
           //to initialise the reference type
        });

        requests.push(newRequest);
    }
     
    function approveRequest(uint index) public {      // index is address of the request we are trying to approve
        Request storage request = requests[index];        //storage is used instead of memory because we want to manipulate the data ,not make a copy in the memory of it

        require(approvers[msg.sender]);         //Check if Person is donator
        require(!request.approvals[msg.sender]); //Check if person hasn't voted yet

        request.approvals[msg.sender] = true;
        request.approvalCount++;
    }

    function finalizeRequest(uint index) public restricted {
        Request storage request = requests[index];  //Using storage keyword will make us able to make changes in requests[index]

        require(request.approvalCount > (approversCount / 2));
        require(!request.complete);

        request.recipient.transfer(request.value);
        request.complete = true;
    }
}