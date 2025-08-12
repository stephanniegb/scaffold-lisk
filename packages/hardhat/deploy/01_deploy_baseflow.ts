import { HardhatRuntimeEnvironment } from "hardhat/types";
import { DeployFunction } from "hardhat-deploy/types";

const USDC_ADDRESS = "0x036CbD53842c5426634e7929541eC2318f3dCF7e";

const deployBaseFlow: DeployFunction = async function (hre: HardhatRuntimeEnvironment) {
  const { deployer } = await hre.getNamedAccounts();
  const { deploy, log } = hre.deployments;

  log("----------------------------------------------------");
  log("Deploying BaseFlowImplementation and waiting for confirmations...");

  await deploy("BaseFlowImplementation", {
    from: deployer,
    args: [USDC_ADDRESS],
    log: true,
    autoMine: true,
  });

  log("----------------------------------------------------");
  log("BaseFlow deployed successfully");
  log("----------------------------------------------------");
};

export default deployBaseFlow;

deployBaseFlow.tags = ["BaseFlow"];
