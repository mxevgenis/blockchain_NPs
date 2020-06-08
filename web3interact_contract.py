import  json
from web3 import Web3
from web3.middleware import geth_poa_middleware

#ganache_url = "http://127.0.0.1:7545"

vbox_url= "http://192.168.1.41:22000"

#web3 = Web3(Web3.HTTPProvider(ganache_url))

web3 = Web3(Web3.HTTPProvider(vbox_url))

web3.middleware_onion.inject(geth_poa_middleware, layer=0)



###### Use the JSON file to retrieve abi and address ######
with open('data.json') as data_json:
    data = json.loads(data_json.read())
    abi = data['abi']
    address = data['contract_address']
#    print(address)


web3.eth.defaultAccount = web3.eth.accounts[0]

contract = web3.eth.contract(address=address, abi=abi)

generateProv = input('Generate account for providers (Y/N): ')


if generateProv == 'Y':
    numProv = int(input('Enter number of providers: '))
    for i in range(numProv):
        web3.parity.personal.unlock_account(web3.eth.defaultAccount, "", 3600)
        web3.parity.personal.new_account("")
        web3.eth.sendTransaction({'from':web3.eth.defaultAccount, 'to':web3.eth.accounts[i], 'value': web3.toWei(100, "ether")})
print(web3.eth.accounts)



addProv = input('Add new NP (Y/N): ')

if addProv == 'Y':
    for i in range(numProv):
        #print(i)
        name = input('Enter Providers Name: ')
        offered_res = int(input('Enter offered resources: '))
        reserved_res = int(input('Enter reserved resources: '))
        cost = int(input('Enter resources cost: '))
        region = input('Enter Region: ')
        sla = int(input('Enter SLA number: '))
        addressNP = web3.eth.accounts[i+1]
        tx_hash = contract.functions.addNetworkProvider(name, offered_res, reserved_res, cost, region, sla, addressNP).transact()
        web3.eth.waitForTransactionReceipt(tx_hash)


count = int(format(contract.functions.np_count().call()))
#print(count)

NetworkProviderName =list()
NetworkProviderAddresses =list()
NPinfos = list()

for i in range(1,count):
    NPaddress = format(contract.functions.NetProvtoOwner(i).call())
    NPinformation = format(contract.functions.NetworkProviders(i).call())
    NPinfos.append(contract.functions.NetworkProviders(i).call())
    NPname = contract.functions.NetworkProviders(i).call()
    NetworkProviderName.append(NPname[0])
    NetworkProviderAddresses.append(NPaddress)

    #print('Updated NPs : ', NPaddress)
    #print('Network Provider Info : ', NPinformation)
    #print('Network Provider: ', NPname[0])

#print('List of Names', NetworkProviderName)
#print('List of Addresses', NetworkProviderAddresses)
print('Infos as list',NPinfos)
ProviderToAddress = dict( zip(NetworkProviderName,NetworkProviderAddresses ))
print(ProviderToAddress)


#request_res = format(contract.functions.get_request_resources(2).call())
#print('Borrow : ',request_res)


#BestMatch = format(contract.functions.getBestMatch(5).call())

demand_resources = int(input('Enter number of resources needed: '))

BestMatch = contract.functions.getBestMatch(demand_resources).call()




results= BestMatch[1]
#print(results)
_result = results[0]
id = _result -1
print('Result',_result)
if id >0:
    name= NetworkProviderName[id]
    address = NetworkProviderAddresses[id]
    NPinfo = NPinfos[id]
    cost = NPinfo[3]
    print(name, address, cost)
    final_cost = cost * demand_resources
    print(final_cost)


make_transaction=input('Proceed to transaction (Y/N): ')

if make_transaction== 'Y' and id >0:
    prov_req= input('Enter the name of the provider that request resources: ')
    web3.eth.defaultAccount = ProviderToAddress[prov_req]
    # HasNetProv = format(contract.functions.HasNetProv(web3.eth.defaultAccount).call())

    print(web3.eth.defaultAccount)
    destination_address = ProviderToAddress[name]
    print(destination_address)
    if web3.eth.defaultAccount != destination_address:
        web3.parity.personal.unlock_account(web3.eth.defaultAccount,"", 3600)
        tx_hash = contract.functions.transaction(_result, demand_resources).transact({'from':web3.eth.defaultAccount,'value': web3.toWei(final_cost, 'ether')})
        web3.eth.waitForTransactionReceipt(tx_hash)
    print('Infos as list',NPinfos)