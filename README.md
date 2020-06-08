# blockchain_NPs
Code for using blockchain for the collaboration of Network Providers in next generation networks. 
This code is applyied in a quorum blockchain network and uses the web3 py library.


The code contained in this project uses the web3 py library for interacting with a Quorum blockchain network.
The deploy script connect to the blockchain network and deploys the smart contract defined by the ABI and the Bytecode.
When the SC is deployed its address is stored in a json file which is later used for calling the SC's functions.
The interact contract is used for creating accounts for the Network Providers and fund them with 100 ether.
A NP is characterized by:
a) name,
b) offered resources,
c) reserved resources,
d) cost,
e) domain,
f)sla

In order to conduct our experiments we select an NP who wants extra resources and we search among the NPs in order to select the valid candidate from which the NP should borrow resources.
The solution is bases on which NP can fulfil the requirements in matters of resources and the cost.
The cheaper provider with the required resources wins.
