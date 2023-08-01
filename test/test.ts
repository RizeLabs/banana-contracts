import { expect } from "chai";
import { ethers } from "hardhat";

import { EntryPoint__factory } from "@account-abstraction/contracts";
import UserOperation from "./utils/userOperation";

const getKeccakHash = (key: string) => {
    const hash = ethers.utils.keccak256(ethers.utils.toUtf8Bytes(key));
    return hash;
 }

describe("BananaAccount tests", function () {
        
   let accounts: any;
   let owner: any;
   let entryPointFactory: any;
   let entryPoint: any;
   let singleton: any;
   let accountProxyFactory: any;


    before(async () => {

        accounts = await ethers.getSigners();
        owner = await accounts[0];
        entryPointFactory = await (await ethers.getContractFactory("EntryPoint")).deploy(); 
        entryPoint = await EntryPoint__factory.connect(entryPointFactory.address, accounts[0]);
        console.log("entryPoint address: ", entryPoint.address);

        const singletonFactory = await ethers.getContractFactory("BananaAccount");
        singleton = await singletonFactory.deploy();
        console.log("singleton address: ", singleton.address);
        
        const accountProxyFactoryF = await ethers.getContractFactory("BananaAccountProxyFactory");
        accountProxyFactory = await accountProxyFactoryF.deploy();
        console.log("accountProxyFactory address: ", accountProxyFactory.address);
 
    });

    describe("Set: take native tokens out of Smart Account", function () {
        
        it("success if enough tokens and owner call", async () => {

            const TouchIdSafeWalletContractQValuesArray: Array<string> = ["0x6ee246f17bc61a711f23629960353320cf7dc3d8c53c719efacd0b212ad63e67", "0x8a9bf5c1af217f5e0aa4e3bd671429bb0ff855c3932c4ca02962b035f31cfcbd"];
            //@ts-ignore
            const TouchIdSafeWalletContractInitializer = singleton.interface.encodeFunctionData('setupWithEntrypoint',
                [
                ["0x5FbDB2315678afecb367f032d93F642f64180aa3"], // owners 
                1,                                              // thresold will remain fix 
                "0x0000000000000000000000000000000000000000",   // to address 
                "0x",                                           // modules setup calldata
                "0xac1c08a5a59cEA20518f7201bB0dda29d9454eb0",          // fallback handler
                "0x0000000000000000000000000000000000000000",   // payment token
                0,                                              // payment 
                "0x0000000000000000000000000000000000000000",   // payment receiver
                entryPoint.address,                // entrypoint
                getKeccakHash("abcd"),
                // @ts-ignore
                TouchIdSafeWalletContractQValuesArray,          // q values 
                ]);
            console.log("TouchIdSafeWalletContractInitializer: ", TouchIdSafeWalletContractInitializer);
            const add = await accountProxyFactory.getAddress(singleton.address, "0", TouchIdSafeWalletContractInitializer);
            await accountProxyFactory.createProxyWithNonce(singleton.address, TouchIdSafeWalletContractInitializer, "0");
            console.log("add: ", add);
            const abicoder =  new ethers.utils.AbiCoder();
            const finalSignature = "0x31ee1ddaff95e0ced0930c66a7681f6c6ac7b1f1ad0e59bbef9952c42a15c096eae5225b2ebde52b6a3bbca09e05966be089217449f0d1928c098e9028969e9eb5f1ee8ce934d9b012ec517f939e10903cc26cf626a0f535577a0c80fcb52a16";
            
            const scw = await ethers.getContractAt("BananaAccount", add);

            const op: UserOperation = {
                "sender": add,
                "nonce": "0",
                "initCode": "0x",
                "callData": "0x2694bd1d0000000000000000000000008b220bc9529c0bc18265c1b822fcc579ee586ba2000000000000000000000000000000000000000000000000000000e8d4a510000000000000000000000000000000000000000000000000000000000000000080000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000043a4b66f100000000000000000000000000000000000000000000000000000000",
                "callGasLimit": ethers.BigNumber.from("0x055555"),
                "verificationGasLimit": "1500000",
                "maxFeePerGas": ethers.BigNumber.from("0x42b0dd51fe"),
                "maxPriorityFeePerGas": ethers.BigNumber.from("0x59682f00"),
                "paymasterAndData": "0x",
                "preVerificationGas": ethers.BigNumber.from("0xd38c"),
                "signature": abicoder.encode(
                    ["uint", "uint","bytes", "string", "string", "bytes32"],
                    [
                      ethers.BigNumber.from(finalSignature.slice(0,66)),
                      ethers.BigNumber.from("0x"+finalSignature.slice(66,130)),
                      "0x49960de5880e8c687434170f6476605b8fe4aeb9a28632c7995cf3ba831d97630500000000",
                      '{"type":"webauthn.get","challenge":"',
                      '","origin":"http://localhost:3000","crossOrigin":false,"other_keys_can_be_added_here":"do not compare clientDataJSON against a template. See https://goo.gl/yabPex"}',
                      getKeccakHash("abcd")

                    ]
                  ),
                // "signature": "0x792d699f26620a150e19d027c702afd8b1eca09b26585a93a264ff5f319b6ce8c2b387cd7ca009ffaa47a1cacb0e94eea5e74b5bee008f678b0d22494b3ecb427a2c44bc6e9ef9850b7b2869808a60bd67f8790b6c9c68a159eda25c38802cd2a7849fdfaf29521832f841580a407b6284f3b5c1e9f4528c767aae7ed2e5d894"
                // "48bed44d1bcd124a28c27f343a817e5f5243190d3c52bf347daf876de1dbbf77"
            }

            console.log("balance of owner: ", await ethers.provider.getBalance(owner.address))
      
            console.log("entryPointFactory: ", entryPoint.address)
            
            const txn = await owner.sendTransaction(
                {
                    to: entryPointFactory.address, 
                    value: ethers.utils.parseEther("1")
                });
            await txn.wait();
            console.log("balance of ep: ", await ethers.provider.getBalance(entryPoint.address))
            console.log("here0")
            console.log("balance of scw: ", await ethers.provider.getBalance(add))
            

            await owner.sendTransaction({to: add, value: ethers.utils.parseEther("1")});
            console.log("balance of scw: ", await ethers.provider.getBalance(add))

            console.log("here1")
            // console.log("UserOperation: ", op)
            console.log("address: ", add)
            // console.log("entrypoint: ", entryPoint)
            await entryPoint.handleOps( [op], add);


            // console.log("deposit of scw: ", await scw.getDeposit())
            // const use

        });

    });

    
});

