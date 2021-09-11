var express = require("express");
var router = express.Router();
var bodyParser = require("body-parser");

router.use(bodyParser.urlencoded({ extended: true }));
router.use(bodyParser.json());

const txSubmit = require("./invoke");
const txFetch = require("./query");

//var TFBC = require("./FabricHelper");

// Request LC
router.post("/requestLC", async function(req, res) {
  try {
    let result = await txSubmit.invoke("requestLC", JSON.stringify(req.body));
    res.send(result);
  } catch (err) {
    res.status(500).send(err);
  }
});

// Issue LC
router.post("/issueLC", async function(req, res) {
  try {
    let result = await txSubmit.invoke("issueLC", JSON.stringify(req.body));
    res.send(result);
  } catch (err) {
    res.status(500).send(err);
  }
});

// Accept LC
router.post("/acceptLC", async function(req, res) {
  try {
    let result = await txSubmit.invoke("acceptLC", JSON.stringify(req.body));
    res.send(result);
  } catch (err) {
    res.status(500).send(err);
  }
});

// Get LC
router.post("/getLC", async function(req, res) {
  //TFBC.getLC(req, res); req.body.lcId
  try {
    let result = await txFetch.query("getLC", req.body.lcId);
    res.send(JSON.parse(result));
  } catch (err) {
    res.status(500).send(err);
  }
});

// Get LC history
router.post("/getLCHistory", async function(req, res) {
  try {
    let result = await txFetch.query("getLCHistory", req.body.lcId);
    res.send(JSON.parse(result));
  } catch (err) {
    res.status(500).send(err);
  }
});

module.exports = router;
