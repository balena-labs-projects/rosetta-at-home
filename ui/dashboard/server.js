const express = require("express");
const axios = require("axios");
const app = express();
const bodyParser = require("body-parser");
const port = 80;
const SdkInstanceFactory = require("balena-sdk");
let sdk;

// Enable HTML template middleware
app.use(express.static(__dirname));
app.set("view engine", "ejs");

app.use(bodyParser.urlencoded({ extended: true }));

// Set Account Key handler
app.post("/manage/setkey", async (req, res) => {
  const [{ id: serviceId }] = await sdk.models.service.getAllByApplication(
    Number(process.env.BALENA_APP_ID),
    {
      $select: "id",
      $filter: { service_name: "boinc-client" },
    }
  );
  await sdk.models.device.serviceVar.set(
    process.env.BALENA_DEVICE_UUID,
    serviceId,
    "ACCOUNT_KEY",
    req.body.accountKey
  );
  res.redirect("/");
});

// Shutdown handler
app.post("/manage/shutdown", async (req, res) => {
  res.redirect("/");
  await axios.post(
    `${process.env.BALENA_SUPERVISOR_ADDRESS}/v1/shutdown?apikey=${process.env.BALENA_SUPERVISOR_API_KEY}`,
    {}
  );
});

// Reboot handler
app.post("/manage/reboot", async (req, res) => {
  res.redirect("/");
  await axios.post(
    `${process.env.BALENA_SUPERVISOR_ADDRESS}/v1/reboot?apikey=${process.env.BALENA_SUPERVISOR_API_KEY}`,
    {}
  );
});

app.get("/", (req, res) =>
  res.render("index.ejs", {
    deviceName: process.env.BALENA_DEVICE_NAME_AT_INIT || "balena",
  })
);

app.listen(port, () => {
  sdk = SdkInstanceFactory();
  sdk.auth.logout();
  sdk.auth.loginWithToken(process.env.BALENA_API_KEY);
  console.log(`Dashboard app listening at http://localhost:${port}`);
});
