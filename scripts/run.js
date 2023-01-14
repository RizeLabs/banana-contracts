const ethers = require('ethers')
const ecArtifact = require('../artifacts/contracts/EllipticCurve.sol/EllipticCurve.json')

const main = async () => {
    let ethProvider = new ethers.providers.JsonRpcProvider('https://eth-goerli.g.alchemy.com/v2/V5p1PckEwUqIq5s5rA2zvwRKH0V9Hslr')
    const signer = new ethers.Wallet("326d3b8f081040e0044fde540508dde301cdae5c387d207f7ea15ceb32b9630d", ethProvider);
    let ec = new ethers.Contract("0xA52b226C604fB42701C7FFE0Db7E153Fc3430c33",  ecArtifact.abi, signer);
    console.log(ec);
    try {
    let tx = await ec.temp();
    console.log(tx);
    } catch (err) {
        console.log(err)
    }
}

main();