import web3 from "./web3";
import CampaignFactory from "./build/CampaignFactory.json";

const instance = new web3.eth.Contract(
	JSON.parse(CampaignFactory.interface),
	"0xFC15EAcc545553c1f916998D1eFC749C2875cA40"
);

export default instance;
