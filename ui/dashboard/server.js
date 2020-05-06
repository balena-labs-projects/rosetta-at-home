const express = require("express");
const axios = require("axios");
const app = express();
const bodyParser = require("body-parser");
const port = 80;
const SdkInstanceFactory = require("balena-sdk");
const fs = require("fs");
const ROSETTA_XML_PATH =
	"/usr/app/stats/sched_request_boinc.bakerlab.org_rosetta.xml";
let sdk;
let hostId;

// Enable HTML template middleware
app.use(express.static(__dirname));
app.set("view engine", "ejs");

app.use(bodyParser.urlencoded({ extended: true }));
app.use(bodyParser.json());

// Set Account Key handler
app.post("/manage/setkey", async (req, res) => {
	const [{ id: serviceId }] = await sdk.models.service.getAllByApplication(
		Number(process.env.BALENA_APP_ID),
		{
			$select: "id",
			$filter: { service_name: "boinc-client" },
		}
	);
	const { accountKey } = req.body;
	if (!accountKey || !(accountKey && accountKey.trim())) {
		await sdk.models.device.serviceVar.remove(
			process.env.BALENA_DEVICE_UUID,
			serviceId,
			"ACCOUNT_KEY"
		);
	} else {
		await sdk.models.device.serviceVar.set(
			process.env.BALENA_DEVICE_UUID,
			serviceId,
			"ACCOUNT_KEY",
			req.body.accountKey
		);
	}
	res.sendStatus(200);
});

// Shutdown handler
app.post("/manage/shutdown", async (req, res) => {
	res.sendStatus(200);
	await axios.post(
		`${process.env.BALENA_SUPERVISOR_ADDRESS}/v1/shutdown?apikey=${process.env.BALENA_SUPERVISOR_API_KEY}`,
		{}
	);
});

// Reboot handler
app.post("/manage/reboot", async (req, res) => {
	res.sendStatus(200);
	await axios.post(
		`${process.env.BALENA_SUPERVISOR_ADDRESS}/v1/reboot?apikey=${process.env.BALENA_SUPERVISOR_API_KEY}`,
		{}
	);
});

app.get("/", async (req, res) => {
	let accountKey = "";
	try {
		const [{ id: serviceId }] = await sdk.models.service.getAllByApplication(
			Number(process.env.BALENA_APP_ID),
			{
				$select: "id",
				$filter: { service_name: "boinc-client" },
			}
		);
		accountKey = await sdk.models.device.serviceVar.get(
			process.env.BALENA_DEVICE_UUID,
			serviceId,
			"ACCOUNT_KEY"
		);
	} catch (error) {
		console.log("error", error);
	}

	try {
		const data = fs.readFileSync(ROSETTA_XML_PATH, "utf8");
		hostId = data.split("\n")[2].match("<hostid>(.*)</hostid>")[1];
	} catch (err) {
		console.error("Could not read xml file", err);
	}

	res.render("index.ejs", {
		deviceName: process.env.BALENA_DEVICE_NAME_AT_INIT || "balena",
		hostId: hostId,
		accountKey: accountKey,
	});
});

app.listen(port, () => {
	sdk = SdkInstanceFactory();
	sdk.auth.logout();
	sdk.auth.loginWithToken(process.env.BALENA_API_KEY);
});
