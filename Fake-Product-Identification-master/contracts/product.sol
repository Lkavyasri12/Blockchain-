pragma solidity ^0.8.12;

contract product {

    uint256 sellerCount; //Number of sellers
    uint256 productCount; //Number of products

    struct seller{  //Structure to hold seller information
        uint256 sellerId; 
        bytes32 sellerName;
        bytes32 sellerBrand;
        bytes32 sellerCode;
        uint256 sellerNum;
        bytes32 sellerManager;
        bytes32 sellerAddress;
    }
    mapping(uint=>seller) public sellers;  //Mapping to store sellers using their IDs

    struct productItem{  //Structure to hold product information
        uint256 productId;
        bytes32 productSN;
        bytes32 productName;
        bytes32 productBrand;
        uint256 productPrice;
        bytes32 productStatus;
    }

    mapping(uint256=>productItem) public productItems; //Mapping to store products using their IDs
    mapping(bytes32=>uint256) public productMap; //Mapping to map product serial numbers to product IDs
    mapping(bytes32=>bytes32) public productsManufactured; //Mapping to track products manufactured by their serial numbers
    mapping(bytes32=>bytes32) public productsForSale; //Mapping to track products available for sale by their serial numbers
    mapping(bytes32=>bytes32) public productsSold;  // Mapping to track products sold to consumers by their serial numbers
    mapping(bytes32=>bytes32[]) public productsWithSeller; // Mapping to track products associated with sellers
    mapping(bytes32=>bytes32[]) public productsWithConsumer;  // Mapping to track products associated with consumers
    mapping(bytes32=>bytes32[]) public sellersWithManufacturer; // Mapping to track sellers associated with manufacturers


    //SELLER SECTION : Function to add a new seller
    function addSeller(bytes32 _manufacturerId, bytes32 _sellerName, bytes32 _sellerBrand, bytes32 _sellerCode,
    uint256 _sellerNum, bytes32 _sellerManager, bytes32 _sellerAddress) public{
        sellers[sellerCount] = seller(sellerCount, _sellerName, _sellerBrand, _sellerCode,
        _sellerNum, _sellerManager, _sellerAddress); // Add seller to the mapping
        sellerCount++; // Increment the seller count

        sellersWithManufacturer[_manufacturerId].push(_sellerCode);  // Add seller code to the list associated with the manufacturer
    }

// Function to view all sellers
    function viewSellers () public view returns(uint256[] memory, bytes32[] memory, bytes32[] memory, bytes32[] memory, uint256[] memory, bytes32[] memory, bytes32[] memory) {
        uint256[] memory ids = new uint256[](sellerCount); // Array to store seller IDs
        bytes32[] memory snames = new bytes32[](sellerCount); // Array to store seller names
        bytes32[] memory sbrands = new bytes32[](sellerCount); // Array to store seller brands
        bytes32[] memory scodes = new bytes32[](sellerCount); // Array to store seller codes
        uint256[] memory snums = new uint256[](sellerCount); // Array to store seller contact numbers
        bytes32[] memory smanagers = new bytes32[](sellerCount); // Array to store seller managers
        bytes32[] memory saddress = new bytes32[](sellerCount);  // Array to store seller addresses
        
        for(uint i=0; i<sellerCount; i++){
            ids[i] = sellers[i].sellerId;
            snames[i] = sellers[i].sellerName;
            sbrands[i] = sellers[i].sellerBrand;
            scodes[i] = sellers[i].sellerCode;
            snums[i] = sellers[i].sellerNum;
            smanagers[i] = sellers[i].sellerManager;
            saddress[i] = sellers[i].sellerAddress;
        }
        return(ids, snames, sbrands, scodes, snums, smanagers, saddress);  // Return arrays containing seller information
    }

    //PRODUCT SECTION :  // Function to add a new product

    function addProduct(bytes32 _manufactuerID, bytes32 _productName, bytes32 _productSN, bytes32 _productBrand,
    uint256 _productPrice) public{
        productItems[productCount] = productItem(productCount, _productSN, _productName, _productBrand,
        _productPrice, "Available");  // Add product to the mapping
        productMap[_productSN] = productCount; // Map product serial number to product ID
        productCount++; // Increment the product count
        productsManufactured[_productSN] = _manufactuerID;  // Map product to the manufacturer
    }

 // Function to view all products
    function viewProductItems () public view returns(uint256[] memory, bytes32[] memory, bytes32[] memory, bytes32[] memory, uint256[] memory, bytes32[] memory) {
        uint256[] memory pids = new uint256[](productCount); // Array to store product IDs
        bytes32[] memory pSNs = new bytes32[](productCount); // Array to store product serial numbers
        bytes32[] memory pnames = new bytes32[](productCount); // Array to store product names
        bytes32[] memory pbrands = new bytes32[](productCount); // Array to store product brands
        uint256[] memory pprices = new uint256[](productCount); // Array to store product prices
        bytes32[] memory pstatus = new bytes32[](productCount); // Array to store product statuses
        
        for(uint i=0; i<productCount; i++){
            pids[i] = productItems[i].productId;
            pSNs[i] = productItems[i].productSN;
            pnames[i] = productItems[i].productName;
            pbrands[i] = productItems[i].productBrand;
            pprices[i] = productItems[i].productPrice;
            pstatus[i] = productItems[i].productStatus;
        }
        return(pids, pSNs, pnames, pbrands, pprices, pstatus); // Return arrays containing product information
    }

    //SELL Product :  Function for a manufacturer to sell a product

    function manufacturerSellProduct(bytes32 _productSN, bytes32 _sellerCode) public{
        productsWithSeller[_sellerCode].push(_productSN); // Add product to the list associated with the seller
        productsForSale[_productSN] = _sellerCode; // Map product to the seller for sale

    }
 // Function for a seller to sell a product to a consumer
    function sellerSellProduct(bytes32 _productSN, bytes32 _consumerCode) public{   
        bytes32 pStatus;
        uint256 i;
        uint256 j=0;

        if(productCount>0) {
            for(i=0;i<productCount;i++) {
                if(productItems[i].productSN == _productSN) {
                    j=i;
                }
            }
        }

        pStatus = productItems[j].productStatus; // Get the status of the product
        if(pStatus == "Available") {
            productItems[j].productStatus = "Not Available"; // Mark the product as not available
            productsWithConsumer[_consumerCode].push(_productSN); // Add product to the list associated with the consumer
            productsSold[_productSN] = _consumerCode;  // Map product to the consumer as sold
        }
    }

 // Function to query products associated with a seller
    function queryProductsList(bytes32 _sellerCode) public view returns(uint256[] memory, bytes32[] memory, bytes32[] memory, bytes32[] memory, uint256[] memory, bytes32[] memory){
        bytes32[] memory productSNs = productsWithSeller[_sellerCode]; // Get list of products associated with the seller
        uint256 k=0;

        uint256[] memory pids = new uint256[](productCount); // Array to store product IDs
        bytes32[] memory pSNs = new bytes32[](productCount); // Array to store product serial numbers
        bytes32[] memory pnames = new bytes32[](productCount); // Array to store product names
        bytes32[] memory pbrands = new bytes32[](productCount); // Array to store product brands
        uint256[] memory pprices = new uint256[](productCount); // Array to store product prices
        bytes32[] memory pstatus = new bytes32[](productCount); // Array to store product statuses

        
        for(uint i=0; i<productCount; i++){
            for(uint j=0; j<productSNs.length; j++){
                if(productItems[i].productSN==productSNs[j]){
                    pids[k] = productItems[i].productId;
                    pSNs[k] = productItems[i].productSN;
                    pnames[k] = productItems[i].productName;
                    pbrands[k] = productItems[i].productBrand;
                    pprices[k] = productItems[i].productPrice;
                    pstatus[k] = productItems[i].productStatus;
                    k++;
                }
            }
        }
        return(pids, pSNs, pnames, pbrands, pprices, pstatus); // Return arrays containing product information associated with the seller
    }
 // Function to query sellers associated with a manufacturer
    function querySellersList (bytes32 _manufacturerCode) public view returns(uint256[] memory, bytes32[] memory, bytes32[] memory, bytes32[] memory, uint256[] memory, bytes32[] memory, bytes32[] memory) {
        bytes32[] memory sellerCodes = sellersWithManufacturer[_manufacturerCode]; // Get list of sellers associated with the manufacturer
        uint256 k=0;
        uint256[] memory ids = new uint256[](sellerCount); // Array to store seller IDs
        bytes32[] memory snames = new bytes32[](sellerCount);  // Array to store seller names
        bytes32[] memory sbrands = new bytes32[](sellerCount);  // Array to store seller brands
        bytes32[] memory scodes = new bytes32[](sellerCount); // Array to store seller codes
        uint256[] memory snums = new uint256[](sellerCount);  // Array to store seller contact numbers
        bytes32[] memory smanagers = new bytes32[](sellerCount); // Array to store seller managers
        bytes32[] memory saddress = new bytes32[](sellerCount); // Array to store seller addresses
        
        for(uint i=0; i<sellerCount; i++){
            for(uint j=0; j<sellerCodes.length; j++){
                if(sellers[i].sellerCode==sellerCodes[j]){
                    ids[k] = sellers[i].sellerId;
                    snames[k] = sellers[i].sellerName;
                    sbrands[k] = sellers[i].sellerBrand;
                    scodes[k] = sellers[i].sellerCode;
                    snums[k] = sellers[i].sellerNum;
                    smanagers[k] = sellers[i].sellerManager;
                    saddress[k] = sellers[i].sellerAddress;
                    k++;
                    break;
               }
            }
        }

        return(ids, snames, sbrands, scodes, snums, smanagers, saddress); // Return arrays containing seller information associated with the manufacturer
    }
 // Function to get purchase history of a consumer
    function getPurchaseHistory(bytes32 _consumerCode) public view returns (bytes32[] memory, bytes32[] memory, bytes32[] memory){
        bytes32[] memory productSNs = productsWithConsumer[_consumerCode]; // Get list of products associated with the consumer
        bytes32[] memory sellerCodes = new bytes32[](productSNs.length);  // Array to store seller codes
        bytes32[] memory manufacturerCodes = new bytes32[](productSNs.length);  // Array to store manufacturer codes
        for(uint i=0; i<productSNs.length; i++){
            sellerCodes[i] = productsForSale[productSNs[i]]; // Get seller code associated with each product
            manufacturerCodes[i] = productsManufactured[productSNs[i]]; // Get manufacturer code associated with each product
        }
        return (productSNs, sellerCodes, manufacturerCodes); // Return arrays containing purchase history
    }

    //Verify
 // Function to verify if a product was sold to a specific consumer

    function verifyProduct(bytes32 _productSN, bytes32 _consumerCode) public view returns(bool){
        if(productsSold[_productSN] == _consumerCode){
            return true; // Return true if product was sold to the consumer
        }
        else{
            return false;  // Return false if product was not sold to the consumer
        }
    }
}
